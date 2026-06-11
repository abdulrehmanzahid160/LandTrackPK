USE master;
GO

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

CREATE TABLE CitizenPhones (
    PhoneID     INT IDENTITY(1,1) PRIMARY KEY,
    CitizenID   INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID) ON DELETE CASCADE,
    PhoneNumber VARCHAR(15) NOT NULL
);
GO

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

CREATE TABLE Ownership (
    OwnershipID     INT IDENTITY(1,1) PRIMARY KEY,
    PlotID          INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    CitizenID       INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    AcquiredDate    DATE NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE OwnershipHistory (
    HistoryID           INT IDENTITY(1,1) PRIMARY KEY,
    PlotID              INT NOT NULL FOREIGN KEY REFERENCES LandParcels(PlotID) ON DELETE CASCADE,
    PreviousCitizenID   INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    NewCitizenID        INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID),
    TransferDate        DATETIME NOT NULL DEFAULT GETDATE()
);
GO

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

GO
CREATE TRIGGER trg_LogOwnershipChange
ON TransferRequests
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

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

        DECLARE @CitizenID INT;
        SELECT @CitizenID = CitizenID FROM Citizens WHERE CNIC = @OwnerCNIC;

        IF @CitizenID IS NULL
        BEGIN
            THROW 50001, 'Citizen with the provided CNIC does not exist.', 1;
        END

        INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType, RegisteredDate)
        VALUES (@PlotNumber, @Area, @AreaUnit, @District, @Tehsil, @LandType, GETDATE());

        DECLARE @NewPlotID INT = SCOPE_IDENTITY();

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

GO
CREATE PROCEDURE sp_TransferOwnership
    @TransferID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @PlotID INT, @FromCitizenID INT, @ToCitizenID INT, @Status VARCHAR(10);

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

        UPDATE Ownership
        SET CitizenID = @ToCitizenID, AcquiredDate = GETDATE()
        WHERE PlotID = @PlotID;

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

INSERT INTO Citizens (FullName, CNIC, Street, City, District, PostalCode, PasswordHash, Role)
VALUES
('Ahmed Raza',     '3520112345671', 'House 12 Street 4', 'Lahore',     'Lahore',     '54000', 'admin123', 'Officer'),
('Muhammad Tariq', '3520198765432', 'Street 7',          'Rawalpindi', 'Rawalpindi', '46000', 'admin123', 'Citizen'),
('Sara Bibi',      '3520156789012', 'Gulberg III',       'Lahore',     'Lahore',     '54660', 'admin123', 'Citizen');

INSERT INTO CitizenPhones (CitizenID, PhoneNumber)
VALUES
(1, '03001234567'),
(1, '04237654321'),
(2, '03211234567'),
(3, '03451234567'),
(3, '03009876543');

INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType)
VALUES
('LHR-2024-001', 10.00, 'Marla', 'Lahore',     'Shalimar',  'Residential'),
('RWP-2024-002',  4.00, 'Kanal', 'Rawalpindi', 'Murree',    'Agricultural'),
('FSD-2024-003',  5.00, 'Marla', 'Faisalabad', 'Sammundri', 'Commercial'),
('MUL-2024-004',  8.00, 'Marla', 'Multan',     'Shujabad',  'Residential');

INSERT INTO Ownership (PlotID, CitizenID)
VALUES
(1, 2),
(2, 2),
(3, 3),
(4, 3);

INSERT INTO TransferRequests (PlotID, FromCitizenID, ToCitizenID, Reason, Status)
VALUES
(1, 2, 3, 'Selling property to Sara', 'Pending'),
(3, 3, 2, 'Gifting commercial plot to Tariq', 'Pending');

INSERT INTO Disputes (PlotID, FiledByCitizenID, Description, Status)
VALUES
(4, 2, 'Boundary wall overlap issue with the neighboring property.', 'Open');
GO

CREATE TABLE AuditLog (
   AuditLogID   INT IDENTITY PRIMARY KEY,
   TableName    VARCHAR(50),
   Action       VARCHAR(10),
   RecordID     INT,
   ChangedBy    NVARCHAR(100),
   ChangeDate   DATETIME DEFAULT GETDATE(),
   OldValue     NVARCHAR(500),
   NewValue     NVARCHAR(500)
);
GO

ALTER TABLE Citizens ADD IsActive BIT NOT NULL DEFAULT 1;
ALTER TABLE Citizens ADD CreatedAt DATETIME DEFAULT GETDATE();
GO

SELECT * INTO TransferRequests_Backup FROM TransferRequests;
GO

TRUNCATE TABLE TransferRequests_Backup;
GO

DROP TABLE TransferRequests_Backup;
GO

