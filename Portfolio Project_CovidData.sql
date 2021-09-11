Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Shows what percentage of population got Covid
Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries where Highest Infection Rate compared to population
Select Location, Population, MAX (total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected desc

-- Showing countries with highest death count per population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Lets break things down by continent - reverse

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Lets break things down by continent
-- showing continent with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select date, Sum (new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage --,
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by date
order by 1,2

-- Global Numbers total

Select Sum (new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage --,
From PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

-- Join 2 tables on location and date

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Looking at total population vs total vaccination - check

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at total population vs total vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
  
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
Drop View PercentPopulationVaccinated

Select *
From PercentPopulationVaccinated
