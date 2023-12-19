const mysql = require("mysql");
const util = require("util");
const express = require('express');
const ejs = require('ejs');
const bodyParser = require('body-parser');

const PORT = 8000;
const DB_HOST = 'localhost';
const DB_USER = 'root';
const DB_NAME = 'coursework';
const DB_PASSWORD = '';
const DB_PORT = 3306;

const app = express();

app.set('view engine', 'ejs');
app.use(express. static('public'));
app.use(bodyParser.urlencoded({extended: false}));

// Set the connection parameters.
var connection = mysql.createConnection({
	host: DB_HOST,
	user: DB_USER,
	password: DB_PASSWORD,
	database: DB_NAME,
	port: DB_PORT,
});

// To use async await with mysql.
connection.query = util.promisify(connection.query).bind(connection);

// Connect to database.
connection.connect(function (err) {
	if (err) {
		console.error("error connecting: " + err.stack);
		return;
	}
	console.log("Connected");
});	

// Load index (home) page.
app.get('/', async (req, res) => {
	const studentCount = await connection.query('SELECT COUNT(*) as count FROM Student');
	const societyCount = await connection.query('SELECT COUNT(*) as count FROM Society');
	
	res.render('index', {
		studentCount: studentCount[0].count,
		societyCount: societyCount[0].count,
	});
});

// View all societies
app.get("/societies", async (req, res) => {
	const societies = await connection.query(
		"SELECT * FROM Society"
	);
	res.render("societies", {
		societies: societies,
	});
});

// View a specific society.
app.get("/societies/view/:id", async (req, res) => {
	const society = await connection.query(
		"SELECT * FROM Society WHERE Society_Name = ?",
		[req.params.id]
	);
	const events = await connection.query(`
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
		AND Society.Society_Name = ?`,
		[req.params.id]
	);
	const eventCount = await connection.query(`
		SELECT COUNT(*) as count 
		FROM Event
		JOIN EventDates
		ON Event.Event_ID = EventDates.Event_ID
		JOIN Society
		ON Society.Society_Name = EventDates.Society_Name
		AND Society.Society_Name = ?`,
		[req.params.id]
	);
	const budgets = await connection.query(`
		SELECT
			Budget_Name,
			Budget_Amount
		FROM Budget
		WHERE Budget.Society_Name = ?`,
		[req.params.id]
	);

	res.render("society-view", {
		society: society[0],
		events: events,
		eventCount: eventCount[0].count,
		budgets: budgets,
		message: '',
	});
});
	
// Edit a specific society.
app.get("/societies/edit/:id", async (req, res) => {
	const society = await connection.query("SELECT * FROM Society WHERE Society_Name = ?",
		[req.params.id]
	);
	const events = await connection.query(`
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
		AND Society.Society_Name = ?`,
		[req.params.id]
	);

	res.render("society-edit", {
		society: society[0],
		events: events,
		message: '',
	});
});

// Update database
app.post("/societies/edit/:id", async (req, res) => {
	const updatedSociety = req.body;
	var msg = '';

	if (!isNaN(updatedSociety.Cost)) {
		msg = 'Society not updated, invalid cost';
	} else {
		await connection.query('UPDATE Society SET ? WHERE Society_Name = ?',
		[updatedSociety, req.params.id]);
		msg = 'Society updated';
	}
	
	const society = await connection.query(
		"SELECT * FROM Society WHERE Society_Name = ?",
		[req.params.id]
	);

	res.render("society-edit", {
		society: society[0],
		message: msg,
	});
})

// View all students
app.get("/students", async (req, res) => {
	const students = await connection.query(
		"SELECT * FROM Student"
	);

	res.render("students", {
		students: students,
		message: '',
	});
});

