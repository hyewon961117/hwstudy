## 12-1 아파트 가격 상관관계 분석하기
# 데이터 준비하기
load("./06_geodataframe/06_apt_price.rdata")
library(sf)
apt_price <- st_drop_geometry(apt_price)
apt_price$py_area <- round(apt_price$area/3.3,0) # 크기 변환
head(apt_price$py_area)

# 한글 패치
require(showtext)
font_add_google(name="Nanum Gothic", regular.wt=400, bold.wt=700)
showtext_auto()
showtext_opts(dpi=112)

# 사용자 화면 구현하기

library(shiny)

ui <- fluidPage(
  # 제목 설정
  titlePanel("아파트 가격 상관관계 분석"),
  sidebarPanel(
    selectInput(
      inputId="sel_gu",
      label="지역을 선택하세요",
      choices = unique(apt_price$addr_1),
      selected = unique(apt_price$addr_1)[1]),
    sliderInput(
      inputId = "range_py",
      label="평수",
      min=0, max=max(apt_price$py_area),
      value = c(0,30)),
    selectInput(
      inputId = "var_x",
      label = "X축 변수를 선택하시오",
      choices = list(
        "매매가(평당)" = "py",
        "크기(평)" = "py_area",
        "건축 연도" = "con_year",
        "층수" = "floor"),
      selected = "py_area"),
    selectInput(
      inputId = "var_y",
      label = "Y축 변수를 선택하시오",
      choices = list(
        "매매가(평당)" = "py",
        "크기(평)" = "py_area",
        "건축 연도" = "con_year",
        "층수" = "floor"),
      selected = "py"),
    checkboxInput(
      inputId = "corr_checked",
      label = strong("상관 계수"),
      value = TRUE),
    checkboxInput(
      inputId = "reg_checked",
      label = strong("회귀 계수"),
      value = TRUE)),
  mainPanel(
    h4("플로팅"),
    plotOutput("scatterPlot"),
    h4("상관 계수"),
    verbatimTextOutput("corr_coef"),
    h4("회귀 계수"),
    verbatimTextOutput("reg_fit")))


# 서버 구현하기

server <- function(input, output, session){
  apt_sel=reactive({
    apt_sel=subset(apt_price,
                   addr_1 == input$sel_gu &
                     py_area >= input$range_py[1] &
                     py_area <= input$range_py[2])
    return(apt_sel)
  })
  output$scatterPlot <- renderPlot({
    var_name_x <- as.character(input$var_x)
    var_name_y <- as.character(input$var_y)
    plot(
      apt_sel()[, input$var_x],
      apt_sel()[, input$var_y],
      xlab = var_name_x,
      ylab = var_name_y,
      main = "플로팅")
    fit <- lm(apt_sel()[, input$var_y]~apt_sel()[, input$var_x])
    abline(fit, col="red")
  })
  output$corr_coef <- renderText({
    if(input$corr_checked){
      cor(apt_sel()[,input$var_x],
          apt_sel()[,input$var_y])
    }
  })
  output$reg_fit <- renderPrint({
    if(input$reg_checked){
      fit <- lm(apt_sel()[,input$var_y]~apt_sel()[,input$var_x])
      names(fit$coefficients) <- c("Intercept", input$var_x)
      summary(fit)$coefficients
    }
  })
}

shinyApp(ui, server)

#########################################################################
## 12-2 : 여러 지역 상관관계 비교하기

# 데이터 준비하기
load("./06_geodataframe/06_apt_price.rdata")
library(sf)
apt_price <- st_drop_geometry(apt_price)
apt_price$py_area <- round(apt_price$area/3.3,0)
head(apt_price$py_area)

# 사용자 화면 구현하기
library(shiny)
library(ggpmisc)

ui <- fluidPage(
  titlePanel("여러 지역 상관관계 비교"),
  fluidRow(
    column(6,
           selectInput(
             inputId = "region",
             label = "지역을 선택하세요",
             unique(apt_price$addr_1),
             multiple = TRUE)),
    column(6,
           sliderInput(
             inputId = "range_py",
             label = "평수를 선택하세요",
             min = 0, max = max(apt_price$py_area),
             value=c(0,30))),
    column(12, plotOutput(outputId = "gu_Plot", height="600"))))

# 서버 구현하기
server <- function(input, output, session){
  apt_sel = reactive({
    apt_sel = subset(apt_price,
                     addr_1 == unlist(strsplit(paste(input$region, collapse=","),","))&
                       py_area >= input$range_py[1] &
                       py_area <= input$range_py[2])
    return(apt_sel)
  })
    output$gu_Plot <- renderPlot({
      if (nrow(apt_sel()) == 0)
        return(NULL)
      ggplot(apt_sel(), aes(x=py_area, y=py, col="red")) +
        geom_point() + geom_smooth(method="lm", col="blue") + 
        facet_wrap(~addr_1, scale='free_y', ncol=3) +
        theme(legend.position="none") +
        xlab('크기(평)') + ylab('평당 가격(만원)') +
        stat_poly_eq(aes(label = paste(..eq.label..)),
                     label.x = "right", label.y = "top",
                     formula = y~x, parse = TRUE, size = 5, col="black")
    })
}

# 애플리케이션 실행
shinyApp(ui, server)

#########################################################################
## 12-3 : 지진 발생 분석하기
# 데이터 준비하기
load("./01_code/earthquake/earthquake_16_21.rdata")
head(quakes, 2)

# 사용자 화면 구현하기
library(shiny)
library(leaflet)
library(ggplot2)
library(ggpmisc)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%; height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top=10, right=10,
                sliderInput(
                  inputId = "range",
                  label = "진도",
                  min = min(quakes$mag),
                  max = max(quakes$mag),
                  value = range(quakes$mag),
                  step = 0.5
                ),
                sliderInput(
                  inputId = "time",
                  label = "기간",
                  sep = "",
                  min = min(quakes$year),
                  max = max(quakes$year),
                  value = range(quakes$year),
                  step = 1
                ),
                plotOutput("histCentile", height=230),
                plotOutput("depth", height = 230),
                p(span("자료 출처 : 기상청", align = "center",
                       style = "color:black; background-color:white"))
                )
)

# 서버 구현하기
server <- function(input, output, session){
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2] &
             quakes$year >= input$time[1] & quakes$year <= input$time[2],]
  })
  output$map <- renderLeaflet({
    leaflet(quakes) %>% addTiles() %>% 
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat))
  })
  output$histCentile <- renderPlot({
    if (nrow(filteredData())==0)
      return(NULL)
    centileBreaks <- hist(plot = FALSE, filteredData()$mag, breaks = 20)$breaks
    hist(filteredData()$mag,
         breaks = centileBreaks,
         main = "지진 발생 정보", xlab = "진도", ylab = "빈도",
         col = "blue", border="grey")
  })
  output$depth <- renderPlot({
    ggplot(filteredData(), aes(x=mag, y=-depth)) + 
      geom_point(size=3, col="red") +
      geom_smooth(method="lm", col="blue") + 
      xlab("진도") + ylab("깊이") +
      stat_poly_eq(aes(label = paste(..eq.label..)),
                   label.x = "right", label.y = "top",
                   formula = y~x, parse=TRUE, size=5, col="black")
  })
  observe({
    leafletProxy("map", data = filteredData()) %>% clearShapes() %>% 
      addCircles(
        radius = ~log((quakes$mag))^20,
        weight = 1, color = "grey70",
        fillColor = "red", fillOpacity = 0.6, popup=~paste(mag)
      )
  })
  }

# 애플리케이션 실행
shinyApp(ui, server)