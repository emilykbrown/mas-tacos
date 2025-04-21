CREATE TABLE menu_item_promo_tbl (
    menu_item_promo_id VARCHAR(40) PRIMARY KEY,
    menu_item_id VARCHAR(40) NOT NULL,
    promotion_id VARCHAR(40) NOT NULL,
    discount_amount DECIMAL(10 , 2 ) NOT NULL,
    insert_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_by VARCHAR(40),
    last_updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_updated_by VARCHAR(40),
    FOREIGN KEY (menu_item_id) REFERENCES menu_item_tbl(menu_item_id),
    FOREIGN KEY (promotion_id) REFERENCES promotion_tbl(promotion_id),
    FOREIGN KEY (inserted_by) REFERENCES user_tbl (user_id),
    FOREIGN KEY (last_updated_by) REFERENCES user_tbl (user_id)
);