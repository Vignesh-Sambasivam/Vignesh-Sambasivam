--Selecing the database that we would be working on

use [Portfolio Project];
select * from [Covid-Deaths]

-- Selecting the data that we would be working on
-- There are two seperate fields for continent and location in the data and in many rows continent is null which affects our analysis while grouping
select location,date,total_cases,new_cases,total_deaths,population from [Covid-Deaths] where continent is not null order by 1;


-- Total Cases vs Total Deaths In US and Australia
--  Likelihood of death if someone gets affected by COVID country-wise
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as 'Death Percentage' from [Covid-Deaths] 
where location in('Australia','United States') and continent is not null order by 1;

-- Total Cases vs Total Population in US and Australia
--  Percentage of population that got affected by COVID Datewise
select location,date,total_cases,population,round((total_cases/population)*100,2) as 'Affected Percentage' from [Covid-Deaths] 
where location in ('Australia','United States') and continent is not null order by 1;

--Total Cases Vs Total Population and Percentage of Population affected Monthwise
select location,year(date)as 'Year',datename(month,date) as [month],sum(total_cases) as total,population,round((sum(total_cases) /population)*100,2) as 
' Affected %' 
from [Covid-Deaths] 
where location in ('Australia','United States') group by location, year(date),month(date),datename(month,date),population order by year(date),month(date);

--Looking at Countries with Highest Infection Rate
select location,population,MAX(total_cases) as Highest_Infection_Count,MAX(ROUND((total_cases/population)*100,2)) as '% of population infected'
from [Covid-Deaths] where continent is not null
group by location,population order by '% of population infected' desc;

--Highest Death Count in each country (Without considering Null values)
select location,MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Covid-Deaths] where continent is not null group by location having max(total_deaths) is not null order by Highest_Death_Count desc;


-- Continent-Wise analysis
-- Case 1: Where Continent is null

select location,MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Covid-Deaths] where continent is null group by location having max(total_deaths) is not null order by Highest_Death_Count desc

-- Case 2: Where Continent is not null

select location,MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Covid-Deaths] where continent is not null group by location having max(total_deaths) is not null order by Highest_Death_Count desc;

--- To Select the TOP N Continents with least death count
-- This is done using CTE and a Rank function
with Result as
(
select location,rank() over (order by max(cast(total_deaths as int)) asc)as Ranking,MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Covid-Deaths]  where continent is null group by location having max(total_deaths) is not null
)
select * from Result where Ranking=3;

with Results as
(
select location,rank() over (order by max(cast(total_deaths as int)) desc)as Ranking,MAX(cast(total_deaths as int)) as Highest_Death_Count
from [Covid-Deaths]  where continent is not null group by location having max(total_deaths) is not null
)
select * from Results where Ranking=2;

 --On a Global Level Number of new cases and new deaths recorded monthly

select year(date)as'Year',datename(month,date) as [Month],sum(new_cases)as Total_NewCases,
sum(cast(new_deaths as int))as Total_NewDeath,
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as 'Death%'
from [Covid-Deaths] group by year(date),month(date),datename(month,date) order by year(date),month(date);

-- Finding the Rolling Total of Number of New cases Recorded Daily
select location,date,year(date) as [year],datename(month,date)as[month],new_cases, 
sum(new_cases) over (partition by location order by location,date) as Rolling_Total_newcases
from [Covid-Deaths] order by year,month(date);

