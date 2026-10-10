USE educare_school;

INSERT INTO users (email, name, password_hash, role)
VALUES ('admin@educare.com', 'EDUCARE Admin', '$2b$10$HCmjbqcD9l97.H99mJwT3uGp3E7LPj2L5ETKsKxozlr8FZ.BApY6W', 'Admin')
ON DUPLICATE KEY UPDATE name = VALUES(name), password_hash = VALUES(password_hash), role = VALUES(role);

INSERT INTO teachers (teacher_id, employee_id, full_name, email, phone, gender, qualification, max_daily_periods, max_weekly_periods, status)
VALUES
  ('TCH-001', 'EMP-1001', 'Anita Sharma', 'anita.sharma@educare.com', '9876543210', 'Female', 'M.A. English', 6, 30, 'Active'),
  ('TCH-002', 'EMP-1002', 'Ravi Kumar', 'ravi.kumar@educare.com', '9876543211', 'Male', 'M.Sc. Mathematics', 6, 30, 'Active'),
  ('TCH-003', 'EMP-1003', 'Priya Reddy', 'priya.reddy@educare.com', '9876543212', 'Female', 'M.Sc. Physics', 6, 30, 'Active'),
  ('TCH-004', 'EMP-1004', 'Suresh Rao', 'suresh.rao@educare.com', '9876543213', 'Male', 'B.Ed. Social Studies', 5, 24, 'Active'),
  ('TCH-005', 'EMP-1005', 'Lakshmi Devi', 'lakshmi.devi@educare.com', '9876543214', 'Female', 'M.A. Hindi', 5, 24, 'Active'),
  ('TCH-006', 'EMP-1006', 'Arun Kumar', 'arun.kumar@educare.com', '9876543215', 'Male', 'B.Tech. Computer Science', 6, 30, 'Active'),
  ('TCH-007', 'EMP-1007', 'Sneha Patel', 'sneha.patel@educare.com', '9876543216', 'Female', 'M.A. English', 5, 24, 'Active'),
  ('TCH-008', 'EMP-1008', 'Meena Reddy', 'meena.reddy@educare.com', '9876543217', 'Female', 'M.Sc. Biology', 6, 30, 'Active'),
  ('TCH-009', 'EMP-1009', 'Kiran Kumar', 'kiran.kumar@educare.com', '9876543218', 'Male', 'M.P.Ed.', 5, 20, 'Active'),
  ('TCH-010', 'EMP-1010', 'Swathi Rao', 'swathi.rao@educare.com', '9876543219', 'Female', 'B.A. Arts', 4, 18, 'Active')
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name), email = VALUES(email), phone = VALUES(phone), qualification = VALUES(qualification), status = VALUES(status);

INSERT INTO classes (class_number, class_name, academic_year, total_sections)
VALUES
  (1, 'Class 1', '2026-2027', 2),
  (2, 'Class 2', '2026-2027', 2),
  (3, 'Class 3', '2026-2027', 1),
  (4, 'Class 4', '2026-2027', 1),
  (5, 'Class 5', '2026-2027', 1),
  (6, 'Class 6', '2026-2027', 1),
  (7, 'Class 7', '2026-2027', 1),
  (8, 'Class 8', '2026-2027', 2),
  (9, 'Class 9', '2026-2027', 1),
  (10, 'Class 10', '2026-2027', 1)
ON DUPLICATE KEY UPDATE class_name = VALUES(class_name), academic_year = VALUES(academic_year), total_sections = VALUES(total_sections);

INSERT INTO classrooms (room_number, building, floor, capacity, room_type, facilities, status)
VALUES
  ('101', 'Main Block', 1, 40, 'Normal Classroom', 'Smart Board, Projector, AC', 'Available'),
  ('102', 'Main Block', 1, 40, 'Normal Classroom', 'Smart Board, Projector', 'Available'),
  ('103', 'Main Block', 1, 45, 'Normal Classroom', 'Smart Board, Projector', 'Available'),
  ('201', 'Main Block', 2, 42, 'Normal Classroom', 'Smart Board, Projector, AC', 'Available'),
  ('202', 'Main Block', 2, 44, 'Normal Classroom', 'Projector, AC', 'Available'),
  ('203', 'Main Block', 2, 46, 'Normal Classroom', 'Smart Board', 'Available'),
  ('204', 'Main Block', 2, 48, 'Normal Classroom', 'Projector, AC', 'Available'),
  ('205', 'Main Block', 2, 50, 'Normal Classroom', 'Smart Board, Projector', 'Available'),
  ('301', 'Science Wing', 3, 36, 'Science Lab', 'Lab Tables, Smart Board, AC', 'Available'),
  ('302', 'Science Wing', 3, 36, 'Science Lab', 'Lab Tables, Projector', 'Available'),
  ('401', 'IT Block', 4, 30, 'Computer Lab', 'Computers, Smart Board, AC', 'Available'),
  ('402', 'IT Block', 4, 35, 'Computer Lab', 'Computers, Projector, AC', 'Available'),
  ('501', 'Arts Wing', 5, 25, 'Art Room', 'Art Tables, Storage, AC', 'Available'),
  ('502', 'Music Wing', 5, 25, 'Music Room', 'Audio System, Instruments', 'Available'),
  ('601', 'Sports Block', 6, 60, 'Sports Ground', 'Track, Equipment', 'Available')
