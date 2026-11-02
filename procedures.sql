-- Stored procedure for validated result insertion/update.
-- Run schema.sql first. VALUES() in the upsert clause is supported by MySQL
-- and MariaDB; MySQL 8.0.20+ deprecates it but continues to accept it.

DROP PROCEDURE IF EXISTS sp_record_result;
DELIMITER //
CREATE PROCEDURE sp_record_result(
    IN p_student_id INT UNSIGNED,
    IN p_subject_id INT UNSIGNED,
    IN p_term_id INT UNSIGNED,
    IN p_ca_score DECIMAL(5,2),
    IN p_exam_score DECIMAL(5,2)
)
BEGIN
    DECLARE v_class_id INT UNSIGNED;
    DECLARE v_student_not_found BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_student_not_found = TRUE;

    IF p_ca_score IS NULL OR p_ca_score < 0 OR p_ca_score > 40 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CA score must be between 0 and 40';
    END IF;

    IF p_exam_score IS NULL OR p_exam_score < 0 OR p_exam_score > 60 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Exam score must be between 0 and 60';
    END IF;

    SELECT s.class_id INTO v_class_id
    FROM student AS s
    WHERE s.student_id = p_student_id;

    IF v_student_not_found OR v_class_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student does not exist';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM class_subject AS cs
        WHERE cs.class_id = v_class_id
          AND cs.subject_id = p_subject_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Subject is not offered in the student class';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM term AS t
        WHERE t.term_id = p_term_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Term does not exist';
    END IF;

    INSERT INTO result
        (student_id, class_id, subject_id, term_id, ca_score, exam_score)
    VALUES
        (p_student_id, v_class_id, p_subject_id, p_term_id, p_ca_score, p_exam_score)
    ON DUPLICATE KEY UPDATE
        ca_score = VALUES(ca_score),
        exam_score = VALUES(exam_score);
END//
DELIMITER ;

-- Example:
-- CALL sp_record_result(1, 1, 1, 32.50, 48.00);
