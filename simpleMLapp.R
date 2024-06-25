library(shiny)
library(readr)
library(openxlsx)

# Load the .RDS file containing the model (replace with your actual model loading code)
loaded_model <- readRDS("academic_performance_model.RDS")

# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel("Academic Performance Prediction"),
  
  # Sidebar with file upload and action button
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV File:",
                accept = c(".csv")),
      downloadButton("download", "Predict & Download")  # Download button added directly in sidebarPanel
    ),
    
    # Main panel for displaying outputs (none in this case)
    mainPanel()
  )
)

# Define server logic
server <- function(input, output) {
  
  # Reactive expression to read uploaded CSV file and predict
  predictions <- reactive({
    req(input$file)
    
    # Read uploaded CSV file
    df <- read_csv(input$file$datapath)
    
    # Ensure required columns are present
    if (!all(c("IQ", "EQ", "AQ") %in% colnames(df))) {
      return(showNotification("Uploaded file must contain IQ, EQ, and AQ columns.", type = "warning"))
    }
    
    # Predict academic performance
    predictions <- predict(loaded_model, newdata = df)
    
    # Combine original data with predictions for display
    prediction_table <- cbind(df, Predicted_Academic_Performance = predictions)
    
    return(prediction_table)
  })
  
  # Download predictions as CSV file (.csv)
  output$download <- downloadHandler(
    filename = function() {
      "predictions.csv"
    },
    content = function(file) {
      predictions_df <- predictions()
      write.csv(predictions_df, file, row.names = FALSE)
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
