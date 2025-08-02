-- NETFLIX Project --
SET SESSION local_infile = 1;

create database netflix;
use  netflix;
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
 select * from netflix;
 
 /* should have csv file in the following destiantion */
 SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv"
INTO TABLE netflix
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*
-- 15 Business Problems & Solutions
*/
-- 1. Count the number of Movies vs TV Shows
select * from netflix;

select type,count(*)
 from netflix 
group by 1; 

-- 2. Find the most common rating for movies and TV shows
select 
	type,
    rating
    from
	(select 
		type,
		rating,
		count(rating),
		rank() over(partition by type order by count(*) desc) as ranking
	from netflix 
	group by type,rating
	) as R
    where ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select * from netflix;
select * from netflix
where(type = "Movie" && release_year = "2020");

-- 4. Find the top 5 countries with the most content on Netflix
-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    TRIM(jt.country) AS country,
    COUNT(*) AS total_count
FROM netflix n
JOIN JSON_TABLE(
    CONCAT('["', REPLACE(n.country, ',', '","'), '"]'),
    '$[*]' COLUMNS (country VARCHAR(100) PATH '$')
) AS jt
WHERE jt.country IS NOT NULL
GROUP BY country
ORDER BY total_count DESC
LIMIT 5;

-- 5. Identify the longest movie
select * from netflix
where 
	type = "Movie"
    and
    duration = (select max(duration) from netflix);
    
-- 6. Find content added in the last 5 years
select * from netflix

where 
	str_to_date(date_added,'%M %D %Y') >= curdate() -interval 5 year;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix
where 
	director = "Rajiv Chilaka";
    
-- 8. List all TV shows with more than 5 seasons
select * from netflix
where 
	type = "TV show" && duration > "5 season";
    
-- 9. Count the number of content items in each genre
select 
	trim(jt.listed_in) as genre,
    count(n.show_id) as show_count
from netflix n
join json_table(
				concat('["',replace(listed_in, ',', '","'),'"]'),
				'$[*]'COLUMNS (listed_in varchar(100) path '$')
				)as jt
where jt.listed_in is not null
group by 1
order by 2
;
                
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!

select 
	country,
    release_year,
    count(show_id)
from netflix
where country="India"
group by release_year
order by count(show_id) desc 
limit 5;

-- 11. List all movies that are documentaries
 select * from netflix
  where
	type = "movie"
    && listed_in = "documentaries";
      
-- 12. Find all content without a director
SELECT * 
FROM netflix
WHERE TRIM(director) = '' 
   OR director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select 
    count(show_id) as total_movies
from netflix
where
 type = "Movie"
 && casts LIKE '%Salman Khan%' &&
 str_to_date(date_added,'%M %D %Y')>= curdate() - interval 10 year;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select
	count(show_id) as total_movies,
    trim(jt.casts) as actor
 from netflix n
 join json_table(
				concat('["',replace(casts, ',', '","'),'"]'),
				'$[*]'COLUMNS (casts varchar(100) path '$')
				)as jt
where country ="India" && trim(jt.casts) is not null
group by     trim(jt.casts)
order by count(show_id) desc
limit 10; 


 
 
/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN LOWER(description) LIKE '%kill%' 
              OR LOWER(description) LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
 
