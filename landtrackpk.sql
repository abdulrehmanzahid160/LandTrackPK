-- ================================================================
--      LANDTRACK PK — COMPLETE DATABASE SETUP & UPGRADES
--      Based on course slides: SQL, Normalization, Transactions
-- ================================================================
-- RELATIONSHIP CARDINALITIES:
--   Citizens → Ownership:           1:M (one citizen owns many plots)
--   LandParcels → Ownership:        1:1 (one plot has one active owner)
--   Citizens → TransferRequests:    1:M (one citizen can make many requests)
--   LandParcels → Disputes:         1:M (one plot can have many disputes)
--   Citizens → CitizenPhones:       1:M (one citizen, many phone numbers)
--   TransferRequests → OwnershipHistory: 1:1 (one transfer = one history log)
-- ================================================================

USE master;
GO

-- Recreate database if it exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'LandTrackPK')
BEGIN
    ALTER DATABASE LandTrackPK SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LandTrackPK;
END
GO

CREATE DATABASE LandTrackPK;
GO

USE LandTrackPK;
GO

-- ================================================================
-- BASE TABLES CREATION
-- ================================================================

-- TABLE 1: Citizens
-- Composite Attribute: Address is decomposed into Street, City, District, PostalCode
-- Multivalued Attribute: Phone removed; see CitizenPhones table
CREATE TABLE Citizens (
    CitizenID       INT IDENTITY(1,1) PRIMARY KEY,
    CNIC            CHAR(13) NOT NULL UNIQUE,
    FullName        NVARCHAR(100) NOT NULL,
    Street          NVARCHAR(100),
    City            NVARCHAR(50),
    District        NVARCHAR(50),
    PostalCode      VARCHAR(10),
    PasswordHash    VARCHAR(255) NOT NULL,
    Role            VARCHAR(10) NOT NULL CHECK (Role IN ('Citizen', 'Officer'))
);
GO

-- TABLE 2: CitizenPhones (Multivalued Attribute)
-- One citizen can have many phone numbers (1:M)
CREATE TABLE CitizenPhones (
    PhoneID     INT IDENTITY(1,1) PRIMARY KEY,
    CitizenID   INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID) ON DELETE CASCADE,
    PhoneNumber VARCHAR(15) NOT NULL
);
GO

-- TABLE 3: LandParcels
CREATE TABLE LandParcels (
    PlotID          INT IDENTITY(1,1) PRIMARY KEY,
    PlotNumber      VARCHAR(20) NOT NULL UNIQUE,
    Area            DECIMAL(10,2) NOT NULL,
    AreaUnit        VARCHAR(10) NOT NULL CHECK (AreaUnit IN ('Marla', 'Kanal')),
    District        NVARCHAR(50) NOT NULL,
    Tehsil          NVARCHAR(50) NOT NULL,
    LandType        VARCHAR(20) NOT NULL CHECK (LandType IN ('Agricultural','Residential','Commercial')),
    RegisteredDate  DATE NOT NULL DEFAULT GETDATE()
);
GO

-- TABLE 4: Ownership (1:1 with LandParcels, 1:M with Citizens)
CREATE TABLE Ownership (
    OwnershipID     INT IDENTITY(1,1) PRIMARY KEY,
    PlotID          INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    CitizenID       INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    AcquiredDate    DATE NOT NULL DEFAULT GETDATE()
);
GO

