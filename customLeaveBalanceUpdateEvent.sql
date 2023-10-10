CREATE EVENT updateCustomLeaveBalance
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '14:31:00')
COMMENT 'update custom leave balance'
DO
CALL bw_leave_tracker.UpdateLeaveBalances();
show events;