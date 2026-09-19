-- Danny's Diner | 8 Week SQL Challenge, Case Study 1
-- PostgreSQL solutions

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
  s.customer_id,
  SUM(m.price) AS total_amount_spent
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS visit_days
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item(s) from the menu purchased by each customer?
WITH ranked_sales AS (
  SELECT
    s.customer_id,
    m.product_name,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
  FROM dannys_diner.sales AS s
  JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
)
SELECT DISTINCT customer_id, product_name
FROM ranked_sales
WHERE purchase_rank = 1
ORDER BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased?
SELECT
  m.product_name,
  COUNT(*) AS total_purchases
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY total_purchases DESC
LIMIT 1;

-- 5. Which item(s) was the most popular for each customer?
WITH item_counts AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS item_quantity
  FROM dannys_diner.sales AS s
  JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
  GROUP BY s.customer_id, m.product_name
), ranked_items AS (
  SELECT
    *,
    RANK() OVER (PARTITION BY customer_id ORDER BY item_quantity DESC) AS item_rank
  FROM item_counts
)
SELECT customer_id, product_name, item_quantity
FROM ranked_items
WHERE item_rank = 1
ORDER BY customer_id, product_name;

-- 6. Which item was purchased first after each customer became a member?
WITH member_sales AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS purchase_rank
  FROM dannys_diner.sales AS s
  JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
  JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
  WHERE s.order_date >= mb.join_date
)
SELECT customer_id, order_date, product_name
FROM member_sales
WHERE purchase_rank = 1
ORDER BY customer_id, product_name;

-- 7. Which item was purchased just before each customer became a member?
WITH pre_member_sales AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS purchase_rank
  FROM dannys_diner.sales AS s
  JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
  JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
  WHERE s.order_date < mb.join_date
)
SELECT customer_id, order_date, product_name
FROM pre_member_sales
WHERE purchase_rank = 1
ORDER BY customer_id, product_name;

-- 8. What is the total number of items and amount spent for each member before joining?
SELECT
  s.customer_id,
  COUNT(*) AS total_items,
  SUM(m.price) AS total_amount_spent
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 9. If every $1 spent is worth 10 points and sushi earns 2× points,
-- how many points does each customer have?
SELECT
  s.customer_id,
  SUM(m.price * 10 * CASE WHEN m.product_name = 'sushi' THEN 2 ELSE 1 END) AS points
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10. How many points do A and B have at the end of January if every item
-- earns 2× points during the first week of membership (including join day)?
SELECT
  s.customer_id,
  SUM(
    m.price * 10 * CASE
      WHEN s.order_date BETWEEN mb.join_date AND mb.join_date + INTERVAL '6 days' THEN 2
      WHEN m.product_name = 'sushi' THEN 2
      ELSE 1
    END
  ) AS points
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
WHERE s.order_date <= DATE '2021-01-31'
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 11. Join All The Things: show each sale with membership status.
SELECT
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  CASE WHEN s.order_date >= mb.join_date THEN 'Y' ELSE 'N' END AS member
FROM dannys_diner.sales AS s
JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
LEFT JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
ORDER BY s.customer_id, s.order_date, m.product_name;

-- 12. Rank All The Things: rank purchases only after a customer becomes a member.
WITH joined_sales AS (
  SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE WHEN s.order_date >= mb.join_date THEN 'Y' ELSE 'N' END AS member
  FROM dannys_diner.sales AS s
  JOIN dannys_diner.menu AS m ON m.product_id = s.product_id
  LEFT JOIN dannys_diner.members AS mb ON mb.customer_id = s.customer_id
)
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  member,
  CASE
    WHEN member = 'Y' THEN DENSE_RANK() OVER (PARTITION BY customer_id, member ORDER BY order_date)
  END AS ranking
FROM joined_sales
ORDER BY customer_id, order_date, product_name;
