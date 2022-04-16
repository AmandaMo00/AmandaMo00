library(shiny)
library(plotly)

shinyApp(
  ui = fluidPage(
    tabsetPanel(
      
      tabPanel("Upload Data", fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   
                   fileInput('f1', label = 'Upload data for Analysis', accept = '.csv')
                   
                   
                   
                   
                   
                   
                 ),
                 mainPanel(
                   
                 )
               )
      ),
      
      tabPanel("Visualization", fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   
                   
                   
                   selectInput('v1', label='Select Variable', choices=''),
                   selectInput('v2', label='Select Variable', choices=''),
                   selectInput(
                     "type",
                     label = "Select Plot Type",
                     choices = c('Scatter','Density','Barplot'),
                     selected = 'Scatter'
                   )
                   
                   
                   
                   
                   ),
                 mainPanel(
                   plotOutput('show_plot')
                 )
               )
      ),
      tabPanel("Modeling", fluid = TRUE,
               sidebarLayout(
                 sidebarPanel(
                   
                   
                   selectInput('y', label='Select target variable', choices=c('')),
                   checkboxGroupInput("x", label = "Select input variables"),
                   
                   selectInput('modeltype1', label=h1('Model 1'), choices=c('rpart', 'ranger',  'adaboost'), selected = 'rpart'),
                   
                   sliderInput('hp1', 'Choose Hyperparameter 1', min=0, max=10, value = 5),
                   
                   selectInput('modeltype2', label=h1('Model 2'), choices=c('rpart', 'ranger', 'adaboost'), selected = 'ranger'),
                   
                   sliderInput('hp2', 'Choose Hyperparameter 1', min=0, max=10, value = 5),
                   
                   selectInput('modeltype3', label=h1('Model 3'), choices=c('rpart', 'ranger', 'adaboost'), selected = 'adaboost'),
                   
                   sliderInput('hp3', 'Choose Hyperparameter 3', min=0, max=10, value = 5)
                   
                   
                   
                   
                   ),
                 mainPanel(
                   textOutput(outputId = "a1"),
                   textOutput(outputId = "a2"),
                   textOutput(outputId = "a3")
                   
                 )
               )
      )
    )
  ), 
  server = function(input, output, session) {
    
    myData <- reactive({
      inFile = input$f1
      if (is.null(inFile)) return(NULL)
      data <- read.csv(inFile$datapath, header = TRUE)
      data
    }
    )
    
    output$show_plot <- renderPlot({
      
      inFile = input$f1
      v1 = input$v1
      d <- read.csv(inFile$datapath, header = TRUE)
      
      v1 = input$v1
      v2 = input$v2
      t =  input$type
      
      if(t=='Scatter'){
        library(ggplot2)
        r = ggplot(d, aes(x = d[[v1]], y = d[[v2]]))+
          geom_point()+
          labs(x = v1, y = v2)
        
      }
      
      if(t=='Density'){
        library(ggplot2)
        library(gridExtra)
        r1 = ggplot(d, aes(x = d[[v1]]))+
          geom_density()+
          labs(x = v1)
        
        r2 = ggplot(d, aes(x = d[[v2]]))+
          geom_density()+
          labs(x = v2)
        
        r = grid.arrange(r1, r2, nrow = 2)
        
        
      }
      
      #for barplot x is limits to continuous
      if(t=='Barplot'){
        library(ggplot2)
        library(gridExtra)
        r1 = ggplot(d, aes(x= d[[v1]]))+
          geom_histogram()+
          labs(x=v1)
        
        r2 = ggplot(d, aes(x = d[[v2]]))+
          geom_histogram()+
          labs(x= v2)
        
        r = grid.arrange(r1, r2, nrow = 2)
        
        
      }
      
      #return(ggplotly(r))
      return(r)
      
      
    })
    
    output$a1 <- renderText({
      inFile = input$f1
      d <- read.csv(inFile$datapath, header = TRUE)
      library(dplyr)
      d=d %>% 
        filter_all(~!is.na(.)) %>% 
        filter_all(~!(.==''))
      v1 = as.character(input$y)
      v2 = as.numeric(input$x)
      d = cbind(d[,v1], d[,v2])
      names(d)[1]='target'
      #print(v2)
      
       
      
      model1=input$modeltype1
      set.seed(2019)
      
      if (model1 == "rpart") { 
        library(caret)
        library(rpart)
      
        max_depth = input$hp1
        library(rpart)
        library(rattle)
        mytree <- rpart(target ~., data = d, method = "class", control = rpart.control(maxdepth = max_depth))
        pred= predict(mytree,d,type="class")
        library(caret)
        cm=confusionMatrix(as.factor(pred),as.factor(d$target))
        a1=cm$overall['Accuracy']
        
     
      }
      
      if (model1=="ranger"){
        library(caret)
        library(ranger)
        
        d=d %>% 
          mutate(target = as.character(target))
        noftree= input$hp1
        
        myGrid = expand.grid(mtry=2, splitrule="gini", min.node.size=noftree)
        
        forest = train(target~., data = d,method = "ranger", tuneGrid = myGrid)
        pred_forest= predict(forest, data = d)
        
        cm=confusionMatrix(as.factor(pred_forest), as.factor(d$target))
        
        a1=cm$overall['Accuracy']
       
        
      }
      
      if (model1 == "adaboost"){
        d=d %>% 
          mutate(target = as.character(target))
        library(adabag)
        noftree= input$hp1
        myGrid = expand.grid(mfinal = noftree ,maxdepth=3)
        model <- train(target~.,data = d, method = "AdaBag", tuneGrid = myGrid)
        
       
        pred=predict(model,d)
        
        cm=confusionMatrix(as.factor(pred), as.factor(d$target))
        
        a1=cm$overall['Accuracy']
        
        
        
      }
      return(a1)
    
    })
    
    output$a2 <- renderText({
      inFile = input$f1
      d <- read.csv(inFile$datapath, header = TRUE)
      library(dplyr)
      d=d %>% 
        filter_all(~!is.na(.)) %>% 
        filter_all(~!(.==''))
      v1 = as.character(input$y)
      v2 = as.numeric(input$x)
      d = cbind(d[,v1], d[,v2])
      names(d)[1]='target'
     
      
      
      
      model1=input$modeltype2
      set.seed(2019)
      
      if (model1 == "rpart") { 
        library(caret)
        library(rpart)
        
        max_depth = input$hp2
        library(rpart)
        library(rattle)
        mytree <- rpart(target ~., data = d, method = "class", control = rpart.control(maxdepth = max_depth))
        pred= predict(mytree,d,type="class")
        library(caret)
        cm=confusionMatrix(as.factor(pred),as.factor(d$target))
        a2=cm$overall['Accuracy']
        
        
      }
      
      if (model1=="ranger"){
        library(caret)
        library(ranger)
        
        d=d %>% 
          mutate(target = as.character(target))
        noftree= input$hp2
        
        myGrid = expand.grid(mtry=2, splitrule="gini", min.node.size=noftree)
        
        forest = train(target~., data = d,method = "ranger", tuneGrid = myGrid)
        pred_forest= predict(forest, data = d)
        
        cm=confusionMatrix(as.factor(pred_forest), as.factor(d$target))
        
        a2=cm$overall['Accuracy']
        
        
      }
      
      if (model1 == "adaboost"){
        d=d %>% 
          mutate(target = as.character(target))
        library(adabag)
        noftree= input$hp2
        myGrid = expand.grid(mfinal = noftree ,maxdepth=3)
        model <- train(target~.,data = d, method = "AdaBag", tuneGrid = myGrid)
        
        
        pred=predict(model,d)
        
        cm=confusionMatrix(as.factor(pred), as.factor(d$target))
        
        a2=cm$overall['Accuracy']
        
        
        
      }
      return(a2)
      
    })
    
    output$a3 <- renderText({
      inFile = input$f1
      d <- read.csv(inFile$datapath, header = TRUE)
      library(dplyr)
      d=d %>% 
        filter_all(~!is.na(.)) %>% 
        filter_all(~!(.==''))
      v1 = as.character(input$y)
      v2 = as.numeric(input$x)
      d = cbind(d[,v1], d[,v2])
      names(d)[1]='target'
      #print(v2)
      
      
      
      model1=input$modeltype3
      set.seed(2019)
      
      if (model1 == "rpart") { 
        library(caret)
        library(rpart)
        
        max_depth = input$hp3
        library(rpart)
        library(rattle)
        mytree <- rpart(target ~., data = d, method = "class", control = rpart.control(maxdepth = max_depth))
        pred= predict(mytree,d,type="class")
        library(caret)
        cm=confusionMatrix(as.factor(pred),as.factor(d$target))
        a3=cm$overall['Accuracy']
        
        
      }
      
      if (model1=="ranger"){
        library(caret)
        library(ranger)
        
        d=d %>% 
          mutate(target = as.character(target))
        noftree= input$hp3
        
        myGrid = expand.grid(mtry=2, splitrule="gini", min.node.size=noftree)
        
        forest = train(target~., data = d,method = "ranger", tuneGrid = myGrid)
        pred_forest= predict(forest, data = d)
        
        cm=confusionMatrix(as.factor(pred_forest), as.factor(d$target))
        
        a3=cm$overall['Accuracy']
        
        
      }
      
      if (model1 == "adaboost"){
        d=d %>% 
          mutate(target = as.character(target))
        library(adabag)
        noftree= input$hp3
        myGrid = expand.grid(mfinal = noftree ,maxdepth=3)
        model <- train(target~.,data = d, method = "AdaBag", tuneGrid = myGrid)
        
        
        pred=predict(model,d)
        
        cm=confusionMatrix(as.factor(pred), as.factor(d$target))
        
        a3=cm$overall['Accuracy']
        
        
        
      }
      return(a3)
      
    })
    

    
    
    
       observeEvent(input$f1,{ 
      inFile = input$f1
      data <- read.csv(inFile$datapath, header = TRUE)   
      updateSelectInput(session, 'v1', choices = names(data))}
    )
    
    observeEvent(input$f1,{ 
      inFile = input$f1
      data <- read.csv(inFile$datapath, header = TRUE)   
      updateSelectInput(session, 'v2', choices = names(data))}
    )
    
    
    observeEvent(input$f1,{ 
      inFile = input$f1
      data <- read.csv(inFile$datapath, header = TRUE)   
      updateSelectInput(session, 'y', choices = names(data))}
    )
    
    observeEvent(input$f1,{ 
      inFile = input$f1
      data <- read.csv(inFile$datapath, header = TRUE)
      choices = as.list(c(1:ncol(data)))
      names(choices)= names(data)
      updateCheckboxGroupInput(session, 'x', choices = choices)}
    )
    
    observeEvent(input$modeltype1,{ 
      t = input$modeltype1
      if(t=='ranger'){ 
        updateSliderInput(session, 'hp1', label = 'Number of Trees', min=1, max=10, value = 5 )
        
      }
      
      if(t=='rpart'){ 
        updateSliderInput(session, 'hp1', label = 'Max Depth', min=1, max=10, value = 5 )
        
      }
      
      
      if(t=='adaboost'){ 
        updateSliderInput(session, 'hp1', label = 'Number of trees', min=1, max=10, value = 5 )
        
      }
      
    }
    )
    
    observeEvent(input$modeltype2,{ 
      t = input$modeltype2
      if(t=='ranger'){ 
        updateSliderInput(session, 'hp2', label = 'Number of Trees', min=1, max=10, value = 5 )
        
      }
      
      if(t=='rpart'){ 
        updateSliderInput(session, 'hp2', label = 'Max Depth', min=1, max=10, value = 5 )
        
      }
      
      
      if(t=='adaboost'){ 
        updateSliderInput(session, 'hp2', label = 'Number of trees', min=1, max=10, value = 5 )
        
      }
      
    }
    )
    
    observeEvent(input$modeltype3,{ 
      t = input$modeltype3
      if(t=='ranger'){ 
        updateSliderInput(session, 'hp3', label = 'Number of Trees', min=1, max=10, value = 5 )
        
      }
      
      if(t=='rpart'){ 
        updateSliderInput(session, 'hp3', label = 'Max Depth', min=1, max=10, value = 5 )
        
      }
      
      if(t=='adaboost'){ 
        updateSliderInput(session, 'hp3', label = 'Number of trees', min=1, max=10, value = 5 )
        
      }
      
    }
    )
    
    
    
  }
)
