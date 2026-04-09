CREATE TABLE users (
    user_id VARCHAR(50),
    name VARCHAR(100),
    phone_number VARCHAR(20),
    mail_id VARCHAR(100),
    billing_address TEXT
);

CREATE TABLE bookings (
    booking_id VARCHAR(50),
    booking_date DATETIME,
    room_no VARCHAR(50),
    user_id VARCHAR(50)
);

CREATE TABLE booking_commercials (
    id VARCHAR(50),
    booking_id VARCHAR(50),
    bill_id VARCHAR(50),
    bill_date DATETIME,
    item_id VARCHAR(50),
    item_quantity FLOAT
);

CREATE TABLE items (
    item_id VARCHAR(50),
    item_name VARCHAR(100),
    item_rate INT
);

INSERT INTO users (user_id, name, phone_number, mail_id, billing_address) VALUES
('u1', 'John Doe', '9876543210', 'john.doe@example.com', 'Street 1, City A'),
('u2', 'Jane Smith', '9123456780', 'jane.smith@example.com', 'Street 2, City B'),
('u3', 'Alice Brown', '9988776655', 'alice.brown@example.com', 'Street 3, City C');

INSERT INTO bookings (booking_id, booking_date, room_no, user_id) VALUES
('bk1', '2021-10-10 10:00:00', 'rm101', 'u1'),
('bk2', '2021-11-05 09:30:00', 'rm102', 'u1'),
('bk3', '2021-11-15 12:00:00', 'rm103', 'u2'),
('bk4', '2021-10-20 14:00:00', 'rm104', 'u3'),
('bk5', '2021-12-01 16:00:00', 'rm105', 'u2');

INSERT INTO booking_commercials (id, booking_id, bill_id, bill_date, item_id, item_quantity) VALUES
('1', 'bk1', 'bl1', '2021-10-10 12:00:00', 'itm1', 5),
('2', 'bk1', 'bl1', '2021-10-10 12:00:00', 'itm2', 2),

('3', 'bk2', 'bl2', '2021-11-05 13:00:00', 'itm3', 3),
('4', 'bk2', 'bl2', '2021-11-05 13:00:00', 'itm4', 4),

('5', 'bk3', 'bl3', '2021-11-15 14:00:00', 'itm1', 10),
('6', 'bk3', 'bl3', '2021-11-15 14:00:00', 'itm2', 5),

('7', 'bk4', 'bl4', '2021-10-20 15:00:00', 'itm3', 2),
('8', 'bk4', 'bl4', '2021-10-20 15:00:00', 'itm4', 6),

('9', 'bk5', 'bl5', '2021-12-01 17:00:00', 'itm1', 8),
('10', 'bk5', 'bl5', '2021-12-01 17:00:00', 'itm2', 3);


INSERT INTO items (item_id, item_name, item_rate) VALUES
('itm1', 'Tawa Paratha', 20),
('itm2', 'Mix Veg', 80),
('itm3', 'Paneer Curry', 1500),
('itm4', 'Rice', 50);
-- Q1: Last booked room
SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) latest
ON b.user_id = latest.user_id 
AND b.booking_date = latest.last_booking;

-- Q2: Total billing in Nov 2021
SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE EXTRACT(MONTH FROM bc.bill_date) = 11
AND EXTRACT(YEAR FROM bc.bill_date) = 2021
GROUP BY bc.booking_id;

-- Q3: Bills > 1000 in Oct 2021
SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE EXTRACT(MONTH FROM bc.bill_date) = 10
AND EXTRACT(YEAR FROM bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;

-- Q4: Most & least ordered item
WITH item_orders AS (
    SELECT 
        EXTRACT(MONTH FROM bill_date) AS month,
        item_id,
        SUM(item_quantity) AS total_qty
    FROM booking_commercials
    WHERE EXTRACT(YEAR FROM bill_date) = 2021
    GROUP BY month, item_id
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rnk_desc,
        RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS rnk_asc
    FROM item_orders
)
SELECT *
FROM ranked
WHERE rnk_desc = 1 OR rnk_asc = 1;

-- Q5: Second highest bill customers
WITH bills AS (
    SELECT 
        b.user_id,
        bc.bill_id,
        EXTRACT(MONTH FROM bc.bill_date) AS month,
        SUM(bc.item_quantity * i.item_rate) AS bill_amount
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    JOIN bookings b ON bc.booking_id = b.booking_id
    WHERE EXTRACT(YEAR FROM bc.bill_date) = 2021
    GROUP BY b.user_id, bc.bill_id, month
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_amount DESC) AS rnk
    FROM bills
)
SELECT *
FROM ranked
WHERE rnk = 2;