INSERT INTO Citizens (CNIC, FullName, Street, City, District, PostalCode, PasswordHash, Role)
VALUES ('3520188888888', 'Zain Ali', 'House 45 Street 2', 'Peshawar', 'Peshawar', '25000', 'pass123', 'Citizen');
GO

DECLARE @ZainID INT;
SELECT @ZainID = CitizenID FROM Citizens WHERE CNIC = '3520188888888';
INSERT INTO CitizenPhones (CitizenID, PhoneNumber)
VALUES
(@ZainID, '03331234567'),
(@ZainID, '09151234567');
GO

INSERT INTO LandParcels (PlotNumber, Area, AreaUnit, District, Tehsil, LandType)
VALUES ('PES-2024-005', 12.00, 'Marla', 'Peshawar', 'Peshawar City', 'Commercial');

DECLARE @NewPlotID INT = SCOPE_IDENTITY();
DECLARE @ZainID INT;
SELECT @ZainID = CitizenID FROM Citizens WHERE CNIC = '3520188888888';

INSERT INTO Ownership (PlotID, CitizenID)
VALUES (@NewPlotID, @ZainID);
GO

UPDATE Citizens
SET Street = 'House 99-A Sector C', City = 'Islamabad', PostalCode = '44000'
WHERE CNIC = '3520198765432';
GO

UPDATE Disputes
SET Status = 'Resolved'
WHERE PlotID = 4 AND Status = 'Open';
GO

DELETE FROM CitizenPhones
WHERE PhoneID = (SELECT MIN(PhoneID) FROM CitizenPhones WHERE CitizenID = 1);
GO

DELETE FROM CitizenPhones
WHERE CitizenID IN (SELECT CitizenID FROM Citizens WHERE IsActive = 0);
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'LandOfficer')
BEGIN
    CREATE USER LandOfficer WITHOUT LOGIN;
END
GO

GRANT SELECT, INSERT, UPDATE ON Citizens TO LandOfficer;

GRANT SELECT ON vw_ActiveOwnership TO LandOfficer;

GRANT EXECUTE ON sp_RegisterLand TO LandOfficer;

REVOKE INSERT ON Citizens FROM LandOfficer;

REVOKE EXECUTE ON sp_RegisterLand FROM LandOfficer;
GO

BEGIN TRANSACTION;
  INSERT INTO TransferRequests (PlotID, FromCitizenID, ToCitizenID, Reason, Status)
  VALUES (2, 2, 1, 'Sale agreement signed', 'Pending');
  UPDATE LandParcels SET LandType = 'Residential' WHERE PlotID = 2;
COMMIT;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE Ownership SET CitizenID = 999 WHERE PlotID = 1;
    COMMIT;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    PRINT 'Transaction 2 failed and rolled back as expected due to Foreign Key constraint.';
END CATCH;
GO

BEGIN TRANSACTION;
  SAVE TRANSACTION BeforeUpdate;
  UPDATE Citizens SET City = 'Karachi' WHERE CitizenID = 2;

  ROLLBACK TRANSACTION BeforeUpdate;

  UPDATE Citizens SET IsActive = 1 WHERE CitizenID = 2;
COMMIT;
GO

GO
CREATE VIEW vw_CitizenFullProfile AS
SELECT c.CitizenID, c.FullName, c.CNIC, c.Role,
       c.Street + ', ' + c.City + ', ' + c.District AS FullAddress,
       c.PostalCode, cp.PhoneNumber, c.IsActive
FROM Citizens c
LEFT JOIN CitizenPhones cp ON c.CitizenID = cp.CitizenID;
GO

CREATE VIEW vw_DisputeSummary AS
SELECT d.DisputeID, lp.PlotNumber, lp.District,
       c.FullName AS FiledBy, c.CNIC,
       d.Description, d.Status, d.FiledDate
FROM Disputes d
INNER JOIN LandParcels lp ON d.PlotID = lp.PlotID
INNER JOIN Citizens c ON d.FiledByCitizenID = c.CitizenID;
GO

CREATE VIEW vw_LandStatsByDistrict AS
SELECT District,
       COUNT(*) AS TotalPlots,
       SUM(Area) AS TotalArea,
       AVG(Area) AS AvgArea,
       MAX(Area) AS LargestPlot
FROM LandParcels
GROUP BY District;
GO

CREATE INDEX idx_Citizens_CNIC ON Citizens(CNIC);

CREATE INDEX idx_LandParcels_PlotNumber ON LandParcels(PlotNumber);

CREATE INDEX idx_TransferRequests_Status ON TransferRequests(Status);

CREATE INDEX idx_LandParcels_District_Type ON LandParcels(District, LandType);

