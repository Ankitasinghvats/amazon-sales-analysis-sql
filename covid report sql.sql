CREATE TABLE covid (
    Province VARCHAR(255),
    `Country/Region` VARCHAR(255),
    Latitude FLOAT,
    Longitude FLOAT,
    Date VARCHAR(10), -- Temporary storage for the date as string
    Confirmed INT,
    Deaths INT,
    Recovered INT
);
ALTER TABLE corona
ADD COLUMN year INT,
ADD COLUMN month INT;

-- Step 3: Update the new columns with extracted 'year' and 'month' values
UPDATE corona
SET year = EXTRACT(YEAR FROM Date_converted),
    month = EXTRACT(MONTH FROM Date_converted);
select * from corona
-- To avoid any errors, check missing value / null value 

-- Q1. Write a code to check NULL values
SELECT * FROM corona 
WHERE Province IS NULL 
   OR `Country/Region` IS NULL 
   OR Latitude IS NULL 
   OR Longitude IS NULL 
   OR Date_converted IS NULL 
   OR Confirmed IS NULL 
   OR Deaths IS NULL 
   OR Recovered IS NULL;

/*Q2. If NULL values are present, update them with zeros for all columns. */
UPDATE corona
SET Province = COALESCE(Province, 'Unknown'),
    `Country/Region` = COALESCE(`Country/Region`, 'Unknown'),
    Latitude = COALESCE(Latitude, 0),
    Longitude = COALESCE(Longitude, 0),
    Date_converted = COALESCE(Date_converted, '1900-01-01'),
    Confirmed = COALESCE(Confirmed, 0),
    Deaths = COALESCE(Deaths, 0),
    Recovered = COALESCE(Recovered, 0)
WHERE Province IS NULL 
   OR `Country/Region` IS NULL 
   OR Latitude IS NULL 
   OR Longitude IS NULL 
   OR Date_converted IS NULL 
   OR Confirmed IS NULL 
   OR Deaths IS NULL 
   OR Recovered IS NULL;

-- Q3. check total number of rows
SELECT COUNT(*) FROM corona;

-- Q4. Check what is start_date and end_date
SELECT MIN(date_converted) AS start_date, MAX(date_converted) AS end_date FROM corona;

-- Q5. Number of month present in dataset
SELECT COUNT(DISTINCT(month)) AS num_months FROM corona;


-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT month,
       AVG(Confirmed) AS avg_confirmed, 
       AVG(Deaths) AS avg_deaths, 
       AVG(Recovered) AS avg_recovered
FROM (
    SELECT DATE_FORMAT(Date_converted, '%Y-%m') AS month, 
           Confirmed, 
           Deaths, 
           Recovered
    FROM corona
) AS subquery
GROUP BY month;


-- Q7. Find most frequent value for confirmed, deaths, recovered each month 
SELECT month, 
       year, 
       Confirmed, 
       Deaths, 
       Recovered
FROM (
    SELECT month, 
           year, 
           Confirmed, 
           Deaths, 
           Recovered, 
           ROW_NUMBER() OVER (PARTITION BY month, year ORDER BY COUNT(*) DESC) AS rn
    FROM corona
    GROUP BY month, year, Confirmed, Deaths, Recovered
) AS subquery
WHERE rn = 1;


-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT  year,
       MIN(Confirmed) AS min_confirmed, 
       MIN(Deaths) AS min_deaths, 
       MIN(Recovered) AS min_recovered
FROM corona
GROUP BY year;


-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT  year,
       Max(Confirmed) AS max_confirmed, 
       Max(Deaths) AS max_deaths, 
       Max(Recovered) AS max_recovered
FROM corona
GROUP BY year;

-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT  month,
       sum(Confirmed) AS total_confirmed, 
       sum(Deaths) AS total_deaths, 
       sum(Recovered) AS total_recovered
FROM corona
GROUP BY month;
-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT SUM(Confirmed) AS total_confirmed, 
       AVG(Confirmed) AS avg_confirmed, 
       VARIANCE(Confirmed) AS var_confirmed, 
       STDDEV(Confirmed) AS stdev_confirmed
FROM corona;

-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT month, 
       SUM(Deaths) AS total_deaths, 
       AVG(Deaths) AS avg_deaths, 
       VARIANCE(Deaths) AS var_deaths, 
       STDDEV(Deaths) AS stdev_deaths
FROM corona
GROUP BY month;

-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT SUM(Recovered) AS total_recovered, 
       AVG(Recovered) AS avg_recovered, 
       VARIANCE(Recovered) AS var_recovered, 
       STDDEV(Recovered) AS stdev_recovered
FROM corona;

-- Q14. Find Country having highest number of the Confirmed case
SELECT `Country/Region`, SUM(Confirmed) AS total_confirmed
FROM corona
GROUP BY `Country/Region`
ORDER BY total_confirmed DESC
LIMIT 1;

-- Q15. Find Country having lowest number of the death case
SELECT `Country/Region`, SUM(Deaths) AS total_deaths
FROM corona
GROUP BY `Country/Region`
ORDER BY total_deaths ASC
LIMIT 1;

-- Q16. Find top 5 countries having highest recovered case
SELECT `Country/Region`, SUM(Recovered) AS total_recovered
FROM corona
GROUP BY `Country/Region`
ORDER BY total_recovered DESC
LIMIT 5;
