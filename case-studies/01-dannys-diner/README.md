# Danny's Diner

> Case Study 1 of Danny Ma's [8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-1/)

## Business problem

Danny's Diner is a Japanese restaurant serving sushi, curry, and ramen. Danny needs to understand customer visit patterns, spending, favorite dishes, and loyalty-program behavior so that he can create a more personal customer experience.

## Tools used

- PostgreSQL
- CTEs and subqueries
- `JOIN`, `GROUP BY`, and conditional aggregation
- Window functions: `RANK()` and `DENSE_RANK()`

## Data model

| Table | Description |
| --- | --- |
| `sales` | Customer purchases, including purchase date and product ID |
| `menu` | Product names and prices |
| `members` | Loyalty-program join dates |

## Key findings

- Customer **A** spent the most overall (**$76**); customer **B** spent **$74** and customer **C** spent **$36**.
- **Ramen** was the most-purchased menu item, bought **8 times**.
- Customer A's favorite item was ramen; every menu item tied as customer B's most popular item; customer C purchased only ramen.
- Customer A earned **860 points**, customer B earned **940 points**, and customer C earned **360 points** under the standard sushi multiplier.
- By the end of January, the first-week member promotion produced **1,370 points for A** and **820 points for B**.

## Questions answered

1. Total amount each customer spent
2. Number of distinct visit days per customer
3. First menu item(s) purchased by each customer
4. Most-purchased menu item
5. Most popular item(s) for each customer
6. First item purchased after joining the loyalty program
7. Last item purchased before joining the program
8. Pre-membership item count and spend
9. Points earned with a 2× sushi multiplier
10. January points with a 2× first-week membership promotion
11. A member-status view of every sale
12. A ranked view of member purchases

## Run the analysis

1. Load the `sales`, `menu`, and `members` tables from the challenge setup.
2. Run the queries in [solutions.sql](solutions.sql) in a PostgreSQL-compatible SQL client.

The SQL uses the original `dannys_diner` schema names. If your tables are in a different schema, replace the table references accordingly.

## Files

- [solutions.sql](solutions.sql) — documented, runnable solutions for all 12 questions

## Source

The data and prompts are provided by [Danny Ma's 8 Week SQL Challenge](https://8weeksqlchallenge.com/case-study-1/).