-- TABLE 5: OwnershipHistory
CREATE TABLE OwnershipHistory (
    HistoryID           INT IDENTITY(1,1) PRIMARY KEY,
    PlotID              INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    PreviousCitizenID   INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    NewCitizenID        INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    TransferDate        DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- TABLE 6: TransferRequests
CREATE TABLE TransferRequests (
    TransferID      INT IDENTITY(1,1) PRIMARY KEY,
    PlotID          INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    FromCitizenID   INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    ToCitizenID     INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    Reason          NVARCHAR(300),
    Status          VARCHAR(10) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending','Approved','Rejected')),
    RequestDate     DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- TABLE 7: Disputes (WEAK ENTITY)
-- Disputes is a weak entity whose existence depends on LandParcels.
-- DisputeID is the discriminator (partial key).
-- Composite primary key is (PlotID, DisputeID).
-- ON DELETE CASCADE: if a LandParcel is deleted, its disputes are also deleted.
CREATE TABLE Disputes (
    DisputeID           INT IDENTITY(1,1),
    PlotID              INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    FiledByCitizenID    INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    Description         NVARCHAR(500) NOT NULL,
    Status              VARCHAR(10) NOT NULL DEFAULT 'Open' CHECK (Status IN ('Open','Resolved')),
    FiledDate           DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (PlotID, DisputeID)
);
GO

-- ================================================================
-- BASE TRIGGERS & STORED PROCEDURES
-- ================================================================

-- TRIGGER: trg_LogOwnershipChange
GO
CREATE TRIGGER trg_LogOwnershipChange
ON TransferRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Automatically log when Status changes to 'Approved'
    IF UPDATE(Status)
    BEGIN
        INSERT INTO OwnershipHistory (PlotID, PreviousCitizenID, NewCitizenID, TransferDate)
        SELECT i.PlotID, i.FromCitizenID, i.ToCitizenID, GETDATE()
        FROM Inserted i
        INNER JOIN Deleted d ON i.TransferID = d.TransferID
        WHERE i.Status = 'Approved' AND (d.Status IS NULL OR d.Status <> 'Approved');
    END
END;
GO

-- STORED PROCEDURE 1: sp_RegisterLand
GO
CREATE PROCEDURE sp_RegisterLand
    @PlotNumber VARCHAR(20),
    @Area DECIMAL(10,2),
    @AreaUnit VARCHAR(10),
    @District NVARCHAR(50),
    @Tehsil NVARCHAR(50),
    @LandType VARCHAR(20),
    @OwnerCNIC CHAR(13)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Find CitizenID from Citizens using CNIC
        DECLARE @CitizenID INT;
        SELECT @CitizenID = CitizenID FROM Citizens WHERE CNIC = @OwnerCNIC;

        IF @CitizenID IS NULL
        BEGIN
            THROW 50001, 'Citizen with the provided CNIC does not exist.', 1;
        END

        -- Insert into LandParcels
        INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType, RegisteredDate)
        VALUES (@PlotNumber, @Area, @AreaUnit, @District, @Tehsil, @LandType, GETDATE());

        DECLARE @NewPlotID INT = SCOPE_IDENTITY();

        -- Insert into Ownership
        INSERT INTO Ownership (PlotID, CitizenID, AcquiredDate)
        VALUES (@NewPlotID, @CitizenID, GETDATE());

        COMMIT TRANSACTION;
        SELECT 'Success' AS Status, 'Land registered successfully' AS Message, @NewPlotID AS PlotID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrMsg, 1;
    END CATCH
END;
GO

-- STORED PROCEDURE 2: sp_TransferOwnership
GO
CREATE PROCEDURE sp_TransferOwnership
    @TransferID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @PlotID INT, @FromCitizenID INT, @ToCitizenID INT, @Status VARCHAR(10);

        -- Get PlotID, FromCitizenID, ToCitizenID from TransferRequests
        SELECT @PlotID = PlotID, @FromCitizenID = FromCitizenID, @ToCitizenID = ToCitizenID, @Status = Status
        FROM TransferRequests
        WHERE TransferID = @TransferID;

        IF @PlotID IS NULL
        BEGIN
            THROW 50001, 'Transfer request not found.', 1;
        END

        IF @Status <> 'Pending'
        BEGIN
            THROW 50002, 'Transfer request is not pending.', 1;
        END

        -- Update Ownership
        UPDATE Ownership
        SET CitizenID = @ToCitizenID, AcquiredDate = GETDATE()
        WHERE PlotID = @PlotID;

        -- Update TransferRequests status to Approved.
        -- This will automatically trigger trg_LogOwnershipChange, inserting into OwnershipHistory.
        UPDATE TransferRequests
        SET Status = 'Approved'
        WHERE TransferID = @TransferID;

        COMMIT TRANSACTION;
        SELECT 'Success' AS Status, 'Transfer approved successfully' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50000, @ErrMsg, 1;
    END CATCH
END;
GO

-- ================================================================
-- BASE VIEWS
-- ================================================================

GO
CREATE VIEW vw_ActiveOwnership AS
SELECT PlotNumber, FullName AS OwnerName, CNIC, lp.District, Tehsil, LandType, Area, AreaUnit, AcquiredDate
FROM Ownership o
JOIN Citizens c ON o.CitizenID = c.CitizenID
JOIN LandParcels lp ON o.PlotID = lp.PlotID;
GO

CREATE VIEW vw_PendingTransfers AS
SELECT TransferID, PlotNumber, FromOwner.FullName AS FromOwner, ToOwner.FullName AS ToOwner,
       Reason, RequestDate
FROM TransferRequests tr
JOIN LandParcels lp ON tr.PlotID = lp.PlotID
JOIN Citizens AS FromOwner ON tr.FromCitizenID = FromOwner.CitizenID
JOIN Citizens AS ToOwner ON tr.ToCitizenID = ToOwner.CitizenID
WHERE tr.Status = 'Pending';
GO

-- ================================================================
-- BASE SAMPLE DATA
-- ================================================================

-- Insert Citizens
INSERT INTO Citizens (FullName, CNIC, Street, City, District, PostalCode, PasswordHash, Role)
VALUES
('Ahmed Raza',     '3520112345671', 'House 12 Street 4', 'Lahore',     'Lahore',     '54000', 'admin123', 'Officer'),
('Muhammad Tariq', '3520198765432', 'Street 7',          'Rawalpindi', 'Rawalpindi', '46000', 'admin123', 'Citizen'),
('Sara Bibi',      '3520156789012', 'Gulberg III',       'Lahore',     'Lahore',     '54660', 'admin123', 'Citizen');

-- Insert CitizenPhones
INSERT INTO CitizenPhones (CitizenID, PhoneNumber)
VALUES
(1, '03001234567'),
(1, '04237654321'),
(2, '03211234567'),
(3, '03451234567'),
(3, '03009876543');

-- Insert LandParcels
INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType)
VALUES
('LHR-2024-001', 10.00, 'Marla', 'Lahore',     'Shalimar',  'Residential'),
('RWP-2024-002',  4.00, 'Kanal', 'Rawalpindi', 'Murree',    'Agricultural'),
('FSD-2024-003',  5.00, 'Marla', 'Faisalabad', 'Sammundri', 'Commercial'),
('MUL-2024-004',  8.00, 'Marla', 'Multan',     'Shujabad',  'Residential');

