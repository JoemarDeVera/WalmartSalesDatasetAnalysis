-- Create a Database named walmartSalesData.
CREATE DATABASE IF NOT EXISTS walmartSalesData;

-- Use the created Data base for Table Creation.
USE walmartsalesdata;

-- Create a Table inside of the database named sales.
CREATE TABLE IF NOT EXISTS sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL, 
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_pct FLOAT, 
gross_income DECIMAL(12, 4) NOT NULL,
rating FLOAT
);

-- Select sales to make sure the table is created.
SELECT * FROM sales;

-- Run this to copy the file path it shows and put the walmart csv file.
SHOW VARIABLES LIKE 'secure_file_priv';

-- This command loads data from the 'walmartsalesdata.csv' file into the 'sales' table.
-- It skips the first row (header) and uses a temporary variable '@date' to correctly
-- parse and format the date column from MM/DD/YYYY using STR_TO_DATE before insertion.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/walmartsalesdata.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    invoice_id, branch, city, customer_type, gender, product_line,
    unit_price, quantity, VAT, total, @date, time,
    payment_method, cogs, gross_margin_pct, gross_income, rating
)
SET
    date = STR_TO_DATE(SUBSTRING_INDEX(@date, ' ', 1), '%m/%d/%Y');



-- ------------------------------------------------------------
-- ------- Feature Engineering----------------------------
 
 -- This query selects the transaction time and categorizes it into 'Morning',
-- 'Afternoon', or 'Evening' based on the time range, creating a new column.
 
 SELECT
    time,
    CASE
        WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM sales;
 
 -- Adding column to sales table named time_of_day
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(10);

-- Updating table to fill the null values in time_of_day column
UPDATE sales
SET time_of_day =
    CASE
        WHEN time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
        WHEN time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END;
    
    
 -- Day_name
 SELECT
     date,
     DAYNAME(date) 
     AS name_of_day
     FROM sales;

-- added a column, named day_name which determines the day using date column
ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- Month_name
SELECT
    date,
    MONTHNAME(date)
    as month_name
    FROM sales;
    
-- added a column, named month_name which determines the month using the date column
ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ------------------------------------------------------------
-- ------------------ ANALYZE THE DATA  --------------------

-- How many unique cities does the data have?
SELECT 
    DISTINCT city
    FROM sales;
    
-- How many unique branch does the data have?
SELECT 
    DISTINCT branch
    FROM sales;
    
-- Market Reach and Branch Performance
SELECT
    city,
    branch,
    SUM(quantity) AS total_revenue
FROM
    sales
GROUP BY
    city,
    branch
ORDER BY
    total_revenue DESC;
    

-- Operational Efficiency and Seasonal Trends
-- Analyze total revenue and COGS by month to identify seasonal trends and the most profitable months
SELECT
    month_name AS month,
    SUM(total) AS total_revenue,
    SUM(cogs) AS total_cogs
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- Monthly sales summary showing revenue, COGS, profit, and profit margin
SELECT
    month_name AS month,
    SUM(total) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(total) - SUM(cogs) AS gross_profit,
    ((SUM(total) - SUM(cogs)) / SUM(total)) * 100 AS gross_margin_pct
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;

-- Total quantity of product sold by each branches
SELECT 
    branch,
    SUM(quantity) AS total_quantity_sold
FROM 
    sales
GROUP BY 
    branch
ORDER BY 
    total_quantity_sold DESC;


 -- Branches that sold more products than the average across all branches
 SELECT 
    branch,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (
    SELECT AVG(total_quantity) 
    FROM (
        SELECT SUM(quantity) AS total_quantity
        FROM sales
        GROUP BY branch
    ) AS branch_totals
);

-- Product lines with the highest total quantity sold
SELECT 
    product_line,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_line
ORDER BY total_quantity DESC
LIMIT 3;

-- quantity sold in each branch
SELECT 
    branch,
    product_line,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY branch, product_line
ORDER BY branch, total_quantity DESC;

-- All product lines ranked by total revenue and VAT
SELECT 
    product_line,
    SUM(total) AS total_revenue,
    SUM(VAT) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC, total_vat DESC;

-- Product line with the highest total revenue and VAT
SELECT 
    product_line,
    SUM(total) AS total_revenue,
    SUM(VAT) AS total_vat
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC, total_vat DESC
LIMIT 1;

-- Overall average sales across all product lines
SELECT 
    AVG(product_sales) AS avg_sales
FROM (
    SELECT SUM(total) AS product_sales
    FROM sales
    GROUP BY product_line
) AS avg_table;

-- Classify product lines as Good or Bad based on sales vs overall average sales
SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE 
        WHEN SUM(total) > (
            SELECT AVG(product_sales)
            FROM (
                SELECT SUM(total) AS product_sales
                FROM sales
                GROUP BY product_line
            ) AS avg_sales
        ) THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
GROUP BY product_line
ORDER BY total_sales DESC;

-- Show product lines with their sales, overall average sales, and classification Using Cross Join
SELECT 
    product_line,
    SUM(total) AS total_sales,
    avg_sales_table.avg_sales,
    CASE 
        WHEN SUM(total) > avg_sales_table.avg_sales THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM sales
