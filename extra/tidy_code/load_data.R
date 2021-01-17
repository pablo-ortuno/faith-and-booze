

load_data <- function() {
  
  beer_states <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')
  voter_data <- read_rds("/cloud/project/data/1976-2016-president.RData")
  consumption_per_capita <- read_csv("/cloud/project/data/apparent_per_capita_alcohol_consumption_1977_2018.txt")
  electoral_votes <- read_csv("/cloud/project/data/electoral_votes.csv")
  
  voter_data[(3536),] <- voter_data[(3536),] %>%
    mutate(candidatevotes = 1677928 + 78)
  voter_data[(3537),] <- voter_data[(3537),] %>%
    mutate(candidatevotes = 943169 + 259)
  voter_data[(2211),] <- voter_data[(2211),] %>%
    mutate(party = "democrat")
  voter_data[(2560),] <- voter_data[(2560),] %>%
    mutate(party = "democrat")
  voter_data[(3226),] <- voter_data[(3226),] %>%
    mutate(party = "democrat")
  
  voter_data <- voter_data[-c(2545,3415,3543,3544),]
  
  voter_data <<- voter_data %>%
  filter (party %in% c("democrat", "republican")) %>% 
    select(year, state, party, candidatevotes) %>% 
    pivot_wider(names_from = party, values_from = candidatevotes) %>%
    mutate(office = ifelse(democrat_votes > republican_votes, "democrat", "republican")) %>%
    filter(year >= 1976)
  
  model_consumption <- consumption_per_capita %>%
    filter(year <= 2016) %>%
    mutate(state = str_to_title (state)) %>%
    rename(
      beer_per_capita = ethanol_beer_gallons_per_capita,
      wine_per_capita = ethanol_wine_gallons_per_capita,
      spirit_per_capita = ethanol_spirit_gallons_per_capita)
  
  model_data <- full_join(model_consumption, voter_data) %>%
    filter(!(state %in% c("District Of Columbia", "District of Columbia", "Us Total", "South Region", "Northeast Region", "Midwest Region", "West Region"))) %>%
    select(c("year", "state", "beer_per_capita", "wine_per_capita", "spirit_per_capita", "office")) %>%
    arrange(state, year)
  
  model_data_test <<- model_data %>%
    filter(year == 2016)
  
  model_data_train <<- model_data %>%
    filter(year < 2016)
  
  for (n in 1:nrow(model_data_train)) {
    if ((n-1)%%4 == 0) {
      model_data_train$office[n] -> model_data_train$office[n+3]
      model_data_train$office[n] -> model_data_train$office[n+2]
      model_data_train$office[n] -> model_data_train$office[n+1]
    }
  }
  
  model_data_train <- model_data_train %>%
    filter(year != 1976)
  
  model_data_train["office"] <<- lapply(model_data_train["office"] , factor)
  
}


