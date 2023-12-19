DROP DATABASE IF EXISTS coursework;

CREATE DATABASE coursework;

USE coursework;



-- This is the Course table

DROP TABLE IF EXISTS Course;

CREATE TABLE Course (
Crs_Code 	    INT UNSIGNED NOT NULL,
Crs_Title 	    VARCHAR(255) NOT NULL,
Crs_Enrollment  INT UNSIGNED,
PRIMARY KEY (Crs_code));

INSERT INTO Course VALUES 
(100, 'BSc Computer Science', 150),
(101, 'BSc Computer Information Technology', 20),
(200, 'MSc Data Science', 100),
(201, 'MSc Security', 30),
(210, 'MSc Electrical Engineering', 70),
(211, 'BSc Physics', 100),
(300, 'Geography', 80);



-- This is the student table definition

DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
URN         INT UNSIGNED NOT NULL,
Stu_FName 	VARCHAR(255) NOT NULL,
Stu_LName 	VARCHAR(255) NOT NULL,
Stu_DOB 	DATE,
Stu_Phone 	VARCHAR(12),
Crs_Code	INT UNSIGNED NOT NULL,
Stu_Type 	ENUM('UG', 'PG'),
PRIMARY KEY (URN),
FOREIGN KEY (Crs_Code) REFERENCES Course (Crs_Code)
ON DELETE RESTRICT);

INSERT INTO Student VALUES
(612346, 'Pierre', 'Gervais', '2002-03-12', '01483223344', 100, 'UG'),
(612345, 'Sara', 'Khan', '2002-06-20', '01483112233', 100, 'UG'),
(612347, 'Patrick', 'O-Hara', '2001-05-03', '01483334455', 100, 'UG'),
(612348, 'Iyabo', 'Ogunsola', '2002-04-21', '01483445566', 100, 'UG'),
(612349, 'Omar', 'Sharif', '2001-12-29', '01483778899', 100, 'UG'),
(612350, 'Yunli', 'Guo', '2002-06-07', '01483123456', 100, 'UG'),
(612351, 'Costas', 'Spiliotis', '2002-07-02', '01483234567', 100, 'UG'),
(612352, 'Tom', 'Jones', '2001-10-24',  '01483456789', 101, 'UG'),
(612353, 'Simon', 'Larson', '2002-08-23', '01483998877', 101, 'UG'),
(612354, 'Sue', 'Smith', '2002-05-16', '01483776655', 101, 'UG');



-- This is the undergraduate table definition

DROP TABLE IF EXISTS Undergraduate;

