use ocean_view_resort_db;


CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100),
    password VARCHAR(255) NOT NULL,
    contact_no VARCHAR(20),
    address VARCHAR(255),
    role ENUM('Admin', 'Staff') NOT NULL
);

CREATE TABLE staff (
    staff_id INT PRIMARY KEY,
    designation VARCHAR(100),
    FOREIGN KEY (staff_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE admins (
    admin_id INT PRIMARY KEY,
    FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE guests (
    guest_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    contact_no VARCHAR(15)
);

CREATE TABLE rooms (
    room_no INT AUTO_INCREMENT PRIMARY KEY, 
    room_type VARCHAR(50),
    price_per_night DECIMAL(10, 2),
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE reservations (
    reservation_no INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT, 
    room_no INT,
    staff_id INT, 
    room_type VARCHAR(50),
    price_per_night DECIMAL(10, 2),
    check_in_date DATE,
    check_out_date DATE,
    status ENUM('PENDING', 'PAID', 'CANCELLED') DEFAULT 'PENDING',
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (room_no) REFERENCES rooms(room_no),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    INDEX idx_reservation_status (status)
);

CREATE TABLE billings (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    res_no INT,
    total_amount DECIMAL(10, 2),
    tax DECIMAL(10, 2),
    status ENUM('PAID', 'CANCELLED') DEFAULT 'PAID',
    FOREIGN KEY (res_no) REFERENCES reservations(reservation_no) ON DELETE CASCADE,
    INDEX idx_billing_status (status)
);

CREATE TABLE help_guidelines (
    guide_id INT AUTO_INCREMENT PRIMARY KEY, 
    topic VARCHAR(100) NOT NULL,
    content TEXT NOT NULL
);

# Triger

DELIMITER //
CREATE TRIGGER after_reservation_insert
AFTER INSERT ON reservations
FOR EACH ROW
BEGIN
    UPDATE rooms 
    SET is_available = FALSE 
    WHERE room_no = NEW.room_no;
END; //
DELIMITER ;

# Stored Procedures
DELIMITER //
CREATE PROCEDURE GenerateFinalBill(IN res_id INT) 
BEGIN
    DECLARE total_days INT;
    DECLARE daily_rate DECIMAL(10,2);
    DECLARE final_amount DECIMAL(10,2);

    SELECT DATEDIFF(check_out_date, check_in_date), price_per_night 
    INTO total_days, daily_rate
    FROM reservations WHERE reservation_no = res_id;

    IF total_days <= 0 THEN SET total_days = 1; END IF;

    SET final_amount = total_days * daily_rate;

    -- UPDATED: Now includes status = 'PAID'
    INSERT INTO billings (res_no, total_amount, tax, status) 
    VALUES (res_id, final_amount, (final_amount * 0.10), 'PAID');
END; //
DELIMITER ;


#Functions
DELIMITER //
CREATE FUNCTION IsRoomFree(r_no INT) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE available BOOLEAN;
    SELECT is_available INTO available FROM rooms WHERE room_no = r_no;
    RETURN available;
END; //


DELIMITER ;

DELIMITER //
CREATE TRIGGER after_reservation_delete
AFTER DELETE ON reservations
FOR EACH ROW
BEGIN
    UPDATE rooms 
    SET is_available = TRUE 
    WHERE room_no = OLD.room_no;
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_reservation_update
AFTER UPDATE ON reservations
FOR EACH ROW
BEGIN
    -- Rule 1: If status becomes PENDING, mark room as BOOKED (Unavailable)
    IF NEW.status = 'PENDING' THEN
        UPDATE rooms SET is_available = FALSE 
        WHERE room_no = NEW.room_no;
        
    -- Rule 2: If status becomes PAID or CANCELLED, mark room as AVAILABLE
    ELSEIF NEW.status IN ('PAID', 'CANCELLED') THEN
        UPDATE rooms SET is_available = TRUE 
        WHERE room_no = NEW.room_no;
    END IF;
END; //
DELIMITER ;
