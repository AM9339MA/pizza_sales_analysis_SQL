--- SQL Retail Sales Analysis -
CREATE DATABASE pizza_hut;


-- Create TABLE 1

CREATE TABLE orders (
    order_id INT primary key,
    order_date date,
    order_time  time
);

select count(*) from orders;

-- data cleaning 

SELECT 
    *
FROM
    orders
WHERE
    order_id IS NULL OR order_date IS NULL
        OR order_time IS NULL;

--- delete nul values

DELETE FROM orders 
WHERE
    order_id IS NULL OR order_date IS NULL
    OR order_time IS NULL;

-- Create TABLE 2

create table order_details (
    order_details_id int primary key,
    order_id int not null,
    pizza_id varchar(50) not null,
    quantity int not null
);

select * from order_details;

---data cleaning

SELECT 
    *
FROM
    order_details
WHERE
    order_details_id IS NULL
        OR order_id IS NULL
        OR pizza_id IS NULL
        OR quantity IS NULL;

--- delete null values

DELETE FROM order_details 
WHERE
    order_details_id IS NULL
    OR order_id IS NULL
    OR pizza_id IS NULL
    OR quantity IS NULL;

-- Create TABLE 3

create table pizza_types (
    pizza_type_id text not null,
    name varchar(100) not null,
    category varchar (50) not null,
    ingredients varchar(200)
); 

select * from pizza_types;

select count(*) from pizza_types;

-- data cleaning

SELECT 
    *
FROM
    pizza_types
WHERE
    pizza_type_id IS NULL OR name IS NULL
        OR category IS NULL
        OR ingredients IS NULL;

---delete null values

DELETE FROM pizza_types 
WHERE
    pizza_type_id IS NULL OR name IS NULL
    OR category IS NULL
    OR ingredients IS NULL;

-- Create TABLE 4

create table pizzas (
    pizza_id int primary key,
    pizza_type_id text(50) not null,
    size varchar(10),
    price float
);

select * from pizzas;

select count(*) from pizzas;

-- data claning

SELECT 
    *
FROM
    pizzas
WHERE
    pizza_id IS NULL
        OR pizza_type_id IS NULL
        OR size IS NULL
        OR price IS NULL;

--- delete null values

DELETE FROM pizzas 
WHERE
    pizza_id IS NULL
    OR pizza_type_id IS NULL
    OR size IS NULL
    OR price IS NULL;

-- Data Exploration

-- How many uniuque customers we have ?

select count(distinct pizza_id) as total_pizza from pizzas;

select distinct category from pizza_types;

-- Data Analysis & Business Key Problems & Answers

--Basic:
--1--Retrieve the total number of orders placed.
--2--Calculate the total revenue generated from pizza sales.
--3--Identify the highest-priced pizza.
--4--Identify the most common pizza size ordered.
--5--List the top 5 most ordered pizza types along with their quantities.


--Intermediate:
--6--Join the necessary tables to find the total quantity of each pizza category ordered.
--7--Determine the distribution of orders by hour of the day.
--8--Join relevant tables to find the category-wise distribution of pizzas.
--9--Group the orders by date and calculate the average number of pizzas ordered per day.
--10--Determine the top 3 most ordered pizza types based on revenue.

--Advanced:
--11--Calculate the percentage contribution of each pizza type to total revenue.
--12--Analyze the cumulative revenue generated over time.
--13--Determine the top 3 most ordered pizza types based on revenue for each pizza category.


--1--Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_order
FROM
    orders;
    
--2-- Calculate the total revenue generated from pizza sales. --

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

--3-- Identify the highest-priced pizza. --

select * from pizzas;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

--4-- Identify the most common pizza size ordered. --

select * from order_details;

select quantity, count(order_details_id) from order_details group by quantity;

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

--5-- List the top 5 most ordered pizza types along with their quantities. --

select * from pizzas;

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

--6-- Join the necessary tables to find the total quantity of each pizza category ordered. --

select * from pizza_types;

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY pizza_types.category
ORDER BY quantity DESC
LIMIT 1;

--7-- Determine the distribution of orders by hour of the day. --

select * from orders;

SELECT 
    HOUR(order_time) AS order_hour, COUNT(order_id) order_count
FROM
    orders
GROUP BY order_hour;

-- 8-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

--9-- Group the orders by date and calculate the average number of pizzas ordered per day.

select * from orders;
SELECT 
    ROUND(AVG(total_quantity), 0) AS perday_avg_pizza_order
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

--10-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

--11-- Calculate the percentage contribution of each pizza type to total revenue.
 
 SELECT 
    pizza_types.category,
    round(sum(order_details.quantity * pizzas.price) /(SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100, 2) as revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC; 

--12-- Analyze the cumulative revenue generated over time.
select order_date , sum(revenue) over(order by order_date) as cum_revenue from 
(select orders.order_date , sum(order_details.quantity * pizzas.price) as revenue 
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id join orders 
on orders.order_id = order_details.order_id group by orders.order_date) as sales;

--13-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from 
(SELECT 
    pizza_types.category,
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as a) as b
where rn <= 3;

