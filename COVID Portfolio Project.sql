SELECT * 
FROM PortfolioProject..CovidDeaths 
WHERE continent is not null
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Examining Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2


-- Examining Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population, (total_deaths/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2


-- Examining countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location = 'Canada'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Examining countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By location
ORDER BY TotalDeathCount desc


-- Breaking things down by continent

-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By continent
ORDER BY TotalDeathCount desc


-- Global Numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By date
ORDER BY 1,2


-- Examing total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE
IF OBJECT_ID('PercentPopulationVaccinated') IS NOT NULL
DROP TABLE PercentPopulationVaccinated

CREATE TABLE PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated


-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinatedView