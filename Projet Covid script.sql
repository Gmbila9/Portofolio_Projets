CREATE TABLE CovidDeaths (
    iso_code VARCHAR(255),
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	population NUMERIC,
	total_cases NUMERIC,
	new_cases NUMERIC,
	new_cases_smoothed NUMERIC,
	total_deaths NUMERIC,
	new_deaths NUMERIC,
	new_deaths_smoothed NUMERIC,
	total_cases_per_million NUMERIC,
	new_cases_per_million NUMERIC,
	new_cases_smoothed_per_million NUMERIC,
	total_deaths_per_million NUMERIC,
	new_deaths_per_million NUMERIC,
	new_deaths_smoothed_per_million NUMERIC,
	reproduction_rate NUMERIC,
	icu_patients NUMERIC,
	icu_patients_per_million NUMERIC,
	hosp_patients NUMERIC,
	hosp_patients_per_million NUMERIC,
	weekly_icu_admissions VARCHAR(255),
	weekly_icu_admissions_per_million VARCHAR(255),
	weekly_hosp_admissions NUMERIC,
	weekly_hosp_admissions_per_million NUMERIC
);

CREATE TABLE CovidVaccinations(
	iso_code VARCHAR(255),
	continent VARCHAR(255),
	location VARCHAR(255),
	date DATE,
	new_tests NUMERIC,
	total_tests NUMERIC,
	total_tests_per_thousand NUMERIC,
	new_tests_per_thousand NUMERIC,
	new_tests_smoothed NUMERIC,
	new_tests_smoothed_per_thousand NUMERIC,
	positive_rate NUMERIC,
	tests_per_case NUMERIC,
	tests_units VARCHAR(255),
	total_vaccinations NUMERIC,
	people_vaccinated NUMERIC,
	people_fully_vaccinated NUMERIC,
	new_vaccinations NUMERIC,
	new_vaccinations_smoothed NUMERIC,
	total_vaccinations_per_hundred NUMERIC,
	people_vaccinated_per_hundred NUMERIC,
	people_fully_vaccinated_per_hundred NUMERIC,
	new_vaccinations_smoothed_per_million NUMERIC,
	stringency_index NUMERIC,
	Unnamed VARCHAR(255),
	population_density NUMERIC,
	median_age NUMERIC,
	aged_65_older NUMERIC,
	aged_70_older NUMERIC,
	gdp_per_capita NUMERIC,
	extreme_poverty NUMERIC,
	cardiovasc_death_rate NUMERIC,
	diabetes_prevalence NUMERIC,
	female_smokers NUMERIC,
	male_smokers NUMERIC,
	handwashing_facilities NUMERIC,
	hospital_beds_per_thousand NUMERIC,
	life_expectancy NUMERIC,
	human_development_index NUMERIC

)

\copy CovidVaccinations FROM '/Users/GermainMbila/Documents/Projets/Projet_Postgresql/CovidVaccination.csv' DELIMITER ',' CSV HEADER;

SELECT*
FROM CovidVaccinations


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2

-- rate death in Cameroon
Select Location, date, total_deaths,total_cases,(total_deaths/total_cases)*100 AS Death_percentage
From CovidDeaths 
Where Location = 'Cameroon'
order by 1,2

-- total cases vs population 

Select Location, date, total_cases,population, ((total_cases/population)*100)
From CovidDeaths 
Where Location = 'Cameroon'
order by 1,2

-- looking at countries with highest infection rate compared to population 

Select Location, MAX(total_cases) as MaxInfectionCount, population, MAX((total_cases/population)*100) as highestinfectionrate
From CovidDeaths 
WHERE continent is not null
GROUP BY Location, population
order by highestinfectionrate DESC 


population, MAX((total_deaths/population)*100) as highestDeathrate


-- show the country with the highest death count per population

Select location, MAX(total_deaths) as MaxDeathCount
From CovidDeaths
where continent is not null
GROUP BY location
order by MaxDeathCount DESC

-- by continent

Select continent, MAX(total_deaths) as MaxDeathCount
From CovidDeaths 
where continent is not null
GROUP BY continent
order by MaxDeathCount DESC

-- GLOBAL NUMBERS

select date,total_deaths, total_cases,(total_deaths/total_cases)*100 as deathpercentage
From CovidDeaths 
Where continent is not null 
order by deathpercentage desc


-- joindre les bases de données

SELECT location, new_vaccinations
FROM CovidVaccinations 

select *
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date

-- total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by vac.new_vaccinations desc

-- partition by pour fonction cumulative
select dea.continent, dea.location, dea.date, dea.population, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as vaccumuler
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte 
with popvsvac (continent, location, date, population, new_vaccinations, vaccumuler)
AS (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as vaccumuler --(vaccumuler/population)*100
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*
from popvsvac

-- CREATE A NEW TABLE 

Create table PercentPopulationVaccinated
(
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATE,
  population INTEGER,
  new_vaccinations INTEGER,
  vaccumuler INTEGER
)
DROP TABLE PercentPopulationVaccinated
insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as vaccumuler --(vaccumuler/population)*100
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CREATE VIEW TO STORE DATA VISUALISATION

CREATE VIEW PercentpopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location order by dea.location, dea.date) as vaccumuler --(vaccumuler/population)*100
From CovidDeaths dea 
join CovidVaccinations vac 
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null