CREATE TABLE Undergraduate (
UG_URN 	INT UNSIGNED NOT NULL,
UG_Credits   INT NOT NULL,
CHECK (60 <= UG_Credits <= 150),
PRIMARY KEY (UG_URN),
FOREIGN KEY (UG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);

INSERT INTO Undergraduate VALUES
(612345, 120),
(612346, 90),
(612347, 150),
(612348, 120),
(612349, 120),
(612350, 60),
(612351, 60),
(612352, 90),
(612353, 120),
(612354, 90);



-- This is the postgraduate table definition

DROP TABLE IF EXISTS Postgraduate;

CREATE TABLE Postgraduate (
PG_URN 	INT UNSIGNED NOT NULL,
Thesis  VARCHAR(512) NOT NULL,
PRIMARY KEY (PG_URN),
FOREIGN KEY (PG_URN) REFERENCES Student(URN)
ON DELETE CASCADE);


-- Please add your table definitions below this line.......



-- This is the hobby table definition

DROP TABLE IF EXISTS Hobby;

CREATE TABLE Hobby (
Hobby_Name 	VARCHAR(255) NOT NULL,
Hobby_Type  ENUM('Water Sports', 'Sports',
'Creative Arts', 'Performing Arts', 'Fitness'),
PRIMARY KEY (Hobby_Name));

INSERT INTO Hobby VALUES
('Swimming', 'Water Sports'),
('Water Polo', 'Water Sports'),
('Canoeing', 'Water Sports'),
('Football', 'Sports'),
('Tennis', 'Sports'),
('Rugby', 'Sports'),
('Reading', 'Creative Arts'),
('Ballroom Dancing', 'Performing Arts'),
('Hiking', 'Fitness'),
('Weightlifting', 'Fitness'),
('Climbing', 'Fitness');



-- This is the student hobbies table definition

DROP TABLE IF EXISTS StudentHobbies;

CREATE TABLE StudentHobbies (
URN 	    INT UNSIGNED NOT NULL,
Hobby_Name  VARCHAR(255) NOT NULL,
PRIMARY KEY (URN, Hobby_Name),
FOREIGN KEY (URN) REFERENCES Student(URN) 
ON DELETE CASCADE,
FOREIGN KEY (Hobby_Name) REFERENCES Hobby (Hobby_Name)
ON DELETE CASCADE);

INSERT INTO StudentHobbies VALUES
(612345, 'Weightlifting'),
(612345, 'Swimming'),
(612346, 'Swimming'),
(612346, 'Canoeing'),
(612347, 'Canoeing'),
(612348, 'Tennis'),
(612348, 'Hiking'),
(612349, 'Reading'),
(612350, 'Canoeing'),
(612350, 'Tennis'),
(612350, 'Hiking'),
(612351, 'Ballroom Dancing'),
(612352, 'Tennis'),
(612353, 'Reading'),
(612353, 'Ballroom Dancing'),
(612354, 'Hiking'),
(612354, 'Climbing'),
(612354, 'Weightlifting');



-- This is the society table definition

DROP TABLE IF EXISTS Society;

CREATE TABLE Society (
Society_Name        VARCHAR(255) NOT NULL,
Membership_Cost     INT UNSIGNED NOT NULL,
Facebook_Username   VARCHAR(255),
Society_Type        ENUM('Water Sports', 
'Sports', 'Creative Arts', 'Performing Arts', 'Fitness'),
PRIMARY KEY (Society_Name));

INSERT INTO Society VALUES
('Swimming', 30, NULL, 'Water Sports'),
('Canoeing', 28, 'universityofsurreycanoeclub', 'Water Sports'),
('Football', 25, NULL, 'Sports'),
('Drawing', 25, 'uos_drawing_society', 'Creative Arts'),
('Athletics', 25, 'surrey_does_athletics', 'Sports'),
('Computer Science', 0, 'surrey_compsoc', NULL),
('Running', 22, 'surrey.running.club', 'Fitness');



-- This is the student societies table definition

DROP TABLE IF EXISTS StudentSocieties;

CREATE TABLE StudentSocieties (
URN 	        INT UNSIGNED NOT NULL,
Society_Name    VARCHAR(255) NOT NULL,
PRIMARY KEY (URN, Society_Name),
FOREIGN KEY (URN) REFERENCES Student(URN)
ON DELETE CASCADE,
FOREIGN KEY (Society_Name) REFERENCES Society (Society_Name)
ON DELETE CASCADE);

INSERT INTO StudentSocieties VALUES
(612346, 'Swimming'),
(612346, 'Canoeing'),
(612347, 'Canoeing'),
(612348, 'Football'),
(612348, 'Athletics'),
(612349, 'Drawing'),
(612353, 'Swimming'),
(612354, 'Swimming');



-- This is the Budget table definition

DROP TABLE IF EXISTS Budget;

CREATE TABLE Budget (
Society_Name    VARCHAR(255) NOT NULL,
Budget_Name     ENUM('Own Funds', 'General', 'Transport'),
Budget_Amount   INT UNSIGNED,
PRIMARY KEY (Society_Name, Budget_Name),
FOREIGN KEY (Society_Name) REFERENCES Society (Society_Name));

INSERT INTO Budget VALUES
('Athletics', 'Own Funds', 400),
('Athletics', 'General', 200),
('Athletics', 'Transport', 650),
('Computer Science', 'General', 100),
('Computer Science', 'Transport', 0),
('Drawing', 'General', 300),
('Swimming', 'Own Funds', 500),
('Swimming', 'General', 900),
('Swimming', 'Transport', 300),
('Running', 'Own Funds', 600),
('Running', 'General', 450),
('Canoeing', 'General', 400),
('Canoeing', 'Transport', 650),
('Football', 'General', 750);



-- This is the event table definition

DROP TABLE IF EXISTS Event;

CREATE TABLE Event (
Event_ID            INT UNSIGNED NOT NULL,
Event_Name          VARCHAR(255) NOT NULL,
Location            VARCHAR(255) NOT NULL,
Date_And_Time       DATETIME NOT NULL,
End_Date_And_Time   DATETIME,
Duration            INT UNSIGNED,
PRIMARY KEY (Event_ID));

INSERT INTO Event VALUES
(8064, 'Weekly Pub Meetup', 'Aldershot Rd, Guildford GU3 3AA', '2023-11-14 18:30:00', NULL, NULL),
(8065, 'Climbing Club Crossover', '36 Aldershot Rd, Guildford GU2 8AF', '2023-11-28 12:00:00', '2023-11-28 14:00:00', 120),

(8067, 'Charity bake sale', 'Woodbridge Hill, Guildford GU2 9AA', '2023-12-18 19:00:00', '2023-12-18 21:30:00', 150),
(8068, 'New Years Meetup!', '9 Old Palace Rd, Guildford GU2 7TU', '2024-01-01 00:00:00', NULL, NULL),
(8069, 'Swimming Meetup', 'White Hart Ln, Wood Street Village, Guildford GU3 3DZ', '2024-01-10 18:00:00', NULL, NULL),
(8070, 'Charity Fundraiser', 'University Campus, Guildford GU2 7JQ', '2024-01-15 20:30:00', '2023-11-28 23:00:00', NULL);



-- This is the event dates table definition

DROP TABLE IF EXISTS EventDates;

CREATE TABLE EventDates (
Event_ID        INT UNSIGNED NOT NULL,
Society_Name    VARCHAR(255) NOT NULL,
PRIMARY KEY (Society_Name, Event_ID),
FOREIGN KEY (Society_Name) REFERENCES Society (Society_Name)
ON DELETE CASCADE,
FOREIGN KEY (Event_ID) REFERENCES Event (Event_ID)
ON DELETE CASCADE);

INSERT INTO EventDates VALUES
(8064, 'Football'),
(8065, 'Swimming'),
(8067, 'Canoeing'),
(8068, 'Football'),
(8069, 'Swimming'),
(8070, 'Canoeing');
