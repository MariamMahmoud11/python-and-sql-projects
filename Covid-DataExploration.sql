select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date,total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- likehood of dying from having covid 

select location,date , total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..CovidDeaths
--where location like '%Egypt%'
where continent is not null
order by 1,2

-- percentage of covid infection from population
select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Egypt'
where continent is not null
order by 1,2

-- highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like 'Egypt'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- Highest deaths by continent
select location,max(cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc

--countries with highest death count per population
select location,max(cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like 'Egypt'
group by location
order by HighestDeathCount desc

-- global numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int))as totaldeaths, sum(cast(new_deaths as int))/ sum(new_cases) *100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- looking at total population versus vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- use CTE

With PopvsVac (Continent, Location, Population, Date, New_vaccinations, Rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
where dea.continent is not null
)
Select * , (Rollingpeoplevaccinated/cast(Population as int))*100 as percentpeoplevaccinated
from PopvsVac

-- temp table
drop table if exists #populationvaccinations
create table #populationvaccinations
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
insert into #populationvaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
where dea.continent is not null
Select * , (Rollingpeoplevaccinated/cast(Population as int))*100 as percentpeoplevaccinated
from #populationvaccinations


-- create view for later visualization

create view populationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
where dea.continent is not null


create view percentpeoplevaccinated as
With PopvsVac (Continent, Location, Population, Date, New_vaccinations, Rollingpeoplevaccinated)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over 
(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location= vac.location
     and dea.date=vac.date
where dea.continent is not null
)
Select * , (Rollingpeoplevaccinated/cast(Population as int))*100 as percentpeoplevaccinated
from PopvsVac


create view highestdeathsbycontinent as
select location,max(cast (total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
--order by HighestDeathCount desc


