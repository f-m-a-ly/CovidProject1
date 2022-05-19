--SELECT *
--FROM CovidProject1..CovidDeaths
-- WHERE continent IS NOT null
--ORDER BY 3, 4

--SELECT *
--FROM CovidProject1..CovidVaccinations
-- WHERE continent IS NOT null
--ORDER BY 3, 4

--SELECT location, date, total_cases, new_cases, total_deaths, population
-- WHERE continent IS NOT null
--FROM CovidProject1..CovidDeaths
--ORDER BY location, date

-- Total Cases vs Total Deaths in Egypt- % of COVID cases that died
SELECT 
	location, date, 
	total_cases,total_deaths, 
	(total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidProject1..CovidDeaths
WHERE location ='Egypt'
AND continent IS NOT null
ORDER BY location, date

-- Total Cases vs Population in Egypt- % of population that got covid 
SELECT 
	location, date, 
	population, total_cases,
	(total_cases/population) * 100 AS InfectedPopulationPercentage
FROM CovidProject1..CovidDeaths
WHERE location ='Egypt'
AND continent IS NOT null
ORDER BY location, date


-- Country with Highest Infection Rate
SELECT 
	location, population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population) * 100) AS MaxInfectedPopulationPercentage
FROM CovidProject1..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY MaxInfectedPopulationPercentage DESC


-- Country with Highest Death Rate
SELECT 
	location, 
	MAX(cast(total_deaths as int)) AS HighestDeathCount
	--MAX((total_deaths/population) * 100) AS MaxDeathPercentage
FROM CovidProject1..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY HighestDeathCount DESC

-- ====== BY CONTINENT ===== --

-- Continent with Highest Death Rate
SELECT 
	continent,
	MAX(cast(total_deaths as int)) AS HighestDeathCount
	--MAX((total_deaths/population) * 100) AS MaxDeathPercentage
FROM CovidProject1..CovidDeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Global Numbers
SELECT 
	SUM(new_cases) AS GlobalNewCases,
	SUM(cast(new_deaths as int)) AS GlobalNewDeaths,
	SUM(convert(int, new_deaths))/ SUM(new_cases) AS GlobalDeathPercentage
	--total_cases,total_deaths, 
	--(total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidProject1..CovidDeaths
WHERE continent IS NOT null
-- GROUP BY date
ORDER BY 1, 2

-- ===== VACCINATIONS ====== --

SELECT * 
FROM CovidProject1..CovidDeaths d
JOIN CovidProject1..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date

-- Total Population vs New Vacciation per day
SELECT d.continent, d.location, d.date, population, v.new_vaccinations
FROM CovidProject1..CovidDeaths d
JOIN CovidProject1..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null
ORDER BY  2, 3

-- Total Population vs New Vacciation per day
SELECT d.continent, d.location, d.date, population, v.new_vaccinations,
	SUM(CONVERT(int ,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date)
FROM CovidProject1..CovidDeaths d
JOIN CovidProject1..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT null
ORDER BY  2, 3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject1..CovidDeaths dea
Join CovidProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject1..CovidDeaths dea
Join CovidProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject1..CovidDeaths dea
Join CovidProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