-- Insert Ownership records
INSERT INTO Ownership (PlotID, CitizenID)
VALUES
(1, 2), -- LHR-2024-001 owned by Muhammad Tariq
(2, 2), -- RWP-2024-002 owned by Muhammad Tariq
(3, 3), -- FSD-2024-003 owned by Sara Bibi
(4, 3); -- MUL-2024-004 owned by Sara Bibi

-- Insert TransferRequests
INSERT INTO TransferRequests (PlotID, FromCitizenID, ToCitizenID, Reason, Status)
VALUES
(1, 2, 3, 'Selling property to Sara', 'Pending'),
(3, 3, 2, 'Gifting commercial plot to Tariq', 'Pending');

-- Insert Dispute
INSERT INTO Disputes (PlotID, FiledByCitizenID, Description, Status)
VALUES
(4, 2, 'Boundary wall overlap issue with the neighboring property.', 'Open');
GO


-- ================================================================
-- SECTION 1 — DDL (Data Definition Language)
-- ================================================================

-- 1. CREATE a new table called AuditLog:
CREATE TABLE AuditLog (
   AuditLogID   INT IDENTITY PRIMARY KEY,
   TableName    VARCHAR(50),
   Action       VARCHAR(10),  -- INSERT / UPDATE / DELETE
   RecordID     INT,
   ChangedBy    NVARCHAR(100),
   ChangeDate   DATETIME DEFAULT GETDATE(),
   OldValue     NVARCHAR(500),
   NewValue     NVARCHAR(500)
);
GO

