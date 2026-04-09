CREATE TABLE clinics (
    cid VARCHAR(50),
    clinic_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE customer (
    uid VARCHAR(50),
    name VARCHAR(100),
    mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
    oid VARCHAR(50),
    uid VARCHAR(50),
    cid VARCHAR(50),
    amount INT,
    datetime DATETIME,
    sales_channel VARCHAR(50)
);

CREATE TABLE expenses (
    eid VARCHAR(50),
    cid VARCHAR(50),
    description VARCHAR(100),
    amount INT,
    datetime DATETIME
);
INSERT INTO clinics VALUES
('c1', 'City Care', 'Hyderabad', 'Telangana', 'India'),
('c2', 'Health Plus', 'Hyderabad', 'Telangana', 'India'),
('c3', 'Wellness Center', 'Bangalore', 'Karnataka', 'India'),
('c4', 'MediLife', 'Chennai', 'Tamil Nadu', 'India');
INSERT INTO customer VALUES
('u1', 'John Doe', '9876543210'),
('u2', 'Jane Smith', '9123456780'),
('u3', 'Alice Brown', '9988776655'),
('u4', 'David Lee', '9012345678');
INSERT INTO clinic_sales VALUES
('o1', 'u1', 'c1', 2000, '2021-09-10 10:00:00', 'online'),
('o2', 'u2', 'c1', 3000, '2021-09-15 11:00:00', 'offline'),
('o3', 'u3', 'c2', 5000, '2021-10-05 09:30:00', 'online'),
('o4', 'u1', 'c2', 2500, '2021-10-10 14:00:00', 'referral'),
('o5', 'u4', 'c3', 4000, '2021-11-20 16:00:00', 'online'),
('o6', 'u2', 'c4', 3500, '2021-11-25 12:00:00', 'offline');
INSERT INTO expenses VALUES
('e1', 'c1', 'Supplies', 500, '2021-09-12 08:00:00'),
('e2', 'c1', 'Maintenance', 700, '2021-09-18 09:00:00'),
('e3', 'c2', 'Equipment', 1000, '2021-10-07 10:00:00'),
('e4', 'c2', 'Staff Salary', 1500, '2021-10-15 11:00:00'),
('e5', 'c3', 'Utilities', 800, '2021-11-22 13:00:00');
SELECT 
    sales_channel,
    SUM(amount) AS total_revenue
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY sales_channel;
SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;
WITH revenue AS (
    SELECT 
        EXTRACT(MONTH FROM datetime) AS month,
        SUM(amount) AS total_revenue
    FROM clinic_sales
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY EXTRACT(MONTH FROM datetime)
),
expense AS (
    SELECT 
        EXTRACT(MONTH FROM datetime) AS month,
        SUM(amount) AS total_expense
    FROM expenses
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY EXTRACT(MONTH FROM datetime)
)
SELECT 
    r.month,
    r.total_revenue,
    e.total_expense,
    (r.total_revenue - e.total_expense) AS profit,
    CASE 
        WHEN (r.total_revenue - e.total_expense) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM revenue r
JOIN expense e ON r.month = e.month;
WITH clinic_profit AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE EXTRACT(MONTH FROM cs.datetime) = 9
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
        RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 1;
WITH clinic_profit AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
    WHERE EXTRACT(MONTH FROM cs.datetime) = 9
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 2;
