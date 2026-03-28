/* ---------------------------------------------------------------------------------------------------
PHASE 1: TEMPORAL & CUMULATIVE ANALYSIS
Business Goal: Understand our sales velocity. Are we growing month-over-month? 
---------------------------------------------------------------------------------------------------
*/

-- 1. High-Level Yearly & Monthly Sales Aggregations
SELECT
    DATETRUNC(month, order_date) AS Order_Month,
    COUNT(DISTINCT customer_key) AS Total_Active_Customers,
    SUM(Sales_amount) AS Total_Revenue,
    SUM(quantity) AS Total_Units_Sold
FROM fact_sales
WHERE order_Date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- 2. Running Totals (Cumulative Revenue) using Window Functions
SELECT
    Order_Date,
    Total_Sales,
    SUM(Total_Sales) OVER(ORDER BY Order_Date) AS Cumulative_Revenue,
    SUM(AVG_Price) OVER(ORDER BY Order_Date) AS Cumulative_AVG_Price
FROM (
    SELECT
        DATETRUNC(month, order_date) AS Order_Date,
        SUM(sales_amount) AS Total_Sales,
        AVG(price) AS AVG_Price
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
) t;