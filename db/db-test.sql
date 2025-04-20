
CREATE TABLE registar_tbl (
	registar_id VARCHAR(40) PRIMARY KEY,
    registar_name VARCHAR(40) NOT NULL,
    registar_location VARCHAR(80) NOT NULL,
    registar_status ENUM('active', 'inactive', 'maintenance') NOT NULL DEFAULT 'active',
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);