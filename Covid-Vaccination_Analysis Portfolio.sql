
use [Portfolio Project];


--Total Number of People vaccinated across the world

select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by d.location order by  d.location,d.date) as RollingTotal_Vaccinated
from [Covid-Deaths]d join [Covid-Vaccinations]v on d.location=v.location and d.date=v.date
where d.continent is not null order by 2,3

-- Using CTE
-- Finding % of Total Population Vaccinated in Each Country across the world

with PopvsVacc as
(
select d.continent,d.date,d.location,d.population,v.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by d.location order by  d.location,d.date) as RollingTotal_Vaccinated
from [Covid-Deaths]d join [Covid-Vaccinations]v on d.location=v.location and d.date=v.date
where d.continent is not null 
)
select location, max(RollingTotal_Vaccinated) as 'Total No of People Vaccinated' ,
round(max((RollingTotal_Vaccinated)/Population)*100,2) as '% of People Vaccinated'
from PopvsVacc group by location,Population order by location

