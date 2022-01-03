/*
Data Cleaning, and Exploration
*/

--------------------------------------------------------------------------------------
--Look at the data

SELECT *
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019


SELECT *
FROM ProjectsPortfolio..BoxOfficeMojo2019Gross

--------------------------------------------------------------------------------------
--What were the top 10 highest earning films in 2019?

SELECT TOP (10) *
FROM ProjectsPortfolio..BoxOfficeMojo2019Gross
ORDER BY [2019 Gross] DESC

--------------------------------------------------------------------------------------
--Change date format

SELECT
PARSENAME(REPLACE([Date, Day], ',', '.'), 2) AS "Date"
,PARSENAME(REPLACE([Date, Day], ',', '.'), 1) AS "Day"
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019


ALTER TABLE	ProjectsPortfolio..BoxOfficeMojoDaily2019
ADD [Date] DATE;


UPDATE ProjectsPortfolio..BoxOfficeMojoDaily2019
SET [Date] = TRIM(PARSENAME(REPLACE([Date, Day], ',', '.'), 2))


ALTER TABLE	ProjectsPortfolio..BoxOfficeMojoDaily2019
ADD [Day] NVARCHAR(255);


UPDATE ProjectsPortfolio..BoxOfficeMojoDaily2019
SET [Day] = TRIM(PARSENAME(REPLACE([Date, Day], ',', '.'), 1))

--------------------------------------------------------------------------------------
--Join 2019 Total Gross data into Daily Gross data

SELECT *
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019 d
	LEFT JOIN ProjectsPortfolio..BoxOfficeMojo2019Gross g
	ON d.[#1 Release] = g.[#1 Release]
ORDER BY [Date]

--------------------------------------------------------------------------------------
--Show daily running Gross for each movie

SELECT *,
	SUM(d.[Gross]) OVER (PARTITION BY d.[#1 Release ] ORDER BY d.[Date]) AS RunningGross
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019 d
	LEFT JOIN ProjectsPortfolio..BoxOfficeMojo2019Gross g
	ON d.[#1 Release] = g.[#1 Release]
ORDER BY d.[Date] ASC

--------------------------------------------------------------------------------------
--Compare revenue on weekends vs weekdays for each film

WITH WkEndRev AS
	(
	SELECT [#1 Release], SUM([Gross]) AS WeekendRevenue
	FROM ProjectsPortfolio..BoxOfficeMojoDaily2019
	WHERE [Day] IN ('Friday', 'Saturday', 'Sunday')
	GROUP BY [#1 Release]
	)
SELECT wer.[#1 Release], wer.WeekendRevenue, SUM([Gross]) AS WeekdayRevenue
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019 bo
	JOIN WkEndRev wer
		ON bo.[#1 Release] = wer.[#1 Release]
WHERE [Day] IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday')
GROUP BY wer.[#1 Release], wer.WeekendRevenue
ORDER BY WeekendRevenue DESC

--------------------------------------------------------------------------------------
--Which films had higher weekday earnings than on weekends?

WITH WkEndRev AS
	(
	SELECT [#1 Release], SUM([Gross]) AS WeekendRevenue
	FROM ProjectsPortfolio..BoxOfficeMojoDaily2019
	WHERE [Day] IN ('Friday', 'Saturday', 'Sunday')
	GROUP BY [#1 Release]
	),
	WkDayRev AS
	(
	SELECT [#1 Release], SUM([Gross]) AS WeekdayRevenue
	FROM ProjectsPortfolio..BoxOfficeMojoDaily2019
	WHERE [Day] IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday')
	GROUP BY [#1 Release]
	)
SELECT wer.[#1 Release], WeekdayRevenue, WeekendRevenue
FROM WkEndRev wer
	JOIN WkDayRev wdr
		ON wer.[#1 Release] = wdr.[#1 Release]
WHERE WeekendRevenue < WeekdayRevenue
ORDER BY WeekdayRevenue DESC

--------------------------------------------------------------------------------------
--What percentage of the gross was earned on weekends?

SELECT d.[#1 Release], SUM(d.[Gross])/MAX(g.[2019 Gross]) * 100 AS PctGrossEarnedOnWeekend
FROM ProjectsPortfolio..BoxOfficeMojoDaily2019 d
	LEFT JOIN ProjectsPortfolio..BoxOfficeMojo2019Gross g
	ON d.[#1 Release] = g.[#1 Release]
WHERE d.[Day] IN ('Friday', 'Saturday', 'Sunday')
GROUP BY d.[#1 Release]
ORDER BY PctGrossEarnedOnWeekend DESC
