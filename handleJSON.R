library(mongolite)
library(jsonlite)

# Import JSON
airlines <- fromJSON("./dataset_flights/airlines.json")

# Connexion MongoDB
m <- mongo(collection = "airlines", db = "flights", url = "mongodb://localhost:27017")

# Conversion et insertion
m$insert(airlines)

# Vérification
print(m$count())