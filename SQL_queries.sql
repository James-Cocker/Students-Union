USE coursework;

-- 5.1: See Query 1
-- 5.2: See Query 2
-- 5.3: See Query 3
-- 5.4: See Query 3


-- Query 1 displays the total budget amount going into a club. This is ordered
-- high to low in terms of this budget total. This could be used to see all the 
-- clubs with a high budget, which could be better spent elsewhere.

SELECT Society_Name, Budget_Amount
FROM Budget
GROUP BY Society_Name
ORDER BY SUM(Budget_Amount);


-- Query 2 deletes any courses where no students are enrolled.
DELETE FROM Course
WHERE Crs_Code NOT IN (SELECT Crs_Code FROM Student);


-- Query 3 displays all event information from every society, along with 
-- the corresponding society's facebook username. This would be used to 
-- get the event's facebook handle so that the students can find out more 
-- information on the event (such as the people attending).
SELECT
    Event.Event_Name,
    Event.Location,
    Event.Date_And_Time,
    Society.Facebook_Username
FROM Event
JOIN EventDates
  ON Event.Event_ID = EventDates.Event_ID
JOIN Society
  ON Society.Society_Name = EventDates.Society_Name;


-- If you want to do some more queries as the extra challenge task you can include them here

-- Query 4 selects events for the swimming society.
SELECT
  Event.Event_Name,
  Event.Location,
  Event.Date_And_Time,
  Event.Duration
FROM Event
JOIN EventDates
ON Event.Event_ID = EventDates.Event_ID
JOIN Society
ON Society.Society_Name = EventDates.Society_Name
AND Society.Society_Name = 'Swimming';

-- Query 5 Selects the number of events for the swimming society.
SELECT COUNT(*) as count 
FROM Event
JOIN EventDates
ON Event.Event_ID = EventDates.Event_ID
JOIN Society
ON Society.Society_Name = EventDates.Society_Name
AND Society.Society_Name = 'Swimming';

-- Query 6 returns the events for a particular student, given 
-- the societies they are a part of. This must be distinct as
-- there can be crossover events between clubs, and there is
-- a chance the student will be a part of both societies.
SELECT DISTINCT
  StudentSocieties.Society_Name,
  Event.Event_Name,
  Event.Location,
  Event.Date_And_Time,
  Event.Duration
FROM Event
JOIN EventDates
ON Event.Event_ID = EventDates.Event_ID
JOIN StudentSocieties
ON EventDates.Society_Name = StudentSocieties.Society_Name
WHERE StudentSocieties.URN = 612346;

-- Query 9 counts the number of the above events
SELECT COUNT(*) as count 
FROM Event
JOIN EventDates
ON Event.Event_ID = EventDates.Event_ID
JOIN StudentSocieties
ON EventDates.Society_Name = StudentSocieties.Society_Name
WHERE StudentSocieties.URN = 612346;

-- Query 10 selects a set of recommended societies for a student
-- depending on their hobbies. it does this through matching their
-- 'types'. For example, if a studet does swimming, that would count 
-- as a water sport, so canoeing would be recommended to them.
SELECT DISTINCT Society_Name 
FROM Society
JOIN Hobby
ON Hobby.Hobby_Type = Society.Society_Type
WHERE Hobby.Hobby_Type IN 
  (SELECT Hobby_Type
  FROM Hobby
  JOIN StudentHobbies
  ON StudentHobbies.Hobby_Name = Hobby.Hobby_Name
  WHERE StudentHobbies.URN = 612346);

-- Query 11
DELETE FROM Student WHERE URN = 612346;
