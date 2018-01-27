### Problems
use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`. 
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
select concat(first_name, ' ',last_name) as Actor_Name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id,first_name,last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select actor_id,first_name,last_name from actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select last_name,first_name from actor where last_name like '%LI%' order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
alter table actor 
		add middle_name varchar(30);
select first_name, middle_name, last_name from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
alter table actor
		change column middle_name middle_name blob;
        
-- 3c. Now delete the `middle_name` column.
alter table actor
		drop column middle_name;
        
-- 4a. List the last names of actors, as well as how many actors have that last name.
select distinct(last_name), count(last_name) as count_names from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
drop table if exists common_names;
create table common_names (
ast_name varchar(30) not null,
count_names integer default 1
);
insert into common_names
select distinct(last_name), count(last_name) as count_names from actor group by last_name;
select * from common_names where count_names >=2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
select actor_id into @fix_actor_name from actor where first_name = 'GROUCHO' and last_name = 'WILLIAMS'; 
update actor 
	set first_name = 'HARPO' 
	where actor_id = @fix_actor_name;
    
-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
update actor 
	set 
		first_name = case when first_name = 'GROUCHO' then 'MUCHO GROUCHO' else 'GROUCHO' end
	where actor_id = @fix_actor_name;
select * from actor where actor_id = @fix_actor_name;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
describe address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name, last_name, address
from staff s
join address a on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 
select s.staff_id, s.first_name, s.last_name, sum(p.amount)
from staff s
join payment p on s.staff_id = p.staff_id 
where p.payment_date like '2005-08-%'
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, count(actor_id) as actor_count
from film f
inner join film_actor a 
using(film_id)
group by f.title;
   	
-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select f.title,count(i.inventory_id) as n_copies
from inventory i
join film f
using(film_id)
where f.title = 'HUNCHBACK IMPOSSIBLE'
group by f.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
select cus.last_name,cus.first_name, sum(pay.amount) as paid
from payment pay
join customer cus 
using(customer_id)
group by cus.customer_id
order by cus.last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
select title
from film
where title regexp '^[KQ].*'
and language_id in (
	select language_id
	from language
	where name = 'english'
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select a.first_name, a.last_name
from actor a
join film_actor fa using(actor_id)
where fa.film_id in (
	select film_id
    from film
    where title = 'ALONE TRIP'
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cus.first_name,cus.last_name,cus.email
from customer cus
join address
using(address_id)
join city 
using(city_id)
join country
using(country_id)
where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select title
from film
where film_id in( 
	select film_id
	from film_category 
	where category_id in(
		select category_id 
		from category
		where name = 'family'
	)
);

-- 7e. Display the most frequently rented movies in descending order.
select film.title, count(rental.rental_id) as times_rented
from film
join inventory
using(film_id)
join rental
using(inventory_id)
group by title
order by times_rented desc;
    
-- 7f. Write a query to display how much business, in dollars, each store brought in.

-- 7g. Write a query to display for each store its store ID, city, and country.
  	
-- 7h. List the top five genres in gross revenue in descending order. (----Hint----: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
  	
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
  	
-- 8b. How would you display the view that you created in 8a?

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.