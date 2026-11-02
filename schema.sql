-- School database schema for MySQL 8.0.16+ or MariaDB 10.2.1+.
-- These versions enforce CHECK constraints.

SET NAMES utf8mb4;

-- Drop dependents before the tables they reference so this script can be rerun.
DROP TABLE IF EXISTS result;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS class_subject;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS school_class;
DROP TABLE IF EXISTS subject;
DROP TABLE IF EXISTS term;
DROP TABLE IF EXISTS teacher;

CREATE TABLE teacher (
    teacher_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    staff_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(254) NOT NULL,
    phone VARCHAR(25) NOT NULL,
    hire_date DATE NOT NULL,
    PRIMARY KEY (teacher_id),
    UNIQUE KEY uq_teacher_staff_number (staff_number),
    UNIQUE KEY uq_teacher_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE school_class (
    class_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    class_name VARCHAR(20) NOT NULL,
    form_teacher_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (class_id),
    UNIQUE KEY uq_school_class_name (class_name),
    KEY idx_school_class_form_teacher (form_teacher_id),
    -- RESTRICT prevents deleting a teacher who is still assigned; CASCADE
    -- propagates a deliberate teacher ID change to the class assignment.
    CONSTRAINT fk_school_class_form_teacher
        FOREIGN KEY (form_teacher_id) REFERENCES teacher (teacher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE student (
    student_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    admission_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Female', 'Male', 'Other', 'Prefer not to say') NOT NULL,
    guardian_name VARCHAR(120) NOT NULL,
    guardian_phone VARCHAR(25) NOT NULL,
    class_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (student_id),
    UNIQUE KEY uq_student_admission_number (admission_number),
    -- Supports a composite FK from result to ensure the result's class is
    -- the student's assigned class.
    UNIQUE KEY uq_student_id_class (student_id, class_id),
    KEY idx_student_class (class_id),
    -- RESTRICT protects students from accidental loss when deleting a class;
    -- CASCADE keeps references valid if a class ID is deliberately changed.
    CONSTRAINT fk_student_class
        FOREIGN KEY (class_id) REFERENCES school_class (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE subject (
    subject_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    subject_code VARCHAR(12) NOT NULL,
    subject_name VARCHAR(80) NOT NULL,
    PRIMARY KEY (subject_id),
    UNIQUE KEY uq_subject_code (subject_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE class_subject (
    class_id INT UNSIGNED NOT NULL,
    subject_id INT UNSIGNED NOT NULL,
    teacher_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (class_id, subject_id),
    KEY idx_class_subject_subject (subject_id),
    KEY idx_class_subject_teacher (teacher_id),
    -- RESTRICT preserves subject offerings and their history; CASCADE updates
    -- the offering if its class identifier changes.
    CONSTRAINT fk_class_subject_class
        FOREIGN KEY (class_id) REFERENCES school_class (class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- RESTRICT prevents removing a subject that is in use; CASCADE updates
    -- its key in the offering if needed.
    CONSTRAINT fk_class_subject_subject
        FOREIGN KEY (subject_id) REFERENCES subject (subject_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- RESTRICT prevents deleting a teacher with assigned classes/subjects;
    -- CASCADE propagates a deliberate teacher ID change.
    CONSTRAINT fk_class_subject_teacher
        FOREIGN KEY (teacher_id) REFERENCES teacher (teacher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE term (
    term_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    term_name VARCHAR(80) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    PRIMARY KEY (term_id),
    UNIQUE KEY uq_term_name (term_name),
    CONSTRAINT chk_term_dates CHECK (start_date <= end_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE result (
    student_id INT UNSIGNED NOT NULL,
    class_id INT UNSIGNED NOT NULL,
    subject_id INT UNSIGNED NOT NULL,
    term_id INT UNSIGNED NOT NULL,
    ca_score DECIMAL(5,2) NOT NULL,
    exam_score DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (student_id, class_id, subject_id, term_id),
    UNIQUE KEY uq_result_student_subject_term (student_id, subject_id, term_id),
    KEY idx_result_class_subject (class_id, subject_id),
    KEY idx_result_term (term_id),
    CONSTRAINT chk_result_ca_score CHECK (ca_score BETWEEN 0.00 AND 40.00),
    CONSTRAINT chk_result_exam_score CHECK (exam_score BETWEEN 0.00 AND 60.00),
    -- RESTRICT retains results if a student is deleted; CASCADE updates the
    -- reference if the student's ID or class assignment is deliberately changed.
    CONSTRAINT fk_result_student_class
        FOREIGN KEY (student_id, class_id) REFERENCES student (student_id, class_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- RESTRICT protects assessed offerings; CASCADE keeps results attached if
    -- an offering's class or subject key is deliberately changed.
    CONSTRAINT fk_result_class_subject
        FOREIGN KEY (class_id, subject_id) REFERENCES class_subject (class_id, subject_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    -- RESTRICT prevents deleting a term with results; CASCADE updates a term ID
    -- change without orphaning results.
    CONSTRAINT fk_result_term
        FOREIGN KEY (term_id) REFERENCES term (term_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE attendance (
    student_id INT UNSIGNED NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('present', 'absent', 'late') NOT NULL,
    PRIMARY KEY (student_id, attendance_date),
    -- RESTRICT preserves attendance history; CASCADE updates the student key
    -- if it is deliberately changed.
    CONSTRAINT fk_attendance_student
        FOREIGN KEY (student_id) REFERENCES student (student_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
