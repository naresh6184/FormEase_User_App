use leave_management;

-- creating table 
CREATE TABLE leave_applications (
    application_id VARCHAR(6) PRIMARY KEY,
    approved INT(2) default 0  ,
    name VARCHAR(255) NOT NULL,
    roll_no VARCHAR(20) NOT NULL,
    department VARCHAR(100) NOT NULL,
    hostel_block VARCHAR(50) NOT NULL,
    days INT NOT NULL,
    leave_start_date DATE NOT NULL,
    leave_end_date DATE NOT NULL,
    nature_of_leave VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    address TEXT NOT NULL,
    mobile VARCHAR(15) NOT NULL,
    institute_email VARCHAR(255) default "N/A",
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE students (
    roll_no VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);


select * from leave_applications ;