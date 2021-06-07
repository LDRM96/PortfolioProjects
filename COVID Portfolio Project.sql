Select *
from [Porftofilio project]..[Covid Deaths]
Where continent is not null
order by 3,4

--Select *
--from [Porftofilio project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Porftofilio project]..[Covid Deaths]
Where continent is not null
order by 1,2

-- Loking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Mexico

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Porftofilio project]..[Covid Deaths]
Where location like '%Mexico%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Porftofilio project]..[Covid Deaths]
Where location like '%Mexico%'
order by 1,2

--Looking at countries with highest infection rate compare to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Porftofilio project]..[Covid Deaths]
--Where location like '%Mexico%'
Group by Location,population
order by PercentPopulationInfected desc

--Showing Countries with the Highest Death Count per Population

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From [Porftofilio project]..[Covid Deaths]
--Where location like '%Mexico%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT



--Showing the continents with the highest death count per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From [Porftofilio project]..[Covid Deaths]
--Where location like '%Mexico%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [Porftofilio project]..[Covid Deaths]
--Where location like '%Mexico%'
Where continent is not null
--Group by Date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From [Porftofilio project]..[Covid Deaths] dea
Join [Porftofilio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
order by 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porftofilio project]..[Covid Deaths] dea
Join [Porftofilio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2, 3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255) ,
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porftofilio project]..[Covid Deaths] dea
Join [Porftofilio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2, 3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast (vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Porftofilio project]..[Covid Deaths] dea
Join [Porftofilio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
Where dea.continent is not null
--order by 2, 3

Select *
From PercentPopulationVaccinated