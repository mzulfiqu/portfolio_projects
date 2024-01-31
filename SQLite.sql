-- we have two distinct datasets one is apple app store data and other is app store descriptions data
--creating a single table combining all the data related to apple app store descriptions

CREATE TABLE applestore_description_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

-- Identifying stakeholder 
-- here the the stakeholder is an apple developer who would like to seek answers 
-- regarding which app categories are most popular what are the pricing and how to improve ratings


**Exploratory Data Analysis**

--check the number of unique apps
SELECT COUNT(DISTINCT id) AS UniqueAppIds
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIds
FROM applestore_description_combined

	
--check for any missing values in key fields
	
SELECT COUNT(*) AS MissingValue
FROM AppleStore
WHERE track_name is NULL OR user_rating is NULL OR prime_genre is NULL 

SELECT COUNT(*) AS MissingValue
FROM applestore_description_combined
WHERE app_desc is NULL

--Finding the number of apps per genre

SELECT prime_genre, COUNT(*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

	
--Get an overview of the apps ratingsAppleStore
	
SELECT 	MIN(user_rating) AS MinRating,
	MAX(user_rating) AS MaxRating,
        AVG(user_rating) AS AvgRating
FROM AppleStore

	
--Finding if paid apps have higher ratings than free apps 

SELECT CASE
	WHEN price>0 THEN 'Paid'
        ELSE 'Free'
        END AS App_Type,
        ROUND(avg(user_rating),2) AS Avg_rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratings

SELECT CASE
	WHEN lang_num < 10 then '<10 languages'
        when lang_num BETWEEN 10 and 30 then '10-30 languages'
        else '>30 languages'
      	END AS language_bucket,
      	ROUND(avg(user_rating),2) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

	
--Finding genres with low ratings

SELECT prime_genre, ROUND(avg(user_rating),2) AS Avg_Rating
FROM AppleStore
group by prime_genre
ORDER BY Avg_Rating ASC
LIMIT 10

--Finding if there is a correlation between the length of the app description and the user ratings
	
SELECT CASE
	WHEN length(b.app_desc) < 500 then 'short'
        WHEN length(b.app_desc) between 500 and 1000 then 'medium'
        else'long'
        end as desc_length,
        ROUND(avg(user_rating),2) AS Avg_Rating
        
FROM AppleStore a
JOIN applestore_description_combined b
ON a.id = b.id
GROUP BY desc_length
ORDER BY Avg_Rating DESC


--Finding the top rated app from each genre

SELECT prime_genre, track_name, user_rating
FROM
	(SELECT prime_genre, track_name, user_rating,
     RANK() OVER (PARTITION BY prime_genre order by user_rating DESC, rating_count_tot DESC) AS rank
     FROM
     AppleStore
     ) AS a 
WHERE 
a.rank = 1

-- Final Recommendation

-- 1. paid apps have better ratings (could be due to a number of reasons, user who pay for app might have higher engagement and percieve higher value, if the developed app has good quality they might consider charging a fee)
-- 2. Apps supporting between 10 and 30 languages have better ratings (its not just quantity of language, our focus shall be on selecting the right languages to focus on depending on our geographical target audiance)
-- 3. Finance and Book apps have low ratings (this might suggest that the apps in these sector might not meet user expectations, this represents a market opportunity to build something that the users actually need)
-- 4. Apps with longer description have better ratings (users do appreciate a good description detailing the features and intricacies, a well crafted description can set clear expectation for the users even before they download the app)
-- 5. A new app shall aim for an average rating above 3.5 (since avergae ratings are 3.5, in order to stand out from the crowd we shall aim for better ratings)
-- 6. Games and Entertainment have high competition (it suggest high user demands in this segment, presence of high volums of app in this secotr might suggest a saturation level, entering these segment might be challenging)
     
