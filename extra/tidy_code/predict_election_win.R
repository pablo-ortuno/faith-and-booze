

predict_election_win <- function(year_to_predict)
  
{
  
  library(tidyverse)
  library(broom)
  library(openintro)
  library(usmap)
  library(tidymodels)
  library(here)
  
  
  x <- year_to_predict
  
  beer_states <- read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-31/beer_states.csv')
  # Voting data
  voter_data <- read_rds("/cloud/project/data/1976-2016-president.RData")
  
  #Alcohol consumption per capita
  consumption_per_capita <- read_csv("/cloud/project/data/apparent_per_capita_alcohol_consumption_1977_2018.txt")
  
  electoral_votes <- read_csv("/cloud/project/data/electoral_votes.csv")
  
  ### Data wrangling
  
  # Manually merge some conflicting cells
  # In some states there were two entries for the same candidate, resulting in an undesired outcome when pivoting the data
  
  voter_data[(3536),] <- voter_data[(3536),] %>%
    mutate(candidatevotes = 1677928 + 78)
  voter_data[(3537),] <- voter_data[(3537),] %>%
    mutate(candidatevotes = 943169 + 259)
  
  # Manually rename more conflicting cells
  # In Minnesota, for some years, the democrat party was entered as "democratic". Our algorithm didn't pick up the string and resulted in NA's
  
  voter_data[(2211),] <- voter_data[(2211),] %>%
    mutate(party = "democrat")
  voter_data[(2560),] <- voter_data[(2560),] %>%
    mutate(party = "democrat")
  voter_data[(3226),] <- voter_data[(3226),] %>%
    mutate(party = "democrat")
  
  # Eliminate conflicting rows
  
  voter_data <- voter_data[-c(2545,3415,3543,3544),]
  
  
  
  clean_votes <- voter_data %>%
    # Choose only the two main parties
    filter (party %in% c("democrat", "republican")) %>% 
    # Select the only variables we're interested in. Year, state, party, and how many votes the party received
    select(year, state, party, candidatevotes) %>% 
    pivot_wider(names_from = party, values_from = candidatevotes) %>%
    rename(democrat_votes = democrat, republican_votes = republican) %>%
    # Create a new variable that tells us who won the election in that state
    mutate(office = ifelse(democrat_votes > republican_votes, "democrat", "republican")) %>%
    # Filter so voting data is consistent with the rest of our data
    filter(year >= 1976)
  
  
  
  ### Build consumption data frame
  model_consumption <- consumption_per_capita %>%
    # Chose only years previous to 2016
    filter(year <= x) %>%
    # Clean names
    mutate(state = str_to_title (state)) %>%
    rename(
      beer_per_capita = ethanol_beer_gallons_per_capita,
      wine_per_capita = ethanol_wine_gallons_per_capita,
      spirit_per_capita = ethanol_spirit_gallons_per_capita)
  
  ### Build model data frame by joining consumption and votes
  
  model_data <- full_join(model_consumption, clean_votes) %>%
    # Eliminate regions and DC, which doesn't have voter representation.
    filter(!(state %in% c("District Of Columbia", "District of Columbia", "Us Total", "South Region", "Northeast Region", "Midwest Region", "West Region"))) %>%
    select(c(
      "year", 
      "state", 
      "beer_per_capita", 
      "wine_per_capita", 
      "spirit_per_capita", 
      "office")) %>%
    arrange(state, year)
  
  
  
  ### Split data into train and test
  
  model_data_test <- model_data %>%
    filter(year == x)
  
  model_data_train <- model_data %>%
    filter(year < x)
  
  # Apply a simple "for" loop that will "fill in" what party that state voted for in the last four years.
  
  for (n in 1:nrow(model_data_train)) {
    if ((n-1)%%4 == 0) {
      model_data_train$office[n] -> model_data_train$office[n+3]
      model_data_train$office[n] -> model_data_train$office[n+2]
      model_data_train$office[n] -> model_data_train$office[n+1]
    }
  }
  
  # Drop out the year 1976. It was only being used to fill in "office" values.
  
  model_data_train <- model_data_train %>%
    filter(year != 1976)
  
  # Since we want to predict "office", we have to convert it into a factor.
  
  model_data_train["office"] <- lapply(model_data_train["office"] , factor)
  
  
  
  
  
  model_election <- logistic_reg() %>%
    set_engine("glm") %>%
    fit(office ~ ., data = model_data_train, family = "binomial")
  
  tidy(model_election)
  
  
  election_pred <- predict(model_election, model_data_test, type = "prob") %>%
    bind_cols(model_data_test %>% select(office, state)) %>%
    mutate(predicted = ifelse(.pred_democrat > .pred_republican, "democrat", "republican")) %>%
    select(.pred_democrat, .pred_republican, state, office, predicted)
  
  
  partisan_colors <- c("democrat" = "blue3", "republican" = "red3", "null" = "black")
  
  plot_usmap(data = (election_pred %>% filter(predicted == office)), regions = "states", values = "office", color = "black") +
    labs( title = "Election winners predicted correctly",
          subtitle = "by state",
          caption = "States coloured white were predicted incorrectly",
          fill = "Party") +
    theme(
      legend.position = "right") +
    scale_fill_manual(values = partisan_colors)
  
  
  election_pred %>%
    count(office == predicted)
  
  
  election_out <- full_join(election_pred, electoral_votes) %>%
    filter(state != "District Of Columbia")
  
  outcome <- election_out %>%
    group_by(predicted) %>%
    summarise(total_votes = sum (votes))
  
  winner <- outcome %>%
    mutate(max = max(total_votes)) %>%
    filter(total_votes == max)
  
  
  return(winner$predicted)
  
  
}
