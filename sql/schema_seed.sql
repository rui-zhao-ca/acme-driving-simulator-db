/* ---------------------------------------------------------------------
   1) DDL — CORE REFERENCE TABLES
   --------------------------------------------------------------------- */

CREATE TABLE Role (
  RoleID   INT,
  RoleName VARCHAR(50),
  PRIMARY KEY (RoleID)
);

CREATE TABLE `User` (
  UserID   INT,
  UserName VARCHAR(100),
  RoleID   INT,
  PRIMARY KEY (UserID),
  FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

CREATE TABLE Client (
  ClientID   INT,
  ClientName VARCHAR(150),
  PRIMARY KEY (ClientID)
);

/* ---------------------------------------------------------------------
   2) DDL — DOCUMENTS, VERSIONING, CONTENT
   --------------------------------------------------------------------- */

CREATE TABLE Document (
  DocID       INT,
  DocName     VARCHAR(150),
  Description TEXT,
  PRIMARY KEY (DocID)
);

CREATE TABLE DocumentVersion (
  VersionID    INT,
  VersionNum   FLOAT,
  ReleaseID    INT,
  DocID        INT,
  CreatedBy    INT,
  CreationDate DATETIME,
  PRIMARY KEY (VersionID),
  FOREIGN KEY (DocID)     REFERENCES Document(DocID),
  FOREIGN KEY (CreatedBy) REFERENCES `User`(UserID)
);

CREATE TABLE Section (
  SectionID     INT,
  ParentSection INT,
  VersionID     INT,
  PRIMARY KEY (SectionID),
  FOREIGN KEY (ParentSection) REFERENCES Section(SectionID),
  FOREIGN KEY (VersionID)     REFERENCES DocumentVersion(VersionID)
);

CREATE TABLE SectionRows (
  RowID             INT,
  `Order`           INT,
  Type              VARCHAR(50),
  Content           VARCHAR(100),
  Observation       VARCHAR(100),
  Conditionality    VARCHAR(255),
  SectionID         INT,
  CompanyTestResult VARCHAR(20),
  ClientTestResult  VARCHAR(20),
  PRIMARY KEY (RowID),
  FOREIGN KEY (SectionID) REFERENCES Section(SectionID)
);

CREATE TABLE ChangeLog (
  LogID      INT,
  ChangeType VARCHAR(50),
  ChangedBy  INT,
  RowID      INT,
  PRIMARY KEY (LogID),
  FOREIGN KEY (ChangedBy) REFERENCES `User`(UserID),
  FOREIGN KEY (RowID)     REFERENCES SectionRows(RowID)
);

CREATE TABLE ApprovalTask (
  ApprovalID   INT,
  `Status`     VARCHAR(50),
  ApprovalDate DATE,
  ReviewedBy   INT,
  VersionID    INT,
  PRIMARY KEY (ApprovalID),
  FOREIGN KEY (ReviewedBy) REFERENCES `User`(UserID),
  FOREIGN KEY (VersionID)  REFERENCES DocumentVersion(VersionID)
);

CREATE TABLE ApprovalComments (
  CommentID INT,
  `Comment` TEXT,
  ApprovalID INT,
  PRIMARY KEY (CommentID),
  FOREIGN KEY (ApprovalID) REFERENCES ApprovalTask(ApprovalID)
);

CREATE TABLE Notification (
  NotificationID INT,
  EventType       VARCHAR(50),
  Message         TEXT,
  ReceivedBy      INT,
  PRIMARY KEY (NotificationID),
  FOREIGN KEY (ReceivedBy) REFERENCES `User`(UserID)
);

/* ---------------------------------------------------------------------
   3) DDL — OPTIONS, VALUES, PRODUCTS, PLATFORMS
   --------------------------------------------------------------------- */

CREATE TABLE ProductOptions (
  OptionID   INT,
  OptionName VARCHAR(100),
  PRIMARY KEY (OptionID)
);

CREATE TABLE ProductOptionValues (
  ValueID   INT,
  ValueName VARCHAR(100),
  OptionID  INT,
  PRIMARY KEY (OptionID, ValueID),
  FOREIGN KEY (OptionID) REFERENCES ProductOptions(OptionID)
);

CREATE TABLE PlatformOptions (
  OptionID   INT,
  OptionName VARCHAR(100),
  PRIMARY KEY (OptionID)
);

CREATE TABLE PlatformOptionValues (
  ValueID   INT,
  ValueName VARCHAR(100),
  OptionID  INT,
  PRIMARY KEY (OptionID, ValueID),
  FOREIGN KEY (OptionID) REFERENCES PlatformOptions(OptionID)
);

CREATE TABLE Product (
  ProductID    INT,
  Name         VARCHAR(150),
  Family       VARCHAR(100),
  ProductType  VARCHAR(50),
  Standard     VARCHAR(50),
  `Year`       YEAR,
  `Status`     VARCHAR(50),
  CreatedBy    INT,
  CreationDate DATETIME,
  PRIMARY KEY (ProductID),
  FOREIGN KEY (CreatedBy) REFERENCES `User`(UserID)
);

CREATE TABLE Platform (
  PlatformID   INT,
  Name         VARCHAR(150),
  Version      VARCHAR(50),
  `Year`       YEAR,
  PlatformType VARCHAR(50),
  `Status`     VARCHAR(50),
  CreatedBy    INT,
  CreationDate DATETIME,
  PRIMARY KEY (PlatformID),
  FOREIGN KEY (CreatedBy) REFERENCES `User`(UserID)
);

CREATE TABLE ProductOptionSelection (
  ProductOptionSelectionID INT AUTO_INCREMENT PRIMARY KEY,
  ProductID INT,
  OptionID  INT,
  ValueID   INT,
  FOREIGN KEY (ProductID)         REFERENCES Product(ProductID),
  FOREIGN KEY (OptionID, ValueID) REFERENCES ProductOptionValues(OptionID, ValueID)
);

CREATE TABLE PlatformOptionSelection (
  PlatformOptionSelectionID INT AUTO_INCREMENT PRIMARY KEY,
  PlatformID INT,
  OptionID   INT,
  ValueID    INT,
  FOREIGN KEY (PlatformID)        REFERENCES Platform(PlatformID),
  FOREIGN KEY (OptionID, ValueID) REFERENCES PlatformOptionValues(OptionID, ValueID)
);

/* ---------------------------------------------------------------------
   4) DDL — PROJECTS, CONFIGS, DOCUMENT LINKS
   --------------------------------------------------------------------- */

CREATE TABLE Project (
  ProjectID     INT AUTO_INCREMENT PRIMARY KEY,
  Name          VARCHAR(150),
  CreatedBy     INT,
  CreationDate  DATETIME,
  RequestedDate DATETIME NOT NULL,
  ClientID      INT,
  FOREIGN KEY (CreatedBy) REFERENCES `User`(UserID),
  FOREIGN KEY (ClientID)  REFERENCES Client(ClientID)
);

CREATE TABLE ProductConfig (
  ProjectID INT,
  ProductOptionSelectionID INT,
  PRIMARY KEY (ProjectID, ProductOptionSelectionID),
  FOREIGN KEY (ProjectID)                REFERENCES Project(ProjectID),
  FOREIGN KEY (ProductOptionSelectionID) REFERENCES ProductOptionSelection(ProductOptionSelectionID)
);

CREATE TABLE PlatformConfig (
  ProjectID INT,
  PlatformOptionSelectionID INT,
  PRIMARY KEY (ProjectID, PlatformOptionSelectionID),
  FOREIGN KEY (ProjectID)                 REFERENCES Project(ProjectID),
  FOREIGN KEY (PlatformOptionSelectionID) REFERENCES PlatformOptionSelection(PlatformOptionSelectionID)
);

CREATE TABLE ProductDocument (
  ProductID INT,
  VersionID INT,
  PRIMARY KEY (ProductID, VersionID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
  FOREIGN KEY (VersionID) REFERENCES DocumentVersion(VersionID)
);

CREATE TABLE PlatformDocument (
  PlatformID INT,
  VersionID  INT,
  PRIMARY KEY (PlatformID, VersionID),
  FOREIGN KEY (PlatformID) REFERENCES Platform(PlatformID),
  FOREIGN KEY (VersionID)  REFERENCES DocumentVersion(VersionID)
);

/* ---------------------------------------------------------------------
   5) DML — SEED DATA
   --------------------------------------------------------------------- */

/* ----------------- ROLE ----------------- */
INSERT INTO Role (RoleID, RoleName) VALUES
(1,'Admin'),
(2,'Engineer'),
(3,'Manager'),
(4,'Operator'),
(5,'Tester'),
(6,'Writer'),
(7,'Reviewer'),
(8,'Publisher'),
(9,'QA Analyst'),
(10,'Support');

/* ----------------- USER ----------------- */
INSERT INTO `User` (UserID, UserName, RoleID) VALUES
(1,'Alice',1),
(2,'Bob',2),
(3,'Charlie',3),
(4,'David',4),
(5,'Eve',5),
(6,'Alex',6),
(7,'Emilie',6),
(8,'Animesh',6),
(9,'Nina',7),
(10,'Marco',8),
(11,'Priya',9),
(12,'Liam',10);

/* ----------------- CLIENT ----------------- */
INSERT INTO Client (ClientID, ClientName) VALUES
(1,'Red Arrow Corp'),
(2,'Honda'),
(3,'Toyota'),
(4,'AM General'),
(5,'Audi'),
(6,'Ford'),
(7,'Chevrolet'),
(8,'BMW'),
(9,'Nissan'),
(10,'Kia');

/* ----------------- DOCUMENT ----------------- */
INSERT INTO Document (DocID, DocName, Description) VALUES
(1,'User Manual','User manual for product'),
(2,'Technical Specs','Technical specifications'),
(3,'Safety Guidelines','Product safety instructions'),
(4,'Maintenance Guide','Guide for maintenance procedures'),
(5,'Installation Instructions','Steps for installation'),
(6,'Driving Scenarios','Scenario scripts for training & assessment'),
(7,'Diagnostics Guide','Troubleshooting & error codes'),
(8,'Calibration Procedures','Sensor & system calibration steps'),
(9,'Emergency Protocols','Emergency handling & shutdown procedures'),
(10,'Performance Testing','Benchmark and acceptance tests');

/* ----------------- DOCUMENT VERSION ----------------- */
INSERT INTO DocumentVersion (VersionID, VersionNum, ReleaseID, DocID, CreatedBy, CreationDate) VALUES
(1,  1.0, 100, 1, 6, '2025-01-01 10:00:00'),
(2,  2.0, 101, 1, 7, '2025-02-15 11:30:00'),
(3,  1.0, 102, 2, 7, '2025-03-05 09:45:00'),
(4,  1.1, 103, 2, 8, '2025-04-20 14:20:00'),
(5,  1.0, 104, 3, 6, '2025-05-12 08:15:00'),
(6,  1.2, 105, 3, 8, '2025-06-01 16:40:00'),
(7,  2.1, 106, 1, 6, '2025-06-25 12:10:00'),
(8,  1.0, 107, 4, 7, '2025-07-14 13:55:00'),
(9,  1.1, 108, 4, 6, '2025-08-03 15:25:00'),
(10, 1.0, 109, 5, 7, '2025-08-10 10:50:00'),
(11, 2.2, 110, 1, 6, '2025-08-20 09:00:00'),
(12, 3.0, 111, 1, 7, '2025-09-10 10:00:00'),
(13, 3.1, 112, 1, 6, '2025-09-28 09:30:00'),
(14, 4.0, 113, 1, 8, '2025-10-20 14:00:00'),
(15, 2.0, 114, 2, 7, '2025-07-05 11:00:00'),
(16, 2.1, 115, 2, 8, '2025-08-01 11:30:00'),
(17, 3.0, 116, 2, 7, '2025-09-14 09:15:00'),
(18, 1.3, 117, 3, 6, '2025-06-18 10:10:00'),
(19, 2.0, 118, 3, 8, '2025-08-09 13:00:00'),
(20, 1.2, 119, 4, 6, '2025-09-05 16:00:00'),
(21, 2.0, 120, 4, 7, '2025-10-01 10:45:00'),
(22, 1.1, 121, 5, 7, '2025-08-28 09:05:00'),
(23, 2.0, 122, 5, 6, '2025-09-20 11:25:00'),
(24, 2.1, 123, 5, 8, '2025-10-06 17:40:00'),
(25, 1.0, 124, 6, 6, '2025-07-01 09:00:00'),
(26, 1.1, 125, 6, 7, '2025-07-21 09:00:00'),
(27, 2.0, 126, 6, 8, '2025-09-01 09:00:00'),
(28, 1.0, 127, 7, 7, '2025-06-30 12:00:00'),
(29, 1.1, 128, 7, 6, '2025-08-02 12:30:00'),
(30, 1.0, 129, 8, 6, '2025-07-15 15:00:00'),
(31, 1.1, 130, 8, 7, '2025-08-05 15:30:00'),
(32, 1.2, 131, 8, 8, '2025-09-10 15:45:00'),
(33, 1.0, 132, 9, 6, '2025-07-18 10:30:00'),
(34, 1.1, 133, 9, 7, '2025-08-20 14:20:00'),
(35, 1.1, 134, 10, 7, '2025-09-01 11:50:00'),
(36, 1.2, 135, 10, 6, '2025-09-25 12:10:00'),
(37, 2.0, 136, 10, 8, '2025-10-12 12:30:00');

/* ----------------- PRODUCT OPTIONS ----------------- */
INSERT INTO ProductOptions (OptionID, OptionName) VALUES
(1,'Engine'),
(2,'Transmission'),
(3,'AC'),
(4,'Seat Material'),
(5,'Infotainment'),
(6,'Braking Assist'),
(7,'Suspension'),
(8,'Drive Mode'),
(9,'Navigation'),
(10,'Safety Pack');

/* ----------------- PRODUCT OPTION VALUES ----------------- */
INSERT INTO ProductOptionValues (OptionID, ValueID, ValueName) VALUES
(1,1,'Gas'),
(1,2,'Hybrid'),
(2,1,'Automatic'),
(2,2,'Manual'),
(3,1,'True'),
(3,2,'False'),
(4,1,'Leather'),
(4,2,'Cloth'),
(5,1,'Premium'),
(5,2,'Standard');

/* ----------------- PLATFORM OPTIONS ----------------- */
INSERT INTO PlatformOptions (OptionID, OptionName) VALUES
(1,'4D Support'),
(2,'Tech Level'),
(3,'Language Pack'),
(4,'OS Version'),
(5,'Graphics Quality'),
(6,'Haptics Level'),
(7,'Physics Engine'),
(8,'Telemetry Export'),
(9,'Audio Pack'),
(10,'Network Mode');

/* ----------------- PLATFORM OPTION VALUES ----------------- */
INSERT INTO PlatformOptionValues (OptionID, ValueID, ValueName) VALUES
(1,1,'True'),
(1,2,'False'),
(2,1,'High'),
(2,2,'Medium'),
(2,3,'Low'),
(3,1,'English'),
(3,2,'French'),
(4,1,'v1.0'),
(4,2,'v2.0'),
(5,1,'Ultra');

/* ----------------- PRODUCT ----------------- */
INSERT INTO Product (ProductID, Name, Family, ProductType, Standard, `Year`, `Status`, CreatedBy, CreationDate) VALUES
(1,'Honda CRV Sim 2019','Honda','Civil','2.1',2019,'Active',1,'2024-12-01'),
(2,'Toyota Prius 2021','Toyota','Civil','3.0',2021,'Active',2,'2024-12-03'),
(3,'Audi A4 Sim 2020','Audi','Civil','2.5',2020,'Active',3,'2024-12-05'),
(4,'AMG GT Sim 2022','AMG','Civil','3.2',2022,'Active',4,'2024-12-07'),
(5,'Honda Civic Sim 2018','Honda','Civil','2.0',2018,'Active',5,'2024-12-09'),
(6,'Honda Accord Sim 2022','Honda','Civil','3.1',2022,'Active',6,'2025-01-10'),
(7,'Toyota Corolla 2020','Toyota','Civil','2.7',2020,'Active',7,'2025-01-12'),
(8,'Audi Q7 Sim 2023','Audi','Civil','3.3',2023,'Active',8,'2025-02-02'),
(9,'Nissan Leaf 2021','Nissan','Civil','3.0',2021,'Active',9,'2025-02-05'),
(10,'Kia EV6 2022','Kia','Civil','3.2',2022,'Active',10,'2025-02-10');

/* ----------------- PLATFORM ----------------- */
INSERT INTO Platform (PlatformID, Name, Version, `Year`, PlatformType, `Status`, CreatedBy, CreationDate) VALUES
(1,'SimCore Lite','1.0',2020,'Civil','Active',1,'2024-11-10'),
(2,'ACME SimCore Pro','2.0',2021,'Civil','Active',2,'2025-01-05'),
(3,'UltraSim','3.0',2022,'Civil','Active',3,'2025-02-01'),
(4,'BasicSim','1.5',2019,'Civil','Active',4,'2025-03-01'),
(5,'ProSim','2.5',2021,'Civil','Active',5,'2025-04-01'),
(6,'SimCore Ultra','3.1',2023,'Civil','Active',6,'2025-02-15'),
(7,'SimCore Edge','4.0',2024,'Civil','Active',7,'2025-03-01'),
(8,'ProSim X','3.5',2023,'Civil','Active',8,'2025-03-10'),
(9,'UltraSim Neo','4.2',2024,'Civil','Active',9,'2025-03-20'),
(10,'BasicSim Plus','2.0',2022,'Civil','Active',10,'2025-03-25');

/* ----------------- PRODUCT OPTION SELECTION ----------------- */
INSERT INTO ProductOptionSelection (ProductID, OptionID, ValueID) VALUES
-- Product 1
(1,1,2),(1,2,1),(1,3,1),(1,4,1),(1,5,1),
-- Product 2
(2,1,1),(2,2,2),(2,3,1),(2,4,2),(2,5,2),
-- Product 3
(3,1,2),(3,2,1),(3,3,1),(3,4,1),(3,5,2),
-- Product 4
(4,1,1),(4,2,2),(4,3,1),(4,4,2),(4,5,1),
-- Product 5
(5,1,2),(5,2,1),(5,3,1),(5,4,1),(5,5,2);

/* ----------------- PLATFORM OPTION SELECTION ----------------- */
INSERT INTO PlatformOptionSelection (PlatformID, OptionID, ValueID) VALUES
-- Platform 1
(1,1,1),(1,2,2),(1,3,1),(1,4,1),(1,5,1),
-- Platform 2
(2,1,2),(2,2,1),(2,3,1),(2,4,2),(2,5,1),
-- Platform 3
(3,1,1),(3,2,3),(3,3,2),(3,4,1),(3,5,1),
-- Platform 4
(4,1,2),(4,2,3),(4,3,1),(4,4,2),(4,5,1),
-- Platform 5
(5,1,1),(5,2,2),(5,3,2),(5,4,1),(5,5,1);

/* ----------------- PROJECT -----------------
   NOTE: Keep insertion order to preserve auto-increment IDs:
     - First 5 rows -> ProjectID 1..5
     - Next 5 rows  -> ProjectID 6..10
     - Last 4 rows  -> ProjectID 11..14
   ----------------- */
INSERT INTO Project (Name, CreatedBy, CreationDate, RequestedDate, ClientID) VALUES
-- 1..5
('Red Arrow Hybrid Training System', 1,  '2025-07-31', '2025-07-20', 1),
('Honda CRV Hybrid Training',        2,  '2025-07-31', '2025-07-18', 2),
('Toyota Prius Advanced Training',   3,  '2025-08-01', '2025-07-19', 3),
('Audi A4 Sim Project',              4,  '2025-08-02', '2025-07-22', 5),
('AMG GT Sim Project',               5,  '2025-08-03', '2025-07-24', 4),

-- 6..10
('Ford Fleet Training',              6,  '2025-08-04', '2025-07-26', 6),
('Chevy Safety Suite',               7,  '2025-08-05', '2025-07-27', 7),
('BMW Performance Tuning',           8,  '2025-08-06', '2025-07-28', 8),
('Nissan EV Driver Program',         9,  '2025-08-07', '2025-07-30', 9),
('Kia EV6 Launch Prep',              10, '2025-08-08', '2025-07-31', 10),

-- 11..14
('Honda Driver Assist Pilot',        2,  '2025-08-10', '2025-08-02', 2),
('Honda EV Training - Phase 2',      2,  '2025-08-12', '2025-08-03', 2),
('Toyota Prius Track Training',      3,  '2025-08-11', '2025-08-01', 3),
('Audi A4 Simulator Upgrade',        4,  '2025-08-12', '2025-08-02', 5);

/* ----------------- PRODUCT CONFIG ----------------- */
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 1,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 1;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 2,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 2;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 3,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 3;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 4,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 4;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 5,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 5;

INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 6,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 1;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 7,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 2;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 8,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 3;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 9,  ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 4;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 10, ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 5;

INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 11, ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 5;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 12, ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 6;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 13, ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 2;
INSERT INTO ProductConfig (ProjectID, ProductOptionSelectionID)
SELECT 14, ProductOptionSelectionID FROM ProductOptionSelection WHERE ProductID = 3;

/* ----------------- PLATFORM CONFIG ----------------- */
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 1,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 1;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 2,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 2;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 3,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 3;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 4,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 4;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 5,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 5;

INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 6,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 1;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 7,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 2;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 8,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 3;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 9,  PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 4;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 10, PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 5;

INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 11, PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 6;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 12, PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 2;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 13, PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 7;
INSERT INTO PlatformConfig (ProjectID, PlatformOptionSelectionID)
SELECT 14, PlatformOptionSelectionID FROM PlatformOptionSelection WHERE PlatformID = 8;

/* ----------------- PRODUCT DOCUMENT ----------------- */
INSERT INTO ProductDocument (ProductID, VersionID) VALUES
(1,1),(1,4),(2,3),(3,4),(4,5),
(6,2),(7,3),(8,6),(9,7),(10,10),
(1,11),(1,12),(6,13),(6,14),(2,15),
(7,16),(7,17),(5,18),(9,19),(3,20),
(8,21),(10,22),(4,23),(10,24),(1,25),
(2,26),(2,27),(3,28),(6,29),(7,30),
(8,31),(10,32),(9,33),(5,34),(4,35),
(8,36),(8,37);

/* ----------------- PLATFORM DOCUMENT ----------------- */
INSERT INTO PlatformDocument (PlatformID, VersionID) VALUES
(1,6),(2,7),(3,8),(4,9),(5,7),
(6,1),(7,4),(8,5),(9,9),(10,2),
(2,11),(5,12),(2,13),(5,14),(3,15),
(7,16),(3,17),(1,18),(6,19),(4,20),
(8,21),(9,22),(10,23),(9,24),(6,25),
(7,26),(7,27),(2,28),(7,29),(8,30),
(10,31),(8,32),(6,33),(9,34),(7,35),
(10,36),(7,37);

/* ----------------- NOTIFICATION ----------------- */
INSERT INTO Notification (NotificationID, EventType, Message, ReceivedBy) VALUES
(1,'TaskAssigned','New task assigned to you',1),
(2,'DocumentUpdated','Document updated',2),
(3,'ProjectStatus','Project status changed',3),
(4,'TaskCompleted','Task completed successfully',4),
(5,'Reminder','Submit your report',5),
(6,'DocumentReviewed','Document has been reviewed',1),
(7,'TaskOverdue','Task overdue',2),
(8,'ProjectCompleted','Project completed',3),
(9,'NewAssignment','You have a new assignment',4),
(10,'Reminder','Submit weekly report',5);

/* ----------------- SECTION ----------------- */
INSERT INTO Section (SectionID, ParentSection, VersionID) VALUES
(1,  NULL, 1),
(2,  NULL, 1),
(3,  1,    2),
(4,  2,    3),
(5,  NULL, 4),
(6,  3,    2),
(7,  NULL, 5),
(8,  7,    5),
(9,  NULL, 9),
(10, 9,    10);

/* ----------------- SECTION ROWS ----------------- */
INSERT INTO SectionRows
(RowID, `Order`, Type, Content, Observation, Conditionality, SectionID, CompanyTestResult, ClientTestResult)
VALUES
(1,  1, 'Text',      'Introduction to product', 'None',           'Mandatory', 1,  'Pass','N/A'),
(2,  2, 'Text',      'Safety instructions',     'Check carefully', 'Mandatory', 1,  'Fail','Fail'),
(3,  1, 'Checklist', 'Verify settings',         'Required',       'Optional',  2,  'Pass','Fail'),
(4,  1, 'Text',      'Installation steps',      'None',           'Mandatory', 3,  'Fail','N/A'),
(5,  2, 'Text',      'Maintenance tips',        'Important',      'Optional',  4,  'N/A','Fail'),
(6,  1, 'Image',     'Diagram of system',       'High quality',   'Mandatory', 5,  'Pass','Pass'),
(7,  2, 'Checklist', 'Final verification',      'Required',       'Mandatory', 5,  'Pass','Fail'),
(8,  1, 'Text',      'Overview of installation','None',           'Mandatory', 6,  'Fail','Pass'),
(9,  2, 'Checklist', 'Verify connections',      'Required',       'Optional',  6,  'Pass','N/A'),
(10, 1, 'Text',      'Safety precautions',      'High priority',  'Mandatory', 7,  'Pass','Pass'),
(11, 2, 'Image',     'Wiring diagram',          'High quality',   'Optional',  7,  'N/A','N/A'),
(12, 1, 'Checklist', 'Final approval',          'Required',       'Mandatory', 8,  'Fail','Fail');

/* ----------------- CHANGE LOG ----------------- */
INSERT INTO ChangeLog (LogID, ChangeType, ChangedBy, RowID) VALUES
(1,'Insert',1,1),
(2,'Update',2,2),
(3,'Delete',3,3),
(4,'Update',4,4),
(5,'Insert',5,5),
(6,'Insert',1,6),
(7,'Update',2,7),
(8,'Insert',9,8),
(9,'Update',10,9),
(10,'Delete',11,12);

/* ----------------- APPROVAL TASK ----------------- */
INSERT INTO ApprovalTask (ApprovalID, `Status`, ApprovalDate, ReviewedBy, VersionID) VALUES
(1,'Pending',  '2025-08-10', 1,  9),
(2,'Approved', '2025-08-11', 2, 10),
(3,'Rejected', '2025-08-12', 3,  7),
(4,'Pending',  '2025-08-13', 4,  6),
(5,'Approved', '2025-08-14', 5,  8),
(6,'Approved', '2025-08-15', 6, 16),
(7,'Rejected', '2025-08-15', 7, 19),
(8,'Pending',  '2025-08-15', 8, 18),
(9,'Approved', '2025-08-16', 9, 15),
(10,'Approved','2025-08-16',10, 16),
(11,'Approved','2025-08-17', 1, 11),
(12,'Approved','2025-08-18', 1, 12),
(13,'Approved','2025-08-18', 1, 13),
(14,'Rejected','2025-08-19', 1, 14),
(15,'Approved','2025-08-17', 2, 15),
(16,'Rejected','2025-08-17', 2, 16),
(17,'Rejected','2025-08-18', 2, 17),
(18,'Rejected','2025-08-17', 3, 18),
(19,'Rejected','2025-08-18', 3, 19),
(20,'Approved','2025-08-18', 3, 20),
(21,'Pending', '2025-08-17', 4, 21),
(22,'Pending', '2025-08-18', 4, 22),
(23,'Approved','2025-08-18', 4, 22),
(24,'Approved','2025-08-17', 5, 23),
(25,'Rejected','2025-08-17', 5, 24),
(26,'Approved','2025-08-18', 5, 25),
(27,'Approved','2025-08-17', 7, 26),
(28,'Rejected','2025-08-18', 7, 27),
(29,'Rejected','2025-08-18', 7, 28),
(30,'Rejected','2025-08-17',11, 29),
(31,'Rejected','2025-08-18',11, 30),
(32,'Rejected','2025-08-19',11, 31);

/* ----------------- APPROVAL COMMENTS ----------------- */
INSERT INTO ApprovalComments (CommentID, `Comment`, ApprovalID) VALUES
(1,'Looks good', 1),
(2,'Please revise section 2', 2),
(3,'Not acceptable', 3),
(4,'Check figures', 4),
(5,'Approved with remarks', 5),
(6,'Meets release criteria', 6),
(7,'Fails AC check under hybrid mode', 7),
(8,'Awaiting additional test evidence', 8),
(9,'Good to publish for releaseID 110', 9),
(10,'Approved after minor edits', 10);
