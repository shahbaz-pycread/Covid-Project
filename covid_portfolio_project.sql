SELECT * 
FROM dbo.CovidDeath
WHERE continent is not null
order by 3,4;

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--order by 3,4;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeath
order by 1,2;

--Total Cases vs Total Deaths in India
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location = 'India'
order by 1,2;

-- Total Cases vs Population
SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeath
--WHERE location = 'India'
order by 1,2;

-- Countries with the Highest Infection Rate compared to Population
SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
FROM PortfolioProject..CovidDeath
--WHERE location = 'India'
GROUP BY location,population
order by 4 DESC;

--Countries with the Highest Death Count per Population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeath
--WHERE location = 'India'
WHERE continent is not null
group by continent
order by TotalDeathCounts DESC;

-- Global Numbers
SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
--WHERE location = 'India'
WHERE continent is not null
GROUP BY date
order by 1,2;

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeath
--WHERE location = 'India'
WHERE continent is not null
order by 1,2;


SELECT * 
FROM PortfolioProject..CovidVaccinations;

-- Joining CovidDeath and CovidVaccinations tables

SELECT * 
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date;

-- Total Population vs Vaccination 
-- Total People around the world that have been vaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;

-- USE CTE
WITH PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;

-- TEMP TABLE
DROP TABLE If exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Creating view to store data for visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath as dea
JOIN PortfolioProject..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null;
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated;