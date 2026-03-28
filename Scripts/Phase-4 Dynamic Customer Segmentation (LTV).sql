/* ---------------------------------------------------------------------------------------------------
PHASE 4: DYNAMIC CUSTOMER SEGMENTATION (LTV)
Business Goal: Automatically classify customers into VIPs, Regulars, and New users based on spend.
---------------------------------------------------------------------------------------------------
*/

WITH Customer_Spending_Behaviour AS (
    SELECT
        c.Customer_Key,
        SUM(f.Sales_Amount) AS Lifetime_Value_Sales,
        DATEDIFF(month, MIN(f.order_Date), MAX(f.order_Date)) AS Lifespan_Months
    FROM dim_customers c
    LEFT JOIN fact_sales f ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
)
SELECT
    Customer_Segment,
    COUNT(Customer_Segment) AS Total_Users,
    CONCAT(ROUND(CAST(COUNT(Customer_Segment) AS FLOAT) / SUM(COUNT(Customer_Segment)) OVER() * 100, 2), '%') AS Audience_Makeup
FROM(
    SELECT
        Customer_Key,
        CASE	
            WHEN Lifespan_Months >= 12 AND Lifetime_Value_Sales >= 5000 THEN 'VIP'
            WHEN Lifespan_Months >= 12 AND Lifetime_Value_Sales < 5000 THEN 'Regular'
            WHEN Lifespan_Months < 12 THEN 'New'
        END AS Customer_Segment
    FROM Customer_Spending_Behaviour
) t
WHERE Customer_Segment IS NOT NULL
GROUP BY Customer_Segment
ORDER BY Total_Users DESC;