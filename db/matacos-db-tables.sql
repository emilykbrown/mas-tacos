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

ALTER TABLE user_tbl ADD FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id);

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
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
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
    section_desc TEXT,
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

CREATE TABLE reservation_tbl (
    reservation_id VARCHAR(40) PRIMARY KEY,
    customer_id VARCHAR(40) NOT NULL,
    table_id VARCHAR(40) NOT NULL,
    reservation_time DATETIME NOT NULL,
    party_size INT NOT NULL,
    reservation_status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
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

CREATE TABLE menu_category_tbl (
	menu_category_id VARCHAR(40) PRIMARY KEY,
    menu_category_name VARCHAR(40) NOT NULL,
    menu_category_desc TEXT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE menu_item_tbl (
	menu_item_id VARCHAR(40) PRIMARY KEY,
	menu_category_id VARCHAR(40) NOT NULL,
    menu_item_name VARCHAR(40) NOT NULL,
    menu_item_price DECIMAL(10,2),
    menu_item_is_available BOOL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (menu_category_id) REFERENCES menu_category_tbl(menu_category_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE menu_size_tbl (
	menu_size_id VARCHAR(40) PRIMARY KEY,
	menu_item_id VARCHAR(40) NOT NULL,
    menu_size_name VARCHAR(40) NOT NULL,
    menu_size_price DECIMAL(10,2),
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (menu_item_id) REFERENCES menu_item_tbl(menu_item_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE menu_customization_tbl (
	menu_customization_id VARCHAR(40) PRIMARY KEY,
	menu_item_id VARCHAR(40) NOT NULL,
    price_adjustment DECIMAL(10,2),
    inserted_by VARCHAR(40),
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (menu_item_id) REFERENCES menu_item_tbl(menu_item_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE allergen_tbl (
	allergen_id VARCHAR(40) PRIMARY KEY,
    allergen_name VARCHAR(40) NOT NULL,
    allergen_notes TEXT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE menu_allergen_tbl (
	menu_allergen_id VARCHAR(40) PRIMARY KEY,
    menu_item_id VARCHAR(40) NOT NULL,
    allergen_id VARCHAR(40) NOT NULL,
    allergen_notes TEXT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (menu_item_id) REFERENCES menu_item_tbl(menu_item_id),
    FOREIGN KEY (allergen_id) REFERENCES allergen_tbl(allergen_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE ingredient_tbl (
	ingredient_id VARCHAR(40) PRIMARY KEY,
    inventory_id VARCHAR(40) NOT NULL,
    ingredient_name VARCHAR(40) NOT NULL,
    shelf_life VARCHAR(20),
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE menu_ingredient_tbl (
	menu_ingredient_id VARCHAR(40) PRIMARY KEY,
    menu_item_id VARCHAR(40) NOT NULL,
    ingredient_id VARCHAR(40) NOT NULL,
    ingredient_notes TEXT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),    
    FOREIGN KEY (menu_item_id) REFERENCES menu_item_tbl(menu_item_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredient_tbl(ingredient_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ==== Inventory ====
CREATE TABLE inventory_tbl (
    inventory_id VARCHAR(40) PRIMARY KEY,
    inventory_name VARCHAR (40) NOT NULL,
    inventory_category VARCHAR(150) NOT NULL,
    inventory_units VARCHAR(150) NOT NULL,
    units_stocked SMALLINT NOT NULL,
    min_stocked_level SMALLINT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);
ALTER TABLE ingredient_tbl ADD FOREIGN KEY (inventory_id) REFERENCES inventory_tbl(inventory_id);

CREATE TABLE inventory_transcation_tbl (
    inventory_transcation_id VARCHAR(40) PRIMARY KEY,
    inventory_id VARCHAR (40) NOT NULL,
    employee_id VARCHAR (40) NOT NULL,
    transaction_type ENUM('restock', 'usage') NOT NULL,
    transaction_date DATETIME NOT NULL,
    transaction_qty int NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (inventory_id) REFERENCES inventory_tbl(inventory_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE inventory_waste_tbl (
    inventory_waste_id VARCHAR(40) PRIMARY KEY,
    inventory_id VARCHAR (40) NOT NULL,
    employee_id VARCHAR (40) NOT NULL,
    waste_reason TEXT NOT NULL,
    waste_date DATETIME NOT NULL,
    wase_qty int NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (inventory_id) REFERENCES inventory_tbl(inventory_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE supply_tbl (
    supply_id VARCHAR(40) PRIMARY KEY,
    supply_name VARCHAR (40) NOT NULL,
    supply_category VARCHAR(150) NOT NULL,
    supply_units VARCHAR(150) NOT NULL,
    units_stocked SMALLINT NOT NULL,
    min_stocked_level SMALLINT NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE supply_transcation_tbl (
    supply_transcation_id VARCHAR(40) PRIMARY KEY,
    supply_id VARCHAR (40) NOT NULL,
    employee_id VARCHAR (40) NOT NULL,
    transaction_type ENUM('restock', 'usage') NOT NULL,
    transaction_date DATETIME NOT NULL,
    transaction_qty int NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (supply_id) REFERENCES supply_tbl(supply_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE supply_waste_tbl (
    supply_waste_id VARCHAR(40) PRIMARY KEY,
    supply_id VARCHAR (40) NOT NULL,
    employee_id VARCHAR (40) NOT NULL,
    waste_reason TEXT NOT NULL,
    waste_date DATETIME NOT NULL,
    wase_qty int NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (supply_id) REFERENCES supply_tbl(supply_id),
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id) ON DELETE CASCADE,
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ==== Vendors ====

CREATE TABLE vendor_tbl (
    vendor_id VARCHAR(40) PRIMARY KEY,
    vendor_name VARCHAR(55) NOT NULL,
    vendor_phone VARCHAR(20) NOT NULL,
    vendor_email VARCHAR(255) NOT NULL,
    vendor_address TEXT,
    vendor_website TEXT,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE vendor_order_tbl (
    vendor_order_id VARCHAR(40) PRIMARY KEY,
    vendor_id VARCHAR(40) NOT NULL,
    placed_by VARCHAR(40) NOT NULL,
    approved_by VARCHAR(40) NOT NULL,
    order_date DATETIME NOT NULL,
    expected_date DATETIME NOT NULL,
    total_cost DECIMAL(10, 2) NULL,
    order_status ENUM('Pending', 'Approved', 'Partially Fulfilled', 'Completed', 'Canceled'),
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id),
    FOREIGN KEY (vendor_id) REFERENCES vendor_tbl(vendor_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE vendor_order_item_tbl (
    vendor_order_item_id VARCHAR(40) PRIMARY KEY,
    inventory_id VARCHAR(40) NOT NULL,
    supply_id VARCHAR(40) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NULL,
    subtotal GENRATED ALWAYS AS (quantity * unit_price),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (inventory_id) REFERENCES inventory_tbl(inventory_id),
    FOREIGN KEY (supply_id) REFERENCES supply_tbl(supply_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE vendor_contact_tbl (
    vendor_id VARCHAR(40) NOT NULL,
    contact_name VARCHAR(55) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    conatac_email VARCHAR(255) NOT NULL,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (supply_id) REFERENCES supply_tbl(supply_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE vendor_bill_tbl (
    vendor_bill_id VARCHAR(40) PRIMARY KEY,
    vendor_id VARCHAR(40) NOT NULL,
    bill_date DATE NOT NULL,
    bill_due_date DATE NOT NULL,
    bill_total_amount DECIMAL(10,2) NOT NULL,
    bill_status ENUM('Pending', 'Paid', 'Overdue') DEFAULT 'Pending',
    bill_payment_method ENUM('Bank Transfer', 'Credit Card', 'Cash', 'Check'),
    bill_paid_date DATE NULL,
    bill_notes TEXT,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (vendor_id) REFERENCES vendor_tbl(vendor_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE vendor_bill_item_tbl (
    vendor_order_item_id VARCHAR(40) PRIMARY KEY,
    inventory_id VARCHAR(40) NOT NULL,
    supply_id VARCHAR(40) NOT NULL,
    vendor_bill_id VARCHAR(40) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NULL,
    subtotal GENRATED ALWAYS AS (quantity * unit_price),
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (inventory_id) REFERENCES inventory_tbl(inventory_id),
    FOREIGN KEY (supply_id) REFERENCES supply_tbl(supply_id),
    FOREIGN KEY (vendor_bill_id) REFERENCES vendor_bill_tbl(vendor_bill_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ==== Uniforms ====

CREATE TABLE uniform_tbl (
    uniform_id VARCHAR(40) PRIMARY KEY,
    vendor_id VARCHAR(40) NOT NULL,
    uniform_name VARCHAR(100) NOT NULL,
    uniform_desc TEXT NOT NULL,
    uniform_size TEXT NOT NULL,
    uniform_color VARCHAR(50) NOT NULL, 
    uniform_cost DECIMAL(10,2) NOT NULL,
    uniform_stock_quantity INT DEFAULT 0,
	insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (vendor_id) REFERENCES vendor_tbl(vendor_id),
	FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

CREATE TABLE employee_uniform_tbl (
    employee_uniform_id VARCHAR(40)
    employee_id INT NOT NULL,
    uniform_id INT NOT NULL,
    employee_size VARCHAR(10),
    employee_quantity INT DEFAULT 1,  
    uniform_assigned_date DATE DEFAULT CURRENT_DATE,  
    uniform_returned_date DATE,  
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (employee_id) REFERENCES employee_tbl(employee_id),
    FOREIGN KEY (uniform_id) REFERENCES uniform_tbl(uniform_id),
    FOREIGN KEY (inserted_by) REFERENCES user_tbl(user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl(user_id)
);

-- ==== Orders ====

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


