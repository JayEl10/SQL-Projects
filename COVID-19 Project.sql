/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Subqueries, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


--Look at the data

SELECT *
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date


--Select data in the United States

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'United States'
ORDER BY location, date


--Total Deaths vs Total Cases in the United States
--Shows chance of dying if you contract COVID in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'United States'
ORDER BY location, date


--Total Cases vs Population in the United States
--Shows percentage of population infected with COVID in the United States

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
AND location = 'United States'
ORDER BY location, date


--Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Countries with lower infection rate than the United States

WITH CountryInfectionRate
AS
(
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentPopulationInfected
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
)
SELECT *
FROM CountryInfectionRate
WHERE PercentPopulationInfected <
	(
	SELECT PercentPopulationInfected
	FROM CountryInfectionRate
	WHERE location = 'United States'
	)
ORDER BY PercentPopulationInfected DESC


--Countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Total deaths by continent

SELECT continent, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--World cases, deaths, and death rate

SELECT
	SUM(new_cases) AS WorldTotalCases, SUM(CAST(new_deaths AS INT)) AS WorldTotalDeaths, 
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS WorldDeathPercentage
FROM ProjectsPortfolio..CovidDeaths
WHERE continent IS NOT NULL


--Total population vs vaccinations
--Shows percentage of population that has recieved at least one COVID vaccination

SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ProjectsPortfolio..CovidDeaths d
JOIN ProjectsPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY location, date


--Using CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac
AS
(
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ProjectsPortfolio..CovidDeaths d
JOIN ProjectsPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac


--Using Temp Table to perform calculation on PARTITION BY in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ProjectsPortfolio..CovidDeaths d
JOIN ProjectsPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
	d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM ProjectsPortfolio..CovidDeaths d
JOIN ProjectsPortfolio..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
