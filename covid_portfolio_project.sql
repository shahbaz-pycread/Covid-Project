-- Covid Death Table
SELECT  *
    FROM PortfolioProject..['covid-deaths$']
    WHERE continent is not NULL
    ORDER BY 3,4;


-- Covid Vaccination
SELECT TOP 2 * 
    FROM PortfolioProject..['covid-vaccinations$']
    ORDER BY 3,4;

SELECT [location], [date], population, [total_cases],[new_cases], total_deaths
    FROM PortfolioProject..['covid-deaths$']
     WHERE continent is not NULL
    order by 1,2;

-- Data For India
-- Total Cases Vs Total Deaths

SELECT [location], [date], [total_cases], total_deaths, (total_deaths/total_cases)*100 DeathPercentage
    FROM PortfolioProject..['covid-deaths$']
    WHERE [location] LIKE '%ndia' 
    order by 1,2;

-- Total Cases Vs Population
-- Shows what percentage of population got covid
SELECT [location], [date],population, [total_cases], (total_cases/population)*100 PercentPopulationInfected
    FROM PortfolioProject..['covid-deaths$']
    WHERE [location] LIKE '%ndia'
    order by 1,2;

-- Looking at countries having highest infection rate
SELECT [location], population,MAX(total_cases) HighestInfectionCount, MAX((total_cases/population))*100 PercentPopulationInfected
    FROM PortfolioProject..['covid-deaths$']
    WHERE continent is not NULL
    GROUP BY [location], population
    ORDER BY PercentPopulationInfected DESC;

-- Looking at countries having highest Death Count
SELECT [location], MAX(CAST(total_deaths as int)) DeathCount
    FROM PortfolioProject..['covid-deaths$']
    WHERE continent is not NULL
    GROUP BY [location]
    ORDER BY DeathCount DESC;


-- Continents with the highest death count
SELECT continent, MAX(CAST(total_deaths as int)) DeathCount
    FROM PortfolioProject..['covid-deaths$']
    WHERE continent is NOT NULL
    GROUP BY [continent]
    ORDER BY DeathCount DESC;


-- Global Numbers
 SELECT  [date], SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths as int)) TotalNewDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 DeathPercentage
    FROM PortfolioProject..['covid-deaths$']
    WHERE continent is not null 
    group by [date]
    order by 1,2;

-- Joining tables
-- Total Populations Vs Vaccinations
SELECT dea.continent,  dea.[location], dea.[date], dea.population, vac.new_vaccinations
    FROM PortfolioProject..['covid-deaths$'] dea
    JOIN PortfolioProject..['covid-vaccinations$'] vac
    ON dea.[location] = vac.[location] AND dea.[date] = vac.[date]
    WHERE dea.continent is not NULL
    ORDER BY 2,3;

SELECT dea.continent,  dea.[location], dea.[date], dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
    FROM PortfolioProject..['covid-deaths$'] dea
    JOIN PortfolioProject..['covid-vaccinations$'] vac
    ON dea.[location] = vac.[location] AND dea.[date] = vac.[date]
    WHERE dea.continent is not NULL
    ORDER BY 2,3;

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations , RollingPeopleVaccinated)
AS
(
    SELECT dea.continent,  dea.[location], dea.[date], dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
        FROM PortfolioProject..['covid-deaths$'] dea
        JOIN PortfolioProject..['covid-vaccinations$'] vac
        ON dea.[location] = vac.[location] AND dea.[date] = vac.[date]
        WHERE dea.continent is not NULL
        -- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / Population)*100
 FROM PopvsVac;

-- TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,  dea.[location], dea.[date], dea.population, vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
        FROM PortfolioProject..['covid-deaths$'] dea
        JOIN PortfolioProject..['covid-vaccinations$'] vac
        ON dea.[location] = vac.[location] AND dea.[date] = vac.[date]
       -- WHERE dea.continent is not NULL
        -- ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated / Population)*100
    FROM #PercentPopulationVaccinated

--  Creating Views to store data for visualization
-- Views

CREATE view PercentPopulationVaccinated as 
SELECT dea.continent,  dea.[location], dea.[date], dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) RollingPeopleVaccinated
    FROM PortfolioProject..['covid-deaths$'] dea
    JOIN PortfolioProject..['covid-vaccinations$'] vac
    ON dea.[location] = vac.[location] AND dea.[date] = vac.[date]
    WHERE dea.continent is not NULL
        -- ORDER BY 2,3

SELECT *
    FROM PercentPopulationVaccinated;