-- 2. ALTER the Citizens table:
ALTER TABLE Citizens ADD IsActive BIT NOT NULL DEFAULT 1;
ALTER TABLE Citizens ADD CreatedAt DATETIME DEFAULT GETDATE();
GO

-- 3. CREATE a backup table using SELECT INTO:
SELECT * INTO TransferRequests_Backup FROM TransferRequests;
GO

-- 4. TRUNCATE the backup table:
TRUNCATE TABLE TransferRequests_Backup;
GO

-- 5. DROP the backup table:
DROP TABLE TransferRequests_Backup;
GO


-- ================================================================
-- SECTION 2 — DML (Data Manipulation Language)
-- ================================================================

-- 1. INSERT a new citizen with all composite address fields
INSERT INTO Citizens (CNIC, FullName, Street, City, District, PostalCode, PasswordHash, Role)
VALUES ('3520188888888', 'Zain Ali', 'House 45 Street 2', 'Peshawar', 'Peshawar', '25000', 'pass123', 'Citizen');
GO

-- 2. INSERT multiple phone numbers for that citizen in CitizenPhones
DECLARE @ZainID INT;
SELECT @ZainID = CitizenID FROM Citizens WHERE CNIC = '3520188888888';
INSERT INTO CitizenPhones (CitizenID, PhoneNumber)
VALUES 
(@ZainID, '03331234567'),
(@ZainID, '09151234567');
GO

-- 3. INSERT a new LandParcel and an Ownership record for it
INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType)
VALUES ('PES-2024-005', 12.00, 'Marla', 'Peshawar', 'Peshawar City', 'Commercial');

DECLARE @NewPlotID INT = SCOPE_IDENTITY();
DECLARE @ZainID INT;
SELECT @ZainID = CitizenID FROM Citizens WHERE CNIC = '3520188888888';

INSERT INTO Ownership (PlotID, CitizenID)
VALUES (@NewPlotID, @ZainID);
GO

-- 4. UPDATE a citizen's address (Street, City, PostalCode)
UPDATE Citizens
SET Street = 'House 99-A Sector C', City = 'Islamabad', PostalCode = '44000'
WHERE CNIC = '3520198765432';
GO

-- 5. UPDATE a dispute status from Open to Resolved WHERE condition
UPDATE Disputes
SET Status = 'Resolved'
WHERE PlotID = 4 AND Status = 'Open';
GO

-- 6. DELETE a phone number from CitizenPhones WHERE PhoneID matches
DELETE FROM CitizenPhones
WHERE PhoneID = (SELECT MIN(PhoneID) FROM CitizenPhones WHERE CitizenID = 1);
GO

-- 7. Show DELETE with subquery:
DELETE FROM CitizenPhones
WHERE CitizenID IN (SELECT CitizenID FROM Citizens WHERE IsActive = 0);
GO


-- ================================================================
-- SECTION 3 — DCL (Data Control Language)
-- ================================================================

-- 1. Create a database user called LandOfficer
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'LandOfficer')
BEGIN
    CREATE USER LandOfficer WITHOUT LOGIN;
END
GO

-- 2. GRANT SELECT, INSERT, UPDATE on Citizens TO LandOfficer
GRANT SELECT, INSERT, UPDATE ON Citizens TO LandOfficer;

-- 3. GRANT SELECT on vw_ActiveOwnership TO LandOfficer
GRANT SELECT ON vw_ActiveOwnership TO LandOfficer;

