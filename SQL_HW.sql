USE sakila;

SELECT * from actor
-- * 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name
FROM actor;
-- 
-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
-- 
SELECT concat(first_name,' , ', last_name) 
FROM actor;

-- 
-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
-- 
SELECT actor_id first_name, last_name
FROM actor
WHERE first_name='Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:

SELECT actor_id first_name, last_name
FROM actor
WHERE first_name LIKE '%GEN%';
-- 
-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
-- 
SELECT actor_id first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
-- 
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh',  'China');

-- * 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
-- 
ALTER TABLE actor 
ADD COLUMN  middle_name varchar(45) after first_name;


-- * 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
-- 
ALTER TABLE actor 
MODIFY middle_name blob;
-- * 3c. Now delete the `middle_name` column.
-- 
ALTER TABLE actor 
DROP COLUMN middle_name;
-- * 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(first_name)
FROM actor
GROUP BY last_name;
-- 
-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
-- 
SELECT last_name, count(first_name) as count
FROM actor
GROUP BY last_name
HAVING count >= 2;

-- * 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
-- 
UPDATE actor
set first_name= "HARPO"
WHERE first_name= "GROUCHO" and last_name="WILLIAMS";
-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
-- 
UPDATE actor
set first_name= 
CASE WHEN first_name= 'HARPO'  AND actor_id='172' 
           THEN 'GROUCHO'
           ELSE 'MUCHOGROUCHO' END;
-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- 
--   * Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
SHOW CREATE TABLE address;
-- 
-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT s.first_name, s.last_name,a.address
FROM staff as s
JOIN address as a
WHERE a.address_id=s.address_id;
-- 
-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
-- 



SELECT s.staff_id,s.first_name, s.last_name,  SUM(a.amount) as Total
FROM staff as s
JOIN payment as a
WHERE a.staff_id=s.staff_id AND payment_date LIKE '2005-08%'
GROUP BY  staff_id;


-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
-- 

SELECT  f.film_id,COUNT(a.actor_id) as 'Number of Actors'
FROM film as f
INNER JOIN film_actor as a
WHERE a.film_id=f.film_id
GROUP BY film_id
-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(inventory_id) as 'Number of copies'
FROM inventory
WHERE film_id IN
(
SELECT film_id
from film
WHERE title='Hunchback Impossible'
)
GROUP BY film_id

-- 
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- 
--   ```
select c.customer_id, sum(p.amount) as total
from customer as c
join payment as p
WHERE c.customer_id=p.customer_id
GROUP BY c.customer_id
--   ```
-- 
-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
-- 
SELECT * from film

SELECT title
FROM film
WHERE title LIKE 'K%'OR title LIKE 'Q%'

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor 
WHERE actor_id IN
(

	SELECT actor_id 
	FROM film_actor
	WHERE film_id IN 
(
		SELECT film_id 
		from film
		WHERE title='Alone Trip'
)
)
-- 
-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- 


SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
(
		SELECT address_id
        FROM address
        WHERE city_id IN
        (
				SELECT city_id
                FROM city
                WHERE country_id IN
                (
					SELECT country_id
                    FROM country
                    WHERE country ='Canada'
                    )
				)
		)

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
-- 

SELECT title
from film
WHERE film_id IN
(
	SELECT film_id 
    FROM film_category
    WHERE category_id IN
    (
		SELECT category_id
        from category 
        WHERE name='Family'
        )
	)
-- * 7e. Display the most frequently rented movies in descending order.


SELECT title,count(film_id)	
FROM film
WHERE film_id IN
(
	SELECT film_id
    FROM inventory
    WHERE inventory_id IN
    (
		SELECT inventory_id
        FROM rental
        )
	)
GROUP BY title
	
-- 
-- * 7f. Write a query to display how much business, in dollars, each store brought in.

DROP TABLE IF EXISTS temp1;
CREATE TABLE temp1
SELECT title, rental_rate, inventory_id, store_id
from film
JOIN inventory
USING(film_id)


DROP TABLE IF EXISTS temp2;
CREATE TABLE temp2
SELECT title, rental_rate, inventory_id, store_id
from inventory
JOIN temp1
USING(inventory_id)

DROP TABLE IF EXISTS temp3;
CREATE TABLE temp3
SELECT title, rental_rate, inventory_id, store_id
from store
JOIN temp2
USING(store_id)

SELECT store_id, sum(rental_rate)
FROM temp3
GROUP BY store_id

-- 
-- * 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, address.city_id, city.city, country.country
FROM store as store
JOIN address as address
	ON store.address_id=address.address_id
JOIN city as city
   ON address.city_id=city.city_id
JOIN country as country
   ON country.country_id=city.country_id

-- 
-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 
SELECT name, sum(amount) as Total
FROM category 
JOIN film_category 
	USING (category_id)
JOIN inventory 
	USING (film_id)
JOIN rental
     USING(inventory_id)
JOIN payment
	USING (rental_id)
GROUP BY name
ORDER BY Total DESC;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 
CREATE VIEW TopRevenue AS
SELECT name, sum(amount) as Total
FROM category 
JOIN film_category 
	USING (category_id)
JOIN inventory 
	USING (film_id)
JOIN rental
     USING(inventory_id)
JOIN payment
	USING (rental_id)
GROUP BY name
ORDER BY Total DESC;
-- * 8b. How would you display the view that you created in 8a?

SELECT * from toprevenue
-- 
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW toprevenue
-- 