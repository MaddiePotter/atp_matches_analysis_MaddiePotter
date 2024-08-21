USE [atp_matches]
SELECT *
FROM atp_matches_2016;

--QUESTIONS

--Section 1
--Q1: Total number of distinct players
SELECT winner_name AS 'player_name'
FROM atp_matches_2016
UNION
SELECT loser_name
FROM atp_matches_2016
ORDER BY player_name ASC;


--Q1a: All player height
WITH player_name_height AS (
SELECT winner_name AS 'Player_Name', winner_height AS 'Player_Height'
FROM atp_matches_2016
UNION 
SELECT loser_name, loser_height
FROM atp_matches_2016
)
SELECT Player_Name, (1.00 * Player_Height) AS 'Player_Height_cm'
FROM player_name_height
ORDER BY Player_Height_cm ASC;


--Q1a: Average Winner Height
WITH winner_distinct_height AS (
    SELECT distinct winner_name, winner_height
	FROM atp_matches_2016
)
SELECT AVG(1.00 * winner_height)
FROM winner_distinct_height;


--Q1b: Average Loser Height
WITH loser_distinct_height AS (
    SELECT distinct loser_name, loser_height
	FROM atp_matches_2016
)
SELECT AVG(1.00 * loser_height)
FROM loser_distinct_height;


--Q1d: Loser Height Distribution 
SELECT COUNT(loser_height), (1.00 * loser_height) AS 'Loser_Height_cm'
FROM atp_matches_2016
GROUP BY loser_height;


--Q1d: Winner Height Distribution
SELECT COUNT(winner_height), (1.00 * winner_height) AS 'Winner_Height_cm'
FROM atp_matches_2016
GROUP BY winner_height;


--	Q1d: Count of players height
WITH player_name_height AS (
SELECT winner_name AS 'Player_Name', winner_height AS 'Player_Height'
FROM atp_matches_2016
UNION 
SELECT loser_name, loser_height
FROM atp_matches_2016
)
SELECT COUNT(Player_Name), (1.00 * Player_Height) AS 'Player_Height_cm'
FROM player_name_height
GROUP BY Player_Height;


-- Q1e: Count of players in height distribution
WITH player_name_height AS (
SELECT winner_name AS 'Player_Name', winner_height AS 'Player_Height'
FROM atp_matches_2016
UNION 
SELECT loser_name, loser_height
FROM atp_matches_2016
),
height_range AS
(
  SELECT *,
         CASE
             WHEN Player_Height < 165.00 THEN 'Under 165' 
             WHEN Player_Height BETWEEN 165.00 AND 185.00 THEN '165 - 185'
             WHEN Player_Height BETWEEN 185.00 AND 205.00 THEN '185 - 205'
             WHEN Player_Height > 205.00 THEN 'Over 205'
             ELSE 'Invalid Height'
         END AS Heights_in_cm
  FROM player_name_height
)
SELECT COUNT(*) AS Height_Count,
       Heights_in_cm
FROM height_range
GROUP BY Heights_in_cm
ORDER BY CASE Heights_in_cm
           WHEN 'Under 165' THEN 1
           WHEN '165 - 185' THEN 2
           WHEN '185 - 205' THEN 3
		   WHEN 'Over 205' THEN 4
         END;


--Q3: All Player Country
WITH player_name_ioc AS (
SELECT winner_name AS 'Player_Name', winner_ioc AS 'Player_IOC'
FROM atp_matches_2016
UNION 
SELECT loser_name, loser_ioc
FROM atp_matches_2016
)
SELECT player_name, player_ioc
FROM player_name_ioc
ORDER BY player_ioc ASC;

--	Q3a: Player country distribution
WITH player_name_ioc AS (
SELECT winner_name AS 'Player_Name', winner_ioc AS 'Player_IOC'
FROM atp_matches_2016
UNION 
SELECT loser_name, loser_ioc
FROM atp_matches_2016
)
SELECT count(player_name) AS 'Player_Count', player_ioc AS 'Player_IOC'
FROM player_name_ioc
GROUP BY player_ioc
ORDER BY 1 DESC;


