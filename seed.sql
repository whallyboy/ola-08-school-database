-- Synthetic Nigerian sample data. Run after schema.sql.
INSERT INTO teachers
    (staff_no, first_name, middle_name, last_name, email, phone, hire_date)
VALUES
    ('TCH-001', 'Amina', 'Ngozi', 'Okonkwo', 'amina.okonkwo@school.test', '08000000101', '2018-09-01'),
    ('TCH-002', 'Chidi', NULL, 'Eze', 'chidi.eze@school.test', '08000000102', '2019-01-15'),
    ('TCH-003', 'Ibrahim', 'Musa', 'Bello', 'ibrahim.bello@school.test', '08000000103', '2017-09-04'),
    ('TCH-004', 'Funmi', 'Tola', 'Adeyemi', 'funmi.adeyemi@school.test', '08000000104', '2020-02-10'),
    ('TCH-005', 'Grace', 'Ada', 'Nwosu', 'grace.nwosu@school.test', '08000000105', '2021-09-06'),
    ('TCH-006', 'Yusuf', 'Sani', 'Garba', 'yusuf.garba@school.test', '08000000106', '2016-11-07');

INSERT INTO school_classes (class_name, form_teacher_staff_no)
VALUES
    ('JSS1 A', 'TCH-001'),
    ('JSS2 A', 'TCH-002'),
    ('SSS1 A', 'TCH-003');

INSERT INTO subjects (subject_code, subject_name)
VALUES
    ('ENG', 'English Language'),
    ('MTH', 'Mathematics'),
    ('BIO', 'Biology'),
    ('CHE', 'Chemistry'),
    ('PHY', 'Physics'),
    ('ICT', 'Information and Communication Technology'),
    ('CIV', 'Civic Education'),
    ('GEO', 'Geography');

INSERT INTO terms (academic_year, term_name, start_date, end_date)
VALUES ('2026/2027', 'First Term', '2026-09-07', '2026-12-18');

INSERT INTO guardians (guardian_id, guardian_name, phone)
VALUES
    (1, 'Aisha Yusuf', '08000000001'),
    (2, 'Chuka Okafor', '08000000002'),
    (3, 'Musa Bello', '08000000003'),
    (4, 'Tayo Adeyemi', '08000000004'),
    (5, 'Ifeanyi Nwosu', '08000000005'),
    (6, 'Maryam Suleiman', '08000000006'),
    (7, 'Bode Balogun', '08000000007'),
    (8, 'Amina Garba', '08000000008'),
    (9, 'Chika Eze', '08000000009'),
    (10, 'Eno Ekanem', '08000000010'),
    (11, 'Yinka Adebayo', '08000000011'),
    (12, 'Ibrahim Danladi', '08000000012'),
    (13, 'Rita Nnamdi', '08000000013'),
    (14, 'Hauwa Danjuma', '08000000014'),
    (15, 'Kemi Ojo', '08000000015');

INSERT INTO students
    (admission_no, first_name, middle_name, last_name, date_of_birth, gender)
