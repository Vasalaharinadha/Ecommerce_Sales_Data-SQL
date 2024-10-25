select * from student;
--1 Top 5 Most Frequently Sold Products by Category
WITH ranked_products AS (
    SELECT product_category,product_detail, COUNT(*) AS sales_frequency, ROW_NUMBER() OVER ( PARTITION BY product_category 
        ORDER BY COUNT(*) DESC) AS rank FROM student GROUP BY product_category, product_detail;
)
SELECT product_category, product_detail, sales_frequency FROM ranked_products WHERE rank <= 5; 


--2 Total Revenue by Store in January 2023
select store_id,sum(transaction_qty*unit_price) as total from student where transaction_date between '2023-01-01' and '2023-01-31'
	group by store_id;


--3 Unique Product Types in 'Lower Manhattan' Store
select distinct(product_type) as uniqu from student where store_location='Lower Manhattan' order by uniqu asc ;


--4 Transactions Before 12:00 PM
select  COUNT(*) AS total_transactions_before_noon from student where transaction_time<='12:00:00'::time;


--5 Average Revenue Per Transaction During Peak and Non-Peak Hours
select * from student;
SELECT 
    store_location,
    product_category,
    AVG(CASE WHEN transaction_time BETWEEN '07:00:00' AND '09:00:00' THEN (transaction_qty*unit_price) ELSE NULL END) AS avg_revenue_peak_hours,
    AVG(CASE WHEN transaction_time NOT BETWEEN '07:00:00' AND '09:00:00' THEN (transaction_qty*unit_price) ELSE NULL END) AS avg_revenue_non_peak_hours
FROM student
GROUP BY store_location, product_category;


--6 Product with Most Price Fluctuations
SELECT 
    product_detail,
    MAX(unit_price) - MIN(unit_price) AS price_fluctuation
FROM student
GROUP BY product_detail
ORDER BY price_fluctuation DESC
LIMIT 1;


--7 Products Sold in Every Store
WITH store_counts AS (
    SELECT 
        product_id, 
        COUNT(DISTINCT store_id) AS stores_sold_in
    FROM student
    GROUP BY product_id
),
total_stores AS (
    SELECT COUNT(DISTINCT store_id) AS total_store_count
    FROM student
)
SELECT 
    sc.product_id  
FROM store_counts sc, total_stores ts
WHERE sc.stores_sold_in = ts.total_store_count;
select * from student;
--8 Top 5 Days with Largest Deviation from Average Daily Transaction Quantity
WITH cte AS (
    SELECT 
        transaction_date,
        SUM(transaction_qty) AS total_qty
    FROM student
    GROUP BY transaction_date
    ORDER BY transaction_date ASC
),
cte_avg AS (
    SELECT 
        AVG(total_qty) AS avg_total
    FROM cte
),
deviation AS (
    SELECT 
        c.transaction_date,
        c.total_qty,
        ABS(c.total_qty - a.avg_total) AS deviation
    FROM cte c, cte_avg a
)
SELECT 
    transaction_date,
    total_qty,
    deviation
FROM deviation
ORDER BY deviation DESC
LIMIT 5;

--9 Stores with Average Unit Price Greater Than $2.50
SELECT 
    store_id,
    store_location,
    AVG(unit_price) AS avg_unit_price
FROM student
GROUP BY store_id, store_location
HAVING AVG(unit_price) > 2.50;

--10 Product with Highest Average Sales Quantity Per Transaction in Each Store
WITH avg_qty_per_transaction AS (
    SELECT
        store_id,
        product_id, 
        AVG(transaction_qty) AS avg_qty
    FROM student
    GROUP BY store_id, product_id
),
ranked_products AS (
    SELECT
        store_id,
        product_id,  
        avg_qty,
        RANK() OVER(PARTITION BY store_id ORDER BY avg_qty DESC) AS rank
    FROM avg_qty_per_transaction
)
SELECT
    store_id,
    product_id, 
    avg_qty
FROM ranked_products
WHERE rank = 1;
