ON DUPLICATE KEY UPDATE building = VALUES(building), floor = VALUES(floor), capacity = VALUES(capacity), room_type = VALUES(room_type), facilities = VALUES(facilities), status = VALUES(status);

INSERT INTO sections (section_name, class_id, academic_year, student_count, classroom_id)
VALUES
  ('1-A', 1, '2026-2027', 36, 1),
  ('1-B', 1, '2026-2027', 34, 2),
  ('2-A', 2, '2026-2027', 38, 3),
  ('2-B', 2, '2026-2027', 35, 4),
  ('3-A', 3, '2026-2027', 39, 5),
  ('4-A', 4, '2026-2027', 41, 6),
  ('5-A', 5, '2026-2027', 42, 7),
  ('6-A', 6, '2026-2027', 43, 8),
  ('7-A', 7, '2026-2027', 44, 1),
  ('8-A', 8, '2026-2027', 42, 9),
  ('8-B', 8, '2026-2027', 39, 10),
  ('9-A', 9, '2026-2027', 44, 11),
  ('10-A', 10, '2026-2027', 46, 12)
ON DUPLICATE KEY UPDATE academic_year = VALUES(academic_year), student_count = VALUES(student_count), classroom_id = VALUES(classroom_id);

INSERT INTO subjects (subject_code, subject_name, class_id, weekly_periods_required, subject_type, preferred_period, required_room_type)
VALUES
  ('ENG-1', 'English', 1, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-1', 'Mathematics', 1, 5, 'Academic', 1, 'Normal Classroom'),
  ('SCI-1', 'Science', 1, 3, 'Academic', 3, 'Normal Classroom'),
  ('HIN-1', 'Hindi', 1, 4, 'Language', 4, 'Normal Classroom'),
  ('PE-1', 'Physical Education', 1, 2, 'Sports', 5, 'Sports Ground'),
  ('ART-1', 'Art', 1, 1, 'Activity', 6, 'Art Room'),
  ('ENG-2', 'English', 2, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-2', 'Mathematics', 2, 5, 'Academic', 1, 'Normal Classroom'),
  ('SCI-2', 'Science', 2, 3, 'Academic', 3, 'Normal Classroom'),
  ('HIN-2', 'Hindi', 2, 4, 'Language', 4, 'Normal Classroom'),
  ('PE-2', 'Physical Education', 2, 2, 'Sports', 5, 'Sports Ground'),
  ('ENG-3', 'English', 3, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-3', 'Mathematics', 3, 5, 'Academic', 1, 'Normal Classroom'),
  ('SCI-3', 'Science', 3, 4, 'Academic', 3, 'Normal Classroom'),
  ('SOC-3', 'Social Studies', 3, 4, 'Academic', 4, 'Normal Classroom'),
  ('ENG-4', 'English', 4, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-4', 'Mathematics', 4, 5, 'Academic', 1, 'Normal Classroom'),
  ('SCI-4', 'Science', 4, 4, 'Academic', 3, 'Normal Classroom'),
  ('SOC-4', 'Social Studies', 4, 4, 'Academic', 4, 'Normal Classroom'),
  ('ENG-5', 'English', 5, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-5', 'Mathematics', 5, 5, 'Academic', 1, 'Normal Classroom'),
  ('SCI-5', 'Science', 5, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-5', 'Social Studies', 5, 4, 'Academic', 4, 'Normal Classroom'),
  ('COMP-5', 'Computer Science', 5, 2, 'Practical', 7, 'Computer Lab'),
  ('ENG-6', 'English', 6, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-6', 'Mathematics', 6, 6, 'Academic', 1, 'Normal Classroom'),
  ('SCI-6', 'Science', 6, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-6', 'Social Studies', 6, 5, 'Academic', 4, 'Normal Classroom'),
  ('HIN-6', 'Hindi', 6, 4, 'Language', 5, 'Normal Classroom'),
  ('ENG-7', 'English', 7, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-7', 'Mathematics', 7, 6, 'Academic', 1, 'Normal Classroom'),
  ('SCI-7', 'Science', 7, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-7', 'Social Studies', 7, 5, 'Academic', 4, 'Normal Classroom'),
  ('HIN-7', 'Hindi', 7, 4, 'Language', 5, 'Normal Classroom'),
  ('ENG-8', 'English', 8, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-8', 'Mathematics', 8, 6, 'Academic', 1, 'Normal Classroom'),
  ('SCI-8', 'Science', 8, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-8', 'Social Studies', 8, 5, 'Academic', 4, 'Normal Classroom'),
  ('HIN-8', 'Hindi', 8, 4, 'Language', 5, 'Normal Classroom'),
  ('COMP-8', 'Computer Science', 8, 2, 'Practical', 7, 'Computer Lab'),
  ('PE-8', 'Physical Education', 8, 2, 'Sports', 5, 'Sports Ground'),
  ('ENG-9', 'English', 9, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-9', 'Mathematics', 9, 6, 'Academic', 1, 'Normal Classroom'),
  ('SCI-9', 'Science', 9, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-9', 'Social Studies', 9, 5, 'Academic', 4, 'Normal Classroom'),
  ('HIN-9', 'Hindi', 9, 4, 'Language', 5, 'Normal Classroom'),
  ('COMP-9', 'Computer Science', 9, 3, 'Practical', 7, 'Computer Lab'),
  ('ENG-10', 'English', 10, 5, 'Academic', 2, 'Normal Classroom'),
  ('MAT-10', 'Mathematics', 10, 6, 'Academic', 1, 'Normal Classroom'),
  ('SCI-10', 'Science', 10, 5, 'Academic', 3, 'Normal Classroom'),
  ('SOC-10', 'Social Studies', 10, 5, 'Academic', 4, 'Normal Classroom'),
  ('HIN-10', 'Hindi', 10, 4, 'Language', 5, 'Normal Classroom'),
  ('COMP-10', 'Computer Science', 10, 3, 'Practical', 7, 'Computer Lab')
ON DUPLICATE KEY UPDATE class_id = VALUES(class_id), weekly_periods_required = VALUES(weekly_periods_required), subject_type = VALUES(subject_type), required_room_type = VALUES(required_room_type);

INSERT INTO teacher_subjects (teacher_id, subject_id, class_id, section_id)
SELECT t.id, s.id, s.class_id, NULL
FROM teachers t
JOIN subjects s ON s.subject_name IN ('English', 'Mathematics', 'Science', 'Social Studies', 'Hindi', 'Computer Science')
WHERE t.full_name IN ('Anita Sharma', 'Ravi Kumar', 'Priya Reddy', 'Suresh Rao', 'Lakshmi Devi', 'Arun Kumar', 'Sneha Patel', 'Meena Reddy')
ON DUPLICATE KEY UPDATE class_id = VALUES(class_id), section_id = VALUES(section_id);

INSERT INTO school_settings (id, school_name, school_address, academic_year, principal_name, school_start_time, school_end_time, working_days, periods)
VALUES (
  1,
  'EDUCARE HIGH SCHOOL',
  '12 Greenfield Avenue, Hyderabad',
  '2026-2027',
  'Mrs. Kavya Nair',
  '08:30',
  '15:30',
  JSON_ARRAY('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'),
  JSON_ARRAY(
    JSON_OBJECT('number',1,'label','P1','start','08:30 AM','end','09:15 AM'),
    JSON_OBJECT('number',2,'label','P2','start','09:15 AM','end','10:00 AM'),
    JSON_OBJECT('number',3,'label','P3','start','10:00 AM','end','10:45 AM'),
    JSON_OBJECT('number',4,'label','P4','start','11:00 AM','end','11:45 AM'),
    JSON_OBJECT('number',5,'label','P5','start','11:45 AM','end','12:30 PM'),
    JSON_OBJECT('number',6,'label','P6','start','01:15 PM','end','02:00 PM'),
    JSON_OBJECT('number',7,'label','P7','start','02:00 PM','end','02:45 PM'),
    JSON_OBJECT('number',8,'label','P8','start','02:45 PM','end','03:30 PM')
  )
)
ON DUPLICATE KEY UPDATE school_name = VALUES(school_name), academic_year = VALUES(academic_year), principal_name = VALUES(principal_name), school_start_time = VALUES(school_start_time), school_end_time = VALUES(school_end_time), working_days = VALUES(working_days), periods = VALUES(periods);

INSERT INTO teacher_availability (teacher_id, day, period_number, status)
SELECT t.id, d.day, p.period_number, 'AVAILABLE'
FROM teachers t
CROSS JOIN (SELECT 'Monday' AS day UNION ALL SELECT 'Tuesday' UNION ALL SELECT 'Wednesday' UNION ALL SELECT 'Thursday' UNION ALL SELECT 'Friday' UNION ALL SELECT 'Saturday') d
CROSS JOIN (SELECT 1 AS period_number UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8) p
ON DUPLICATE KEY UPDATE status = VALUES(status);

INSERT INTO class_subjects (section_id, subject_id, teacher_id, periods_per_week)
SELECT s.id, sub.id, ts.teacher_id, sub.weekly_periods_required
FROM sections s
JOIN classes c ON c.id = s.class_id
JOIN subjects sub ON sub.class_id = c.id
LEFT JOIN teacher_subjects ts ON ts.subject_id = sub.id AND ts.class_id = c.id AND ts.section_id IS NULL
ON DUPLICATE KEY UPDATE teacher_id = VALUES(teacher_id), periods_per_week = VALUES(periods_per_week);
