## 9-1 처음 만나는 샤이니
# 샤이니 : R분석 결과를 웹 애플리케이션으로 구현할 수 있는 패키지
install.packages("shiny")
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


