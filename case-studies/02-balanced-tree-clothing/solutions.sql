-- Balanced Tree Clothing Co.
-- Case Study 7 of Danny Ma's 8 Week SQL Challenge
-- SQL dialect: PostgreSQL

/* -------------------------------------------------------------------------- */
/* A. High Level Sales Analysis                                                */
/* -------------------------------------------------------------------------- */

-- 1. What was the total quantity sold for all products?
SELECT
  SUM(qty) AS total_quantity
FROM balanced_tree.sales;

-- 2. What is the total generated revenue for all products before discounts?
SELECT
  SUM(qty * price) AS total_revenue
FROM balanced_tree.sales;

-- 3. What was the total discount amount for all products?
SELECT
  ROUND(SUM(qty * price * discount::NUMERIC / 100), 2) AS total_discount
FROM balanced_tree.sales;

/* -------------------------------------------------------------------------- */
/* B. Transaction Analysis                                                     */
/* -------------------------------------------------------------------------- */

-- 4. How many unique transactions were there?
SELECT
  COUNT(DISTINCT txn_id) AS unique_transactions
FROM balanced_tree.sales;

-- 5. What is the average unique products purchased in each transaction?
WITH transaction_products AS (
  SELECT
    txn_id,
    COUNT(DISTINCT prod_id) AS unique_products
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT
  ROUND(AVG(unique_products)) AS avg_unique_products
FROM transaction_products;

-- 6. What are the 25th, 50th, and 75th percentile values for revenue per transaction?
WITH transaction_revenue AS (
  SELECT
    txn_id,
    SUM(qty * price) AS revenue
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) AS pct_25,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) AS pct_50,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) AS pct_75
FROM transaction_revenue;

-- 7. What is the average discount value per transaction?
WITH transaction_discounts AS (
  SELECT
    txn_id,
    SUM(qty * price * discount::NUMERIC / 100) AS total_discount
  FROM balanced_tree.sales
  GROUP BY txn_id
)
SELECT
  ROUND(AVG(total_discount), 2) AS avg_discount_per_transaction
FROM transaction_discounts;

-- 8. What is the percentage split of all transactions for members vs non-members?
WITH member_transactions AS (
  SELECT
    member,
    COUNT(DISTINCT txn_id) AS transactions
  FROM balanced_tree.sales
  GROUP BY member
)
SELECT
  member,
  transactions,
  ROUND(100 * transactions::NUMERIC / SUM(transactions) OVER (), 2) AS transaction_percentage
FROM member_transactions
ORDER BY member;

-- 9. What is the average revenue for member transactions and non-member transactions?
WITH transaction_revenue AS (
  SELECT
    member,
    txn_id,
    SUM(qty * price) AS revenue
  FROM balanced_tree.sales
  GROUP BY member, txn_id
)
SELECT
  member,
  ROUND(AVG(revenue), 2) AS avg_revenue
FROM transaction_revenue
GROUP BY member
ORDER BY member;

/* -------------------------------------------------------------------------- */
/* C. Product Analysis                                                         */
/* -------------------------------------------------------------------------- */

-- 10. What are the top 3 products by total revenue before discount?
SELECT
  product_details.product_id,
  product_details.product_name,
  SUM(sales.qty * sales.price) AS total_revenue
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY
  product_details.product_id,
  product_details.product_name
ORDER BY total_revenue DESC
LIMIT 3;

-- 11. What is the total quantity, revenue, and discount for each segment?
SELECT
  product_details.segment_id,
  product_details.segment_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  ROUND(SUM(sales.qty * sales.price * sales.discount::NUMERIC / 100), 2) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY
  product_details.segment_id,
  product_details.segment_name
ORDER BY total_revenue DESC;

-- 12. What is the top selling product for each segment?
WITH ranked_segment_products AS (
  SELECT
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name,
    SUM(sales.qty) AS product_quantity,
    RANK() OVER (
      PARTITION BY product_details.segment_id
      ORDER BY SUM(sales.qty) DESC
    ) AS quantity_rank
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name
)
SELECT
  segment_id,
  segment_name,
  product_id,
  product_name,
  product_quantity
FROM ranked_segment_products
WHERE quantity_rank = 1
ORDER BY product_quantity DESC;

-- 13. What is the total quantity, revenue, and discount for each category?
SELECT
  product_details.category_id,
  product_details.category_name,
  SUM(sales.qty) AS total_quantity,
  SUM(sales.qty * sales.price) AS total_revenue,
  ROUND(SUM(sales.qty * sales.price * sales.discount::NUMERIC / 100), 2) AS total_discount
FROM balanced_tree.sales
INNER JOIN balanced_tree.product_details
  ON sales.prod_id = product_details.product_id
GROUP BY
  product_details.category_id,
  product_details.category_name
ORDER BY total_revenue DESC;

-- 14. What is the top selling product for each category?
WITH ranked_category_products AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
    product_details.product_id,
    product_details.product_name,
    SUM(sales.qty) AS product_quantity,
    RANK() OVER (
      PARTITION BY product_details.category_id
      ORDER BY SUM(sales.qty) DESC
    ) AS quantity_rank
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name,
    product_details.product_id,
    product_details.product_name
)
SELECT
  category_id,
  category_name,
  product_id,
  product_name,
  product_quantity
FROM ranked_category_products
WHERE quantity_rank = 1
ORDER BY product_quantity DESC;

