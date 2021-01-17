#CODEBOOKS

#Codebook for U.S. President Returns 1976–2016

The data file `1976-2016-president` contains constituency (state-level) returns for elections to the U.S. presidency from 1976 to 2016.  The data source is the document "[Statistics of the Congressional Election](http://history.house.gov/Institution/Election-Statistics/Election-Statistics/)," published biennially by the Clerk of the U.S. House of Representatives.

Each row represents the number of votes for a specific presidential candidate from a specific party on an specific year, by state. It has dimensions `3740`x`14` 

##Variables 
- `year` : year in which election was held
- `office` : U.S. President
- `state` : state name 
- `state_po` : U.S. postal code state abbreviation
- `state_fips` : State FIPS code
- `state_cen` : U.S. Census state code
- `state_ic`: ICPSR state code
- `candidate` : name of the candidate as it appears in the House Clerk report
- `party` : party of the candidate
- `writein`: vote totals associated with write-in candidates. `TRUE` denotes a write-in candidate. `FALSE` denotes a non-write-in one
- `candidatevotes` : votes recieved by this candidate for this particular party
- `totalvotes` : total number of votes cast for this election
- `version` : date of the file's last update in y-m-d format

#Codebook for Beer Production by U.S State

The data file `beer_states.csv` contains state-level beer production by year (2008-2019). The data is available at:https://www.kaggle.com/jessemostipak/beer-production .  The data this week comes from the Alcohol and Tobacco Tax and Trade Bureau (TTB).

Each row represents the yearly amount of consumption of beer by each state, and how it was consume It has dimensions `1,872`x`4`.

##Variables 
- `state` : The U.S State of the observation
- `year` : year
- `barrels` : Barrels produced within each type
- `type` : Type of production/use (On premise, Bottles/Cans, Kegs/Barrels)


#Codebook for Alcohol Consumption per Capita by U.S State

The data file `consumption_per_capita.csv` contains estimates for ethyl alcohol consumption from various alcoholic drinks in gallons per capita per year between 1977 and 2018 for each state. These drinks include: beer, wine, and spirits. There is also a column which include a total of all alcoholic drinks per capita. The data is available at: https://doi.org/10.3886/E105583V4-43770. Alcohol consumption per capita comes from a study conducted by the University of Pennsylvania.

Each row represents the yearly amount of consumption of beer by each state from the years 1977 to 2018. It has dimensions `2,143`x`10`.


#Variables
- `state` : The U.S State of the observation
- `year` : year
- `ethanol_beer_gallons_per_capita` : Beer consumed per capita in gallons
- `ethanol_wine_gallons_per_capita` : Wine consumed per capita in gallons
- `ethanol_spirit_gallons_per_capita` : Spirit consumed per capita in gallons
- `ethanol_all_drinks_gallons_per_capita` : All the drinks consumed per capita in gallons
- `number_of_beers` : Beer number
- `number_of_glasses_wine` : Glasses of wine number
- `number_of_shots_liquor` : Shots of liquor number
- `number_of_drinks_total` : Total Drinks number

