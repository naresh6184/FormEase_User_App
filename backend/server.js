const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");
const crypto = require("crypto");

const app = express();
app.use(cors());
app.use(express.json());

// Database configuration
const db = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "Naresh@6184",
  database: "leave_management",
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
})

// Generate unique 6-character ID
const generateID = () => crypto.randomBytes(3).toString('hex').toLowerCase();

app.post("/submit-application", async (req, res) => {
  try {
    const { name, roll_no, department, hostel_block, days,
      leave_start_date, leave_end_date, nature_of_leave,
      reason, address, mobile, institute_email } = req.body;  // Added institute_email

    if (!institute_email) {
      return res.status(400).json({ success: false, error: "Missing institute_email" });
    }

    // Generate unique application ID
    let applicationId;
    let isUnique = false;

    while (!isUnique) {
      applicationId = generateID();
      const [rows] = await db.query(
        "SELECT application_id FROM leave_applications WHERE application_id = ?",
        [applicationId]
      );
      if (rows.length === 0) isUnique = true;
    }

    // Insert into database (Added institute_email)
    const [result] = await db.query(
      `INSERT INTO leave_applications (
        application_id, name, roll_no, department, hostel_block,
        days, leave_start_date, leave_end_date, nature_of_leave,
        reason, address, mobile, institute_email
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [applicationId, name, roll_no, department, hostel_block, days,
       leave_start_date, leave_end_date, nature_of_leave, reason,
       address, mobile, institute_email]  // Added institute_email
    );

    res.json({
      success: true,
      application_id: applicationId
    });

  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});
app.get("/get-student-name", async (req, res) => {
  try {
    const { roll_no } = req.query;

    if (!roll_no) {
      return res.status(400).json({ success: false, error: "Missing roll number" });
    }

    const [rows] = await db.query(
      "SELECT name FROM students WHERE roll_no = ? LIMIT 1",
      [roll_no]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, error: "Student not found" });
    }

    res.json({ success: true, name: rows[0].name });

  } catch (error) {
    console.error("Error fetching student name:", error);
    res.status(500).json({ success: false, error: "Internal server error" });
  }
});
