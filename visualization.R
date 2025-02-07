library(shiny)
library(mongolite)
library(ggplot2)
library(dplyr)
library(leaflet)

# Connexion MongoDB
mongo <- mongo(collection = "flight_reports", db = "flights", url = "mongodb://localhost:27017")
data <- mongo$find()

# UI
ui <- fluidPage(
  titlePanel("Visualisation des Vols"),
  sidebarLayout(
    sidebarPanel(
      selectInput("weather_var", "Variable météo", 
                  choices = c("Température" = "weather_temp", "Humidité" = "weather_humid", "Vitesse du vent" = "weather_wind_speed"),
                  selected = "weather_temp"),
      sliderInput("delay_range", "Plage de retard à l'arrivée (min)",
                  min = min(data$arr_delay, na.rm = TRUE), max = max(data$arr_delay, na.rm = TRUE),
                  value = c(min(data$arr_delay, na.rm = TRUE), max(data$arr_delay, na.rm = TRUE)))
    ),
    mainPanel(
      plotOutput("weatherPlot"),
      leafletOutput("flightMap"),
      plotOutput("delayHist")
    )
  )
)

# Server
server <- function(input, output) {
  output$weatherPlot <- renderPlot({
    ggplot(data, aes_string(x = "time_hour", y = input$weather_var)) +
      geom_line() +
      labs(title = paste("Évolution de", input$weather_var), x = "Temps", y = input$weather_var)
  })
  
  output$flightMap <- renderLeaflet({
    leaflet(data) %>%
      addTiles() %>%
      addPolylines(lng = ~c(origin_lon, dest_lon), lat = ~c(origin_lat, dest_lat),
                   group = ~flight, color = "blue")
  })
  
  output$delayHist <- renderPlot({
    ggplot(data %>% filter(arr_delay >= input$delay_range[1], arr_delay <= input$delay_range[2]),
           aes(x = arr_delay)) +
      geom_histogram(binwidth = 5, fill = "blue", color = "white") +
      labs(title = "Distribution des Retards", x = "Retard à l'arrivée (min)", y = "Nombre de vols")
  })
}

shinyApp(ui, server)