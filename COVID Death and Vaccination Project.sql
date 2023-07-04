-- imported with all columns in close to correct data types (every numerical as float)

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying from contracting COVID in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows percentage of population in each country that have contracted COVID over time
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Countries Ranked by Infection Rate
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Countries Ranked by Death Count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Instead of countries, let's compare by continents


-- Continents Ranked by Death Count 
/* SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount desc */

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

-- Global Death Percentage each day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1

-- Global Death Percentage all time
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1


-- 
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vax
    ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent is not NULL
ORDER by 2,3

-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingCountVaccination) 
as (
    SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vax
    ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent is not NULL
)
SELECT *, (RollingCountVaccination/population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinatinos NUMERIC,
    RollingCountVaccination NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vax
    ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent is not NULL
ORDER by 2,3

SELECT *, (RollingCountVaccination/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) as RollingCountVaccination
FROM PortfolioProject..CovidDeaths death
JOIN PortfolioProject..CovidVaccinations vax
    ON death.location = vax.location
    AND death.date = vax.date
WHERE death.continent is not NULL
--ORDER by 2,3

SELECT * 
FROM PercentPopulationVaccinated