# WalmartSalesDatasetAnalysis

## About 

This project analyzes historical Walmart sales data to uncover key insights and provide data-driven recommendations for improving sales strategies and optimizing business operations.

## Project Goal
The primary objective of this analysis is to:

Identify the top-performing branches and products.

Analyze sales trends over time for different product lines.

Explore customer behavior patterns, such as purchasing habits and preferences.

The ultimate aim is to use these insights to improve sales strategies, enhance customer engagement, and optimize business performance.

## Dataset 
The dataset used for this project was obtained from the Kaggle Walmart Sales Forecasting Competition. It contains historical sales data for 45 Walmart stores, including various departments and detailed information on weekly sales. The dataset also includes important external factors that can influence sales, such as special holiday markdown events, which adds a layer of complexity to the analysis (https://www.kaggle.com/c/walmart-recruiting-store-sales-forecasting).

## Technologies
The primary tool used for this project was MySQL. I used it to create the database and tables, load the dataset, and perform all the data cleaning, feature engineering, and exploratory data analysis through SQL queries.

## Methodology 
1. **Data Wrangling:** This is the first step where inspection of data is done to make sure **NULL** values and missing values are detected and data replacement methods are used to replace, missing or **NULL** values.

> 1. Created a Database
> 2. Created table and insert the data.
> 3. When we created our database tables, we made sure that every field had a value by using the NOT NULL constraint. This means there are no null values to select.

2. **Feature Engineering:** Created New Columns.

> 1. Added a new column named time_of_day to categorize sales into Morning, Afternoon, and Evening, which helps us understand when the most sales occur.

> 2. Added a new column named day_name to extract the day of the week for each transaction, helping us identify the busiest day for each branch.
> 3. Added a new column named month_name to list the month of each sale, which helps us determine which months have the highest sales and profit.

2. Exploratory Data Analysis (EDA): The purpose of this analysis is to answer the project's questions and achieve its key aims.
3. Conclusion:

# Key Business Questions

## Market and Branch Analysis

How many unique cities are in the dataset?

How many unique branches does the data have?

Which city and branch generate the most total revenue?

Which branche sold more products than the average across all branches?

## Product Performance

Which product lines have the highest total quantity sold in each branch?

What are all product lines ranked by total revenue and VAT?

Which product line has the highest total revenue and VAT?

What is the overall average sales across all product lines?

How are product lines classified as "Good" or "Bad" based on whether their sales are greater than the overall average?

What is the average rating for each product line?

## Sales and Revenue

What is the total revenue and COGS by month to identify seasonal trends?

What is the monthly sales summary, including total revenue, COGS, gross profit, and gross margin percentage?

How many sales were made in each time of the day per weekday (e.g., on a Monday)?

Which customer type generates the most revenue?

## Customer and Rating Insights

What is the distribution of sales by gender, and which gender buys more?

What is the most common product line purchased by each gender?

What is the most common customer type?

What is the best average rating per day of the week?

Which day of the week has the best average ratings per branch?

What is the average customer rating per branch by time of day?

Which time of day does each branch receive the most customer ratings?


## Revenue And Profit Calculations
First, the Cost of Goods Sold (COGS) is simply the unit price multiplied by the quantity of items sold:

> COGS = unitsPrice * quantity

The Value Added Tax (VAT) is 5% of the COGS. This tax is then added to the COGS to get the final amount billed to the customer:

> $VAT = 5% * COGS $$ total(gross_sales) = VAT + COGS $

My Gross Profit (also known as Gross Income) is what's left after subtracting the COGS from the total sales:

> grossProfit(grossIncome)=total(gross_sales)−COGS.

Finally, the Gross Margin is the gross profit expressed as a percentage of the total revenue: 

> Gross Margin Percentage = (gross income / total revenue) * 100.
 

To make it clearer, let's use the first row of our data as an example:

With a Unit Price of $45.79 and a Quantity of 7, the COGS is $320.53.

The VAT is 5% of that, which comes to $16.03.

The Total billed to the customer is $320.53 + $16.03 = $336.56.

The Gross Income (or profit) for this sale is exactly the VAT amount, $16.03.

The Gross Margin percentage is then calculated as (16.03/336.56)≈4.76%.

Understanding these simple calculations is key to interpreting the sales and profitability metrics we'll be looking at throughout the analysis.

## Repository
All the code and SQL queries for this project are available in this repository. Feel free to explore the files and check out the code.





