
----- BY COUNTRY -----

SELECT *
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

/* 
SELECT *
FROM [Portfolio Project - Alex]..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4 
*/

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- DeathPercentage shows liklihood og dying if you are infected in your country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE Location = 'India' AND continent IS NOT NULL
ORDER BY 1,2 

-- Total Cases vs Population
-- CovidPercentage shows what percentage of population got covid
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS CovidPercentage
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE Location = 'India' AND continent IS NOT NULL
ORDER BY 1,2 

-- Shows countries with highest infection rate to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS CovidPercentage
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY CovidPercentage DESC

-- Shows countries with highest death count per population
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

----- BY CONTINENT -----

-- Shows continents with highest death count per population
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

----- GLOBAL -----

-- Shows DeathPercentage in the world by date
SELECT Date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2 

-- Shows overall DeathPercentage in the world
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project - Alex]..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 


-- Shows Join between Vaccinations and Deaths
-- Looking at Total Population vs Vaccination. Hereyou will get an error because RollingPeopleVaccinated is just created and used in the same query. Hence next query is the solution. Use CTE ot Temp table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/Population)*100
FROM [Portfolio Project - Alex]..CovidDeaths dea
JOIN [Portfolio Project - Alex]..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM [Portfolio Project - Alex]..CovidDeaths dea
JOIN [Portfolio Project - Alex]..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM [Portfolio Project - Alex]..CovidDeaths dea
JOIN [Portfolio Project - Alex]..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for visualizing later

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM [Portfolio Project - Alex]..CovidDeaths dea
JOIN [Portfolio Project - Alex]..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
