/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    customer_id, SUM(price) AS total_amount
FROM
    sales
        INNER JOIN
    menu ON menu.product_id = sales.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
    customer_id, COUNT(distinct(order_date)) as days_visited
FROM
    sales
GROUP BY customer_id; 



-- 3. What was the first item from the menu purchased by each customer?
With CTE as
(Select distinct customer_id, product_name, dense_rank() over(partition by customer_id order by order_date asc) as ranks
from sales s
join menu m
on m.product_id=s.product_id
)
select customer_id, product_name as first_order
from CTE
where ranks=1
group by customer_id, product_name;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
With CTE as
(Select m.product_name, count(s.product_id) as times_purchased
from sales s 
join menu m on m.product_id=s.product_id
group by m.product_name
order by m.product_id desc)
Select product_name, max(times_purchased) as number_of_purchases
from CTE;

-- 5. Which item was the most popular for each customer?
With CTE as
(Select  s.customer_id, m.product_name, count(s.product_id) as count, dense_rank() over(partition by s.customer_id order by count(s.product_id) desc) as ranks
from sales s
join menu m on m.product_id=s.product_id
group by s.customer_id, m.product_name, s.product_id)
select customer_id, product_name as popular_product
from CTE
where ranks=1;
-- 6. Which item was purchased first by the customer after they became a member?
With CTE as
(Select s.customer_id, m.product_name, s.order_date, mem.join_date, dense_rank()over(partition by s.customer_id order by s.order_date asc) as ranks
from sales s
join menu m on m.product_id=s.product_id
join members mem on mem.customer_id=s.customer_id
Where s.order_date>=mem.join_date
group by s.customer_id, m.product_name, s.order_date)
Select customer_id, product_name
from CTE
order by ranks desc limit 3;
-- 7. Which item was purchased just before the customer became a member?
With CTE as
(Select s.customer_id, m.product_name, s.order_date, mem.join_date, dense_rank()over(partition by s.customer_id order by s.order_date desc) as ranks
from sales s
join menu m on m.product_id=s.product_id
join members mem on mem.customer_id=s.customer_id
Where s.order_date<mem.join_date
group by s.customer_id, m.product_name, s.order_date)
Select customer_id, product_name
from CTE
where ranks=1;
-- 8. What is the total items and amount spent for each member before they became a member?
With CTE as 
(select s.customer_id, s.order_date,m.product_name,mem.join_date,m.price, count(s.product_id) as count
from sales s 
join menu m on 
m.product_id=s.product_id
join members mem on mem.customer_id=s.customer_id
Where s.order_date<mem.join_date
group by m.product_name, s.customer_id)
Select customer_id,sum(count) as total_items, sum(count*price) as total_amount
from CTE
group by customer_id;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'Sushi' THEN 20 * price
        ELSE 10 * price
    END) AS points
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
GROUP BY s.customer_id;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT 
    s.customer_id,
    SUM(CASE
        WHEN DATE_ADD(mem.join_date, INTERVAL 7 DAY) THEN m.price * 20
        WHEN m.product_name = 'sushi' THEN 20 * price
        ELSE 10 * price
    END) AS points
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members mem ON mem.customer_id = s.customer_id
WHERE
    s.order_date >= mem.join_date
        AND MONTH(s.order_date) = 1
GROUP BY s.customer_id;
select * from menu;
Select * from sales;
Select * from members;
-- The following questions are related to creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
-- Join all the things

CREATE VIEW Joins AS
    SELECT 
        s.customer_id,
        s.order_date,
        m.product_name,
        m.price,
        mem.join_date,
        CASE
            WHEN mem.join_date IS NULL THEN 'N'
            ELSE 'Y'
        END AS members
    FROM
        sales s
            JOIN
        menu m ON m.product_id = s.product_id
            LEFT JOIN
        members mem ON mem.customer_id = s.customer_id
            AND s.order_date >= mem.join_date; 
            
            select * from joins;
-- Danny also requires further information about the ranking of customer products but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
-- Rank all the things

Select customer_id, order_date, product_name, price, join_date, members,
Case When members='Y' then
dense_rank() over(partition by customer_id order by order_date desc)
 end as ranks
 from joins;