VALUES
    ('ADM-J1-001', 'Amina', 'Zainab', 'Yusuf', '2013-04-12', 'Female'),
    ('ADM-J1-002', 'Ibrahim', 'Musa', 'Yusuf', '2013-09-05', 'Male'),
    ('ADM-J1-003', 'Chidinma', 'Ada', 'Okafor', '2013-02-18', 'Female'),
    ('ADM-J1-004', 'Chukwuemeka', 'Emeka', 'Okafor', '2013-11-23', 'Male'),
    ('ADM-J1-005', 'Zainab', 'Aisha', 'Bello', '2013-07-14', 'Female'),
    ('ADM-J1-006', 'Abdul', 'Musa', 'Bello', '2013-01-30', 'Male'),
    ('ADM-J1-007', 'Oluwaseun', 'Tobi', 'Adeyemi', '2013-06-08', 'Male'),
    ('ADM-J1-008', 'Omolara', 'Tola', 'Adeyemi', '2013-10-19', 'Female'),
    ('ADM-J1-009', 'Ifeoma', 'Ada', 'Nwosu', '2013-03-26', 'Female'),
    ('ADM-J1-010', 'Kelechi', 'Chima', 'Nwosu', '2013-12-02', 'Male'),
    ('ADM-J2-001', 'Fatima', 'Maryam', 'Suleiman', '2012-05-21', 'Female'),
    ('ADM-J2-002', 'Bashir', 'Sani', 'Suleiman', '2012-08-16', 'Male'),
    ('ADM-J2-003', 'Tunde', 'Babatunde', 'Balogun', '2012-01-11', 'Male'),
    ('ADM-J2-004', 'Damilola', 'Tolu', 'Balogun', '2012-10-07', 'Female'),
    ('ADM-J2-005', 'Halima', 'Amina', 'Garba', '2012-04-03', 'Female'),
    ('ADM-J2-006', 'Sani', 'Yusuf', 'Garba', '2012-09-29', 'Male'),
    ('ADM-J2-007', 'Adaeze', 'Ngozi', 'Eze', '2012-02-14', 'Female'),
    ('ADM-J2-008', 'Obinna', 'Chidi', 'Eze', '2012-11-05', 'Male'),
    ('ADM-J2-009', 'Esther', 'Ini', 'Ekanem', '2012-06-17', 'Female'),
    ('ADM-J2-010', 'Emem', 'Anita', 'Ekanem', '2012-12-20', 'Female'),
    ('ADM-S1-001', 'Daniel', 'Ayo', 'Adebayo', '2010-03-09', 'Male'),
    ('ADM-S1-002', 'Ayomide', 'Tobi', 'Adebayo', '2010-08-24', 'Female'),
    ('ADM-S1-003', 'Hadiza', 'Mariam', 'Ibrahim', '2010-01-16', 'Female'),
    ('ADM-S1-004', 'Yahaya', 'Sule', 'Ibrahim', '2010-07-31', 'Male'),
    ('ADM-S1-005', 'Ngozi', 'Ada', 'Nnamdi', '2010-04-27', 'Female'),
    ('ADM-S1-006', 'Chisom', 'Ifeanyi', 'Nnamdi', '2010-10-12', 'Male'),
    ('ADM-S1-007', 'Samuel', 'John', 'Danjuma', '2010-02-06', 'Male'),
    ('ADM-S1-008', 'Rahila', 'Hauwa', 'Danjuma', '2010-09-18', 'Female'),
    ('ADM-S1-009', 'Favour', 'Kemi', 'Ojo', '2010-05-13', 'Female'),
    ('ADM-S1-010', 'Temitope', 'Dayo', 'Ojo', '2010-12-01', 'Male');

INSERT INTO student_guardians
    (admission_no, guardian_id, relationship_to_student, is_primary)
VALUES
    ('ADM-J1-001', 1, 'Mother', 1), ('ADM-J1-002', 1, 'Mother', 1),
    ('ADM-J1-003', 2, 'Father', 1), ('ADM-J1-004', 2, 'Father', 1),
    ('ADM-J1-005', 3, 'Father', 1), ('ADM-J1-006', 3, 'Father', 1),
    ('ADM-J1-007', 4, 'Father', 1), ('ADM-J1-008', 4, 'Father', 1),
    ('ADM-J1-009', 5, 'Father', 1), ('ADM-J1-010', 5, 'Father', 1),
    ('ADM-J2-001', 6, 'Mother', 1), ('ADM-J2-002', 6, 'Mother', 1),
    ('ADM-J2-003', 7, 'Father', 1), ('ADM-J2-004', 7, 'Father', 1),
    ('ADM-J2-005', 8, 'Mother', 1), ('ADM-J2-006', 8, 'Mother', 1),
    ('ADM-J2-007', 9, 'Mother', 1), ('ADM-J2-008', 9, 'Mother', 1),
    ('ADM-J2-009', 10, 'Mother', 1), ('ADM-J2-010', 10, 'Mother', 1),
    ('ADM-S1-001', 11, 'Father', 1), ('ADM-S1-002', 11, 'Father', 1),
    ('ADM-S1-003', 12, 'Guardian', 1), ('ADM-S1-004', 12, 'Guardian', 1),
    ('ADM-S1-005', 13, 'Mother', 1), ('ADM-S1-006', 13, 'Mother', 1),
    ('ADM-S1-007', 14, 'Guardian', 1), ('ADM-S1-008', 14, 'Guardian', 1),
    ('ADM-S1-009', 15, 'Mother', 1), ('ADM-S1-010', 15, 'Mother', 1);

