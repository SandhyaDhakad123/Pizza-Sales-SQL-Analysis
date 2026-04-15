-- 🍕 Pizza Sales SQL Analysis Project


-- 1. Total number of orders
SELECT COUNT(order_id) AS total_orders
FROM orders;


-- 2. Total revenue generated
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id;


-- 3. Highest priced pizza
SELECT pizza_types.name, pizzas.price
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- 4. Most common pizza size ordered
SELECT pizzas.size,
COUNT(order_details.order_details_id) AS order_count
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- 5. Top 5 most ordered pizza types
SELECT pizza_types.name,
SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- 6. Total quantity by pizza category
SELECT pizza_types.category,
SUM(order_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7. Orders distribution by hour
SELECT HOUR(order_time) AS hour,
COUNT(order_id) AS order_count
FROM orders
GROUP BY hour;


-- 8. Category-wise pizza distribution
SELECT pizza_types.category,
COUNT(pizza_types.name) AS count
FROM pizza_types
GROUP BY pizza_types.category;


-- 9. Average pizzas ordered per day
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT orders.order_date,
    SUM(order_details.quantity) AS quantity
    FROM orders
    JOIN order_details
    ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;


-- 10. Top 3 pizzas by revenue
SELECT pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- 11. Percentage contribution by category
SELECT pizza_types.category,
ROUND(
    SUM(order_details.quantity * pizzas.price) * 100.0 /
    (SELECT SUM(order_details.quantity * pizzas.price)
     FROM order_details
     JOIN pizzas
     ON pizzas.pizza_id = order_details.pizza_id),
2) AS revenue_percentage
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;


-- 12. Cumulative revenue over time
SELECT order_date,
SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
    FROM orders
    JOIN order_details
    ON orders.order_id = order_details.order_id
    JOIN pizzas
    ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY orders.order_date
) AS sales;


-- 13. Top 3 pizzas by revenue for each category
SELECT name, category, revenue
FROM (
    SELECT pizza_types.name,
    pizza_types.category,
    SUM(order_details.quantity * pizzas.price) AS revenue,
    RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rn
    FROM pizza_types
    JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details
    ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.name, pizza_types.category
) ranked
WHERE rn <= 3;
