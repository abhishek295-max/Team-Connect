CREATE TABLE IF NOT EXISTS departments (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(160) NOT NULL,
    description VARCHAR(500),
    team_connect_channel_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_departments_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employees (
    id BIGINT NOT NULL AUTO_INCREMENT,
    ems_employee_id BIGINT NULL,
    team_connect_user_id INT NULL,
    department_id BIGINT NULL,
    name VARCHAR(160) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(40), gender VARCHAR(40), job_title VARCHAR(160),
    hire_date DATE, salary DECIMAL(15,2), address VARCHAR(500),
    role VARCHAR(40) NOT NULL DEFAULT 'EMPLOYEE',
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_employees_ems_id (ems_employee_id),
    UNIQUE KEY uk_employees_email (email), KEY idx_employees_department (department_id),
    CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employee_user_mapping (
    id BIGINT NOT NULL AUTO_INCREMENT,
    employee_id BIGINT NOT NULL,
    team_connect_user_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_mapping_employee (employee_id),
    UNIQUE KEY uk_mapping_user (team_connect_user_id),
    CONSTRAINT fk_mapping_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS projects (
    id BIGINT NOT NULL AUTO_INCREMENT,
    project_name VARCHAR(180) NOT NULL,
    description TEXT, start_date DATE, end_date DATE,
    team_connect_channel_id INT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS project_members (
    project_id BIGINT NOT NULL, employee_id BIGINT NOT NULL,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (project_id, employee_id),
    CONSTRAINT fk_project_member_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    CONSTRAINT fk_project_member_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attendance (
    id BIGINT NOT NULL AUTO_INCREMENT, employee_id BIGINT NOT NULL, date DATE NOT NULL,
    status VARCHAR(30) NOT NULL, check_in TIME NULL, check_out TIME NULL,
    notes VARCHAR(500), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), UNIQUE KEY uk_attendance_employee_date (employee_id, date),
    CONSTRAINT fk_attendance_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS leave_requests (
    id BIGINT NOT NULL AUTO_INCREMENT, employee_id BIGINT NOT NULL,
    start_date DATE NOT NULL, end_date DATE NOT NULL, leave_type VARCHAR(50) NOT NULL,
    reason VARCHAR(1000), status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    reviewed_by INT NULL, applied_on TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewed_at TIMESTAMP NULL, PRIMARY KEY (id), KEY idx_leave_employee (employee_id),
    CONSTRAINT fk_leave_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS salary_records (
    id BIGINT NOT NULL AUTO_INCREMENT, employee_id BIGINT NOT NULL,
    amount DECIMAL(15,2) NOT NULL, payment_date DATE NOT NULL,
    period_label VARCHAR(80), status VARCHAR(30) NOT NULL DEFAULT 'PROCESSED',
    notes VARCHAR(500), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), CONSTRAINT fk_salary_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS documents (
    id BIGINT NOT NULL AUTO_INCREMENT, employee_id BIGINT NOT NULL,
    original_name VARCHAR(255) NOT NULL, storage_key VARCHAR(255) NOT NULL,
    content_type VARCHAR(128) NOT NULL, file_size BIGINT NOT NULL,
    uploaded_by INT NOT NULL, uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), CONSTRAINT fk_document_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS performance_reviews (
    id BIGINT NOT NULL AUTO_INCREMENT, employee_id BIGINT NOT NULL,
    reviewer_employee_id BIGINT NULL, rating DECIMAL(4,2), review_content TEXT,
    review_date DATE NOT NULL, status VARCHAR(30) NOT NULL DEFAULT 'PUBLISHED',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id), CONSTRAINT fk_review_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ems_announcements (
    id BIGINT NOT NULL AUTO_INCREMENT, title VARCHAR(180) NOT NULL, body TEXT NOT NULL,
    audience VARCHAR(30) NOT NULL DEFAULT 'ALL', created_by INT NOT NULL,
    published_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS system_settings (
    setting_key VARCHAR(100) NOT NULL,
    setting_value VARCHAR(255) NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (setting_key)
) ENGINE=InnoDB;
