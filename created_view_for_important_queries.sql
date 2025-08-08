
CREATE VIEW total_quantity_sold_branch AS
SELECT 
    branch,
    SUM(quantity) AS total_quantity_sold
FROM 
    sales
GROUP BY 
    branch
ORDER BY 
    total_quantity_sold DESC;


CREATE VIEW revenue_by_city_branch AS
SELECT
    city,
    branch,
    SUM(gross_income) AS total_revenue
FROM
    sales
GROUP BY
    city,
    branch
ORDER BY
    total_revenue DESC;


CREATE VIEW revenue_cogs_profit_branch AS
SELECT
    month_name AS month,
    SUM(total) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(total) - SUM(cogs) AS gross_profit,
    ((SUM(total) - SUM(cogs)) / SUM(total)) * 100 AS gross_margin_pct
FROM sales
GROUP BY month
ORDER BY total_revenue DESC;


CREATE VIEW product_line_total_sales AS
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

CREATE VIEW sales_transaction_time_of_day AS 
SELECT 
    time_of_day,
    COUNT(*) AS total_sales
FROM 
    sales
GROUP BY 
    time_of_day
ORDER BY 
    total_sales DESC;



CREATE VIEW sales_summary_by_gender AS
SELECT 
    gender,
    COUNT(DISTINCT invoice_id) AS num_customers,
    SUM(quantity) AS total_products_bought,
    SUM(total) AS total_sales
FROM sales
GROUP BY gender
ORDER BY total_sales DESC;


CREATE VIEW product_line_purchase_by_gender AS 
SELECT 
    gender,
    COUNT(DISTINCT invoice_id) AS num_customers,
    SUM(quantity) AS total_products_bought,
    SUM(total) AS total_sales
FROM sales
GROUP BY gender
ORDER BY total_sales DESC;


CREATE VIEW ave_rating_total_rating_by_day AS 
SELECT
    day_name,
    ROUND(AVG(rating), 2) AS avg_rating,
    COUNT(*) AS total_ratings
FROM sales
GROUP BY day_name
ORDER BY FIELD(day_name, 
               'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


CREATE VIEW common_user_type AS 
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;


CREATE VIEW day_week_ratings AS 
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;


