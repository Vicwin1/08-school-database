-- Sample data for schema.sql. Run schema.sql first.
-- All names, contact details, scores, and dates are fictional examples.

INSERT INTO teacher
    (teacher_id, staff_number, first_name, middle_name, last_name, email, phone, hire_date)
VALUES
    (1, 'STF-001', 'Adaeze', 'Ngozi', 'Okafor', 'adaeze.okafor@example.test', '0800-000-0101', '2018-09-03'),
    (2, 'STF-002', 'Chinedu', NULL, 'Eze', 'chinedu.eze@example.test', '0800-000-0102', '2019-01-14'),
    (3, 'STF-003', 'Amina', 'Bello', 'Yusuf', 'amina.yusuf@example.test', '0800-000-0103', '2017-09-11'),
    (4, 'STF-004', 'Tunde', NULL, 'Adebayo', 'tunde.adebayo@example.test', '0800-000-0104', '2020-04-06'),
    (5, 'STF-005', 'Ngozi', 'Ifeoma', 'Nwosu', 'ngozi.nwosu@example.test', '0800-000-0105', '2021-09-06'),
    (6, 'STF-006', 'Bashir', NULL, 'Mohammed', 'bashir.mohammed@example.test', '0800-000-0106', '2016-02-15');

INSERT INTO school_class (class_id, class_name, form_teacher_id)
VALUES
    (1, 'JSS1 A', 1),
    (2, 'JSS1 B', 2),
    (3, 'JSS2 A', 3);

INSERT INTO student
    (student_id, admission_number, first_name, middle_name, last_name,
     date_of_birth, gender, guardian_name, guardian_phone, class_id)
VALUES
    (1,  'SWD/26/001', 'Chiamaka', 'Ada', 'Okeke',       '2013-02-14', 'Female', 'Mr. Emeka Okeke',       '0800-100-0001', 1),
    (2,  'SWD/26/002', 'Oluwaseun', NULL, 'Akinyemi',    '2013-05-22', 'Male',   'Mrs. Bola Akinyemi',    '0800-100-0002', 1),
    (3,  'SWD/26/003', 'Fatima', 'Zainab', 'Abubakar',   '2012-11-09', 'Female', 'Mr. Musa Abubakar',     '0800-100-0003', 1),
    (4,  'SWD/26/004', 'Obinna', NULL, 'Ibe',            '2013-08-03', 'Male',   'Mrs. Ifeoma Ibe',       '0800-100-0004', 1),
    (5,  'SWD/26/005', 'Temiloluwa', 'Grace', 'Ojo',     '2013-01-28', 'Female', 'Mr. Segun Ojo',         '0800-100-0005', 1),
    (6,  'SWD/26/006', 'Ibrahim', NULL, 'Sani',          '2012-12-17', 'Male',   'Mrs. Aisha Sani',       '0800-100-0006', 1),
    (7,  'SWD/26/007', 'Chisom', 'Joy', 'Ezeani',        '2013-04-11', 'Female', 'Mr. Nnamdi Ezeani',     '0800-100-0007', 1),
    (8,  'SWD/26/008', 'Damilare', NULL, 'Bamidele',     '2013-07-30', 'Male',   'Mrs. Kemi Bamidele',    '0800-100-0008', 1),
    (9,  'SWD/26/009', 'Mariam', 'Aisha', 'Lawal',       '2012-10-06', 'Female', 'Mr. Abdul Lawal',       '0800-100-0009', 1),
    (10, 'SWD/26/010', 'Kelechi', NULL, 'Onyema',        '2013-03-19', 'Male',   'Mrs. Amaka Onyema',     '0800-100-0010', 1),
    (11, 'SWD/26/011', 'Ayomide', 'Tobi', 'Adekunle',    '2013-06-08', 'Male',   'Mrs. Ronke Adekunle',   '0800-100-0011', 2),
    (12, 'SWD/26/012', 'Nneka', NULL, 'Umeh',            '2013-09-25', 'Female', 'Mr. Patrick Umeh',      '0800-100-0012', 2),
    (13, 'SWD/26/013', 'Sadiq', 'Musa', 'Garba',         '2012-12-02', 'Male',   'Mrs. Hadiza Garba',     '0800-100-0013', 2),
    (14, 'SWD/26/014', 'Efe', NULL, 'Oghene',            '2013-02-21', 'Female', 'Mr. Ejiro Oghene',      '0800-100-0014', 2),
    (15, 'SWD/26/015', 'Samuel', 'David', 'Nwachukwu',   '2013-05-04', 'Male',   'Mrs. Grace Nwachukwu',  '0800-100-0015', 2),
    (16, 'SWD/26/016', 'Zainab', NULL, 'Abdullahi',      '2012-08-16', 'Female', 'Mr. Ismail Abdullahi',  '0800-100-0016', 2),
    (17, 'SWD/26/017', 'Fiyinfoluwa', 'Mide', 'Afolabi', '2013-11-12', 'Female', 'Mrs. Yetunde Afolabi',  '0800-100-0017', 2),
    (18, 'SWD/26/018', 'Chukwudi', NULL, 'Nnamani',      '2013-01-07', 'Male',   'Mr. Joseph Nnamani',    '0800-100-0018', 2),
    (19, 'SWD/26/019', 'Hauwa', 'Maryam', 'Bello',       '2012-10-29', 'Female', 'Mrs. Rabi Bello',       '0800-100-0019', 2),
    (20, 'SWD/26/020', 'Emmanuel', NULL, 'Ogunleye',     '2013-04-02', 'Male',   'Mr. Kunle Ogunleye',    '0800-100-0020', 2),
    (21, 'SWD/26/021', 'Amarachi', 'Chioma', 'Ekwueme',  '2012-01-15', 'Female', 'Mrs. Ngozi Ekwueme',    '0800-100-0021', 3),
    (22, 'SWD/26/022', 'Farouk', NULL, 'Abiola',         '2012-03-27', 'Male',   'Mr. Rilwan Abiola',     '0800-100-0022', 3),
    (23, 'SWD/26/023', 'Bisola', 'Yetunde', 'Shittu',    '2011-12-10', 'Female', 'Mrs. Moji Shittu',      '0800-100-0023', 3),
    (24, 'SWD/26/024', 'Uche', NULL, 'Nwankwo',           '2012-06-19', 'Male',   'Mr. Chika Nwankwo',     '0800-100-0024', 3),
    (25, 'SWD/26/025', 'Aisha', 'Lami', 'Danjuma',       '2012-09-13', 'Female', 'Mr. Danjuma Danjuma',   '0800-100-0025', 3),
    (26, 'SWD/26/026', 'Olamide', NULL, 'Adegoke',       '2011-10-24', 'Male',   'Mrs. Folake Adegoke',   '0800-100-0026', 3),
    (27, 'SWD/26/027', 'Nkiruka', 'Ada', 'Opara',        '2012-02-08', 'Female', 'Mr. Chinedu Opara',     '0800-100-0027', 3),
    (28, 'SWD/26/028', 'Mubarak', NULL, 'Shehu',         '2011-11-30', 'Male',   'Mrs. Bilkisu Shehu',    '0800-100-0028', 3),
    (29, 'SWD/26/029', 'Tomiwa', 'Ayodeji', 'Olawale',   '2012-05-16', 'Male',   'Mr. Olufemi Olawale',   '0800-100-0029', 3),
    (30, 'SWD/26/030', 'Peace', NULL, 'Udo',              '2012-07-05', 'Female', 'Mrs. Eno Udo',          '0800-100-0030', 3);

