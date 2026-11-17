ALTER TABLE salary_records
    ADD COLUMN base_salary DECIMAL(15,2) NULL,
    ADD COLUMN bonus DECIMAL(15,2) NULL,
    ADD COLUMN deductions DECIMAL(15,2) NULL;

INSERT INTO system_settings (setting_key, setting_value)
VALUES
    ('ATTENDANCE_ENABLED', 'true'),
    ('PAYROLL_ENABLED', 'true'),
    ('LEAVE_MANAGEMENT_ENABLED', 'true'),
    ('EMAIL_NOTIFICATIONS_ENABLED', 'false')
ON DUPLICATE KEY UPDATE setting_key = VALUES(setting_key);
