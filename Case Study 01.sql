-- 1) What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(price) AS totalAmountSpent
FROM sales s
	JOIN menu m
		ON s.product_id=m.product_id
GROUP BY s.customer_id;

-- 2) How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS numberOfVisit
FROM sales
GROUP BY customer_id;

-- 3) What was the first item from the menu purchased by each customer?
WITH CTE 
AS
(
SELECT s.customer_id, m.product_name, RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS num
FROM sales s
	JOIN menu m
		ON s.product_id=m.product_id
)
SELECT DISTINCT customer_id, product_name
FROM CTE
WHERE num=1;

-- OR

WITH CTE 
AS
(
SELECT s.customer_id, m.product_name, RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS num
FROM sales s
	JOIN menu m
		ON s.product_id=m.product_id
)
SELECT customer_id, product_name
FROM CTE
WHERE num=1
GROUP BY customer_id, product_name;

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(1)
FROM sales s
	JOIN menu m
		ON s.product_id=m.product_id
GROUP BY m.product_name
ORDER BY COUNT(1) DESC
LIMIT 1;

-- 


