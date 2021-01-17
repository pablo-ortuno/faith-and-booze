

predict_election_plot <- function(year_to_predict)
  
{
  model_consumption <- consumption_per_capita %>%
    filter(year <= x) %>%
    mutate(state = str_to_title (state)) %>%
    rename(
      beer_per_capita = ethanol_beer_gallons_per_capita,
      wine_per_capita = ethanol_wine_gallons_per_capita,
      spirit_per_capita = ethanol_spirit_gallons_per_capita)
  
  model_data <- full_join(model_consumption, clean_votes) %>%
    filter(!(state %in% c("District Of Columbia", "District of Columbia", "Us Total", "South Region", "Northeast Region", "Midwest Region", "West Region"))) %>%
    select(c(
      "year", 
      "state", 
      "beer_per_capita", 
      "wine_per_capita", 
      "spirit_per_capita", 
      "office")) %>%
    arrange(state, year)
  
  model_data_test <- model_data %>%
    filter(year == x)
  
  model_data_train <- model_data %>%
    filter(year < x)
  
  for (n in 1:nrow(model_data_train)) {
    if ((n-1)%%4 == 0) {
      model_data_train$office[n] -> model_data_train$office[n+3]
      model_data_train$office[n] -> model_data_train$office[n+2]
      model_data_train$office[n] -> model_data_train$office[n+1]
    }
  }
  
  model_data_train <- model_data_train %>%
    filter(year != 1976)
  
  model_data_train["office"] <- lapply(model_data_train["office"] , factor)
  
  
  
  
  
  model_election <- logistic_reg() %>%
    set_engine("glm") %>%
    fit(office ~ ., data = model_data_train, family = "binomial")
  
  tidy(model_election)
  
  
  election_pred <- predict(model_election, model_data_test, type = "prob") %>%
    bind_cols(model_data_test %>% select(office, state)) %>%
    mutate(predicted = ifelse(.pred_democrat > .pred_republican, "democrat", "republican")) %>%
    select(.pred_democrat, .pred_republican, state, office, predicted) %>% 
    mutate(correct_prediction = predicted == office) %>% 
    mutate(pred_for_plot = ifelse(correct_prediction, paste("correctly" , office ), paste("actually" , office )))
  
  
  partisan_colors <- c("correctly democrat" = "blue3", "correctly republican" = "red3", "actually democrat" = "lightskyblue1", "actually republican" = "lightpink","null" = "black")
  
  plot_usmap(data = election_pred , regions = "states", values = "pred_for_plot", color = "black") +
    labs( title = "States Predicted Correctly",
          subtitle = "by winning party",
          caption = "States coloured white were predicted incorrectly",
          fill = "Party") +
    theme(
      legend.position = "right") +
    scale_fill_manual(values = partisan_colors)

 
}
