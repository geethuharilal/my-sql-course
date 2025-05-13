-- Football Match exercise
 
/*
The FootballMatch table shows the EPL matches played in 2024/25 season as of 16th March 2025
 
Important Columns
Date - Match Date (dd/mm/yy)
Time - Time of match kick off
HomeTeam- Home Team
AwayTeam - Away Team
FTHG -Full Time Home Team Goals
FTAG - Full Time Away Team Goals
FTR - Full Time Result (H=Home Win, D=Draw, A=Away Win)
 
Full details at https://zomalex.co.uk/datasets/football_match_dataset.html
*/
 
SELECT
    fm.Date
    , fm.HomeTeam
    , fm.AwayTeam
    , fm.FTHG
    , fm.FTAG
    , fm.FTR
FROM
    FootballMatch fm
 
/*
How many games have been played?.  
- In total
- By each team
- By Month
*/
SELECT COUNT(*) as total_games from FootballMatch fm;

SELECT MONTH(Date), COUNT(*) as total_games
from FootballMatch fm
group by MONTH(Date) ;

SELECT
    DATENAME(MONTH,fm.[Date]) AS monthName
    ,MONTH(fm.[Date])

    ,COUNT(*) AS total_games
FROM
    FootballMatch fm
GROUP BY MONTH(fm.[Date]),DATENAME(MONTH,fm.[Date])
ORDER BY MONTH(fm.[Date]) ASC;

 
SELECT
    DATENAME(YEAR,fm.[Date]) AS yearName
    ,DATENAME(MONTH,fm.[Date]) AS monthName
    ,MONTH(fm.[Date]) AS monthNumber
    ,COUNT(*) AS total_games
FROM
    FootballMatch fm
GROUP BY MONTH(fm.[Date]),DATENAME(MONTH,fm.[Date]),DATENAME(YEAR,fm.[Date])
ORDER BY yearName ASC,monthNumber ASC;


SELECT
    DATENAME(YEAR,fm.[Date]) AS yearName
    ,DATENAME(MONTH,fm.[Date]) AS monthName
    --,MONTH(fm.[Date]) AS monthNumber
    ,COUNT(*) AS total_games
FROM
    FootballMatch fm
GROUP BY MONTH(fm.[Date]),DATENAME(MONTH,fm.[Date]),DATENAME(YEAR,fm.[Date])
ORDER BY yearName ASC,MONTH(fm.[Date]) ASC;


-- How many goals have been scored in total

SELECT
    SUM(fm.FTHG)+SUM(fm.FTAG) AS totalGoals
FROM
    FootballMatch fm

-- How many goals have been scored by each team?
SELECT
    fm.HomeTeam as homeTeam
    ,sum(fm.FTHG) AS totalGoals
FROM
    FootballMatch fm
GROUP BY fm.HomeTeam

SELECT
    fm.AwayTeam as awayTeam
    ,sum(fm.FTAG) AS totalGoals
FROM
    FootballMatch fm
GROUP BY fm.AwayTeam


   
    SELECT
        fm.HomeTeam AS team
    ,sum(fm.FTHG) AS totalGoals
    FROM
        FootballMatch fm
    GROUP BY fm.HomeTeam
UNION ALL
    SELECT
        fm.AwayTeam AS team
    ,sum(fm.FTAG) AS totalGoals
    FROM
        FootballMatch fm
    GROUP BY fm.AwayTeam
    ORDER by team



with cte as(
    SELECT
        fm.HomeTeam AS team
    ,sum(fm.FTHG) AS totalGoals
    FROM
        FootballMatch fm
    GROUP BY fm.HomeTeam
UNION ALL
    SELECT
        fm.AwayTeam AS team
    ,sum(fm.FTAG) AS totalGoals
    FROM
        FootballMatch fm
    GROUP BY fm.AwayTeam
  
   )SELECT cte.team, sum(cte.totalGoals) as TotalGoals from cte GROUP by cte.team 
   ORDER by sum(cte.totalGoals) DESC

   -- temp approach
DROP TABLE if EXISTS #LeagueTable

    SELECT
        fm.HomeTeam AS Team
    ,sum(fm.FTHG) AS GF
    into #LeagueTable 
    FROM
        FootballMatch fm
    GROUP BY fm.HomeTeam