-- 15. What is the percentage split of revenue by product for each segment?
WITH product_revenue AS (
  SELECT
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name,
    SUM(sales.qty * sales.price) AS product_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.segment_id,
    product_details.segment_name,
    product_details.product_id,
    product_details.product_name
)
SELECT
  segment_id,
  segment_name,
  product_id,
  product_name,
  product_revenue,
  ROUND(
    100 * product_revenue::NUMERIC / SUM(product_revenue) OVER (PARTITION BY segment_id),
    2
  ) AS segment_product_percentage
FROM product_revenue
ORDER BY segment_id, segment_product_percentage DESC;

-- 16. What is the percentage split of revenue by segment for each category?
WITH segment_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
    product_details.segment_id,
    product_details.segment_name,
    SUM(sales.qty * sales.price) AS segment_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name,
    product_details.segment_id,
    product_details.segment_name
)
SELECT
  category_id,
  category_name,
  segment_id,
  segment_name,
  segment_revenue,
  ROUND(
    100 * segment_revenue::NUMERIC / SUM(segment_revenue) OVER (PARTITION BY category_id),
    2
  ) AS category_segment_percentage
FROM segment_revenue
ORDER BY category_id, category_segment_percentage DESC;

-- 17. What is the percentage split of total revenue by category?
WITH category_revenue AS (
  SELECT
    product_details.category_id,
    product_details.category_name,
    SUM(sales.qty * sales.price) AS category_revenue
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.category_id,
    product_details.category_name
)
SELECT
  category_id,
  category_name,
  category_revenue,
  ROUND(100 * category_revenue::NUMERIC / SUM(category_revenue) OVER (), 2) AS category_revenue_percentage
FROM category_revenue
ORDER BY category_id;

-- 18. What is the total transaction penetration for each product?
WITH product_transactions AS (
  SELECT
    product_details.product_id,
    product_details.product_name,
    COUNT(DISTINCT sales.txn_id) AS product_transactions
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
  GROUP BY
    product_details.product_id,
    product_details.product_name
),
total_transactions AS (
  SELECT COUNT(DISTINCT txn_id) AS transaction_count
  FROM balanced_tree.sales
)
SELECT
  product_id,
  product_name,
  product_transactions,
  ROUND(100 * product_transactions::NUMERIC / transaction_count, 2) AS penetration_percentage
FROM product_transactions
CROSS JOIN total_transactions
ORDER BY penetration_percentage DESC, product_name;

-- 19. What is the most common combination of any 3 products in a single transaction?
WITH transaction_products AS (
  SELECT DISTINCT
    sales.txn_id,
    product_details.product_id,
    product_details.product_name
  FROM balanced_tree.sales
  INNER JOIN balanced_tree.product_details
    ON sales.prod_id = product_details.product_id
),
three_product_combinations AS (
  SELECT
    product_1.product_name AS product_1,
    product_2.product_name AS product_2,
    product_3.product_name AS product_3,
    COUNT(*) AS transaction_count
  FROM transaction_products AS product_1
  INNER JOIN transaction_products AS product_2
    ON product_1.txn_id = product_2.txn_id
    AND product_1.product_id < product_2.product_id
  INNER JOIN transaction_products AS product_3
    ON product_1.txn_id = product_3.txn_id
    AND product_2.product_id < product_3.product_id
  GROUP BY
    product_1.product_name,
    product_2.product_name,
    product_3.product_name
)
SELECT
  product_1,
  product_2,
  product_3,
  transaction_count
FROM three_product_combinations
ORDER BY transaction_count DESC
LIMIT 1;

/* -------------------------------------------------------------------------- */
/* D. Bonus Challenge                                                          */
/* -------------------------------------------------------------------------- */

-- 20. Recreate balanced_tree.product_details from product_hierarchy and product_prices.
WITH RECURSIVE hierarchy AS (
  SELECT
    id,
    parent_id,
    level_text,
    level_name,
    id AS category_id,
    level_text AS category_name,
    NULL::INTEGER AS segment_id,
    NULL::TEXT AS segment_name,
    NULL::INTEGER AS style_id,
    NULL::TEXT AS style_name
  FROM balanced_tree.product_hierarchy
  WHERE level_name = 'Category'

  UNION ALL

  SELECT
    child.id,
    child.parent_id,
    child.level_text,
    child.level_name,
    parent.category_id,
    parent.category_name,
    CASE WHEN child.level_name = 'Segment' THEN child.id ELSE parent.segment_id END AS segment_id,
    CASE WHEN child.level_name = 'Segment' THEN child.level_text ELSE parent.segment_name END AS segment_name,
    CASE WHEN child.level_name = 'Style' THEN child.id ELSE parent.style_id END AS style_id,
    CASE WHEN child.level_name = 'Style' THEN child.level_text ELSE parent.style_name END AS style_name
  FROM hierarchy AS parent
  INNER JOIN balanced_tree.product_hierarchy AS child
    ON child.parent_id = parent.id
)
SELECT
  product_prices.product_id,
  product_prices.price,
  CONCAT(hierarchy.style_name, ' ', hierarchy.segment_name, ' - ', hierarchy.category_name) AS product_name,
  hierarchy.category_id,
  hierarchy.segment_id,
  hierarchy.style_id,
  hierarchy.category_name,
  hierarchy.segment_name,
  hierarchy.style_name
FROM hierarchy
INNER JOIN balanced_tree.product_prices
  ON hierarchy.id = product_prices.id
WHERE hierarchy.level_name = 'Style'
ORDER BY product_prices.id;
