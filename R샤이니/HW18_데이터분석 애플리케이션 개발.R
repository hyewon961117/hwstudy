## 10-1 반응형 지도 만들기

load("./06_geodataframe/06_apt_price.rdata") # 아파트 실거래 데이터
library(sf)
library(sp)
library(raster)
bnd <- st_read("data/sigun_bnd/seoul.shp") # 서울시 경계선
load("./07_map/07_kde_high.rdata") # 최고가 래스터 이미지
load("./07_map/07_kde_hot.rdata") # 급등 지역 래스터 이미지
grid <- st_read("data/seoul/seoul.shp") # 서울시 1km 그리드

# 2단계 마커클러스터링 설정
pcnt_10 <- as.numeric(quantile(apt_price$py, probs=seq(.1,.9,by=.1))[1]) # 하위 10%
pcnt_90 <- as.numeric(quantile(apt_price$py, probs=seq(.1,.9,by=.1))[9]) # 상위 10%
load("./data/circle_marker.rdata")
circle.colors <- sample(x=c("red","green","blue"), size=1000, replace=TRUE)

# 3단계 반응형 지도 만들기
library(leaflet)
library(purrr)
library(raster)
leaflet() %>% 
  # 기본 맵 설정 : 오픈스트리트맵
  addTiles(options = providerTileOptions(minZoom=9,maxZoom=18)) %>% 
  # 최고가 지역 KDE
  addRasterImage(raster_high,
                 colors = colorNumeric(c("blue","green","yellow","red"),
                                       values(raster_high),
                                       na.color="transparent"),
                 opacity=0.4, group="2021 최고가") %>% 
  # 급등 지역 KDE
  addRasterImage(raster_hot,
                 colors = colorNumeric(c("blue","green","yellow","red"),
                                       values(raster_hot),
                                       na.color="transparent"),
                 opacity=0.4, group="2021 급등지") %>% 
  # 레이어 스위치 메뉴
  addLayersControl(baseGroups = c("2021 최고가", "2021 급등지"),
                   options = layersControlOptions(collapsed=FALSE)) %>% 
  # 서울시 외곽 경계선
  addPolygons(data=bnd, weight=3, stroke=T, color="red", fillOpacity = 0) %>% 
  # 마커클러스터링
  addCircleMarkers(data=apt_price, 
                   lng=unlist(map(apt_price$geometry, 1)), 
                   lat=unlist(map(apt_price$geometry,2)), 
                   radius=10, stroke=FALSE, fillOpacity = 0.6, 
                   fillColor = circle.colors, weight=apt_price$py,
                   clusterOptions = markerClusterOptions(iconCreateFunction=JS(avg.formula)))

######################################################################
# 10-2 지도 애플리케이션 만들기

# 1단계 : 그리드 필터링하기
grid <- st_read("data/seoul/seoul.shp")
grid <- as(grid,"Spatial") # sf형을 sp형으로 변환
grid <- as(grid,"sfc") # sp형 데이터 필요한 부분만 자르기위해 변환
grid <- grid[which(sapplt(st_contains(st_sf(grid),apt_price),length)>0)] # st_contains()로 그리드와 아파트를 결합하여 데이터가 포함된(~length)>0) 그리드만 남겨놓기 (필터링)
# 필터링 결과 확인 (그리드 확인)

# 2단계 : 반응형 지도 모듈화하기

m <- leaflet() %>% 
  # 기본 맵 설정 : 오픈스트리트맵
  addTiles(options = providerTileOptions(minZoom=9,maxZoom=18)) %>% 
  # 최고가 지역 KDE
  addRasterImage(raster_high,
                 colors = colorNumeric(c("blue","green","yellow","red"),
                                       values(raster_high),
                                       na.color="transparent"),
                 opacity=0.4, group="2021 최고가") %>% 
  # 급등 지역 KDE
  addRasterImage(raster_hot,
                 colors = colorNumeric(c("blue","green","yellow","red"),
                                       values(raster_hot),
                                       na.color="transparent"),
                 opacity=0.4, group="2021 급등지") %>% 
  # 레이어 스위치 메뉴
  addLayersControl(baseGroups = c("2021 최고가", "2021 급등지"),
                   options = layersControlOptions(collapsed=FALSE)) %>% 
  # 서울시 외곽 경계선
  addPolygons(data=bnd, weight=3, stroke=T, color="red", fillOpacity = 0) %>% 
  # 마커클러스터링
  addCircleMarkers(data=apt_price, 
                   lng=unlist(map(apt_price$geometry, 1)), 
                   lat=unlist(map(apt_price$geometry,2)), 
                   radius=10, stroke=FALSE, fillOpacity = 0.6, 
                   fillColor = circle.colors, weight=apt_price$py,
                   clusterOptions = markerClusterOptions(iconCreateFunction=JS(avg.formula))) %>% 
  # 앞절 코드에서 추가되는 부분
  # 그리드 지도 레이어 추가
  leafem::addFeatures(st_sf(grid),layerId=~seq_len(length(grid)),color='grey')

# 지도 확인
m

# 3단계 : 애플리케이션 구현하기
# 샤이니에서 구현하기

# mapedit 패키지 : 자바스크립트 뿐만 아니라 HTML 같은 웹 프로그래밍 기술을 활용하여 더 복잡한 지도 기반 애플리케이션을 구현할 수 있도록 도와줌
# mapedit 패키지는 지도의 특정 지점을 선택하거나 처리하는 라이브러리 제공
# selectModUI() : 지도 입력 모듈, 지도에서 특정 지점이 선택될 때 입력값을 서버로 전달
# callModule():입력 결과를 처리하여 다시 화면으로 전달하는 출력 모듈

