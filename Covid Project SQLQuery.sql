Select * 
From SQL_Portfolio_Project..CovidDeath2022
order by 3,4

Select *
From SQL_Portfolio_Project..CovidVaccinations2022
order by 3,4

-- Selecting data that we are going to be using. 

Select location, date, total_cases, new_cases, total_deaths, population
From SQL_Portfolio_Project..CovidDeath2022
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- (Shows the likelihood of dying if you contract COVID in your country)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercDeath
From SQL_Portfolio_Project..CovidDeath2022
where location like '%Bangladesh%'
order by 1,2

-- Looking at Total Cases vs Population
--(Shows what percentage of population got COVID)

Select location, date, Population, total_cases, (total_cases/population)*100 as CasePerc, (total_deaths/total_cases)*100 as PercDeath
From SQL_Portfolio_Project..CovidDeath2022
-- where location like '%states%'
order by 1,2

-- Looking at countris with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercCase
From SQL_Portfolio_Project..CovidDeath2022
-- where location like '%states%'
Group by Location, Population
order by PercCase desc

-- Looking at countris with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int))  as TotalDeathCount
From SQL_Portfolio_Project..CovidDeath2022
-- where location like '%states%'
Group by location
order by TotalDeathCount desc

-- Looking at CONTINENTS, Income Class with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int))  as TotalDeathCount
From SQL_Portfolio_Project..CovidDeath2022
-- where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS using Aggregate Functions

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as PercDeath
From SQL_Portfolio_Project..CovidDeath2022
-- where location like '%states%'
where continent is not null
order by 1,2

-- Joining Covid Deaths and Covid Vaccination Data set 

Select * 
From SQL_Portfolio_Project..CovidDeath2022 dea
Join SQL_Portfolio_Project..CovidVaccinations2022 vac
	On dea.location = vac.location 
	and dea.date = vac.date

-- Using Sub-Queries to look at Rolling New Vaccinations Count

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingVacCount
From SQL_Portfolio_Project..CovidDeath2022 dea
Join SQL_Portfolio_Project..CovidVaccinations2022 vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Vaccination by country using CTE and TempTable

-- CTE 

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVacCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast(vac.new_vaccinations as bigint)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingVacCount
From SQL_Portfolio_Project..CovidDeath2022 dea
Join SQL_Portfolio_Project..CovidVaccinations2022 vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (RollingVacCount/Population)*100 as PercVaccinated 
From PopvsVac

-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccintations numeric,
RollingVacCount numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingVacCount
From SQL_Portfolio_Project..CovidDeath2022 dea
Join SQL_Portfolio_Project..CovidVaccinations2022 vac
	On dea.location = vac.location 
	and dea.date = vac.date


Select *, (RollingVacCount/Population)*100 as PercVaccinated 
From #PercentPopulationVaccinated



-- Creating ad-hoc view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint, vac.new_vaccinations)) Over (Partition by dea.Location Order by dea.location, dea.date) as RollingVacCount
From SQL_Portfolio_Project..CovidDeath2022 dea
Join SQL_Portfolio_Project..CovidVaccinations2022 vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

Select * 
From PercentPopulationVaccinated