library(pdftools)
library(mongolite)

# Import PDF
weather <- pdf_text("./dataset_flights/weather.pdf")

# Split PDF text into lines
weather_lines <- unlist(strsplit(weather, "\n"))

# Convert lines to a data frame assuming CSV format
weather_df <- read.csv(text = weather_lines, header = TRUE)

# Connexion MongoDB
m <- mongo(collection = "weather", db = "flights", url = "mongodb://localhost:27017")

# Conversion et insertion
m$insert(weather_df)

# Vérification
print(m$count())
