/*
Data Cleaning, and Exploration
*/

--Look at the data

SELECT *
FROM ProjectsPortfolio..StudentsPerformanceinExams


--Sum up math, reading, and writing scores

SELECT [gender], [race/ethnicity], [parental level of education], [lunch], [test preparation course]
	, [math score], [reading score], [writing score], SUM([math score] + [reading score] + [writing score]) AS TotalScore
FROM ProjectsPortfolio..StudentsPerformanceinExams
GROUP BY [gender], [race/ethnicity], [parental level of education], [lunch], [test preparation course], [math score], [reading score], [writing score]


--Create a new column for TotalScore

ALTER TABLE	ProjectsPortfolio..StudentsPerformanceinExams
ADD TotalScore float


--Populate new TotalScore column

UPDATE ProjectsPortfolio..StudentsPerformanceinExams
SET TotalScore = [math score] + [reading score] + [writing score]


--Find average test scores by race/ethnicity

SELECT [race/ethnicity], AVG(TotalScore) AS AvgTotalScore
FROM ProjectsPortfolio..StudentsPerformanceinExams
GROUP BY [race/ethnicity]
ORDER BY AvgTotalScore DESC


--Find number of parents with college degrees by race/ethnicity

SELECT [race/ethnicity], [parental level of education], COUNT([parental level of education]) AS NumberOfCollegeDegrees
FROM ProjectsPortfolio..StudentsPerformanceinExams
WHERE [parental level of education] IN ('associate''s degree', 'bachelor''s degree', 'master''s degree')
GROUP BY [race/ethnicity], [parental level of education]
ORDER BY NumberOfCollegeDegrees DESC


--Do students perform better if their parents have a high level of education?
--The data shows that students who perform better have parents with high levels of education

SELECT [parental level of education], AVG(TotalScore) AS AvgTotalScore
FROM ProjectsPortfolio..StudentsPerformanceinExams
GROUP BY [parental level of education]
ORDER BY AvgTotalScore ASC


--Does high parent education level affect test scores across all races?
--Find average test scores by race, and parent education level

SELECT [race/ethnicity], [parental level of education], AVG(TotalScore) AS AvgTotalScore
FROM ProjectsPortfolio..StudentsPerformanceinExams
GROUP BY [race/ethnicity], [parental level of education]
ORDER BY [race/ethnicity], [parental level of education], AvgTotalScore DESC


--Do test preparation courses improve scores?
--Use CTE, and Self-Join to calculate percent increase in average test scores.
--Test preparation courses improve scores across all races, and parent education levels, with the exception of students from Group B, with parents who have obtained a Master's degree.

WITH AvgTotalScoreCTE AS
	(
	SELECT [race/ethnicity], [parental level of education], [test preparation course], AVG(TotalScore) AS AvgTotalScore
	FROM ProjectsPortfolio..StudentsPerformanceinExams
	GROUP BY [race/ethnicity], [parental level of education], [test preparation course]
	)
SELECT a.[race/ethnicity], a.[parental level of education], a.AvgTotalScore AS AvgTotalScoreNoTestPrep, b.AvgTotalScore AS AvgTotalScoreWithTestPrep
	, ((b.AvgTotalScore - a.AvgTotalScore) / a.AvgTotalScore * 100) AS PercentIncreaseInAvgTotalScoreWithTestPrep
FROM AvgTotalScoreCTE a
	JOIN AvgTotalScoreCTE b
		ON a.[race/ethnicity] = b.[race/ethnicity]
		AND a.[parental level of education] = b.[parental level of education]
WHERE a.[test preparation course] = 'none'
AND b.[test preparation course] = 'completed'
GROUP BY a.[race/ethnicity], a.[parental level of education], a.AvgTotalScore, b.AvgTotalScore

