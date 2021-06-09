standardize_data <- function(data, nfcst) {
  
  # A function for data standardization (monthly and quarterly datasets)
  # 
  # Input arguments:
  # "data" - a tibble of prepared data
  # "fcst" - a number of forecasted months
  # 
  # Output arguments:
  # "mean_std" - a dataset w/ mean and standard deviation of data (for restoring)
  # "data_std" - a standardized dataset
  
  # Remove an observation of GDP which we will nowcast
  data$dyobs[nrow(data)] = NA
  
  # Store values of mean and std (monthly dataset)
  params <- data %>% 
    gather(key = "Indicator", value = "Value", -date) %>% 
    group_by(Indicator) %>% 
    summarise(Mean = mean(Value, na.rm = T),
              Std = sqrt(var(Value, na.rm = T)))
  
  # Order means by colnames of data
  MZ <- params %>% 
    select(-Std) %>% 
    spread(Indicator, Mean) %>% 
    select(colnames(data)[-1]) %>% 
    as.matrix()
  
  MZ_m <- matrix(MZ, nrow(data) + nfcst, ncol(MZ), byrow = TRUE)
  
  SD <- params %>% 
    select(-Mean) %>% 
    spread(Indicator, Std) %>% 
    select(colnames(data)[-1]) %>% 
    as.matrix()
  
  SD_m <- matrix(SD, nrow(data) + nfcst, ncol(SD), byrow = TRUE)
  
  # Create an empty tibble for binding w/ monthly dataset
  temp_df <- data %>% 
    select(-date) %>% 
    .[1:nfcst,]
  temp_df[!is.na(temp_df)] <- NA
  
  # Standardize monthly dataset and add rows for storing forecasted values
  Zm <- data %>% 
    mutate_if(is.numeric, ~ (scale(.) %>% as.vector)) %>% 
    dplyr::select(-date) %>% 
    bind_rows(temp_df) %>% 
    mutate_all(replace_na, 0)
  
  # Create an empty tibble for binding w/ quarterly dataset
  temp_df <- data %>% 
    select(-date) %>% 
    .[1:(nfcst/3),]
  temp_df[!is.na(temp_df)] <- NA
  
  # Standardize monthly dataset and add rows for storing forecasted values
  Zq <- data %>% 
    dplyr::filter(month(date) %% 3 == 0) %>% 
    mutate_if(is.numeric, ~ (scale(.) %>% as.vector)) %>% 
    dplyr::select(-date) %>% 
    bind_rows(temp_df) %>% 
    mutate_all(replace_na, 0) %>% 
    .[,1:3]
  
  MZ_q <- matrix(MZ[1:ncol(Zq)], nrow(Zq), ncol(Zq), byrow = TRUE)
  SD_q <- matrix(SD[1:ncol(Zq)], nrow(Zq), ncol(Zq), byrow = TRUE)
  
  data_std <- list(Zm = Zm, Zq = Zq, MZ_m = MZ_m, MZ_q = MZ_q, SD_m = SD_m, SD_q = SD_q)
  
  return(data_std)  
  
}