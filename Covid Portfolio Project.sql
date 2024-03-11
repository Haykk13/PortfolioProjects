select *
from CovidDeaths
where continent is null
order by 3, 4

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths FLOAT;

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 3 desc

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where location = 'Armenia'
and continent is not null
order by 1, 2

--Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Highest Infection Rate Countries

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected 
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--Countries with Higherst Death Count per Population

Select location, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Continents with Higherst Death Count per Population

Select continent, Max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Global Infections Per Day

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage 
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- Total Population vs Vaccination

alter table CovidVaccinations
alter column total_vaccinations float;

alter table CovidVaccinations
alter column new_vaccinations float;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2, 3

-- CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentVac
from PopvsVac

-- Temp Table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--View to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

	select *
	from PercentPopulationVaccinated