-- 4. GRANT EXECUTE on sp_RegisterLand TO LandOfficer
GRANT EXECUTE ON sp_RegisterLand TO LandOfficer;

-- 5. REVOKE INSERT on Citizens FROM LandOfficer
REVOKE INSERT ON Citizens FROM LandOfficer;

-- 6. REVOKE EXECUTE on sp_RegisterLand FROM LandOfficer
REVOKE EXECUTE ON sp_RegisterLand FROM LandOfficer;
GO


-- ================================================================
-- SECTION 4 — TCL (Transaction Control Language)
-- ================================================================

-- TRANSACTION 1 — Successful Transfer (COMMIT):
BEGIN TRANSACTION;
  INSERT INTO TransferRequests (PlotID, FromCitizenID, ToCitizenID, Reason, Status)
  VALUES (2, 2, 1, 'Sale agreement signed', 'Pending');
  UPDATE LandParcels SET LandType = 'Residential' WHERE PlotID = 2;
COMMIT;
GO

-- TRANSACTION 2 — Failed Transfer (ROLLBACK):
BEGIN TRY
    BEGIN TRANSACTION;
    -- This will fail due to FK constraint because CitizenID 999 does not exist
    UPDATE Ownership SET CitizenID = 999 WHERE PlotID = 1;
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'Transaction 2 failed and rolled back as expected due to Foreign Key constraint.';
END CATCH;
GO

-- TRANSACTION 3 — SAVEPOINT example:
BEGIN TRANSACTION;
  SAVE TRANSACTION BeforeUpdate;
  UPDATE Citizens SET City = 'Karachi' WHERE CitizenID = 2;
  -- Decide to undo only this part
  ROLLBACK TRANSACTION BeforeUpdate;
  -- Other operations continue here
  UPDATE Citizens SET IsActive = 1 WHERE CitizenID = 2;
COMMIT;
GO


-- ================================================================
-- SECTION 11 — VIEWS (upgraded)
-- ================================================================

-- NEW View 3: Full citizen profile with all phones
GO
CREATE VIEW vw_CitizenFullProfile AS
SELECT c.CitizenID, c.FullName, c.CNIC, c.Role,
       c.Street + ', ' + c.City + ', ' + c.District AS FullAddress,
       c.PostalCode, cp.PhoneNumber, c.IsActive
FROM Citizens c
LEFT JOIN CitizenPhones cp ON c.CitizenID = cp.CitizenID;
GO

-- NEW View 4: Dispute summary with plot and citizen info
CREATE VIEW vw_DisputeSummary AS
SELECT d.DisputeID, lp.PlotNumber, lp.District,
       c.FullName AS FiledBy, c.CNIC,
       d.Description, d.Status, d.FiledDate
FROM Disputes d
INNER JOIN LandParcels lp ON d.PlotID = lp.PlotID
INNER JOIN Citizens c ON d.FiledByCitizenID = c.CitizenID;
GO

-- NEW View 5: Land statistics by district
CREATE VIEW vw_LandStatsByDistrict AS
SELECT District,
       COUNT(*) AS TotalPlots,
       SUM(Area) AS TotalArea,
       AVG(Area) AS AvgArea,
       MAX(Area) AS LargestPlot
FROM LandParcels
GROUP BY District;
GO


-- ================================================================
-- SECTION 10 — INDEXES
-- ================================================================

-- Index on CNIC for fast citizen lookup
CREATE INDEX idx_Citizens_CNIC ON Citizens(CNIC);

-- Index on PlotNumber for fast property search
CREATE INDEX idx_LandParcels_PlotNumber ON LandParcels(PlotNumber);

-- Index on Status for fast transfer filtering
CREATE INDEX idx_TransferRequests_Status ON TransferRequests(Status);

-- Composite index on District + LandType for reporting queries
CREATE INDEX idx_LandParcels_District_Type ON LandParcels(District, LandType);

