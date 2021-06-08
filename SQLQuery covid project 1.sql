Select *
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Order By 3,4


	Select *
	From PortfolioProject..CovidVaccinations
	Order By 3,4


	Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths
	Order by 1,2

	--Cases vs Deaths
	--chance if dieing from covid once you contract it in your country

	Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	WHere location like '%states%'
	Order by 1,2

	--total cases vs populationbin U.S.
	-- percent of population that got covid

	Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	WHere location like '%states%'
	Order by 1,2


	--countries with the highest infection rate to population

	Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	--WHere location like '%states%'
	Group by Location, Population
	Order by PercentPopulationInfected desc

	--Countries with the highest death count per capita

	Select Location, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	--WHere location like '%states%'
	Where continent is not null
	Group by Location
	Order by TotalDeathCount desc

	--continents with highest death per capita

	Select continent, MAX(Cast(Total_Deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	--WHere location like '%states%'
	Where continent is not null
	Group by continent
	Order by TotalDeathCount desc

	--daily global numbers


	Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST
		(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	--WHere location like '%states%'
	Where continent is not null
	Group by date
	Order by 1,2

	--total popylaion vs vaccianitons

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


	--Use CTE

	with PopvsVac (continent,location, date, population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3
	)
	Select*, (RollingPeopleVaccinated/population)*100
	From PopvsVac

	--Temp Table

	Create Table #PercentPopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	Date Datetime,
	population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3

	Select*, (RollingPeopleVaccinated/population)*100
	From #PercentPopulationVaccinated


	--Creating veiw to store date for later visualization

	Create view PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3