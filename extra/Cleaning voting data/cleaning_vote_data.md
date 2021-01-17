Untitled
================

``` r
library(tidyverse)
library(broom)
library(here)
library(stringr)
library(openintro)
```

``` r
# Voting data
voter_data <- read_rds("/cloud/project/data/1976-2016-president.RData")
write_rds(voter_data, "/cloud/project/data/voter_data.rds")
```

### CLEANING VOTING DATA

Preliminary cleaning

``` r
voter_data %>%
  filter (party %in% c("democrat", "republican")) %>% 
  select(year, state, party, candidatevotes) %>% 
  pivot_wider(names_from = party, values_from = candidatevotes) %>%
  rename(democrat_votes = democrat, republican_votes = republican)
```

    ## Warning: Values are not uniquely identified; output will contain list-cols.
    ## * Use `values_fn = list` to suppress this warning.
    ## * Use `values_fn = length` to identify where the duplicates arise
    ## * Use `values_fn = {summary_fun}` to summarise duplicates

    ## # A tibble: 561 x 4
    ##     year state                democrat_votes republican_votes
    ##    <int> <I<chr>>             <list>         <list>          
    ##  1  1976 Alabama              <int [1]>      <int [1]>       
    ##  2  1976 Alaska               <int [1]>      <int [1]>       
    ##  3  1976 Arizona              <int [1]>      <int [1]>       
    ##  4  1976 Arkansas             <int [1]>      <int [1]>       
    ##  5  1976 California           <int [1]>      <int [1]>       
    ##  6  1976 Colorado             <int [1]>      <int [1]>       
    ##  7  1976 Connecticut          <int [1]>      <int [1]>       
    ##  8  1976 Delaware             <int [1]>      <int [1]>       
    ##  9  1976 District of Columbia <int [1]>      <int [1]>       
    ## 10  1976 Florida              <int [1]>      <int [1]>       
    ## # … with 551 more rows

This outputs votes as a list. This must be because two different rows
have a shared value. Lets examine and find where the problem is

``` r
voter_data %>%
  filter (party %in% c("democrat", "republican")) %>% 
  select(year, state, party, candidatevotes) %>% 
  pivot_wider(names_from = party, values_from = candidatevotes, values_fn = length) %>%
  #Adding the values_fn = length argument is going to tell us wich entries of the list have a vector (its length will not be = 1)
  filter(
    democrat != 1 | republican != 1
  )
```

    ## # A tibble: 3 x 4
    ##    year state    democrat republican
    ##   <int> <I<chr>>    <int>      <int>
    ## 1  2004 Maryland        2          1
    ## 2  2016 Arizona         2          1
    ## 3  2016 Maryland        2          2

So the issues arise in 2004 Maryland, where two rows contain “democrat”,
2016 Arizona, where two rows contain “democrat”, and 2016 Maryland,
where there are two different rows for each party. Lets see exactly
where the error arises from

``` r
voter_data %>%
  select(year, state, candidate, party, candidatevotes) %>%
  filter(year == 2004, state == "Maryland", party == "democrat")
```

    ##      year    state   candidate    party candidatevotes
    ## 2538 2004 Maryland Kerry, John democrat        1334493
    ## 2545 2004 Maryland       Other democrat              7

The problem here is two different candidates. Fixed by erasing row 2545

``` r
voter_data %>%
  select(year, state, candidate, party, candidatevotes) %>%
  filter(year == 2016, state == "Arizona", party == "democrat")
```

    ##      year   state        candidate    party candidatevotes
    ## 3409 2016 Arizona Clinton, Hillary democrat        1161167
    ## 3415 2016 Arizona             <NA> democrat             42

The problem here is, again, two different candidates for the same part

``` r
voter_data %>%
  select(year, state, candidate, party, candidatevotes) %>%
  filter(year == 2016, state == "Maryland", party == "democrat" | party == "republican")
```

    ##      year    state        candidate      party candidatevotes
    ## 3536 2016 Maryland Clinton, Hillary   democrat        1677928
    ## 3537 2016 Maryland Trump, Donald J. republican         943169
    ## 3543 2016 Maryland Trump, Donald J. republican            259
    ## 3544 2016 Maryland Clinton, Hillary   democrat             78

So we’ll solve this issues by erasing rows 2415, 3415, and adding the
corresponding values for rows 3565 and 3544, and 3537 and 3543. Since we
know exactly what values we’re dealing with we’ll just rewrite the
values and delete two rows

``` r
voter_data[(3536),] <- voter_data[(3536),] %>%
    mutate(candidatevotes = 1677928 + 78)

voter_data[(3537),] <- voter_data[(3537),] %>%
    mutate(candidatevotes = 943169 + 259)
  
voter_data <- voter_data[-c(2545,3415,3543,3544),]
```

Now we can correctly apply our cleaning and add a “winner” variable

``` r
clean_votes <- voter_data %>%
  filter (party %in% c("democrat", "republican")) %>% 
  select(year, state, party, candidatevotes) %>% 
  pivot_wider(names_from = party, values_from = candidatevotes) %>%
  rename(democrat_votes = democrat, republican_votes = republican) %>%
  mutate(winner = ifelse(democrat_votes > republican_votes, "democrat", "republican")) # Note there are no entries where the number of votes are equal 

clean_votes
```

    ## # A tibble: 561 x 5
    ##     year state                democrat_votes republican_votes winner    
    ##    <int> <I<chr>>                      <dbl>            <dbl> <chr>     
    ##  1  1976 Alabama                      659170           504070 democrat  
    ##  2  1976 Alaska                        44058            71555 republican
    ##  3  1976 Arizona                      295602           418642 republican
    ##  4  1976 Arkansas                     498604           267903 democrat  
    ##  5  1976 California                  3742284          3882244 republican
    ##  6  1976 Colorado                     460801           584278 republican
    ##  7  1976 Connecticut                  647895           719261 republican
    ##  8  1976 Delaware                     122461           109780 democrat  
    ##  9  1976 District of Columbia         137818            27873 democrat  
    ## 10  1976 Florida                     1636000          1469531 democrat  
    ## # … with 551 more rows

As expected, class variables are as desired
