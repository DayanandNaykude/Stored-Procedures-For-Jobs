CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateLeaveBalances`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE employeeId INT;
    DECLARE leaveTypeId varchar(45);
    DECLARE leaveBalance DECIMAL(10, 2);
    DECLARE employeeLeaveId varchar(45);
    DECLARE new_leave_balance DECIMAL(10, 2);
    DECLARE leaveBalanceAppDate DATE;
    DECLARE new_id varchar(45);
    DECLARE existingEmployeeLeaveId varchar(45);
    

    -- Declare a cursor to fetch records
    DECLARE records_cursor CURSOR FOR
        SELECT 
		employee_id,
        leave_type_fkid,
        leave_balance,
        id,
        leave_balance_applicable_date
		FROM
			bw_leave_tracker.employee_leave
		WHERE
			leave_balance_applicable_date = CURDATE()
				AND is_active = 0
				AND is_leave_balance_added = 0;

    -- Declare handlers for exceptions
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN records_cursor;

    read_loop: LOOP
        FETCH records_cursor INTO employeeId, leaveTypeId, leaveBalance, employeeLeaveId, leaveBalanceAppDate ;
        IF done THEN
            LEAVE read_loop;
        END IF;

			
        -- Check if an employee record exists
		SELECT 
			COUNT(*)
		INTO @employee_count FROM
			bw_leave_tracker.employee_leave
		WHERE
			employee_id = employeeId
				AND is_active = 1
				AND leave_type_fkid = leaveTypeId;

		
        
        IF @employee_count > 0 THEN
			-- get employee leave record id for existing record
				SELECT 
				id
				INTO existingEmployeeLeaveId FROM
					bw_leave_tracker.employee_leave
				WHERE
					employee_id = employeeId
						AND is_active = 1
						AND leave_type_fkid = leaveTypeId;
                        
					-- Update leave balance
					UPDATE bw_leave_tracker.employee_leave 
					SET 
						leave_balance = leave_balance + leaveBalance
					WHERE
						id = existingEmployeeLeaveId;
        ELSE
            -- Insert a new employee record
            SET new_id = UUID();
            INSERT INTO `bw_leave_tracker`.`employee_leave` (`id`, `employee_id`, `leave_type_fkid`, `leave_balance`, `leave_balance_applicable_date`, `is_active`) VALUES (new_id, employeeId, leaveTypeId ,leaveBalance , leaveBalanceAppDate, '1');
        END IF;
        
       END LOOP;

    CLOSE records_cursor;
    
     
END