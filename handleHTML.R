#Chargement des planes avec le fichier html
library(rvest)

# Charger le fichier HTML
page <- read_html("F:/Cours/R/project_r/dataset_flights/planes.html")

# Extraire une table HTML
planes <- page %>% html_table(fill = TRUE)

# Afficher les données
print(planes)

m <- mongo(collection = "planes", db = "flights", url = "mongodb://localhost:27017")

# Insérer les données dans MongoDB
m$insert(planes[[1]])