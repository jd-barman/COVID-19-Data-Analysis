select * from [Covid project portfolio]..['covid death data']
where continent is not NULL
order by 3,4

--select * from [Covid project portfolio]..['covid vacination']


-- Selecting data required for the project
 

-- Looking at total cases vs total deaths
--Likelihood of dying if one contract covid in perticular country

select location,date,total_deaths,total_cases,round((total_deaths/total_cases)*100 , 2) as death_percentage
from ['covid death data']
where location like '%states%'
--where location = 'india'
order by 1,2

 


--Looking at the total_cases vs population
--Showing how much population got covid

select location,date,population,total_cases,(total_cases/population)*100 as case_percentage
from ['covid death data']
where location like '%states%'
--where location = 'india'
order by 2

-- Countries with highest infection rate

select location,population,max(total_cases) as highest_infection,round((max((total_cases/population))*100),2) as highest_infection_percentage
from ['covid death data']
where continent is not NULL
group by location, population
order by 4 desc

--Highest death in countries

select location,max(cast(total_deaths as int)) as highest_death
from ['covid death data']
where continent is not NULL
--where location = 'india'
group by location
order by highest_death desc


--Highest death in continents

select continent,max(cast(total_deaths as int)) as continent_highest_death
from ['covid death data']
where continent is not NULL
--where location = 'india'
group by continent
order by continent_highest_death desc


--Countries having highest death rate

--select location,population,max(cast(total_deaths as int)) as highest_death, (max(total_deaths)/population)*100 as highest_death_rate
--from ['covid death data']
--where continent is not NULL
----where location = 'india'
--group by location ,population
--order by highest_death_rate desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round((sum(cast(new_deaths as int))/sum(new_cases))*100 , 2) as death_percentage
from ['covid death data']
--where location like '%states%'
--where location = 'india'
where continent is not null
--group by date
order by 1

--Exploring covid vacination table

alter table ['covid death data'] drop column F27,F28,	F29,	F30,	F31,	F32,	F33,	F34,	F35,	F36,	F37,	F38,	F39,	F40,	F41,	F42,	F43,	F44,	F45,	F46,	F47,	F48,	F49,	F50,	F51,	F52,	F53,	F54,	F55,	F56,	F57,	F58,	F59,	F60,	F61,	F62,	F63,	F64,	F65,	F66,	F67

--Join Two Tables

select * from [Covid project portfolio]..['covid death data'] dea
join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date

--Looking at Total Population VS vaccination

--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--from [Covid project portfolio]..['covid death data'] dea
--join ['covid vacination'] vac
--on  dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3 


--Creating a Rolling count column for vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,(vac.new_vaccinations))) over (partition by dea.location order by dea.location,
dea.date rows unbounded preceding) as rolling_count
from [Covid project portfolio]..['covid death data'] dea join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Looking for total population VS vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,(vac.new_vaccinations))) over (partition by dea.location order by dea.location,
dea.date rows unbounded preceding) as rolling_count
--, (rolling_count / population)*100
from [Covid project portfolio]..['covid death data'] dea join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with Population_and_Vaccination  (continent,location,date,population,new_vaccinations,rolling_count) as

(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,(vac.new_vaccinations))) over (partition by dea.location order by dea.location,
dea.date rows unbounded preceding) as rolling_count
from [Covid project portfolio]..['covid death data'] dea join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select * ,round((rolling_count / population )* 100 ,2) as vaccinated_percentage
from Population_and_Vaccination 


-- Method 2
--TEMP TABLE

drop table if exists populationVSvaccination
create table populationVSvaccination
(
contient nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count numeric,
)

insert into populationVSvaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,(vac.new_vaccinations))) over (partition by dea.location order by dea.location,
dea.date rows unbounded preceding) as rolling_count
from [Covid project portfolio]..['covid death data'] dea join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select * ,round((rolling_count / population )* 100 ,2) as vaccinated_percentage
from populationVSvaccination


--Creating View to Store Data For Later Visulaization 

create view Vaccinated_Population as 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,(vac.new_vaccinations))) over (partition by dea.location order by dea.location,
dea.date rows unbounded preceding) as rolling_count
from [Covid project portfolio]..['covid death data'] dea join ['covid vacination'] vac
on  dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from Vaccinated_Population