INSERT INTO subject (subject_id, subject_code, subject_name)
VALUES
    (1, 'ENG', 'English Language'),
    (2, 'MAT', 'Mathematics'),
    (3, 'BSC', 'Basic Science'),
    (4, 'SST', 'Social Studies'),
    (5, 'ICT', 'Computer Studies'),
    (6, 'CIV', 'Civic Education'),
    (7, 'YOR', 'Yoruba Language'),
    (8, 'FRE', 'French');

-- Every class offers all eight subjects; each offering has one assigned teacher.
INSERT INTO class_subject (class_id, subject_id, teacher_id)
VALUES
    (1, 1, 1), (1, 2, 2), (1, 3, 2), (1, 4, 3),
    (1, 5, 4), (1, 6, 3), (1, 7, 5), (1, 8, 6),
    (2, 1, 1), (2, 2, 2), (2, 3, 2), (2, 4, 3),
    (2, 5, 4), (2, 6, 3), (2, 7, 5), (2, 8, 6),
    (3, 1, 1), (3, 2, 2), (3, 3, 2), (3, 4, 3),
    (3, 5, 4), (3, 6, 3), (3, 7, 5), (3, 8, 6);

INSERT INTO term (term_id, term_name, start_date, end_date)
VALUES (1, '2026/2027 First Term', '2026-09-07', '2026-12-18');

-- Generate one result per student and each subject offered to that student's class.
-- Formula-generated example scores are bounded by the schema's score checks.
INSERT INTO result (student_id, class_id, subject_id, term_id, ca_score, exam_score)
SELECT
    s.student_id,
    cs.class_id,
    cs.subject_id,
    t.term_id,
    CAST(20 + MOD(s.student_id * 7 + cs.subject_id * 3, 21) AS DECIMAL(5,2)),
    CAST(35 + MOD(s.student_id * 11 + cs.subject_id * 5, 26) AS DECIMAL(5,2))
FROM student AS s
JOIN class_subject AS cs ON cs.class_id = s.class_id
CROSS JOIN term AS t;

-- Generate five daily attendance rows for every seeded student.
INSERT INTO attendance (student_id, attendance_date, status)
SELECT
    s.student_id,
    school_day.attendance_date,
    CASE MOD(s.student_id + DAYOFMONTH(school_day.attendance_date), 10)
        WHEN 0 THEN 'absent'
        WHEN 1 THEN 'late'
        ELSE 'present'
    END
FROM student AS s
CROSS JOIN (
    SELECT DATE('2026-09-07') AS attendance_date
    UNION ALL SELECT DATE('2026-09-08')
    UNION ALL SELECT DATE('2026-09-09')
    UNION ALL SELECT DATE('2026-09-10')
    UNION ALL SELECT DATE('2026-09-11')
) AS school_day;