--	Q3b: Top 5 Countries with the most wins 
WITH winner_distinct_IOC AS (
    SELECT distinct winner_name, winner_ioc
	FROM atp_matches_2016
)
SELECT TOP (5) 
COUNT(winner_name), winner_ioc
FROM winner_distinct_IOC
GROUP BY winner_ioc
ORDER BY 1 DESC;


--	Q3c: Top 5 Countries with the most loses
WITH loser_distinct_IOC AS (
    SELECT distinct loser_name, loser_ioc
	FROM atp_matches_2016
)
SELECT TOP (5) 
COUNT(loser_name), loser_ioc
FROM loser_distinct_IOC
GROUP BY loser_ioc
ORDER BY 1 DESC;


--Section 2

With player_name_full AS (
SELECT winner_name AS 'player_name'
FROM atp_matches_2016
UNION ALL
SELECT loser_name
FROM atp_matches_2016
),
player_count_total AS (
SELECT player_name, count(player_name) as 'player_count'
FROM player_name_full
GROUP BY player_name
)
Select *
FROM atp_matches_2016
INNER JOIN player_count_total ON atp_matches_2016.loser_name = player_count_total.player_name;



--Q1: Top 5 players with the most wins
SELECT TOP (5)
winner_name,
count(winner_name) AS 'Number_of_Wins'
FROM atp_matches_2016
Group BY winner_name
ORDER BY 2 DESC;


--	Q1a: Count of aces per player
--	Q1b: Count of double faults per player
--	Q1c: average match length game per player
SELECT TOP (5)
winner_name, count(winner_name) AS 'win_count',avg(minutes) AS 'avg_minutes', avg(winner_age) AS 'avg_age', 
avg(winner_height) AS 'avg_height', avg(w_ace) AS 'avg_num_of_aces', 
avg(w_df) AS 'avg_num_of_double_faults'
FROM atp_matches_2016
Group By winner_name
ORDER BY win_count DESC;
 

--Q2: Top 5 players with the most loses
SELECT TOP (5)
loser_name,
count(loser_name) AS 'Number_of_Loses'
FROM atp_matches_2016
Group BY loser_name
ORDER BY 2 DESC;


--	Q2a: Count of aces per player
--	Q2b: Count of double faults per player
--	Q2c: average match length game per player
SELECT Top (5)
loser_name, count(loser_name) AS 'lose_count', avg(minutes) AS 'avg_minutes', 
avg(loser_age) AS 'avg_age', 
avg(loser_height) AS 'avg_height', avg(l_ace) AS 'avg_num_of_aces', 
avg(l_df) AS 'avg_num_of_double_faults'
FROM atp_matches_2016
Group By loser_name
ORDER BY lose_count DESC;


--SECTION 3
--Q1: Hard Court vs Grass vs Clay
--Q1a: what percent of games were played on which surface
SELECT 
CAST(100.0 * sum(CASE WHEN surface = 'Hard' THEN 1 else 0 end)/ count(surface) as decimal(5,2)) 
AS 'percent_hardcourt',
CAST(100.0 * sum(CASE WHEN surface = 'Clay' THEN 1 else 0 end)/ count(surface) as decimal(5,2))
AS 'percent_clay',
CAST(100.0 * sum(CASE WHEN surface = 'Grass' THEN 1 else 0 end)/ count(surface) as decimal(5,2))
AS 'percent_grass'
FROM atp_matches_2016;


--Q1b: Averages per court type
SELECT
surface, AVG(minutes) as 'gametime_minutes_AVG', 
(AVG(w_ace) + AVG(l_ace))/2 AS 'Ace_AVG', (AVG(w_df) + AVG(l_df))/2 AS 'Double_Fault_AVG'
FROM atp_matches_2016
GROUP BY surface;







