make_dataset <- function(xlsx_file) {
  # A function for importing xlsx file w/ initial data and make it suitable
  # for estimation in the model
  #
  # Input arguments:
  # 'xlsx_file' - a path to the xlsx file
  #
  # Output arguments:
  # 'data' - a dataset which returns after function execution
  # 'data.Rds' - a final dataset saved in the .Rds format 
  
  # Importing and tidying data for model ------------------------------------
  
  # Transformation info for monthly auxiliaries
  trnsf <- xlsx_file %>% 
    read_excel(sheet = "m") %>% 
    .[1,] %>% 
    gather(key = "Indicator", value = "Transformation") %>% 
    mutate(Transformation = as_factor(Transformation))
  
  # Monthly auxiliaries
  data_m_level <- xlsx_file %>% 
    read_excel(sheet = "m") %>% 
    .[-1,] %>% 
    rename(date = Indicator) %>% 
    mutate(date = as.Date(as.numeric(date), origin = "1899-12-30")) %>% 
    mutate_if(is.character, as.numeric)
  
  # Quarterly observables
  data_q <- xlsx_file %>% 
    read_excel(sheet = "q") %>% 
    mutate(date = as_date(date))
  
  # Transform monthly auxiliaries into quarterly equivalents ----------------
  
  # Calculate growth rate / first difference of monthly dataset
  data_m_growth <- data_m_level %>% 
    gather(value = "Value", key = "Indicator", -date) %>% 
    right_join(trnsf, by = "Indicator") %>% 
    group_by(Indicator) %>% 
    mutate(growth = case_when(
      Transformation == "growth" ~ (Value / dplyr::lag(Value) - 1) * 100,
      Transformation == "diff" ~ Value - dplyr::lag(Value))
    ) %>% 
    dplyr::select(-Value, -Transformation) %>% 
    spread(Indicator, growth) %>% 
    select(colnames(data_m_level))
  
  # Transform monthly values into quarterly (see Mariano and Murazawa, 2003)
  data_m_growth <- data_m_growth %>% 
    gather(value = "Value", key = "Indicator", -date) %>% 
    group_by(Indicator) %>% 
    mutate(growth = Value + 2 * dplyr::lag(Value, 1) + 3 * dplyr::lag(Value, 2) +
             2 * dplyr::lag(Value, 3) + dplyr::lag(Value, 4)) %>% 
    dplyr::select(-Value) %>% 
    spread(Indicator, growth) %>% 
    select(colnames(data_m_level))
  
  # Merge two datasets and save the result ----------------------------------
  
  # Combine quarterly observables w/ monthly panel
  data <- data_m_growth %>% 
    full_join(data_q) %>% 
    dplyr::filter(date <= "2019-12-01") %>% # drop pandemic observations
    .[-(1:6),] %>% # Delete first 6 rows from dataset (5 - MM transformation, 6 - last month)
    relocate(robs, dyobs, dpobs) %>% 
    relocate(date)
  
  # Save the result as .Rds file
  save(data, file = "data/data.Rds")
  
  return(data)
  
}