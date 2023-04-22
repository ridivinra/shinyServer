library(httr)
library(jsonlite)
library(xml2)
library(lubridate)
library(tidyverse)

if(!file.exists("weather.RData")){
  # Do something smart here to append data
  weatherDt <- data.frame()
}else{
  load("weather.RData")
}
WEATHERTYPES <- list(
  observations = "obs",
  forecast = "forec"
)
get_weather_forecast <- function(stData){
  idStr <- paste(stData$id, collapse = ";")
  url <- paste0("https://xmlweather.vedur.is/?op_w=xml&type=forec&lang=is&view=xml&ids=",idStr,"params=T;F;N;W;FX;FG;D;V;P;RH;SNC;SND;R")
  response <- GET(url)
  weather_data <- read_xml(response$content)
  # Extract station data
  stations <- xml_find_all(weather_data, "//station")
  # Initialize an empty tibble to store parsed data
  parsed_data <- tibble(
    id = character(),
    name = character(),
    ftime = POSIXct(),
    temperature = character(),
    wind_speed = numeric(),
    cloud_cover = character(),
    weather_info = character(),
    most_wind = numeric(),
    most_wind_hvida = numeric(),
    wind_direction = character(),
    skyggni = character(),
    air_pressure = character(),
    rakastig = character(),
    snow_info = character(),
    snow_deep = character(),
    urkoma = character()
  )
  # Loop through stations and extract data
  for (station in stations) {
    id <- xml_attr(station, "id")
    name <- xml_text(xml_find_first(station, "./name"))
    forecasts <- xml_find_all(station, "./forecast")
    for (forecast in forecasts) {
      ftime <- xml_text(xml_find_first(forecast, "./ftime")) %>% 
        as.POSIXct()
      temperature <- xml_text(xml_find_first(forecast, "./T")) 
      wind_speed <- xml_text(xml_find_first(forecast, "./F")) %>%
        as.numeric()
      cloud_cover <- xml_text(xml_find_first(forecast, "./N")) 
      weather_info <- xml_text(xml_find_first(forecast, "./W")) 
      most_wind <- xml_text(xml_find_first(forecast, "./FX")) 
      most_wind_hvida <- xml_text(xml_find_first(forecast, "./FG")) 
      wind_direction <- xml_text(xml_find_first(forecast, "./D")) 
      skyggni <- xml_text(xml_find_first(forecast, "./V")) 
      air_pressure <- xml_text(xml_find_first(forecast, "./P")) 
      rakastig <- xml_text(xml_find_first(forecast, "./RH")) 
      snow_info <- xml_text(xml_find_first(forecast, "./SNC"))
      snow_deep <- xml_text(xml_find_first(forecast, "./SND"))
      urkoma <- xml_text(xml_find_first(forecast, "./R"))
      parsed_data <- parsed_data %>%
        add_row(
          id = id,
          name = name,
          ftime = ftime,
          temperature = temperature,
          wind_speed = as.numeric(wind_speed),
          cloud_cover = cloud_cover,
          weather_info = weather_info,
          most_wind = as.numeric(most_wind),
          most_wind_hvida = as.numeric(most_wind_hvida),
          wind_direction = wind_direction,
          skyggni = skyggni,
          air_pressure = air_pressure,
          rakastig = rakastig,
          snow_info = snow_info,
          snow_deep = snow_deep,
          urkoma = urkoma
        )
    }
  }
  return(parsed_data %>% left_join(stData, by = "id"))
}
get_weather_obs <- function(stData){
  idStr <- paste(stData$id, collapse = ";")
  url <- paste0("https://xmlweather.vedur.is/?op_w=xml&type=obs&lang=is&view=xml&ids=",idStr,"&params=T;F;N;W;FX;FG;D;V;P;RH;SNC;SND;R")
  response <- GET(url)
  weather_data <- read_xml(response$content)
  # Extract station data
  stations <- xml_find_all(weather_data, "//station")
  stations[[1]]
  # Define the tibble with all variables
  parsed_data <- tibble(
    id = character(),
    name = character(),
    ftime = POSIXct(),
    temperature = character(),
    wind_speed = numeric(),
    cloud_cover = character(),
    weather_info = character(),
    most_wind = numeric(),
    most_wind_hvida = numeric(),
    wind_direction = character(),
    skyggni = character(),
    air_pressure = character(),
    rakastig = character(),
    snow_info = character(),
    snow_deep = character(),
    urkoma = character()
  )
  # Loop through stations and extract data
  for (station in stations) {
    id <- xml_attr(station, "id")
    name <- xml_text(xml_find_first(station, "./name"))
    ftime <- xml_text(xml_find_first(station, "./time")) %>% 
      as.POSIXct()
    temperature <- xml_text(xml_find_first(station, "./T")) 
    wind_speed <- xml_text(xml_find_first(station, "./F"))
    cloud_cover <- xml_text(xml_find_first(station, "./N")) 
    weather_info <- xml_text(xml_find_first(station, "./W")) 
    most_wind <- xml_text(xml_find_first(station, "./FX")) 
    most_wind_hvida <- xml_text(xml_find_first(station, "./FG")) 
    wind_direction <- xml_text(xml_find_first(station, "./D")) 
    skyggni <- xml_text(xml_find_first(station, "./V")) 
    air_pressure <- xml_text(xml_find_first(station, "./P")) 
    rakastig <- xml_text(xml_find_first(station, "./RH")) 
    snow_info <- xml_text(xml_find_first(station, "./SNC"))
    snow_deep <- xml_text(xml_find_first(station, "./SND"))
    urkoma <- xml_text(xml_find_first(station, "./R"))

    parsed_data <- parsed_data %>% 
      add_row(
        id = id,
        name = name,
        ftime = ftime,
        temperature = temperature,
        wind_speed = as.numeric(wind_speed),
        cloud_cover = cloud_cover,
        weather_info = weather_info,
        most_wind = as.numeric(most_wind),
        most_wind_hvida = as.numeric(most_wind_hvida),
        wind_direction = wind_direction,
        skyggni = skyggni,
        air_pressure = air_pressure,
        rakastig = rakastig,
        snow_info = snow_info,
        snow_deep = snow_deep,
        urkoma = urkoma
      )
  }
  return(parsed_data %>% left_join(stData, by = "id"))
}
Stations <- tibble(
  id = as.character(c(1,422,2738,178,6017,6272,5544,6935,571,4828,3317)),
  lat = c(64.1275, 65.6856,66.161,65.074,63.3996,63.793,64.2691,64.8668,65.283,66.456,65.658),
  long = -c(21.9028, 18.1002,23.2538,22.7339,20.2882,18.0119,15.2135,19.5622,14.4025,15.9527,20.2925)
)
weatherData <- get_weather_obs(stData = Stations)
weatherDataForecast <- get_weather_forecast(stData = Stations)

newWeatherInfo <- bind_rows(
  weatherDataForecast %>% mutate(type = "forecast"),
  weatherData %>% mutate(type = "observation")
) %>% 
  mutate(
    label = paste0(str_split(name, " ", simplify = TRUE)[, 1],"\n","Temp:",temperature,"°C\n","Wind:",wind_speed,"m/s"),
    ftime = as.POSIXct(ftime))
weatherTime <- newWeatherInfo %>% 
  filter(type == 'observation') %>% 
  pull(ftime) %>% 
  unique()
newWeatherInfo <- newWeatherInfo %>% mutate(vtimi = weatherTime)
weatherDt <- bind_rows(newWeatherInfo, weatherDt)
save(weatherDt, file = "weather.RData")
