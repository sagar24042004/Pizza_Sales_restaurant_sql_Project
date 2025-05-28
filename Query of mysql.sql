create database pizza_sale;
use pizza_sale;
create table  orders(
order_id int not null primary key,
order_date date not null,
order_time time not null
);

create table  orders_details(
order_details_id int not null primary key,
order_id int not null ,
pizza_id text not null,
quantity int not null
);

ALTER TABLE orders_details ADD foreign key(order_id) references orders(order_id);
ALTER TABLE pizzas ADD foreign key(pizza_id) references orders_details(pizza_id);
# question 

# Retrieve the total number of orders placed.
select count(order_id) as Total_Number_orders  from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(od.quantity*p.price)) as total_revenue 
from orders_details as od
join 
pizzas as p on od.pizza_id=p.pizza_id;


-- Identify the highest-priced pizza.
select pt.name , p.price as Highest_Price from pizzas as p
join pizza_types as pt on
p.pizza_type_id=pt.pizza_type_id order by p.price desc limit 1;

-- Identify the most common pizza size ordered. 

select p.size , count(od.order_details_id) as count_orders from pizzas as p
join orders_details as od on p.pizza_id =od.pizza_id 
group by p.size order by count_orders desc limit 1;

-- List the top 5 most ordered pizza types along with their quantities

SELECT pt.name, SUM(od.quantity) AS total_orders_quantity FROM pizza_types AS pt
JOIN
pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
JOIN orders_details AS od ON p.pizza_id = od.pizza_id GROUP BY pt.name
ORDER BY total_orders_quantity DESC LIMIT 5;










-- Join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
    pt.category, SUM(od.quantity) AS Total_Quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

/-- create view that display distribution of orders by hour of the day
CREATE VIEW distribution_orders_hour AS
SELECT HOUR(order_time) AS hours, COUNT(order_id) as Num_Orders
FROM orders
GROUP BY hours;
 SELECT * FROM distribution_orders_hour;

--  find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) as Number_Pizza
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity)) AS Number_Pizza_order_PerDay
FROM (SELECT o.order_date, SUM(od.quantity) AS quantity
FROM orders AS o
JOIN orders_details AS od ON o.order_id = od.order_id
GROUP BY o.order_date) AS order_pizza;

-- Determine the top 5 most ordered pizza types based on revenue.
SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price)) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 5;

-- Calculate the percentage contribution of each pizza category to total revenue.
SELECT 
    pt.category,
    CONCAT(ROUND((SUM(od.quantity * p.price) / (SELECT 
                            ROUND(SUM(od.quantity * p.price)) AS total_revenue
                        FROM
                            orders_details AS od
                                JOIN
                            pizzas AS p ON od.pizza_id = p.pizza_id)) * 100),
            '%') AS Percentage_Revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    orders_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over date. 

select OrderDate,sum(rev) over (order by OrderDate) as Cumulative_Revenue
from
(select o.order_date as OrderDate , round(sum(od.quantity * p.price)) as rev
from orders as o 
join orders_details as od on o.order_id=od.order_id 
join pizzas as p on p.pizza_id=od.pizza_id 
group by o.order_date) as sale ;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name , category, round(revenue) from
(select name,category ,revenue,
rank() over (partition by category order by revenue desc) as ranknum from
(select pt.name,pt.category ,sum(od.quantity * p.price) as revenue from pizzas as p
join orders_details as od on p.pizza_id=od.pizza_id
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
group by pt.category,pt.name) as a) as b
where ranknum <= 3;



-- create view that find name of pizza which is high price top 5

CREATE VIEW HIGH_PRICE_PIZZA AS
SELECT pt.name , p.price 
FROM pizzas as p 
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
ORDER by p.price desc limit 5;
select * from high_price_pizza;
 
 
--  Create a view named  bottom 5 low_performing_pizzas that lists pizzas that have sold less than the average quantity sold across all pizzas.
CREATE VIEW low_performing_pizzas AS
with pizza_sale as
(SELECT pt.name as pizza_name,sum(od.quantity) as sold_qty from pizzas as p 
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
join orders_details as od on od.pizza_id=p.pizza_id
Group by pt.name) ,
 average_sale as(
select avg(sold_qty) as avg_sold from pizza_sale
)
select ps.pizza_name ,ps.sold_qty as total_quantity_sold
from pizza_sale as ps , average_sale as av
where ps.sold_qty < av.avg_sold order by ps.sold_qty limit 5;
select * from low_performing_pizzas;


-- create view to identitfyingredients are most frequently used in the 
-- top-selling pizzas, and how can this insight inform inventory purchasing and stocking strategies-- 

CREATE VIEW top_pizza_ingredients_inventory AS
SELECT pt.ingredients,sum(od.quantity) as sold_qty from pizzas as p 
join pizza_types as pt on pt.pizza_type_id=p.pizza_type_id
join orders_details as od on od.pizza_id=p.pizza_id
Group by  pt.ingredients order by sold_qty desc limit 5;
select * from top_pizza_ingredients_inventory;