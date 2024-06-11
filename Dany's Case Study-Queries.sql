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
select * from sales;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
With CTE as
(Select m.product_name, count(s.product_id) as times_purchased
from sales s 
join menu m on m.product_id=s.product_id
group by m.product_name
order by times_purchased desc)
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
where ranks=1;
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
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

