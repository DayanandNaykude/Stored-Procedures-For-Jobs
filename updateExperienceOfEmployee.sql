CREATE DEFINER=`root`@`localhost` PROCEDURE `experience_change`()
BEGIN

    DECLARE done INT DEFAULT 0;

    DECLARE employee_id INT;

    DECLARE currExpYear INT;

    DECLARE currExpMonth INT;

    DECLARE totExpYear INT;

    DECLARE totExpMonth INT;

 

    -- Declare a cursor for employees with joining dates matching the current day

    DECLARE cur CURSOR FOR

        SELECT id, current_no_of_experience_year, current_no_of_experience_month, total_no_of_experience_year, total_no_of_experience_month

        FROM common.employee

        WHERE DAY(joining_date) = DAY(CURDATE());

 

    -- Declare a handler for when there are no more rows to fetch

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

 

    OPEN cur;

 

    -- Loop through the matching rows

    my_loop: LOOP

        FETCH cur INTO employee_id, currExpYear, currExpMonth, totExpYear, totExpMonth;

 

        -- Exit the loop when there are no more rows

        IF done = 1 THEN

            LEAVE my_loop;

        END IF;

 

        -- Add current experience

        SET currExpMonth = currExpMonth + 1;

        IF currExpMonth % 12 = 0 AND currExpMonth != 0 THEN

            SET currExpYear = currExpYear + 1;

            SET currExpMonth = 0;

        END IF;

 

        -- Add total experience

        SET totExpMonth = totExpMonth + 1;

        IF totExpMonth % 12 = 0 AND totExpMonth != 0 THEN

            SET totExpYear = totExpYear + 1;

            SET totExpMonth = 0;

        END IF;

 

        -- Update the employee's experience data in the table

        UPDATE common.employee

        SET

            current_no_of_experience_year = currExpYear,

            current_no_of_experience_month = currExpMonth,

            total_no_of_experience_year = totExpYear,

            total_no_of_experience_month = totExpMonth

        WHERE id = employee_id;

    END LOOP;

 

    CLOSE cur;

END