select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select Data that we are going to be using

select location, date, [total_cases], new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
-- how many cases in a country
-- how many deaths for all the cases
-- percentage of death for those cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DEATHPERCENTAGE
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--alter table [PortfolioProject].[dbo].[CovidDeaths]
--alter column total_cases float

--looking at total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 AS casePERCENTAGE
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfection, max((total_cases/population)*100) AS casePERCENTAGE
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by casePERCENTAGE desc

--show countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidDeaths
where location = 'world'

--let's break things down by continent




--showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, continent, max(cast(total_cases as int)) totaldeathcount, max(population) as maxpopulation
from PortfolioProject..CovidDeaths
where continent like 'North America'
group by continent, location
order by totaldeathcount desc


--GLOBAL NUMBERS


select date, sum(new_deaths) as allnewcases, sum(new_deaths) as newdeaths --sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select date, sum(new_cases) as allnewcases, sum(new_deaths) as newdeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where  continent is not null
group by date
order by 1,2

select sum(new_cases) as allnewcases, sum(new_deaths) as newdeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where  continent is not null
--group by date
order by 1,2


---Looking at tge Total Population vs Vaccination

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--OR USE TEMP TABLE

drop table if exists #PERCENTPOPULATIONVACCINATED
CREATE TABLE #PERCENTPOPULATIONVACCINATED
(Continent varchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

insert into #PERCENTPOPULATIONVACCINATED
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PERCENTPOPULATIONVACCINATED

-------------------------------------------------
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null


select *
from [dbo].[PercentPopulationVaccinated]