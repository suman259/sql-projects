USE imdb;

/* Now that we have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.*/

show tables;

-- Total number of rows in each table of the schema

select count(*) as director_mapping_count from director_mapping ;
select count(*) genre_count from genre ;
select count(*) as row_count from movie ;
select count(*) as row_count from names ;
select count(*) as row_count from ratings ;
select count(*) as row_count from role_mapping ;



-- Null values in movie table

SELECT 
       SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS ID_NULL_COUNT,
       SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_NULL_COUNT,
       SUM(CASE WHEN year IS NULL THEN 1 ELSE 0 END) AS year_NULL_COUNT,
       SUM(CASE WHEN date_published IS NULL THEN 1 ELSE 0 END) AS date_published_NULL_COUNT,
       SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_NULL_COUNT,
       SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_NULL_COUNT,
       SUM(CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS worldwide_gross_income_NULL_COUNT,
       SUM(CASE WHEN languages IS NULL THEN 1 ELSE 0 END) AS languages_NULL_COUNT,
       SUM(CASE WHEN production_company IS NULL THEN 1 ELSE 0 END) AS production_company_NULL_COUNT
FROM movie;



-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Let's find the total number of movies released each year and How does the trend look month wise

select year , count(id) as number_of_movies from movie
group  by year
order by year;

select month(date_published) as month_num , count(id) as number_of_movies from movie
group  by month_num
order by month_num;


/*The highest number of movies is produced in the month of MARCH.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
select count(DISTINCT id) AS number_of_movies , year 
FROM movie
WHERE (country LIKE '%INDIA%'
       OR country LIKE '%USA%' )
	AND year = 2019;		



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Unique list of the genres present in the data set?
-- Type your code below:
select distinct genre from genre;


-- So, Production comapany plans to make a movie of one of these genres.
-- Let's find out Which genre had the highest number of movies produced overall?

select genre ,year , count(movie_id) as num_of_movies from genre  as g
inner join movie as m
on g.movie_id= m.id
where year =  2019
group by genre
order by num_of_movies desc
limit 1;


/* So, based on the insight that we just drew, production company should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Movies that belong to only one genre?

with movie_with_one_genre as
(
select movie_id, count(genre) from genre 
group by movie_id
having count(genre)= 1
)
select count(movie_id) from movie_with_one_genre;



/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of production company's next project.*/

-- What is the average duration of movies in each genre? 

select genre , round(avg(duration)) as avg_duration from genre as g
inner join movie as m 
on g.movie_id=m.id
group by genre;



/* Now we know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/


with triller_rank as 
(select genre ,  count(movie_id) as  movie_count , rank() over (order by count(movie_id)desc) as genre_rank from genre 
group by genre
)
select * from  triller_rank 
where genre='thriller';



/*Thriller movies is in top 3 among all genres in terms of number of movies
 
with lets get the min and max values of different columns in the table*/


-- let's find the minimum and maximum values in  each column of the ratings table except the movie_id column?

select min(avg_rating) as min_avg_rating,
max(avg_rating) as max_avg_rating,
min(total_votes) as min_total_votes,
max(total_votes) as min_total_votes,
min(median_rating) as min_median_rating,
max(median_rating) as min_median_rating from ratings;



/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


select title , avg_rating ,dense_rank () over (order by avg_rating desc) as movie_rank
from ratings as r
inner join movie as m
on r.movie_id=m.id 
group by title
limit 10;



/* So, now that we know the top 10 movies, Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

select median_rating , count(movie_id) as movie_count from ratings
group by median_rating
order by median_rating;


/* Movies with a median rating of 7 is highest in number. */

-- Let's find out Which production house has produced the most number of hit movies (average rating > 8)

select production_company , count(id) as movie_count , dense_rank() over(order by count(id)desc) as prod_company_rank 
from movie as m
inner join ratings as r
on m.id=r.movie_id
where avg_rating >= 8 and production_company is not null
group by production_company;

-- Answer is Dream Warrior Pictures or National Theatre Live or both


-- How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

select genre ,count(g.movie_id) as movie_count from genre as g
inner join movie as m
on g.movie_id=m.id
inner join ratings as r
on m.id=r.movie_id
where month(date_published) = 3 and year = 2017 and m.country='USA' and r.total_votes>=1000
group by genre
order by movie_count desc;


-- Lets try to analyse with a unique problem statement.
-- Let's Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

select m.title , r.avg_rating , g.genre from genre as g
inner join movie as m  
on g.movie_id=m.id 
inner join ratings as r
on m.id=r.movie_id
where title like 'The%' and avg_rating >= 8
group by title 
order by avg_rating desc;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

select median_rating , count(id) as movie_count from movie as m
inner join ratings as r
on m.id=r.movie_id
where median_rating= 8 and date_published between '2018-04-01' and '2019-04-01'
group  by median_rating;


/* Now that we have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/





-- Let's find Which columns in the names table have null values??

select 
sum(case when name is null then 1 else 0 end ) as name_nulls,
sum(case when height is null then 1 else 0 end ) as height_nulls,
sum(case when date_of_birth is null then 1 else 0 end ) as date_of_birth_nulls,
sum(case when known_for_movies is null then 1 else 0 end ) as known_for_movies_nulls
from names;



/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by production comapany.*/

-- Who are the top three directors in the top three genres whose movies have an average rating > 8?

WITH top_genre AS
(
    SELECT genre,
           Count(m.id)                            AS movie_count,
           Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM movie                             AS m
           INNER JOIN genre                       AS g 
           on g.movie_id = m.id
           INNER JOIN ratings  AS r 
           ON r.movie_id = m.id
           WHERE avg_rating > 8
           GROUP BY  genre limit 3)
SELECT     n.NAME                                 AS director_name,
           count(d.movie_id)                      AS movie_count
FROM       director_mapping                       AS d
INNER JOIN genre g 
USING      (movie_id)
INNER JOIN names AS n 
ON      n.id = d.name_id
INNER JOIN top_genre
using    (genre)
INNER JOIN ratings 
using (movie_id)
WHERE   avg_rating > 8
GROUP BY  name
ORDER BY  movie_count DESC limit 3;

  

/* James Mangold can be hired as the director for company's next project. 
Now, let’s find out the top two actors.*/

-- Who are the top two actors whose movies have a median rating >= 8?

select n.name as actor_name ,count(rm.movie_id) as movie_count from names as n
inner join role_mapping as rm
on n.id= rm.name_id
inner join movie as m
on rm.movie_id = m.id
inner join ratings as r
on m.id=r.movie_id
where median_rating >= 8
group by actor_name
order by movie_count desc
limit 2;



/* Company plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Top three production houses based on the number of votes received by their movies?

select production_company , sum(total_votes) as vote_count , rank() over (order by sum(total_votes) desc) as prod_comp_rank from movie as m
inner join ratings as r
on m.id=r.movie_id  
group by production_company
order by sum(total_votes) desc
limit 3;


/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since company is based out of Mumbai, India also wants to woo its local audience. 
Comapny also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Actors with movies released in India based on their average ratings. Which actor is at the top of the list?
--  The actor should have acted in at least five Indian movies. 

SELECT name AS actor_name, total_votes,
			   COUNT(m.id) AS movie_count,
               ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actor_avg_rating,
               RANK() OVER(ORDER BY avg_rating DESC) AS actor_rank
FROM movie as m
INNER JOIN ratings as r 
ON m.id = r.movie_id
INNER JOIN role_mapping AS rm
ON m.id = rm.movie_id
INNER JOIN names AS n
ON rm.name_id = n.id
WHERE category='actor' AND country='india'
GROUP BY name 
HAVING COUNT(m.id)>=5
LIMIT 1;

-- Top actor is Vijay Sethupathi


-- Let's Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- The actresses should have acted in at least three Indian movies. 

select n.name as actress_name,sum(r.total_votes) as total_votes ,count(m.id)as movie_count ,
              ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2) AS actress_avg_rating,
              rank() over (order by r.avg_rating desc) as actress_rank from ratings as r
  inner join movie as m
  on r.movie_id=m.id
  inner join role_mapping as rm
  on  m.id=rm.movie_id
  inner join names as n
  on rm.name_id=n.id
  where category= 'actress' and country= 'India' and lower(languages) like '%hindi%'
  group by name 
  having count(m.id) >=3
  order by actress_avg_rating
  limit 5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Selecting thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/

SELECT 
    m.title AS movie_name,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One time watch'
        ELSE 'Flop'
    END AS movie_category
FROM
    movie AS m
        LEFT JOIN
    ratings AS r ON m.id = r.movie_id
        LEFT JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    LOWER(genre) = 'thriller';


/* Until now, we have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data .*/



-- Let's find out What is the genre-wise running total and moving average of the average movie duration? 

WITH genre_summary AS
(
SELECT 
    genre,
    ROUND(AVG(duration),2) AS avg_duration
FROM
    genre AS g
        LEFT JOIN
    movie AS m 
		ON g.movie_id = m.id
GROUP BY genre
)
SELECT *,
	SUM(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS running_total_duration,
    AVG(avg_duration) OVER (ORDER BY genre ROWS UNBOUNDED PRECEDING) AS moving_avg_duration
FROM
	genre_summary;
    


-- Let us find top 5 movies of each year with top 3 genres.

-- Let's find out Which are the five highest-grossing movies of each year that belong to the top three genres? 

-- Top 3 Genres based on most number of movies
with top_3_genre as 
( SELECT genre, COUNT(movie_id) AS number_of_movies
   FROM genre AS g
   INNER JOIN movie AS m
   ON g.movie_id = m.id
   GROUP BY genre
   ORDER BY COUNT(movie_id) DESC
   LIMIT 3
   ),
   top5_movies AS 
(
  SELECT genre,
         year,
         title AS movie_name,
         worlwide_gross_income,
         DENSE_RANK() OVER(PARTITION BY year ORDER BY worlwide_gross_income DESC) AS movie_rank
         FROM movie AS m
         INNER JOIN genre AS g 
         ON m.id = g.movie_id
         where genre IN (SELECT genre from top_3_genre)
)
select * from top5_movies 
where movie_rank<=5;
   










-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Let's see Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies

select production_company , count(m.id) as movie_count ,  
       row_number () over(order by count(id) desc) as prod_comp_rank
 from movie  as m
 inner join ratings as r
 on m.id=r.movie_id 
 where median_rating>=8 and production_company is not null and  POSITION(',' IN languages)>0
 group by production_company
 order by count(m.id) desc
 limit 2;








