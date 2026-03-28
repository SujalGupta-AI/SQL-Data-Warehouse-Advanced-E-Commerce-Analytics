/* ---------------------------------------------------------------------------------------------------
PHASE 3: CATEGORY CONTRIBUTION & COST SEGMENTATION
Business Goal: Determine how different product lines contribute to the overall revenue pie.
---------------------------------------------------------------------------------------------------
*/

WITH Category_Analysis AS (
    SELECT
        Category,
        SUM(Sales_amount) AS Sales
    FROM dim_products p
    LEFT JOIN fact_sales f ON f.product_key = p.product_key
    WHERE Category IS NOT NULL AND Sales_amount IS NOT NULL
    GROUP BY Category
)
SELECT
    Category,
    Sales,
    SUM(Sales) OVER() AS Total_Global_Sales,
    -- Calculate Part-to-Whole Percentage dynamically
    CONCAT(ROUND(CAST(Sales AS FLOAT) / SUM(Sales) OVER() * 100, 2), '%') AS Revenue_Contribution
FROM Category_Analysis
ORDER BY Sales DESC;