UNION ALL
    SELECT
        fm.AwayTeam AS team
    ,sum(fm.FTAG) AS totalGoals
    FROM
        FootballMatch fm
    GROUP BY fm.AwayTeam

  SELECT Team, SUM(GF) as GF FROM #LeagueTable GROUP BY Team ORDER BY Team

-- add GA
DROP TABLE IF EXISTS #LeagueTable;
 
SELECT
    fm.HomeTeam as Team
    , SUM(fm.FTHG) AS GF
     ,SUM(fm.FTAG) as GA
INTO #LeagueTable
FROM
    FootballMatch fm
group by fm.HomeTeam
UNION ALL
SELECT
    fm.AwayTeam
    , SUM(fm.FTAG)
    , SUM(fm.FTHG)
FROM
    FootballMatch fm
group by fm.AwayTeam  
 
SELECT t.Team As Team,
    SUM(T.GF) as GF
    , SUM(T.GA) as GA
FROM #LeagueTable t
    group by t.Team
    order by t.Team
 

 -- add played
DROP TABLE IF EXISTS #LeagueTable;
 
SELECT
    fm.HomeTeam as Team
    ,count(*) as played
    , SUM(fm.FTHG) AS GF
     ,SUM(fm.FTAG) as GA
INTO #LeagueTable
FROM
    FootballMatch fm
group by fm.HomeTeam
UNION ALL
SELECT
    fm.AwayTeam
    , COUNT(*) as played
    , SUM(fm.FTAG)
    , SUM(fm.FTHG)
FROM
    FootballMatch fm
group by fm.AwayTeam  
 
SELECT t.Team As Team
    , sum(played) as played
    ,SUM(T.GF) as GF
    , SUM(T.GA) as GA
FROM #LeagueTable t
    group by t.Team
    order by t.Team

-- add won
DROP TABLE IF EXISTS #LeagueTable;
 
SELECT
    fm.HomeTeam as Team
    ,count(*) as played
    , sum(CASE fm.FTR when 'H' then 1 else 0 end) as Won
    , SUM(fm.FTHG) AS GF
     ,SUM(fm.FTAG) as GA 
INTO #LeagueTable
FROM
    FootballMatch fm
group by fm.HomeTeam
UNION ALL
SELECT
    fm.AwayTeam
    , COUNT(*) as played
    , SUM(CASE fm.FTR when 'A' then 1 else 0 end) as Won
    , SUM(fm.FTAG)
    , SUM(fm.FTHG)
FROM
    FootballMatch fm
group by fm.AwayTeam  
 
SELECT t.Team As Team
    , sum(T.played) as Played
    , sum(T.Won) as Won
    ,SUM(T.GF) as GF
    , SUM(T.GA) as GA
FROM #LeagueTable t
    group by t.Team
    order by t.Team


-- simpler way

DROP TABLE IF EXISTS #LeagueTable;
 
SELECT
    fm.HomeTeam AS Team
    , case when fm.FTR='H' then 1 else 0 end as Won
    , case fm.FTR when 'D' then 1 else 0 end as Drawn
    , case fm.FTR when 'A' then 1 else 0 end as Lost
    ,fm.FTHG AS GF
    ,fm.FTAG AS GA
INTO #LeagueTable
    FROM FootballMatch fm
UNION ALL
SELECT
        fm.AwayTeam
        , case when fm.FTR = 'A' then 1 else 0 end as Won
        , case fm.FTR when 'D' then 1 else 0 end as Drawn
        , case fm.FTR when 'H' then 1 else 0 end as Lost
        ,fm.FTAG
        ,fm.FTHG
FROM  FootballMatch fm
 
SELECT * FROM #LeagueTable;
 
SELECT
    t.Team AS Team
    , count(*) as played
    , SUM(T.Won) as Won
    , SUM(T.Drawn) as Drawn
    , SUM(T.Lost) as Lost
    ,SUM(T.GF) AS GF    
    ,SUM(T.GA) AS GA
FROM
    #LeagueTable t
GROUP BY t.Team
ORDER BY t.Team;