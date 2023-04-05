## 9-1 처음 만나는 샤이니
# 샤이니 : R분석 결과를 웹 애플리케이션으로 구현할 수 있는 패키지
# install.packages("shiny")
library(shiny)

# 사용자 인터페이스, 서버, 실행이라는 구성요소를 작성함으로써 웹 애플리케이션을 만듦
# ui() :사용자에게 보이는 화면으로 데이터 입력과 분석 결과 출력을 담당
# server() : 입력 결과를 처리한 다음 다시 ui()로 보냄
# shinyApp() : 애플리케이션 실행

ui <- fluidPage("사용자 인터페이스")
server <- function(input, output, session){} # 정의하지 않아 반응X
shinyApp(ui, server)

# 샤이니 샘플 확인
runExample() # 11가지 샘플을 제공
runExample("01_hello") # 첫번째 샘플 실행

# 샤이니가 제공하는 1번 샘플의 데이터 : 올드 페이스풀 간헐천 관측 자료
faithful <- faithful
head(faithful, 2)

# 사용자 인터페이스 부분
ui <- fluidPage( # 사용자 인터페이스 시작 : fluidPage 정의
  titlePanel("샤이니 1번 샘플"), # 제목 입력
  # 레이아웃 구성 : 사이드바 패널 + 페인 패벌
  sidebarLayout(
    sidebarPanel( # 사이드바 패널 시작
      # 입력값 : input$bins 저장
      sliderInput(inputId = "bins", # 입력 아이디
                  label="막대(bin) 개수:", # 텍스트 라벨
                  min=1, max=50, # 선택 범위(1-50)
                  value=30)), # 기본값 30
    mainPanel( # 메일 패널 시작
      # 출력값 : output$distplot 저장
      plotOutput(outputId = "distPlot")) # 차트 출력
  ))

# 서버부분
server <- function(input,output, session){
  #랜더링한 플롯을 output 인자의 distPlot에 저장
  output$distPlot <- renderPlot({
    x <- faithful$waiting # 분출 대기 시간 정보 저장
    # input$ㅠbins을 플롯으로 렌더링
    bins <- seq(min(x),max(x),length.out=input$bins +1)
    # 히스토그램 그리기
    hist(x, breaks=bins, col='#75AADB', border="white", xlab="다음 분출 때까지 대기 시간(분)", main="대기 시간 히스토그램")
  })
}

# 실행
shinyApp(ui, server)
rm(list=ls()) # 메모리 정리

#######################################################################
## 9-2 입력과 출력하기

# 입력받기
# 슬라이더를 표시하는 예
ui <- fluidPage(
  sliderInput("range","연비",min=0, max=35,value=c(0,10))) # 데이터 입력

server <- function(input, output, session) {} # 정의하지 않아 반응 없음
shinyApp(ui, server)

# server() 출력함수를 정의하지 않아 슬라이더를 조작해도 아무런 변화가 없음

# 출력하기 
# 슬라이더 조작시 그 아래 두 값을 더한 값이 출력됨

ui <- fluidPage(
  sliderInput("range","연비",min=0, max=35,value=c(0,10)), textOutput("value")) # 데이터 입력
#textOutput("value") : 결과값 출력

server <- function(input, output, session) {
  output$value <- renderText((input$range[1]+input$range[2]))} # 입력값 계산
shinyApp(ui, server)

########################################################################
## 9-3 반응형 휍 애플리케이션 만들기
# 반응성 : ui()입력값인 input$~ 이 변경될 때 server()가 자동으로 변화를 감지하여 출력값 output$~을 렌더링 후 갱신하는 것을 말함
# 입력 슬라이더 범위가 바뀔 때마다 출력 테이블이 달라지는 샤이니 애플리케이션 만들기

# 데이터 준비
# 데이터 테이블을 편리하게 다룰 수 있는 DT 패키지
# install.packages("DT")
library(DT)
library(ggplot2)
mpg <- mpg
head(mpg,2)
# datatable(iris)

# 시내 연비를 기준으로 필터링된 데이터 테이블을 보여 주는 애플리케이션 만들기

ui <- fluidPage(
  sliderInput("range","연비",min=0,max=35,value=c(0,10)), # 데이터 입력
  DT::dataTableOutput("table")) # 출력

server <- function(input, output, session){
  # 반응식
  cty_sel=reactive({
    cty_sel = subset(mpg, cty >= input$range[1] & cty <=input$range[2])
    return(cty_sel)})
  # 반응 결과 렌더링
  output$table <- DT::renderDataTable(cty_sel())}

shinyApp(ui,server)

# ui() 단일 페이지 화면 정의
# sliderInput() 자동차 연비의 범위를 입력하는 슬라이드를 만듦
# 입력된 데이터는 input$range에 저장되며 server()로 전달됨
# 사용자 입력에 따라 반응(결과를 필터링)하도록 reactive() 반응식 시작
# subset() cty(시내연비)가 조건문에 해당하는 행을 추출한 다음 return()으로 cty_sel 이라는 반응식을 저장
# 이를 데이터 테이블로 출력하고 renderDataTable()로 전달하여 outpuy$table에 저장
# server()내에서 반응식 결과(cty_sel)를 사용할때는 뒤에 호출 연산자()를 붙여야함

#####################################################################
## 9-4 레이아웃 정의하기
# 레이아웃 :제한된 공간 안에 문자, 그림, 기호, 사진 같은 구성 요소를ㄹ 효과적으로 배치하는것을 말함
# 샤이니에서 레이아웃 : 제한된 화면 안에 입력 위젯과 출력 결과를 배치하는 방식을 의미 (일반적으로 그리드라 불리는 규격화된 레이아웃을 선호)
# 그리드 방식 사용하려면 ui()에서 fluidPage()->fluidRow()->column() 순서로 화면 정의하면 됨

# 하나의 페이지에 다양한 위젯이나 차트 등을 효과적으로 배치할 수 있는 단일 페이지 레이아웃 만들기

# 1단계 : 단일 페이지 레이아웃

ui <- fluidPage(
  fluidRow(
    # 첫번째 열 : 빨강(red) 박스로 높이 450 픽셀, 폭 9
    column(9,div(style="height:450px;border:4px solid red;","폭 9")),
    # 두번째 열 : 보라(purple) 박스로 높이 450 픽셀, 폭 3
    column(3,div(style="height:450px;border:4px solid purple;","폭 3")),
    # 세번째 열 : 파랑(blue) 박스로 높이 400 픽셀, 폭 12
    column(12,div(style="height:400px;border:4px solid blue;","폭 12"))))

server <- function(input, output, session){}
shinyApp(ui, server)

# ui() 다음에 fluidPage()로 단일 페이지 화면 시작
# 그리드형 배치를 사용하고자 fluidRow()를 추가
# column()을 이용하여 화면의 배치를 설정 (최대 폭 12)

# 2단계 : 탭 페이지 추가하기
# 사이드바나 탭 같은 화면 확장 방법들을 활용 할 수 있음

ui <- fluidPage(
  fluidRow(
    column(9,div(style="height:450px;border:4px solid red;","폭 9")),
    column(3,div(style="height:450px;border:4px solid red;","폭 3")),
    # 탭 패널 1~2번 추가
    tabsetPanel(
      tabPanel("탭1",
               column(4,div(style="height:300px;border:4px solid red;","폭 4")),
               column(4,div(style="height:300px;border:4px solid red;","폭 4")),
               column(4,div(style="height:300px;border:4px solid red;","폭 4"))),
      tabPanel("탭2", div(style="height:300px;border:4px solid blue;","폭 12")))))

server <- function(input, output, session){}
shinyApp(ui, server)              

