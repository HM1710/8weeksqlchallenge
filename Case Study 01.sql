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

-- 5) Which item was the most popular for each customer?
WITH CTE
AS
(
SELECT customer_id, product_id, COUNT(product_id) AS cnt, RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS ranking
FROM dannys_diner.sales
GROUP BY customer_id, product_id
)
SELECT customer_id, product_name, cnt
FROM CTE c
	JOIN dannys_diner.menu m
		ON c.product_id=m.product_id
WHERE ranking=1

-- 6) Which item was purchased first by the customer after they became a member?
WITH cte
AS
(
SELECT m.customer_id, s.order_date, me.product_name, RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date) AS ranking
FROM dannys_diner.members m
	JOIN dannys_diner.sales s
		ON m.customer_id=s.customer_id
	JOIN dannys_diner.menu me
		ON me.product_id=s.product_id
WHERE s.order_date >= m.join_date
)
SELECT cte.customer_id, cte.product_name
FROM cte
WHERE cte.ranking=1

-- 7) Which item was purchased just before the customer became a member?
WITH cte
AS
(
SELECT m.customer_id, m.join_date, s.order_date, me.product_name, RANK() OVER (PARTITION BY m.customer_id ORDER BY s.order_date DESC) AS ranking
FROM dannys_diner.members m
	JOIN dannys_diner.sales s
		ON m.customer_id=s.customer_id
	JOIN dannys_diner.menu me
		ON me.product_id=s.product_id
WHERE s.order_date < m.join_date
)
SELECT cte.customer_id, cte.product_name
FROM cte
WHERE cte.ranking=1

-- 8) What is the total items and amount spent for each member before they became a member?
WITH CTE
AS
(
SELECT m.customer_id, me.product_name AS prod, SUM(me.price) AS total
FROM dannys_diner.members m
	JOIN dannys_diner.sales s
		ON m.customer_id=s.customer_id
	JOIN dannys_diner.menu me
		ON me.product_id=s.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id, me.product_name
)
SELECT cte.customer_id, COUNT(cte.prod) AS total_items, SUM(cte.total) AS totalAmountSpent
FROM cte
GROUP BY cte.customer_id

-- 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(price*(CASE WHEN m.product_name='sushi' THEN 20 ELSE 10 END)) AS total_points
FROM dannys_diner.sales s
	JOIN dannys_diner.menu m
		ON s.product_id=m.product_id
GROUP BY s.customer_id

-- 10) In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	m.customer_id, --m.join_date, s.order_date, s.order_date::date-m.join_date::date, me.price,
	SUM(price*(CASE WHEN s.order_date::date-m.join_date::date> 7 AND me.product_name<>'sushi' THEN 10
			   WHEN s.order_date::date-m.join_date::date BETWEEN 0 AND 7 THEN 20
			   WHEN me.product_name='sushi' THEN 20
			   ELSE 10
			    END)) AS total
	
FROM dannys_diner.members m
	JOIN dannys_diner.sales s
		ON m.customer_id=s.customer_id
	JOIN dannys_diner.menu me
		ON me.product_id=s.product_id
WHERE s.order_date <= '2021-01-31'
GROUP BY m.customer_id