CROSS JOIN (
    SELECT AVG(product_sales) AS avg_sales
    FROM (
        SELECT SUM(total) AS product_sales
        FROM sales
        GROUP BY product_line
    ) AS product_totals
) AS avg_sales_table
GROUP BY product_line, avg_sales_table.avg_sales
ORDER BY total_sales DESC;

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- This query counts the total number of sales transactions for each time of day 
-- (Morning, Afternoon, Evening) to identify which period has the most sales
SELECT 
    time_of_day,
    COUNT(*) AS total_sales
FROM 
    sales
GROUP BY 
    time_of_day
ORDER BY 
    total_sales DESC;


-- Analyze gender distribution and identify which gender buys more
SELECT 
    gender,
    COUNT(DISTINCT invoice_id) AS num_customers,
    SUM(quantity) AS total_products_bought,
    SUM(total) AS total_sales
FROM sales
GROUP BY gender
ORDER BY total_sales DESC;

-- All product lines ranked by quantity purchased per gender
SELECT 
    gender,
    product_line,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY gender, product_line
ORDER BY gender, total_quantity DESC;


-- Most common product line purchased by each gender
SELECT 
    gender,
    product_line,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY gender, product_line
HAVING SUM(quantity) = (
        SELECT MAX(qty) 
        FROM (
            SELECT 
                gender AS g, 
                product_line AS pl, 
                SUM(quantity) AS qty
            FROM sales
            GROUP BY gender, product_line
        ) AS sub
        WHERE sub.g = sales.gender
)
ORDER BY gender;


-- Best average rating per day (Monday–Sunday order) using existing day_name column
SELECT
    day_name,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_ratings
FROM sales
GROUP BY day_name
ORDER BY FIELD(day_name, 
               'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;


-- This shows the average customer rating per day and per branch (A, B, C)
SELECT
    branch,
    time_of_day,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch IN ('A', 'B', 'C')
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- This finds the time of day when each branch (A, B, C) receives the MOST customer ratings
SELECT branch, time_of_day, num_ratings
FROM (
    SELECT
        branch,
        time_of_day,
        COUNT(*) AS num_ratings,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rn
    FROM sales
    GROUP BY branch, time_of_day
) ranked
WHERE rn = 1;


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

 -- This query finds the day of the week when each branch (A, B, C) receives the highest average rating
SELECT branch, day_name, avg_rating
FROM (
    SELECT 
        branch, 
        day_name, 
        ROUND(AVG(rating), 2) AS avg_rating,
        ROW_NUMBER() OVER (
            PARTITION BY branch 
            ORDER BY AVG(rating) DESC
        ) AS rn
    FROM sales
    GROUP BY branch, day_name
) ranked
WHERE rn = 1;




USE walmartsalesdata;



SELECT
	day_name,
	SUM(total) AS total_sales
FROM sales
GROUP BY day_name 
ORDER BY total_sales DESC;



SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type 
ORDER BY total_revenue DESC;

SELECT 
    gender,
    COUNT(DISTINCT invoice_id) AS num_customers,
    SUM(quantity) AS total_products_bought,
    SUM(total) AS total_sales
FROM sales
GROUP BY gender
ORDER BY total_sales DESC;


## Purchase count by gender
SELECT 
    gender,
    product_line,
    COUNT(*) AS purchase_count
FROM sales
GROUP BY gender, product_line
ORDER BY gender, purchase_count DESC;

## Total sales of product by gender
SELECT 
    gender,
    product_line,
    SUM(total) AS total_sales,
    COUNT(*) AS number_of_purchases,
    AVG(total) AS average_purchase_value
FROM sales
GROUP BY gender, product_line
ORDER BY gender, total_sales DESC;

SELECT 
    day_name,
    AVG(rating) AS average_rating,
    COUNT(*) AS number_of_ratings,
    MIN(rating) AS lowest_rating,
    MAX(rating) AS highest_rating
FROM sales
GROUP BY day_name
ORDER BY average_rating DESC;

## Average rating per branch by day
SELECT 
    branch,
    day_name,
    AVG(rating) AS average_rating,
    COUNT(*) AS number_of_ratings,
    ROUND(AVG(rating), 2) AS rounded_avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, average_rating DESC;

## Average rating by the time of day
SELECT 
    branch,
    time_of_day,
    AVG(rating) AS average_rating,
    COUNT(*) AS number_of_ratings,
    ROUND(AVG(rating), 2) AS rounded_avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, average_rating DESC;



## Best rating by the time of day each branch
WITH branch_time_ratings AS (
    SELECT 
        branch,
        time_of_day,
        COUNT(*) AS rating_count,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_by_branch
    FROM sales
    GROUP BY branch, time_of_day
)
SELECT 
    branch,
    time_of_day AS busiest_time,
    rating_count AS most_ratings_received
FROM branch_time_ratings
WHERE rank_by_branch = 1
ORDER BY branch;





SELECT * 
FROM sales;