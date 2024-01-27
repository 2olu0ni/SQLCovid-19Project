Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Lookin at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Nigeria
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Nigeria%'
order by 1, 2

--Lookin at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
Where Location like '%Nigeria%'
order by 1, 2


--Countries with the highest infection rate
Select Location, Population, MAX(total_cases) as highestInfectionCount,  MAX((total_cases/population))*100 as PopulationPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%Nigeria%'
Group by Location, Population
Order by PopulationPercentage desc


--Showing Countries with Highest Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%World%'
where continent is not null
Group by Location
Order by TotalDeathCount desc

--BY CONTINENT
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%World%'
where continent is null
Group by Location
Order by TotalDeathCount desc

--Continent with the highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%World%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Where Location like '%Nigeria%'
--group by date
order by 1, 2



--Total Population vs Total Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
Where dea.continent is not null
order by 2, 3

--USING CTE
With PopvsVac (Continent, location, date, population, new_vaccinations,
RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100 as VacPopPercentage
from PopvsVac



--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 as VacPopPercentage
from #PercentPopulationVaccinated


--Creating View for Visualization


Create View PercentPopulatnVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int))
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2, 3

Select * 
from PercentPopulatnVaccinated

--View for Global Numbers

Create View DeathPercentage as
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Where Location like '%Nigeria%'
--group by date
--order by 1, 2

Select *
from DeathPercentage