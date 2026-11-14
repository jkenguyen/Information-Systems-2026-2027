USE sakila;

-- 1. List names of all the languages in the database (sorted alphabetically)
SELECT name
FROM language
ORDER BY name;

-- 2. List full names of actors with "GER" in their last name, ordered by their first name
SELECT
    first_name,
    last_name
FROM actor
WHERE last_name LIKE '%GER%'
ORDER BY first_name;

-- 3. Find all the addresses where postal code starts with "57", sorted
SELECT
    address,
    postal_code
FROM address
WHERE postal_code LIKE '57%'
ORDER BY address;

-- 4. How many films involve a "DWARF" in their titles?
SELECT COUNT(*) AS nb_films
FROM film
WHERE title LIKE '%DWARF%';

-- 5. Actors who played in a film with 'WAR' in the title and longer than 2.5 hours
SELECT
    a.first_name,
    a.last_name,
    f.title,
    f.length,
    f.release_year
FROM actor a
JOIN film_actor fa
    ON a.actor_id = fa.actor_id
JOIN film f
    ON fa.film_id = f.film_id
WHERE f.title LIKE '%WAR%'
    AND f.length > 150
ORDER BY a.last_name;

-- 6. Categories with between 55 and 65 films, with the number of films, sorted descending
SELECT
    c.name,
    COUNT(*) AS nb_films
FROM category c
JOIN film_category fc
    ON c.category_id = fc.category_id
GROUP BY c.name
HAVING COUNT(*) BETWEEN 55 AND 65
ORDER BY nb_films DESC;

-- 7. In how many categories is the average (replacement_cost - rental_rate) larger than 17?
SELECT COUNT(*) AS nb_categories
FROM (
    SELECT fc.category_id
    FROM film_category fc
    JOIN film f
        ON fc.film_id = f.film_id
    GROUP BY fc.category_id
    HAVING AVG(f.replacement_cost - f.rental_rate) > 17
) AS t;

-- 8. District(s) whose minimal postal code is maximal over all districts
SELECT
    district,
    MIN(postal_code) AS min_postal_code
FROM address
WHERE postal_code <> ''
    AND district <> ''
GROUP BY district
HAVING MIN(postal_code) = (
    SELECT MAX(min_pc)
    FROM (
        SELECT MIN(postal_code) AS min_pc
        FROM address
        WHERE postal_code <> ''
            AND district <> ''
        GROUP BY district
    ) AS t
);

-- 9. Actors and customers whose first name is the same as the actor with ID 101
SELECT
    first_name,
    last_name,
    'actor' AS type
FROM actor
WHERE first_name = (
    SELECT first_name
    FROM actor
    WHERE actor_id = 101
)
    AND actor_id <> 101
UNION
SELECT
    first_name,
    last_name,
    'customer' AS type
FROM customer
WHERE first_name = (
    SELECT first_name
    FROM actor
    WHERE actor_id = 101
);
