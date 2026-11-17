CREATE TABLE IF NOT EXISTS workspace_agent_tasks (
    id BIGINT NOT NULL AUTO_INCREMENT,
    created_by INT NOT NULL,
    assigned_to INT NOT NULL,
    title VARCHAR(240) NOT NULL,
    details TEXT,
    due_date DATE NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    source_group_id INT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_agent_task_assignee (assigned_to, status, due_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS workspace_policy_documents (
    id BIGINT NOT NULL AUTO_INCREMENT,
    title VARCHAR(180) NOT NULL,
    content MEDIUMTEXT NOT NULL,
    source VARCHAR(255) NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by INT NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_policy_active (active)
) ENGINE=InnoDB;
