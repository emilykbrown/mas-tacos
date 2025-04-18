DROP SCHEMA IF EXISTS mas_tacos;

CREATE SCHEMA mas_tacos;

USE mas_tacos;

-- ==== RBAC ====

CREATE TABLE user_tbl (
    user_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NULL,
    customer_id VARCHAR(40) NULL,
    username VARCHAR(100) NOT NULL,
    user_first_name VARCHAR(40) NOT NULL,
    user_last_name VARCHAR(55) NOT NULL,
    password_hash VARCHAR(255) NOT NULL, 
	user_email VARCHAR(255) NOT NULL,
    is_active BOOL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE role_tbl (
	role_id VARCHAR(40) PRIMARY KEY,
    role_name VARCHAR(40) NOT NULL,
    role_desc TEXT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE permission_tbl (
	permission_id VARCHAR(40) PRIMARY KEY,
    permission_name VARCHAR(40) NOT NULL,
    permission_desc TEXT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE user_role_tbl (
	user_role_id VARCHAR(40) PRIMARY KEY,
    user_id VARCHAR (40) NOT NULL,
    role_id VARCHAR (40) NOT NULL,
	inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (user_id) REFERENCES user_tbl(user_id),
    FOREIGN KEY (role_id) REFERENCES role_tbl(role_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE role_permission_tbl (
	role_permission_id VARCHAR(40) PRIMARY KEY,
    role_id VARCHAR (40) NOT NULL,
    permission_id VARCHAR (40) NOT NULL,
	inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (role_id) REFERENCES role_tbl(role_id),
    FOREIGN KEY (permission_id) REFERENCES permission_tbl(permission_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ==== Employees ====

CREATE TABLE department_tbl (
	department_id VARCHAR(40) PRIMARY KEY,
    department_name VARCHAR(40) NOT NULL,
    department_desc TEXT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE employee_tbl (
	employee_id VARCHAR(40) PRIMARY KEY,
	employee_first_name VARCHAR(40) NOT NULL,
    employee_last_name VARCHAR(55) NOT NULL,
    employee_email VARCHAR(255) NOT NULL, 
	employee_phone VARCHAR(20) NOT NULL,
    hire_date DATE NOT NULL,
    job_title VARCHAR(40) NOT NULL,
    salery DECIMAL (10,2) NOT NULL,
	department_id VARCHAR(40) NOT NULL,
    supervisor_id VARCHAR(40) NOT NULL,
    employment_status ENUM('active', 'terminated', 'on_leave') DEFAULT 'active',
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (department_id) REFERENCES department_tbl(department_id),
    FOREIGN KEY (supervisor_id) REFERENCES employee_tbl(employee_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
); 

CREATE TABLE benefit_tbl (
	benefit_id VARCHAR(40) PRIMARY KEY,
    benefit_name VARCHAR(40) NOT NULL,
    benefit_desc TEXT NOT NULL,
    benefit_provider VARCHAR(40) NOT NULL,
    monthly_cost DECIMAL (10,2) NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);


CREATE TABLE employee_benefit_tbl (
	employee_benefit_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    benefit_id VARCHAR(40) NOT NULL,
    benefit_enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    benefit_status ENUM('active', 'terminated'),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (benefit_id) REFERENCES benefit_tbl(benefit_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE payroll_tbl (
    payroll_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    pay_type ENUM('salery', 'hourly'),
    hourly_rate DECIMAL(5,2) DEFAULT 0.00,
    base_salary DECIMAL(10,2) NULL,
    overtime_hours DECIMAL(5,2) DEFAULT 0.00,
    overtime_rate DECIMAL(5,2) DEFAULT 1.5,  -- Multiplier for overtime pay
    overtime_pay DECIMAL(10,2) GENERATED ALWAYS AS (overtime_hours * (base_salary / 160) * overtime_rate) STORED,
    deductions DECIMAL(10,2) DEFAULT 0.00,
    net_pay DECIMAL(10,2) GENERATED ALWAYS AS (base_salary + overtime_pay + bonuses - deductions - taxes) STORED,
    payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'pending',
    paid_at TIMESTAMP NULL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- *

CREATE TABLE paid_time_off_tbl (
    pto_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    pto_type ENUM('Vacation', 'Sick', 'Personal', 'Other') NOT NULL,
    request_date DATE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INT GENERATED ALWAYS AS (DATEDIFF(end_date, start_date) + 1) STORED,
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',
    approved_by INT NULL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id) ON DELETE SET NULL,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);


CREATE TABLE employee_pto_balance (
    employee_pto_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    vacation_days INT DEFAULT 10,   -- Default PTO per year
    sick_days INT DEFAULT 5,
    personal_days INT DEFAULT 3,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

ALTER TABLE payroll_tbl 
ADD COLUMN pto_deductions DECIMAL(10,2) DEFAULT 0.00,
ADD COLUMN adjusted_net_pay DECIMAL(10,2) GENERATED ALWAYS AS (net_pay - pto_deductions) STORED;


CREATE TABLE bonus_tbl (
    bonus_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    bonus_type ENUM('Performance', 'Holiday', 'Referral', 'Other') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    bonus_date DATE NOT NULL,
    notes TEXT NULL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE shift_log_tbl (
    shift_id VARCHAR(40) PRIMARY KEY,
    shift_name NOT NULL,
    shift_date DATE NOT NULL,
    shift_start_time TIME NOT NULL,
    shift_end_time TIME NOT NULL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);


CREATE TABLE employee_schedules (
    schedule_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    shift_status ENUM('scheduled', 'completed', 'missed', 'canceled') DEFAULT 'scheduled',
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);
-- **
CREATE TABLE employee_attendance (
    attendance_id VARCHAR(40) PRIMARY KEY AUTO_INCREMENT,
    employee_id VARCHAR(40) NOT NULL,
    clock_in TIMESTAMP NOT NULL,
    clock_out TIMESTAMP NULL,
    total_hours DECIMAL(5,2) GENERATED ALWAYS AS (TIMESTAMPDIFF(MINUTE, clock_in, clock_out) / 60.0) STORED,
    attendance_status ENUM('on_time', 'late', 'missed') DEFAULT 'on_time',
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);


CREATE TABLE section_tbl (
    section_id VARCHAR(40) PRIMARY KEY,
    section_name VARCHAR(50) NOT NULL UNIQUE,
    section_description TEXT,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id),
);


CREATE TABLE table_tbl (
    table_id VARCHAR(40) PRIMARY KEY,
    table_number VARCHAR(10) UNIQUE NOT NULL,
    section_id INT NOT NULL,
    table_capacity INT NOT NULL,
    table_status ENUM('available', 'occupied', 'reserved') DEFAULT 'available',
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (section_id) REFERENCES sections(section_id) ON DELETE CASCADE
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);


CREATE TABLE table_assignment_tbl (
    assignment_id VARCHAR(40) PRIMARY KEY,
    employee_id VARCHAR(40) NOT NULL,
    table_id VARCHAR(40) NOT NULL,
    assignment_date DATE NOT NULL,
    shift_start TIME NOT NULL,
    shift_end TIME NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(table_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ***

CREATE TABLE reservation_tbl (
    reservation_id VARCHAR(40) PRIMARY KEY,
    customer_id VARCHAR(40) NOT NULL,
    table_id VARCHAR(40) NOT NULL,
    reservation_time DATETIME NOT NULL,
    party_size INT NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    special_requests TEXT,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (table_id) REFERENCES tables(table_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);



-- ==== Menu ====