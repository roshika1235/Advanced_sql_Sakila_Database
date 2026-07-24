# advanced SQL queries for sakila database.

# 1. all films with PG-13 films with rental rate of 2.99 or lower
# films -> PG-13 -> rental_rate <=2.99  (2 conditions) 
# tables (film ->rental_rate,rating)

use sakila;
select * 
from film
where rating = 'PG-13' and rental_rate <=2.99;

# 2.  films that have deleted scenes.

select * 
from film
where special_features like '%Deleted Scenes%';

# 3. all active customers.

SELECT *
FROM customer
WHERE active=1;

# 4. names of customers who rented a movie on 26th july 2005.
# tables customer (full name)  ->  rental ( on r.customer_id = c.customer_id) -> rental_date

select concat(c.first_name ,' ' , c.last_name) as customer_name 
from customer c , rental r 
where c.customer_id = r.customer_id
and date(r.rental_date) = '2005-07-26';

# 5. distinct names of customers who rented a movie on 26th july 2005.

select distinct concat(c.first_name ,' ' , c.last_name) as customer_name 
from customer c , rental r 
where c.customer_id = r.customer_id
and date(r.rental_date) = '2005-07-26';

# 6. how many rentals we do in a day?
# count(rental_id)  and group by rental_date

select count(rental_id) as total_rentals_in_a_day, date(rental_date) as day
from rental
group by date(rental_date);

# 7. all sci-fi movies in catalog.
# genre of the movie from catalog .  category(category_id) -> film_category (film_id , category_id)  -> film (film_id,title)

select f.title, c.name  
from category c, film_category fc , film f
where c.category_id = fc.category_id 
and fc.film_id = f.film_id 
and c.name like '%Sci-Fi%';

# 8. customers and how many movies they rented so far.

# logic 1: but it will group films --- customer(customer_id) -> rental(customer_id , inventory_id) -> inventory(inventory_id,film_id) -> film(film_id)
# logic 2: customer_id and count(rental_id)

select distinct c.customer_id , count(r.rental_id) as total_rentals
from customer c , rental r 
where c.customer_id = r.customer_id 
group by c.customer_id;

# 9. which movies should be discontinued from the catalog?
# which are inactive and rating < some threshold and may be we can check inventory and tell if film_id is not in inventory or store_id =0
WITH low_rentals AS (
    SELECT inventory_id, COUNT(*) AS total_rentals
    FROM rental
    GROUP BY inventory_id
    HAVING COUNT(*) <= 1
)
SELECT 
    lr.inventory_id,
    f.film_id,
    f.title AS movie_title,
    lr.total_rentals
FROM low_rentals lr
JOIN inventory i ON lr.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id;

# 10. which movies are not retured yet?
# movies (film) -> film_id,title      rental(inventory_id,return_date)  -> inventory (inventory_id , film_id)

select distinct f.title 
from film f , rental r, inventory i 
where r.inventory_id = i.inventory_id 
and i.film_id = f.film_id 
and r.return_date is null;

# mis_2 : how much money and rentals we make for store 1 by day?
# mis_3 : top 3 earning days so far?
