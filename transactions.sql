-- Class transfer examples. Run schema.sql and seed.sql first.
-- Change the IDs before executing. The transaction block changes the student
-- and creates a permanent audit row; it is not an idempotent demo.

SET @student_id = 1;
SET @target_class_id = 2;

-- Successful transfer: lock/read the student's current class, update the
-- student, then record the old and new class in the same transaction.
START TRANSACTION;
SELECT class_id INTO @from_class_id
FROM student
WHERE student_id = @student_id
FOR UPDATE;

UPDATE student
SET class_id = @target_class_id
WHERE student_id = @student_id;

INSERT INTO class_transfers (student_id, from_class_id, to_class_id)
VALUES (@student_id, @from_class_id, @target_class_id);

COMMIT;

-- Robust version: explicitly rolls back for a missing student or target class.
-- The handler also rolls back and re-raises any SQL error (including a foreign
-- key error if the new class lacks one of the student's existing subject offerings).
DROP PROCEDURE IF EXISTS sp_move_student_safely;
DELIMITER //
CREATE PROCEDURE sp_move_student_safely(
    IN p_student_id INT UNSIGNED,
    IN p_target_class_id INT UNSIGNED
)
BEGIN
    DECLARE v_from_class_id INT UNSIGNED;
    DECLARE v_exists INT DEFAULT 0;
    DECLARE v_student_missing BOOLEAN DEFAULT FALSE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_student_missing = TRUE;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_exists
    FROM student
    WHERE student_id = p_student_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student does not exist; transfer rolled back';
    END IF;

    SELECT class_id INTO v_from_class_id
    FROM student
    WHERE student_id = p_student_id
    FOR UPDATE;

    IF v_student_missing THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student no longer exists; transfer rolled back';
    END IF;

    SELECT COUNT(*) INTO v_exists
    FROM school_class
    WHERE class_id = p_target_class_id;

    IF v_exists = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Target class does not exist; transfer rolled back';
    END IF;

    UPDATE student
    SET class_id = p_target_class_id
    WHERE student_id = p_student_id;

    INSERT INTO class_transfers (student_id, from_class_id, to_class_id)
    VALUES (p_student_id, v_from_class_id, p_target_class_id);

    COMMIT;
END//
DELIMITER ;

-- Example call. Use an existing class ID to commit, or a nonexistent ID such
-- as 999999 to see the explicit rollback and SQLSTATE error.
-- CALL sp_move_student_safely(1, 3);
-- CALL sp_move_student_safely(1, 999999);
