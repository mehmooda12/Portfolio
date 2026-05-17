SELECT * FROM CovidVaccinations;
SELECT * FROM CovidDeaths;



--looking at Total cases vs Totaldeaths
SELECT
   location, 
   SUM(cast(ISNULL(total_cases,0) as BIGINT)) as totalCases,
   SUM(cast(ISNULL(total_deaths,0) as BIGINT)) as totalDeaths
FROM CovidDeaths
GROUP BY CovidDeaths.location;



--looking at totalCases Vs population
SELECT 
   location,
   date, 
   cast(total_cases as bigint) as totalCases,
   population,
   (cast(total_cases as float) / cast(population as float)) * 100 as InfectedPercentage
FROM CovidDeaths
ORDER BY InfectedPercentage DESC;



--Showing countries with highest death count per population
SELECT 
    location, 
    MAX(total_deaths) as MaxDeaths 
FROM CovidDeaths 
    WHERE CovidDeaths.continent IS NOT NULL
    GROUP BY location
    ORDER BY MaxDeaths DESC;



--LET'S BREAK THINGS OUT BY CONTINENT(continent death count)
SELECT
    continent,
    MAX(total_deaths) as MaxDeaths 
FROM CovidDeaths 
    WHERE CovidDeaths.continent IS NOT NULL
    GROUP BY continent
    ORDER BY MaxDeaths DESC;



--GLOBAL NUMBERS
SELECT
   location,
   date,
   sum(new_cases) as New_Cases,
   sum(new_deaths) as New_deaths,
   sum(cast(new_deaths as float))/NULLIF(sum(cast(new_cases as float))*100,0) as deathPercentage
FROM CovidDeaths
GROUP BY date,location
ORDER BY deathPercentage DESC;



--Total population VS Total vaccinations
Select 
   CovidDeaths.location,
   SUM(population) as Population,
   SUM(cast(total_vaccinations as BigInt)) as Total_vaccinations
   FROM CovidDeaths JOIN CovidVaccinations 
       ON CovidDeaths.location=CovidVaccinations.location
   WHERE CovidDeaths.continent IS NOT NULL
   GROUP BY CovidDeaths.location
   ORDER BY Total_vaccinations DESC;



--Use CTE
With popVsVacc(location,population,Total_vaccinations)
AS
(
Select 
   CovidDeaths.location,
   SUM(population) as Population,
   SUM(cast(total_vaccinations as BigInt)) as Total_vaccinations
   FROM CovidDeaths JOIN CovidVaccinations 
       ON CovidDeaths.location=CovidVaccinations.location
   GROUP BY CovidDeaths.location
 )
 SELECT *FROM popVsVacc;



 --with temp table
 Create Table #percentPopulationVaccinated
 (
 Location nvarchar(255),
 population bigInt,
 total_vaccinations bigInt,
 )
 Insert into  #percentPopulationVaccinated
 Select 
   CovidDeaths.location,
   SUM(population) as Population,
   SUM(cast(total_vaccinations as BigInt)) as Total_vaccinations
   FROM CovidDeaths JOIN CovidVaccinations 
       ON CovidDeaths.location=CovidVaccinations.location
   GROUP BY CovidDeaths.location
 SELECT * FROM #percentPopulationVaccinated;



 --WITH VIEW
 Create view PercentPopulationVaccinated
 AS
 Select 
   CovidDeaths.location,
   SUM(population) as Population,
   SUM(cast(total_vaccinations as BigInt)) as Total_vaccinations,
   (cast(CovidVaccinations.total_vaccinations as float)/cast(CovidDeaths.population as float)*100) as VaccinatedPercentage
   FROM CovidDeaths JOIN CovidVaccinations 
       ON CovidDeaths.location=CovidVaccinations.location
   GROUP BY CovidDeaths.location,(cast(CovidVaccinations.total_vaccinations as float)/cast(CovidDeaths.population as float)*100) 
 SELECT * FROM PercentPopulationVaccinated;



 --Death percentage view
 Create View deathPercentage
 as 
 SELECT
   location,
   date,
   sum(new_cases) as New_Cases,
   sum(new_deaths) as New_deaths,
   sum(cast(new_deaths as float))/NULLIF(sum(cast(new_cases as float))*100,0) as deathPercentage
FROM CovidDeaths
GROUP BY date,location
SELECT * FROM deathPercentage;



--death rate in continents view
create view deathRateInContinents
as
SELECT
    continent,
    MAX(total_deaths) as MaxDeaths 
FROM CovidDeaths 
    WHERE CovidDeaths.continent IS NOT NULL
    GROUP BY continent
 SELECT *FROM deathRateInContinents




SELECT  continent,MAX(total_deaths) 
as MaxDeaths, SUM(new_cases) as NewCases
FROM CovidDeaths 
WHERE continent is not null 
GROUP BY continent
Order By MaxDeaths DESC;
SELECT CovDea.location,
SUM(cast(CovVacc.new_vaccinations as int)) 
as NewVaccinations FROM CovidDeaths CovDea JOIN CovidVaccinations CovVacc 
ON CovDea.date = CovVacc.date and CovDea.location = CovVacc.location
WHERE CovDea.continent is not null
GROUP BY CovDea.location
Order by NewVaccinations DESC;
--maximum test rate areas
SELECT location,MAX(total_tests) as total_tests FROM CovidVaccinations 
WHERE total_tests is not null
GROUP BY location Order by  total_tests DESC;
--Compare population with positive rate
SELECT CovidDeaths.location,CovidDeaths.population,SUM(cast(CovidVaccinations.positive_rate as float)) 
FROM CovidDeaths JOIN CovidVaccinations ON CovidDeaths.location=CovidVaccinations.location
WHERE positive_rate is not null
GROUP BY CovidDeaths.location,CovidDeaths.population;