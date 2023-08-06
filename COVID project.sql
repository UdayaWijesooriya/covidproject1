SELECT *
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM datascienceproject..covidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select the data that we are lokking for to use

SELECT location, date, total_cases, total_deaths, population
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL


-- Total cases VS total deaths
SELECT location, date, Total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS death_ratio
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Select only Sri Lankan data
SELECT location, date, Total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS death_ratio
FROM datascienceproject..covidDeaths
WHERE location LIKE '%Lanka%'
ORDER BY 1,2

-- Total Deaths VS Population
SELECT location, date, total_cases, population, (total_cases/population) AS PopulationInfected
FROM datascienceproject..covidDeaths
WHERE location LIKE '%Lanka%'
AND continent IS NOT NULL
ORDER BY PopulationInfected DESC

-- Precentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationInfectedPrecnt
FROM datascienceproject..covidDeaths
WHERE covidDeaths.location LIKE '%Lanka%'
AND continent IS NOT NULL
ORDER BY PopulationInfectedPrecnt DESC

-- Showing the countries with highest infection rate compared to population
 

-- Showing the countries highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- lets break things down by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing the continent with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT date,
       SUM(COALESCE(new_cases,0)) AS new_cases,
       SUM(COALESCE(new_deaths, 0)) AS new_deaths,
	   CASE
		   WHEN SUM(COALESCE(new_cases,0)) = 0 THEN NULL 
		   WHEN SUM(COALESCE(new_deaths, 0)) = 0 THEN NULL
           ELSE SUM(COALESCE(new_deaths,0)) / SUM(COALESCE(new_cases,0)) *100
		   END AS NewDeathPercentage
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Total cases
SELECT 
       SUM(COALESCE(new_cases,0)) AS total_cases,
       SUM(COALESCE(new_deaths, 0)) AS total_deaths,
	   CASE
		   WHEN SUM(COALESCE(new_cases,0)) = 0 THEN NULL 
		   WHEN SUM(COALESCE(new_deaths, 0)) = 0 THEN NULL
           ELSE SUM(COALESCE(new_deaths,0)) / SUM(COALESCE(new_cases,0)) *100
		   END AS TtotalDeathPercentage
FROM datascienceproject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at total population VS vaccinations
SELECT 
	  dea.continent, 
	  dea.location, 
	  dea.date, 
	  dea.population, 
	  vac.new_vaccinations,
	  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	  AS rollingPeopleVaccinationated
FROM datascienceproject..covidDeaths dea
JOIN datascienceproject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USE CTE
WITH PopvsVac (Continent, Loaction, Date, population, New_vaccinations, rollingPeopleVaccinationated)
AS (
SELECT 
	  dea.continent, 
	  dea.location, 
	  dea.date, 
	  dea.population, 
	  vac.new_vaccinations,
	  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	  AS rollingPeopleVaccinationated
	  ---(rollingPeopleVaccinationated / population)*100
FROM datascienceproject..covidDeaths dea
JOIN datascienceproject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT * , (rollingPeopleVaccinationated / population)*100 AS PopvsVac
FROM PopvsVac


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated -- FOR DELETE OR CHANGE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinationated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	  dea.continent, 
	  dea.location, 
	  dea.date, 
	  dea.population, 
	  vac.new_vaccinations,
	  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	  AS rollingPeopleVaccinationated
FROM datascienceproject..covidDeaths dea
JOIN datascienceproject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * , (rollingPeopleVaccinationated / population)*100 AS PopvsVac
FROM #PercentPopulationVaccinated


-- CREATING VIEW STORE DATA FOR LATER VISUALIZATION
DROP VIEW IF EXISTS percentPopulationVaccinated
USE datascienceproject;
CREATE VIEW percentPopulationVaccinated AS
SELECT 
	  dea.continent, 
	  dea.location, 
	  dea.date, 
	  dea.population, 
	  vac.new_vaccinations,
	  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	  AS rollingPeopleVaccinationated
FROM datascienceproject..covidDeaths dea
JOIN datascienceproject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM percentPopulationVaccinated

