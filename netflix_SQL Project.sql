Create Database Netflix;
Use Netflix;

--- Business Problems and Solutions
--- 1. Count the Number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*)
FROM netflix_titles
GROUP BY 1;
--- Objective: Determine the distribution of content types on Netflix.


--- 2. Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_titles
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rnk
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rnk = 1;
--- Objective: Identify the most frequently occurring rating for each type of content


--- 3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * 
FROM netflix_titles
WHERE release_year = 2020;
--- Objective: Retrieve all movies released in a specific year.

--- 4. Find the Top 5 Countries with the Most Content on Netflix
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
, country_flat AS (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', numbers.n), ',', -1)) AS single_country
    FROM netflix_titles
    JOIN numbers 
        ON numbers.n <= 1 + CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', ''))
    WHERE country IS NOT NULL AND country <> ''
)
SELECT single_country AS country, COUNT(*) AS total_content
FROM country_flat
GROUP BY single_country
ORDER BY total_content DESC
LIMIT 5;

--- Objective: Identify the top 5 countries with the highest number of content items.

--- 5. Identify the longest movie
SELECT title, duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

 --- Objective: Find the movie with the longest duration.
 
--- 6. Content added in the last 5 years
SELECT title, date_added
FROM netflix_titles
WHERE YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) >= YEAR(CURDATE()) - 5;

--- Objective: Retrieve content added to Netflix in the last 5 years.

--- 7. All movies/TV shows by director 'Toshiya Shinohara'
SELECT title, type
FROM netflix_titles
WHERE director LIKE '%Toshiya Shinohara%';

--- Objective: List all content directed by 'Toshiya Shinohara'.

--- 8. TV shows with more than 5 seasons
SELECT title, duration
FROM netflix_titles
WHERE type = 'TV Show' AND 
      duration LIKE '%Season%' AND
      CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
      
--- Objective: Identify TV shows with more than 5 seasons.

--- 9. Number of content items in each genre (from 'listed_in')
WITH RECURSIVE numbers AS (
    SELECT 1 n
    UNION ALL SELECT n + 1 FROM numbers WHERE n < 5
)
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre,
       COUNT(*) AS total
FROM netflix_titles
JOIN numbers
   ON numbers.n <= 1 + CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', ''))
GROUP BY genre
ORDER BY total DESC;

--- Objective: Count the number of content items in each genre.
 
--- 10. Each year and the average number of content released in India, top 5 years sql
SELECT release_year, AVG(cnt) AS avg_content
FROM (
  SELECT release_year, COUNT(*) AS cnt
  FROM netflix_titles
  WHERE country LIKE '%India%'
  GROUP BY release_year, title
) AS yearly
GROUP BY release_year
ORDER BY avg_content DESC
LIMIT 5;

--- Objective: Calculate and rank years by the average number of content releases by India.

--- 11. All movies that are documentaries
SELECT title
FROM netflix_titles
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';

--- Objective: Retrieve all movies classified as documentaries.

--- 12. All content without a director sql
SELECT title
FROM netflix_titles
WHERE director IS NULL OR director = '';

--- Objective: List content that does not have a director.

--- 13. How many movies has actor 'Kamal Hassan' appeared in last 10 years?
SELECT COUNT(*) AS Kamal_Hassan_movies
FROM netflix_titles
WHERE type = 'Movie'
  AND cast LIKE '%Kamal Hassan%'
  AND release_year >= YEAR(CURDATE()) - 10;
  
--- Objective: Count the number of movies featuring 'Kamal Hassan' in the last 10 years.

--- 14. Top 10 actors in most movies produced in India
WITH actors AS (
  SELECT title, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n), ',', -1)) AS actor
  FROM netflix_titles
  JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
  ) numbers
    ON CHAR_LENGTH(cast) - CHAR_LENGTH(REPLACE(cast, ',', '')) >= n - 1
  WHERE country LIKE '%India%' AND type = 'Movie'
)
SELECT actor, COUNT(*) as movies_count
FROM actors
WHERE actor != ''
GROUP BY actor
ORDER BY movies_count DESC
LIMIT 10;

--- Objective: Identify the top 10 actors with the most appearances in Indian-produced movies

--- 15. Categorize as 'Bad' or 'Good' based on keywords in description, and count
SELECT 
  CASE 
    WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
  END AS content_quality,
  COUNT(*) AS total
FROM netflix_titles
GROUP BY content_quality;

--- Objective: Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


