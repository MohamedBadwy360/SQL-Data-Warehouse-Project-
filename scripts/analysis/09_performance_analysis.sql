/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
===============================================================================
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;



/* Analyze the yearly performance of categories by comparing their sales 
to both the average sales performance of the categories and the previous year's sales */
WITH yearly_categories_sales AS (
	SELECT
		p.category,
		YEAR(s.order_date) AS order_year,
		SUM(s.sales_amount) AS total_sales
	FROM gold.fact_sales AS s
	LEFT JOIN gold.dim_products AS p
	ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY p.category, YEAR(s.order_date)
)

SELECT
	*,
	AVG(total_sales) OVER(PARTITION BY category) AS avg_category_sales,
	total_sales - AVG(total_sales) OVER(PARTITION BY category) AS diff_avg,
	CASE
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY category) > 0 THEN 'Above Avg'
		WHEN total_sales - AVG(total_sales) OVER(PARTITION BY category) < 0 THEN 'Below Avg'
		ELSE 'Avg'
	END AS avg_change,
	LAG(total_sales) OVER(PARTITION BY category ORDER BY order_year ASC) AS py_sales,
	total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY order_year ASC) AS diff_py,
	CASE
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY order_year ASC) > 0 THEN '+YoY'
		WHEN total_sales - LAG(total_sales) OVER(PARTITION BY category ORDER BY order_year ASC) < 0 THEN '-YoY'
		ELSE 'No Change'
	END AS yoy_change
FROM yearly_products_sales
ORDER BY category, order_year
