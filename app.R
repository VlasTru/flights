library(shiny)
library(httr2)
library(dplyr)
library(DBI)
library(duckdb)
library(reactable)
ui <- fluidPage(
    titlePanel("Flights yo"),
    reactableOutput("table")
)

# Define server logic required to draw a histogram
server <- function(input, output) {


  
      resp <- request("https://api.travelpayouts.com/aviasales/v3/get_latest_prices?origin=EVN&destination=IST&currency=USD&departure_at=2025-01&token=3b524593b528496317c30f34007c4265")
      json <- req_perform(resp)
      resp_body_string(json)
      data_to_load <- json %>% resp_body_json(simplifyVector = TRUE) %>% as_tibble()
      data_to_load
      con <- dbConnect(duckdb(), dbdir = "flights.duckdb")
      dbWriteTable(con, "flights", data_to_load, append = TRUE)
      res <- dbGetQuery(con, "SELECT data.found_at, data.value, currency FROM flights order by data.found_at desc")
      output$table <- renderReactable({reactable(res)})
      dbDisconnect(con)
    
}

# Run the application 
shinyApp(ui = ui, server = server)