CREATE UNIQUE INDEX idx_CitizenPhones_Unique
ON CitizenPhones(CitizenID, PhoneNumber);
GO

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

SELECT * FROM Citizens;
SELECT FullName, CNIC, City FROM Citizens WHERE Role = 'Officer';

SELECT PlotNumber, Area, District FROM LandParcels ORDER BY Area DESC;
SELECT FullName, City FROM Citizens ORDER BY FullName ASC;

SELECT District, COUNT(*) AS TotalPlots, SUM(Area) AS TotalArea
FROM LandParcels
GROUP BY District;

SELECT District, COUNT(*) AS TotalPlots
FROM LandParcels
GROUP BY District
HAVING COUNT(*) > 1;

SELECT LandType, AVG(Area) AS AvgArea, MAX(Area) AS MaxArea, MIN(Area) AS MinArea
FROM LandParcels
GROUP BY LandType;
GO

SELECT lp.PlotNumber, c.FullName AS Owner, c.CNIC, lp.District, lp.Area, lp.AreaUnit
FROM LandParcels lp
INNER JOIN Ownership o ON lp.PlotID = o.PlotID
INNER JOIN Citizens c ON o.CitizenID = c.CitizenID;

SELECT lp.PlotNumber, c.FullName, cp.PhoneNumber, lp.District
FROM LandParcels lp
INNER JOIN Ownership o ON lp.PlotID = o.PlotID
INNER JOIN Citizens c ON o.CitizenID = c.CitizenID
INNER JOIN CitizenPhones cp ON c.CitizenID = cp.CitizenID;

SELECT lp.PlotNumber, lp.District, d.Description AS DisputeDescription, d.Status
FROM LandParcels lp
LEFT JOIN Disputes d ON lp.PlotID = d.PlotID;

SELECT lp.PlotNumber, lp.District, d.Description, d.Status
FROM LandParcels lp
RIGHT JOIN Disputes d ON lp.PlotID = d.PlotID;

SELECT lp.PlotNumber, lp.District, d.Description, d.Status
FROM LandParcels lp
FULL JOIN Disputes d ON lp.PlotID = d.PlotID;
GO

SELECT FullName, CNIC FROM Citizens
WHERE CitizenID IN (
    SELECT CitizenID FROM Ownership
    WHERE PlotID IN (SELECT PlotID FROM LandParcels WHERE District = 'Lahore')
);

UPDATE Citizens
SET IsActive = 0
WHERE CitizenID NOT IN (SELECT DISTINCT CitizenID FROM Ownership);

DELETE FROM CitizenPhones
WHERE CitizenID IN (
    SELECT CitizenID FROM Citizens WHERE IsActive = 0
);

INSERT INTO AuditLog (TableName, Action, RecordID, ChangedBy, OldValue, NewValue)
SELECT 'Citizens', 'UPDATE', CitizenID, 'System', 'Active', 'Inactive'
FROM Citizens
WHERE IsActive = 0;

SELECT lp.PlotNumber, lp.District
FROM LandParcels lp
WHERE EXISTS (
    SELECT 1 FROM TransferRequests tr
    WHERE tr.PlotID = lp.PlotID AND tr.Status = 'Pending'
);

SELECT FullName, CNIC FROM Citizens c
WHERE NOT EXISTS (
    SELECT 1 FROM Disputes d WHERE d.FiledByCitizenID = c.CitizenID
);
GO

SELECT COUNT(*) AS TotalCitizens FROM Citizens;
SELECT COUNT(DISTINCT District) AS UniqueDistricts FROM LandParcels;
SELECT SUM(Area) AS TotalLandArea FROM LandParcels;
SELECT AVG(Area) AS AvgPlotSize FROM LandParcels;
SELECT MAX(Area) AS LargestPlot, MIN(Area) AS SmallestPlot FROM LandParcels;

SELECT c.FullName, COUNT(o.PlotID) AS PlotsOwned, SUM(lp.Area) AS TotalArea
FROM Citizens c
INNER JOIN Ownership o ON c.CitizenID = o.CitizenID
INNER JOIN LandParcels lp ON o.PlotID = lp.PlotID
GROUP BY c.FullName
HAVING COUNT(o.PlotID) > 1;
GO

SELECT District AS Location FROM Citizens
UNION
SELECT District FROM LandParcels;

SELECT District AS Location FROM Citizens
UNION ALL
SELECT District FROM LandParcels;

SELECT District FROM Citizens
INTERSECT
SELECT District FROM LandParcels;

SELECT District FROM LandParcels
EXCEPT
SELECT District FROM Citizens;
GO

PRINT '===============================================================';
PRINT 'LandTrackPK Database upgraded successfully with Sections 1-13!';
PRINT '===============================================================';
GO