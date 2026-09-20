# Balanced Tree Clothing Co.

> Case Study 7 of Danny Ma's [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-7/)

## Business problem

Balanced Tree Clothing Co. sells clothing and lifestyle products across mens and womens categories. The merchandising team needs a repeatable monthly reporting script that explains overall sales, transaction behavior, product performance, discount impact, and product hierarchy construction.

## Tools used

- PostgreSQL
- CTEs and subqueries
- `JOIN`, `GROUP BY`, and window functions
- Percentiles with `PERCENTILE_CONT`
- Market basket analysis with self-joins
- Recursive CTEs for hierarchy reconstruction

## Data model

| Table | Description |
| --- | --- |
| `sales` | Product-level transaction records with quantity, price, discount, member flag, and timestamp |
| `product_details` | Denormalized product catalog with category, segment, style, and pricing fields |
| `product_hierarchy` | Category, segment, and style hierarchy used for the bonus reconstruction challenge |
| `product_prices` | Product IDs and prices used to recreate `product_details` |

## Key findings

- Balanced Tree sold **45,216 items** and generated **$1,289,453** in gross revenue before discounts.
- Total discounts across all transactions were **$156,229.14**, averaging **$62.49 per transaction**.
- The business had **2,500 unique transactions**, with an average of **6 unique products** per transaction.
- Member transactions represented about **60%** of transactions, while non-member transactions represented about **40%**.
- The top 3 products by gross revenue were **Blue Polo Shirt - Mens**, **Grey Fashion Jacket - Womens**, and **White Tee Shirt - Mens**.
- Mens products generated **55.38%** of gross revenue, compared with **44.62%** from Womens products.
- The most common 3-product basket was **White Tee Shirt - Mens**, **Grey Fashion Jacket - Womens**, and **Teal Button Up Shirt - Mens**, appearing **352 times**.

## Questions answered

### A. High Level Sales Analysis

1. Total quantity sold
2. Total revenue before discounts
3. Total discount amount

### B. Transaction Analysis

4. Unique transactions
5. Average unique products per transaction
6. Revenue percentiles per transaction
7. Average discount value per transaction
8. Member versus non-member transaction split
9. Average revenue by member status

### C. Product Analysis

10. Top products by revenue
11. Segment-level quantity, revenue, and discounts
12. Top-selling product by segment
13. Category-level quantity, revenue, and discounts
14. Top-selling product by category
15. Revenue split by product within each segment
16. Revenue split by segment within each category
17. Revenue split by category
18. Product transaction penetration
19. Most common 3-product transaction combination

### D. Bonus Challenge

20. Recreate the `product_details` table from product hierarchy and price tables

## Run the analysis

1. Load the Balanced Tree dataset from the challenge setup.
2. Run the queries in [solutions.sql](solutions.sql) in a PostgreSQL-compatible SQL client.

The SQL uses the original `balanced_tree` schema names. If your tables are in a different schema, replace the table references accordingly.

## Files

- [solutions.sql](solutions.sql) - documented, runnable solutions for the reporting questions and bonus challenge

## Source

The data and prompts are provided by [Danny Ma's 8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-7/).
