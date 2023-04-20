-- Selecting And Exploring Relevant Data 

select Location, continent, date, total_cases, new_cases, total_deaths, population
from portfolio..CovidDeaths 
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths

-- Listing all the records with covid death percentage greater than 30%.

SELECT *
FROM (
    SELECT Location, date, total_cases, total_deaths, 
        ROUND((total_deaths / total_cases) * 100, 2) AS DeathPercentage
    FROM portfolio..CovidDeaths
) AS subquery
WHERE DeathPercentage > 30
ORDER BY DeathPercentage DESC;

-- Total Cases vs Population  

-- Listing all the records with chances of getting the virus(ContractionPercentage) greater than 10%

select * from 
		(select Location, continent date, total_cases, population, 
		round((total_cases/population)*100, 2) as ContractionPercentage 
		from portfolio..CovidDeaths where continent is not null) as subquery
where ContractionPercentage > 10
order by 5 desc

-- Listing Top 20 Countries with Highest Infection Rate compared to Population

Select top(20) Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From portfolio..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Listing Top 20 Countries with Highest Death Rate compared to Population

Select TOP(20) Location, Population, MAX(cast(total_deaths as int)) as HighestDeathCount
From portfolio..CovidDeaths
where continent is not null
Group by Location, Population 
order by HighestDeathCount desc

-- Grouping based on Continent

SELECT location, max(cast(total_deaths as int)) as HighestDeathCount
From portfolio..CovidDeaths
where continent is null
group by location
order by HighestDeathCount desc;

-- Global Numbers

SELECT date as 'Date',sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases) * 100) as DeathPercentage
from portfolio..CovidDeaths
where continent is not null 
Group by date
ORDER BY 1;	

SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases) * 100) as DeathPercentage
from portfolio..CovidDeaths
where continent is not null 
ORDER BY 1;	


-- Looking at Total Population vs Vaccination

-- Using CTE

with PopVsVac (Continent, Location, Date, Population,  new_vacicinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations  
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from portfolio..CovidDeaths dea
join portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopVsVac


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
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
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
From portfolio..CovidDeaths dea
Join portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3 