# install.packages("mapedit")
library(mapedit)
library(dplyr)

ui <- fluidPage(
  selectModUI("selectmap"), "선택은 할 수 있지만 아무 반응이 없음")

server <- function(input, output){
  callModule(selectMod, "selectmap", m)}

shinyApp(ui, server)

# 4단계 : 반응식 추가하기

ui <- fluidPage(
  selectModUI("selectmap"),
  textOutput("sel"))

server <- function(input, output, session){
  df <- callModule(selectMod, "selectmap", m)
  output$sel <- renderPrint({df()[1]})}

shinyApp(ui, server)

########################################################################
## 10-3 반응형 지도 애플리케이션 완성하기

# 1단계 : 사용자 인터페이스 설정하기
library(DT)
ui <- fluidPage(
  # 상단 화면 : 지도 + 입력 슬라이더
  fluidRow(
    column(9,selectModUI("selectmap"), div(style="height:45px")),
    column(3,
           sliderInput("range_area","전용면적",sep="",min=0, max=350, value=c(0,200)),
           sliderInput("range_time","건축 연도", sep="", min=1960, max=2020, value=c(1980,2020)),),
    # 하단 화면 : 테이블 출력
    column(12,dataTableOutput(outputId = "table"), 
           div(style="height:200px"))))

# ui()로 시작하면서 flluidPage()로 단일 페이지 화면 시작
# 화면을 그리드형으로 배치하는 fluidRow() 추가하고 세 영역으로 구분
# 화면 위쪽에는 지도를 나타내는 selectModUI()와
# 사용자가 전용면적, 건축 연도를 입력할 수 있도록 sliderInput() 배치
# 아래쪽에는 dataTableOutput()으로 데이터 테이블에 배치
# 최소 면적 input$range_area[1] ; 최대 면적 input$range_area[2]
# 최소 연도 input$range_time[1] ; 최대 면적 input$range_time[2]
# 슬라이더로 입력한 정보는 server의 reactive() 함수로 전달된 다음 조건에 따라 필터링된 데이터가 dataTableOutput()에 출력됨

# 2단계 : 반응식 설정하기
server <- function(input, output, session){
  # 반응식
  apt_sel = reactive({
    apt_sel = subset(apt_price, con_year >= input$range_time[1]&
                       con_year <=input$range_time[2] & 
                       area >= input$range_area[1]&
                       area <=input$range_area[2])
    return(apt_sel)})
  
  # 3단계 : 지도 입출력 모듈 설정하기 (m 부분 넣기)
  g_sel <- callModule(selectMod, 'selectmap',
                      leaflet() %>% 
                        # 기본 맵 설정 : 오픈스트리트맵
                        addTiles(options = providerTileOptions(minZoom=9,maxZoom=18)) %>% 
                        # 최고가 지역 KDE
                        addRasterImage(raster_high,
                                       colors = colorNumeric(c("blue","green","yellow","red"),
                                                             values(raster_high),
                                                             na.color="transparent"),
                                       opacity=0.4, group="2021 최고가") %>% 
                        # 급등 지역 KDE
                        addRasterImage(raster_hot,
                                       colors = colorNumeric(c("blue","green","yellow","red"),
                                                             values(raster_hot),
                                                             na.color="transparent"),
                                       opacity=0.4, group="2021 급등지") %>% 
                        # 레이어 스위치 메뉴
                        addLayersControl(baseGroups = c("2021 최고가", "2021 급등지"),
                                         options = layersControlOptions(collapsed=FALSE)) %>% 
                        # 서울시 외곽 경계선
                        addPolygons(data=bnd, weight=3, stroke=T, color="red", fillOpacity = 0) %>% 
                        # 마커클러스터링
                        addCircleMarkers(data=apt_price, 
                                         lng=unlist(map(apt_price$geometry, 1)), 
                                         lat=unlist(map(apt_price$geometry,2)), 
                                         radius=10, stroke=FALSE, fillOpacity = 0.6, 
                                         fillColor = circle.colors, weight=apt_price$py,
                                         clusterOptions = markerClusterOptions(iconCreateFunction=JS(avg.formula))) %>% 
                        # 앞절 코드에서 추가되는 부분
                        # 그리드 지도 레이어 추가
                        leafem::addFeatures(st_sf(grid),layerId=~seq_len(length(grid)),color='grey'))
  
  # 4단계 :  선택에 따른 반응 결과 저장하기
  # 반응 초기값 설정(NULL)
  rv <- reactiveValues(intersect=NULL, selectgrid=NULL)
  # 반응 결과 (rv : reactive value 저장)
  observe({
    gs <- g_sel()
    rv$selectgrid <- st_sf(grid[as.numeric(gs[which(gs$selected==TRUE), "id"])])
    if(length(rv$selectgrid)>0){
      rv$intersect <- st_intersects(rv$selectgrid, apt_sel())
      rv$sel <- st_drop_geometry(apt_price[apt_price[unlist(rv$intersect[1:10]),],])
    } else {
        rv$intersect <- NULL
      }
  })
  # 5단계 : 반응 결과 렌더링
  output$table <- DT::renderDataTable({
    dplyr::select(rv$sel, ymd, addr_1, apt_nm, price, area, floor, py) %>% 
      arrange(desc(py))},extensions='Buttons', options=list(dom="Bfrtip", scrollY=300, scrollCollapse=T, paging=TRUE, buttons=c('excel')))}

# 6단계 : 애플리케이션 실행하기
shinyApp(ui,server)
  