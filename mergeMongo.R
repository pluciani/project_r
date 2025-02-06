library(mongolite)
library(dplyr)
library(jsonlite)

# Connexion aux collections
con_flights <- mongo("flights", "flights")
con_airlines <- mongo("airlines", "flights")
con_airports <- mongo("airports", "flights")
con_planes <- mongo("planes", "flights")
con_weather <- mongo("weather", "flights")

# Récupération des données
flights <- con_flights$find()
airlines <- con_airlines$find()
airports <- con_airports$find()
planes <- con_planes$find()
weather <- con_weather$find()

weather$time_hour <- as.POSIXct(weather$time_hour)

merged_data <- flights %>%
  left_join(airlines %>% select(carrier, airline_name = name), by = "carrier") %>%
  left_join(airports %>% select(faa, origin_name = name, origin_lat = lat, origin_lon = lon), 
            by = c("origin" = "faa")) %>%
  left_join(airports %>% select(faa, dest_name = name, dest_lat = lat, dest_lon = lon), 
            by = c("dest" = "faa")) %>%
  left_join(planes %>% select(tailnum, manufacturer, model, seats), by = "tailnum") %>%
  left_join(weather %>% select(-year, -month, -day, -hour), by = c("origin", "time_hour")) %>%
  select(-carrier, -origin, -dest, -tailnum) %>% # Suppression des clés étrangères
  rename(
    departure_airport = origin_name,
    arrival_airport = dest_name,
    aircraft_model = model
  ) %>%
  mutate(time_hour = as.POSIXct(time_hour))

# Connexion à la nouvelle collection
con_merged <- mongo("flight_reports", "flights")

# Insertion optimisée
con_merged$insert(merged_data)

# Vérification
con_merged$count()
con_merged$find(limit = 1)