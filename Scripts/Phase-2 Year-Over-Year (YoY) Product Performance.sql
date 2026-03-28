/* ---------------------------------------------------------------------------------------------------
PHASE 2: YEAR-OVER-YEAR (YoY) PRODUCT PERFORMANCE
Business Goal: Identify which products are outperforming their historical averages and PY sales.
---------------------------------------------------------------------------------------------------
*/

WITH Yearly_Product_Sales AS (
    SELECT
        p.Product_Name,
        DATEPART(year, f.Order_Date) AS Order_Year,
        SUM(f.Sales_Amount) AS Current_Sales
    FROM fact_sales f
    LEFT JOIN dim_products p ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL
    GROUP BY p.Product_Name, DATEPART(year, f.Order_Date)
)
SELECT
    Order_Year,
    Product_Name,
    Current_Sales,
    
    -- Compare to historical average
    AVG(Current_Sales) OVER(PARTITION BY product_name) AS Historic_AVG_Sales,
    
    -- YoY Growth using LAG()
    LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) AS Previous_Year_Sales,
    CASE
        WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN Current_Sales - LAG(Current_Sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS YoY_Performance
FROM Yearly_Product_Sales
ORDER BY Product_Name, Order_Year;