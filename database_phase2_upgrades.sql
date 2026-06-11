USE LandTrackPK;
GO

IF OBJECT_ID('Appointments', 'U') IS NULL
BEGIN
    CREATE TABLE Appointments (
        AppointmentID   INT IDENTITY(1,1) PRIMARY KEY,
        CitizenID       INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID) ON DELETE CASCADE,
        ServiceCenter   NVARCHAR(100) NOT NULL,
        Tehsil          NVARCHAR(100) NOT NULL,
        Reason          NVARCHAR(200) NOT NULL,
        AppointmentDate DATE NOT NULL,
        AppointmentTime VARCHAR(20) NOT NULL,
        TokenNumber     VARCHAR(20) NOT NULL,
        Status          VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
    );
END
GO

IF OBJECT_ID('Complaints', 'U') IS NULL
BEGIN
    CREATE TABLE Complaints (
        ComplaintID     INT IDENTITY(1,1) PRIMARY KEY,
        CitizenID       INT NOT NULL FOREIGN KEY REFERENCES Citizens(CitizenID) ON DELETE CASCADE,
        ComplaintType   NVARCHAR(100) NOT NULL,
        Details         NVARCHAR(500) NOT NULL,
        Status          VARCHAR(20) NOT NULL DEFAULT 'Open',
        SubmittedDate   DATETIME NOT NULL DEFAULT GETDATE(),
        AttachmentPath  NVARCHAR(255) NULL
    );
END
GO

IF OBJECT_ID('ComplaintComments', 'U') IS NULL
BEGIN
    CREATE TABLE ComplaintComments (
        CommentID       INT IDENTITY(1,1) PRIMARY KEY,
        ComplaintID     INT NOT NULL FOREIGN KEY REFERENCES Complaints(ComplaintID) ON DELETE CASCADE,
        SenderType      VARCHAR(20) NOT NULL CHECK (SenderType IN ('Complainant', 'ServiceRep')),
        SenderName      NVARCHAR(100) NOT NULL,
        CommentText     NVARCHAR(500) NOT NULL,
        CommentDate     DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

DELETE FROM Appointments;
INSERT INTO Appointments (CitizenID, ServiceCenter, Tehsil, Reason, AppointmentDate, AppointmentTime, TokenNumber, Status)
VALUES
(2, 'DMM Nankana Sahib', 'Nankana Sahib', 'Copy (Personal Record, 17889672)', '2022-09-29', '04:27 pm', '1029', 'Completed'),
(2, 'DMM Nankana Sahib', 'Nankana Sahib', 'Copy (Personal Record, 17889682)', '2022-09-29', '04:27 pm', '1029', 'Completed'),
(2, 'Lahore Model Town', 'Lahore Model Town', 'General Inquiry', '2022-07-07', '04:14 pm', '57', 'Completed');

DELETE FROM ComplaintComments;
DELETE FROM Complaints;

INSERT INTO Complaints (CitizenID, ComplaintType, Details, Status, SubmittedDate, AttachmentPath)
VALUES
(2, 'CNIC Verification', 'please verify CNIC', 'Open', '2023-01-09 15:02:00', 'Fard_20230109_122831.pdf');

DECLARE @ComplaintID INT = SCOPE_IDENTITY();

INSERT INTO ComplaintComments (ComplaintID, SenderType, SenderName, CommentText, CommentDate)
VALUES
(@ComplaintID, 'Complainant', 'Muhammad Tariq', 'check please', '2023-01-09 15:02:00'),
(@ComplaintID, 'ServiceRep', 'Officer Ahmed', 'Verified from admin side', '2023-01-09 15:03:00');
GO