-- Admission-number prefixes assign ten students to each class.
INSERT INTO student_enrollments (admission_no, term_id, class_id)
SELECT s.admission_no, t.term_id, c.class_id
FROM students AS s
CROSS JOIN terms AS t
INNER JOIN school_classes AS c
    ON c.class_name = CASE
        WHEN s.admission_no LIKE 'ADM-J1-%' THEN 'JSS1 A'
        WHEN s.admission_no LIKE 'ADM-J2-%' THEN 'JSS2 A'
        WHEN s.admission_no LIKE 'ADM-S1-%' THEN 'SSS1 A'
    END
WHERE t.academic_year = '2026/2027'
  AND t.term_name = 'First Term';

-- Every class takes all eight sample subjects; each class-subject-term has one teacher.
INSERT INTO class_subject_offerings
    (class_id, subject_code, term_id, teacher_staff_no)
SELECT c.class_id,
       s.subject_code,
       t.term_id,
       CASE s.subject_code
           WHEN 'ENG' THEN 'TCH-001'
           WHEN 'MTH' THEN 'TCH-002'
           WHEN 'BIO' THEN 'TCH-003'
           WHEN 'CHE' THEN 'TCH-004'
           WHEN 'PHY' THEN 'TCH-004'
           WHEN 'ICT' THEN 'TCH-005'
           WHEN 'CIV' THEN 'TCH-006'
           WHEN 'GEO' THEN 'TCH-006'
       END
FROM school_classes AS c
CROSS JOIN subjects AS s
CROSS JOIN terms AS t
WHERE t.academic_year = '2026/2027'
  AND t.term_name = 'First Term';

-- Generates one result for every enrolled student and every subject offered to their class.
INSERT INTO results (admission_no, term_id, subject_code, ca_score, exam_score)
SELECT se.admission_no,
       se.term_id,
       cso.subject_code,
       CAST(10 + MOD(CRC32(CONCAT(se.admission_no, ':', cso.subject_code)), 31) AS DECIMAL(5,2)),
       CAST(35 + MOD(CRC32(CONCAT('EXAM:', se.admission_no, ':', cso.subject_code)), 26) AS DECIMAL(5,2))
FROM student_enrollments AS se
INNER JOIN class_subject_offerings AS cso
    ON cso.class_id = se.class_id
   AND cso.term_id = se.term_id;

-- Generates five school days of attendance for every student (16-20 November 2026).
INSERT INTO attendance (admission_no, attendance_date, status)
SELECT s.admission_no,
       school_days.attendance_date,
       CASE MOD(CRC32(CONCAT(s.admission_no, DATE_FORMAT(school_days.attendance_date, '%Y-%m-%d'))), 20)
           WHEN 0 THEN 'Absent'
           WHEN 1 THEN 'Late'
           ELSE 'Present'
       END
FROM students AS s
CROSS JOIN (
    SELECT CAST('2026-11-16' AS DATE) AS attendance_date
    UNION ALL SELECT CAST('2026-11-17' AS DATE)
    UNION ALL SELECT CAST('2026-11-18' AS DATE)
    UNION ALL SELECT CAST('2026-11-19' AS DATE)
    UNION ALL SELECT CAST('2026-11-20' AS DATE)
) AS school_days;

-- Expected counts: 3 classes, 8 subjects, 6 teachers, 30 students,
-- 1 term, 240 results, and 150 attendance rows.
SELECT 'classes' AS entity, COUNT(*) AS row_count FROM school_classes
UNION ALL SELECT 'subjects', COUNT(*) FROM subjects
UNION ALL SELECT 'teachers', COUNT(*) FROM teachers
UNION ALL SELECT 'students', COUNT(*) FROM students
UNION ALL SELECT 'terms', COUNT(*) FROM terms
UNION ALL SELECT 'results', COUNT(*) FROM results
UNION ALL SELECT 'attendance', COUNT(*) FROM attendance;
