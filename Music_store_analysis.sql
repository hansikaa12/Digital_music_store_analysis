use music;

-- 1. Who is the senior most employee based on job title?
SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;
 
 
-- 2. Which countries have the most Invoices?
SELECT 
    COUNT(*) AS count, billing_country
FROM
    invoice
GROUP BY billing_country;


-- 3. What are top 3 values of total invoice?
SELECT 
    *
FROM
    invoice
ORDER BY total DESC
LIMIT 3;


-- 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT 
    SUM(total) AS sum_total, city
FROM
    customer
        JOIN
    invoice ON invoice.customer_id = customer.customer_id
GROUP BY city
ORDER BY sum_total DESC
LIMIT 1;


select sum(total) as invoice_total, billing_city from invoice
group by billing_city
order by invoice_total desc
limit 1;


-- 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money
select customer.customer_id, customer.first_name, customer.last_name, sum(total) as invoice_total from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by invoice_total desc
limit 1;


-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT email AS Email, first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and 
-- total track count of the top 10 rock bands
SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;



-- 8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. 
-- Order by the song length with the longest songs listed first. 
SELECT track.name as track_name , track.milliseconds
FROM track
WHERE track.milliseconds > (
	SELECT AVG(track.milliseconds) AS avg_track_length
	FROM track)
ORDER BY track.milliseconds DESC;


-- 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
SELECT 
    c.first_name AS customer_first_name, 
    c.last_name AS customer_last_name, 
    a.name AS artist_name, 
    SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN album2 a2 ON t.album_id = a2.album_id
JOIN artist a ON a.artist_id = a2.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, a.artist_id, a.name
ORDER BY total_spent DESC;


-- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount 
-- of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is 
-- shared return all Genres
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along 
-- with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;