-- Unique index on CitizenPhones to prevent duplicate numbers per citizen
CREATE UNIQUE INDEX idx_CitizenPhones_Unique
ON CitizenPhones(CitizenID, PhoneNumber);
GO


-- ================================================================
-- SECTION 12 — AUDIT TRIGGER (using AuditLog table)
-- ================================================================

-- Trigger to log every INSERT on Citizens
GO
CREATE TRIGGER trg_AuditCitizens_Insert
ON Citizens
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, NewValue)
    SELECT 'Citizens', 'INSERT', CitizenID, SYSTEM_USER,
           'New citizen: ' + FullName + ' CNIC: ' + CNIC
    FROM Inserted;
END;
GO

-- Trigger to log every UPDATE on Citizens
CREATE TRIGGER trg_AuditCitizens_Update
ON Citizens
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
    SELECT 'Citizens', 'UPDATE', i.CitizenID, SYSTEM_USER,
           'Old City: ' + ISNULL(d.City, 'NULL'),
           'New City: ' + ISNULL(i.City, 'NULL')
    FROM Inserted i
    INNER JOIN Deleted d ON i.CitizenID = d.CitizenID;
END;
GO

-- Trigger to log every DELETE on Citizens
CREATE TRIGGER trg_AuditCitizens_Delete
ON Citizens
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue)
    SELECT 'Citizens', 'DELETE', CitizenID, SYSTEM_USER,
           'Deleted citizen: ' + FullName + ' CNIC: ' + CNIC
    FROM Deleted;
END;
GO


-- ================================================================
-- SECTION 5 — DQL (Data Query Language — SELECT)
-- ================================================================

-- Basic SELECT
SELECT * FROM Citizens;
SELECT FullName, CNIC, City FROM Citizens WHERE Role = 'Officer';

-- ORDER BY
SELECT PlotNumber, Area, District FROM LandParcels ORDER BY Area DESC;
SELECT FullName, City FROM Citizens ORDER BY FullName ASC;

-- GROUP BY
SELECT District, COUNT(*) AS TotalPlots, SUM(Area) AS TotalArea
FROM LandParcels
GROUP BY District;

-- HAVING
SELECT District, COUNT(*) AS TotalPlots
FROM LandParcels
GROUP BY District
HAVING COUNT(*) > 1;

-- GROUP BY with AVG
SELECT LandType, AVG(Area) AS AvgArea, MAX(Area) AS MaxArea, MIN(Area) AS MinArea
FROM LandParcels
GROUP BY LandType;
GO


-- ================================================================
-- SECTION 6 — ALL JOIN TYPES
-- ================================================================

-- INNER JOIN (3 tables)
SELECT lp.PlotNumber, c.FullName AS Owner, c.CNIC, lp.District, lp.Area, lp.AreaUnit
FROM LandParcels lp
INNER JOIN Ownership o ON lp.PlotID = o.PlotID
INNER JOIN Citizens c ON o.CitizenID = c.CitizenID;

-- INNER JOIN (4 tables — include phone numbers)
SELECT lp.PlotNumber, c.FullName, cp.PhoneNumber, lp.District
FROM LandParcels lp
INNER JOIN Ownership o ON lp.PlotID = o.PlotID
INNER JOIN Citizens c ON o.CitizenID = c.CitizenID
INNER JOIN CitizenPhones cp ON c.CitizenID = cp.CitizenID;

-- LEFT JOIN — all plots even those with no disputes
SELECT lp.PlotNumber, lp.District, d.Description AS DisputeDescription, d.Status
FROM LandParcels lp
LEFT JOIN Disputes d ON lp.PlotID = d.PlotID;

-- RIGHT JOIN — all disputes even if plot info missing
SELECT lp.PlotNumber, lp.District, d.Description, d.Status
FROM LandParcels lp
RIGHT JOIN Disputes d ON lp.PlotID = d.PlotID;

-- FULL JOIN — all plots and all disputes matched or not
SELECT lp.PlotNumber, lp.District, d.Description, d.Status
FROM LandParcels lp
FULL JOIN Disputes d ON lp.PlotID = d.PlotID;
GO