// View specific student
app.get("/students/view/:id", async (req, res) => {
	const student = await connection.query(
		"SELECT * FROM Student WHERE URN = ?",
		[req.params.id]
	);
	const course = await connection.query(
		`SELECT Course.Crs_Title, Course.Crs_Enrollment 
		FROM Course
		JOIN Student
		ON Course.Crs_Code = Student.Crs_Code
		WHERE Student.URN = ?`,
		[req.params.id]
	);
	const events = await connection.query(
		`SELECT DISTINCT
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
		WHERE StudentSocieties.URN = ?`,
		[req.params.id]
	);
	const eventCount = await connection.query(`
		SELECT COUNT(*) as count 
		FROM Event
		JOIN EventDates
		ON Event.Event_ID = EventDates.Event_ID
		JOIN StudentSocieties
		ON EventDates.Society_Name = StudentSocieties.Society_Name
		WHERE StudentSocieties.URN = ?`,
		[req.params.id]
	);
	const hobbies = await connection.query(`
		SELECT Hobby_Name
		FROM StudentHobbies
		WHERE URN = ?`,
		[req.params.id]
	);
	const recommendedSocieties = await connection.query(`
		SELECT DISTINCT Society_Name 
		FROM Society
		JOIN Hobby
		ON Hobby.Hobby_Type = Society.Society_Type
		WHERE Hobby.Hobby_Type IN 
			(SELECT Hobby_Type
			FROM Hobby
			JOIN StudentHobbies
			ON StudentHobbies.Hobby_Name = Hobby.Hobby_Name
			WHERE StudentHobbies.URN = ?)`,
		[req.params.id]
	);
	const societies = await connection.query(`
		SELECT Society.Society_Name 
		FROM Society
		JOIN StudentSocieties
		ON Society.Society_Name = StudentSocieties.Society_Name
		WHERE StudentSocieties.URN = ?`,
		[req.params.id]
	);

	res.render("student-view", {
		student: student[0],
		course: course[0],
		events: events,
		eventCount: eventCount[0].count,
		hobbies: hobbies,
		recommendedSocieties: recommendedSocieties,
		societies: societies,
		message: '',
	});
});
	
// Edit specific student
app.get("/students/edit/:id", async (req, res) => {
	const student = await connection.query(
		"SELECT * FROM Student WHERE URN = ?",
		[req.params.id]
	);
	const courses = await connection.query(
		"SELECT Course.Crs_Code, Course.Crs_Title FROM Course"
	);

	res.render("student-edit", {
		student: student[0],
		courses: courses,
		message: '',
	});
});

app.post("/students/edit/:id", async (req, res) => {
	
	const updatedStudent = req.body;
	var msg = '';

	if (isNaN(updatedStudent.Stu_Phone) || (updatedStudent.Stu_Phone.length != 11)) {
		msg = 'Student not updated, invalid phone number';
	} else {
		await connection.query('UPDATE STUDENT SET ? WHERE URN = ?',
		[updatedStudent, req.params.id]);
		msg = 'Student updated';
	}
	
	const student = await connection.query(
		"SELECT * FROM Student WHERE URN = ?",
		[req.params.id]
	);
	const courses = await connection.query(
		"SELECT Course.Crs_Code, Course.Crs_Title FROM Course"
	);

	res.render("student-edit", {
		student: student[0],
		courses: courses,
		message: msg,
	});
})

// Delete a specific student
app.get("/students/delete/:id", async (req, res) => {
	
	var msg = '';
	
	try{
		await connection.query(
			"DELETE FROM Student WHERE URN = ?",
			[req.params.id]);
		msg = 'Deleted student'
	} catch (err) {
		msg = 'Could not delete student';
	}
	
	const students = await connection.query(
		"SELECT * FROM Student"
	);

	res.render("students", {
		students: students,
		message: msg,
	});
});

// Edit specific student
app.get("/students/new-student", async (req, res) => {
	const courses = await connection.query(
		"SELECT Course.Crs_Code, Course.Crs_Title FROM Course"
	);

	res.render("student-new", {
		courses: courses,
		message: '',
	});
});

app.post("/students/new-student", async (req, res) => {
	
	const newStudent = req.body;
	var msg = '';

	const URNs = await connection.query(
		"SELECT URN FROM Student"
	);

	// Majority of validation is done front end within student-new.ejs
	if (isNaN(newStudent.URN) && !URNs.includes(newStudent.URN)) {
		msg = 'Student not created, invalid URN';
	} else if (isNaN(newStudent.Stu_Phone) || (newStudent.Stu_Phone.length != 11)) {
		msg = 'Student not created, invalid phone number';
	} else {
		try {
			await connection.query(`INSERT INTO Student VALUES (`+newStudent.URN+`, '`
				+newStudent.Stu_FName+`', '`+newStudent.Stu_LName+`', '`+newStudent.Stu_DOB+`', '`
				+newStudent.Stu_Phone+`', `+newStudent.Crs_Code+`, '`+newStudent.Stu_Type+`')`);
			msg = 'Student created';
		} catch {
			msg = 'That URN already exists!';
		}
	}
	
	const courses = await connection.query(
		"SELECT Course.Crs_Code, Course.Crs_Title FROM Course"
	);

	res.render("student-new", {
		courses: courses,
		message: msg,
	});
})


// Ensure app is listening
app.listen(PORT, () => {
	console.log(`Example app listening at http://localhost:${PORT}`);
});

