CREATE DATABASE IF NOT EXISTS educare_school;
USE educare_school;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS conflicts, timetable, class_subjects, teacher_availability, teacher_subjects, sections, classes, subjects, classrooms, teachers, school_settings, users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(150) UNIQUE NOT NULL,
  name VARCHAR(120) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(30) DEFAULT 'Admin',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE teachers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teacher_id VARCHAR(40) UNIQUE NOT NULL,
  employee_id VARCHAR(40) UNIQUE NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  phone VARCHAR(25),
  gender VARCHAR(20),
  qualification VARCHAR(120),
  max_daily_periods INT DEFAULT 6,
  max_weekly_periods INT DEFAULT 30,
  status ENUM('Active','Inactive','On Leave') DEFAULT 'Active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE classes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  class_number INT UNIQUE NOT NULL,
  class_name VARCHAR(80) NOT NULL,
  academic_year VARCHAR(20) NOT NULL,
  class_teacher_id INT NULL,
  total_sections INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (class_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

CREATE TABLE classrooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_number VARCHAR(30) UNIQUE NOT NULL,
  building VARCHAR(80),
  floor INT,
  capacity INT NOT NULL,
  room_type VARCHAR(50) DEFAULT 'Normal Classroom',
  facilities VARCHAR(255),
  status ENUM('Available','Unavailable') DEFAULT 'Available',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE sections (
  id INT AUTO_INCREMENT PRIMARY KEY,
  section_name VARCHAR(30) UNIQUE NOT NULL,
  class_id INT NOT NULL,
  academic_year VARCHAR(20) NOT NULL,
  student_count INT NOT NULL,
  class_teacher_id INT NULL,
  classroom_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (class_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE SET NULL
);

CREATE TABLE subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  subject_code VARCHAR(30) UNIQUE NOT NULL,
  subject_name VARCHAR(120) NOT NULL,
  class_id INT NULL,
  weekly_periods_required INT DEFAULT 3,
  subject_type ENUM('Academic','Practical','Activity','Sports','Language') DEFAULT 'Academic',
  preferred_period INT NULL,
  required_room_type VARCHAR(50) DEFAULT 'Normal Classroom',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL
);

CREATE TABLE teacher_subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teacher_id INT NOT NULL,
  subject_id INT NOT NULL,
  class_id INT NULL,
  section_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_teacher_assignment (teacher_id, subject_id, class_id, section_id),
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
);

CREATE TABLE teacher_availability (
  id INT AUTO_INCREMENT PRIMARY KEY,
  teacher_id INT NOT NULL,
  day VARCHAR(20) NOT NULL,
  period_number INT NOT NULL,
  status ENUM('AVAILABLE','UNAVAILABLE','PREFERRED') DEFAULT 'AVAILABLE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_teacher_period (teacher_id, day, period_number),
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);

CREATE TABLE class_subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  section_id INT NOT NULL,
  subject_id INT NOT NULL,
  teacher_id INT NULL,
  periods_per_week INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY unique_section_subject (section_id, subject_id),
  FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);

CREATE TABLE timetable (
  id INT AUTO_INCREMENT PRIMARY KEY,
  section_id INT NOT NULL,
  subject_id INT NOT NULL,
  teacher_id INT NOT NULL,
  classroom_id INT NOT NULL,
  day VARCHAR(20) NOT NULL,
  period_number INT NOT NULL,
  start_time VARCHAR(20),
  end_time VARCHAR(20),
  status ENUM('Draft','Published') DEFAULT 'Draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX timetable_slot (day, period_number),
  FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE
);

CREATE TABLE conflicts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(80) NOT NULL,
  severity VARCHAR(20) NOT NULL,
  description TEXT,
  teacher_id INT NULL,
  classroom_id INT NULL,
  section_id INT NULL,
  day VARCHAR(20),
  period_number INT,
  status VARCHAR(30) DEFAULT 'Open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
  FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE SET NULL,
  FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE SET NULL
);

CREATE TABLE school_settings (
  id INT PRIMARY KEY DEFAULT 1,
  school_name VARCHAR(150) NOT NULL,
  school_address VARCHAR(255),
  academic_year VARCHAR(20) NOT NULL,
  principal_name VARCHAR(120),
  school_start_time VARCHAR(20) DEFAULT '08:30',
  school_end_time VARCHAR(20) DEFAULT '15:30',
  working_days JSON NOT NULL,
  periods JSON NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