-- ================================================================
-- SECTION 7 — SUBQUERIES
-- ================================================================

-- Subquery with SELECT
SELECT FullName, CNIC FROM Citizens
WHERE CitizenID IN (
    SELECT CitizenID FROM Ownership
    WHERE PlotID IN (SELECT PlotID FROM LandParcels WHERE District = 'Lahore')
);

-- Subquery with UPDATE
UPDATE Citizens
SET IsActive = 0
WHERE CitizenID NOT IN (SELECT DISTINCT CitizenID FROM Ownership);

-- Subquery with DELETE
DELETE FROM CitizenPhones
WHERE CitizenID IN (
    SELECT CitizenID FROM Citizens WHERE IsActive = 0
);

-- Subquery with INSERT
INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
SELECT 'Citizens', 'UPDATE', CitizenID, 'System', 'Active', 'Inactive'
FROM Citizens
WHERE IsActive = 0;

-- EXISTS
SELECT lp.PlotNumber, lp.District
FROM LandParcels lp
WHERE EXISTS (
    SELECT 1 FROM TransferRequests tr
    WHERE tr.PlotID = lp.PlotID AND tr.Status = 'Pending'
);

-- NOT EXISTS
SELECT FullName, CNIC FROM Citizens c
WHERE NOT EXISTS (
    SELECT 1 FROM Disputes d WHERE d.FiledByCitizenID = c.CitizenID
);
GO


-- ================================================================
-- SECTION 8 — AGGREGATE FUNCTIONS
-- ================================================================

SELECT COUNT(*) AS TotalCitizens FROM Citizens;
SELECT COUNT(DISTINCT District) AS UniqueDistricts FROM LandParcels;
SELECT SUM(Area) AS TotalLandArea FROM LandParcels;
SELECT AVG(Area) AS AvgPlotSize FROM LandParcels;
SELECT MAX(Area) AS LargestPlot, MIN(Area) AS SmallestPlot FROM LandParcels;

-- Aggregates with GROUP BY and HAVING
SELECT c.FullName, COUNT(o.PlotID) AS PlotsOwned, SUM(lp.Area) AS TotalArea
FROM Citizens c
INNER JOIN Ownership o ON c.CitizenID = o.CitizenID
INNER JOIN LandParcels lp ON o.PlotID = lp.PlotID
GROUP BY c.FullName
HAVING COUNT(o.PlotID) > 1;
GO


-- ================================================================
-- SECTION 9 — SET OPERATIONS
-- ================================================================

-- UNION: All districts from Citizens and LandParcels combined
SELECT District AS Location FROM Citizens
UNION
SELECT District FROM LandParcels;

-- UNION ALL (includes duplicates)
SELECT District AS Location FROM Citizens
UNION ALL
SELECT District FROM LandParcels;

-- INTERSECT: Districts that appear in both Citizens and LandParcels
SELECT District FROM Citizens
INTERSECT
SELECT District FROM LandParcels;

-- EXCEPT (T-SQL version of MINUS):
-- Districts in LandParcels that no citizen lives in
SELECT District FROM LandParcels
EXCEPT
SELECT District FROM Citizens;
GO


-- ================================================================
-- SECTION 13 — NORMALIZATION COMMENTS
-- ================================================================

-- 1NF: All columns are atomic (no repeating groups).
--      Phone numbers moved to CitizenPhones (separate table).

-- 2NF: All non-key attributes depend on the full primary key.
--      LandParcels has no partial dependencies.
--      Ownership links Citizens and LandParcels properly.

-- 3NF: No transitive dependencies.
--      District in Citizens refers to citizen's home address,
--      District in LandParcels refers to plot location — not redundant.
--      All tables have been reviewed for transitive dependency removal.

PRINT '===============================================================';
PRINT 'LandTrackPK Database upgraded successfully with Sections 1-13!';
PRINT '===============================================================';
GO
