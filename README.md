# Netflix_SQL_Project Based On Movies And TV Shows

![Netflix Logo](https://github.com/Vamsikrishna40/Netflix_SQL_Project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```
## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
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
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT title, duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT title, date_added
FROM netflix_titles
WHERE YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) >= YEAR(CURDATE()) - 5;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Toshiya Shinohara'

```sql
SELECT title, type
FROM netflix_titles
WHERE director LIKE '%Toshiya Shinohara%';
```

**Objective:** List all content directed by 'Toshiya Shinohara'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT title, duration
FROM netflix_titles
WHERE type = 'TV Show' AND 
      duration LIKE '%Season%' AND
      CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT title
FROM netflix_titles
WHERE type = 'Movie' AND listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT title
FROM netflix_titles
WHERE director IS NULL OR director = '';
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Kamal Hassan' Appeared in the Last 10 Years

```sql
SELECT COUNT(*) AS Kamal_Hassan_movies
FROM netflix_titles
WHERE type = 'Movie'
  AND cast LIKE '%Kamal Hassan%'
  AND release_year >= YEAR(CURDATE()) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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

```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
  CASE 
    WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
  END AS content_quality,
  COUNT(*) AS total
FROM netflix_titles
GROUP BY content_quality;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## **Note:**The SQL Queries will Work in MySQL Workbench 

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
