CREATE EVENT DailyExperienceChange
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '14:20:00')
COMMENT 'fetching employees whose joining date(day) is today and unpdate experience'
DO
CALL bw_leave_tracker.experience_change();
show events;


