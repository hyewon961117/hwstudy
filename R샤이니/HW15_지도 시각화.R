## 7-1 어느 지역이 제일 비쌀까?

load("06_geodataframe/06_apt_price.rdata")
library(sf)
library(sp)

# 지역별 평균 가격 구하기
# 어느 지역이 제일 비싼지 알려면 먼저 그리드별 평균 가격을 계산해야함
grid <- st_read("data/seoul/seoul.shp") # 서울시 1km 그리드 불러오기
apt_price <- st_join(apt_price,grid,join=st_intersects) # 실거래 + 그리드 결합

head(apt_price,2)

# 2단계 그리드 + 평균가격 결합
# 그리드 별 평균 가격
kde_high <- aggregate(apt_price$py, by=list(apt_price$ID),mean)
head(kde_high, 2)
colnames(kde_high) <- c("ID","avg_price") # 컬럼명 변경
head(kde_high,2) # 평균가 확인

# 3단계 그리드 + 평균가격 결합
kde_high <- merge(grid, kde_high, by="ID")

# 4단계 지도 그리기
library(ggplot2)
library(dplyr)
kde_high %>% ggplot(aes(fill=avg_price))+geom_sf()+scale_fill_gradient(low="white", high="red") # 그래프 시각화

# 5단계 지도의 경계
# 어느 지역이 제일 비싼지 알려면 데이터가 집중된 곳을 찾아야함
# 커널 밀도 추정을 이용 (대상 영역 설정 필요)

kde_high_sp <- as(st_geometry(kde_high),'Spatial') #sf형-> sp형 변환 : 지도작업을 수월하게 진행하기 위함

# 그리드 중심 x,y 좌표 추출
x <- coordinates(kde_high_sp)[,1]
y <- coordinates(kde_high_sp)[,2]

# bbox로 l1~l4까지 외곽끝점을 나타는 좌표 4개를 추출하는데 약간의 여유를 주고자 0.1% 를 추가함
l1 <- bbox(kde_high_sp)[1,1] - (bbox(kde_high_sp)[1,1]*0.0001)
l2 <- bbox(kde_high_sp)[1,2] + (bbox(kde_high_sp)[1,2]*0.0001)
l3 <- bbox(kde_high_sp)[2,1] - (bbox(kde_high_sp)[2,1]*0.0001)
l4 <- bbox(kde_high_sp)[2,2] + (bbox(kde_high_sp)[2,2]*0.0001)

# install.packages("spatstat")
library(spatstat)
win <- owin(xrange = c(l1,l2), yrange=c(l3,l4)) # 외곽 좌표를 연결하는 지도 경계선 생성
plot(win) # 지도 경계선 확인

# 필요 없는 변수 제거
rm(list = c("kde_high_sp","apt_price","l1","l2","l3","l4"))

# 6단계 밀도 그래프 표시
# 커널 밀도 추정을 할 때는 지도 경계선(win) 내의 포인트 분포 데이터로 커널 밀도를 계산해야함
p <- ppp(x,y,window=win) # 경계선 위에 좌푯값 포인트 생성
# ppp함수는 위도와 경도(x,y)를 포인트로 변환함
d <- density.ppp(p, weights = kde_high$avg_price, sigma=bw.diggle(p), kernel='gaussian') # 커널 밀도 함수로 변환 (kde_high$avg_price 가중치)
plot(d) # 밀도 그래프 확인

rm(list=c("x","y","win","p")) # 변수 정리

# 7단계 픽셀이미지를 레스터 이미지로 변환
# 최종 결과물 도출하기 전에 의미 없는 노이즈를 제거하고 중요한 신호를 찾아내는 작업을 수행해야함
# 커널 밀도 데이터를 래스터 이미지로 변환한 후 노이즈가 제거된 결과 확인
d[d<quantile(d)[4] + (quantile(d)[4]*0.1)] <- NA # 노이즈 제거(전체 하위 75% NA 처리)

# install.packages("raster")
library(raster)
raster_high <- raster(d) # 래스터 변환
plot(raster_high)

# 8단계 클리핑
# 서울시 경계선을 기준으로 외곽의 불필요한 부분을 잘라내는 과정
bnd <- st_read("data/sigun_bnd/seoul.shp") # 서울시 경계선 불러오기
raster_high <- crop(raster_high,extent(bnd)) # 외곽선 자르기
crs(raster_high) <- sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") # 좌표계를 정의
plot(raster_high) # 지도 확인
plot(bnd, col=NA, border = 'red', add=TRUE)

# 9단계 지도그리기
# install.packages("rgdal")
library(rgdal) # 지리 공간 정보를 가지는 레스터 데이터 처리 라아브러리
library(leaflet)

# 지도 위에 래스터 이미지 올리기
leaflet() %>% 
  # 기본 지도 불러오기
  addProviderTiles(providers$CartoDB.Positron) %>%
  # 서울시 경계선 불러오기
  addPolygons(data=bnd, weight=3, color="red", fill=NA) %>%
  # 래스터 이미지 불러오기
  addRasterImage(raster_high, colors=colorNumeric(c("blue","green","yellow","red"), values(raster_high), na.color="transparent"),opacity=0.4)

# 이미지 저장
dir.create('07_map')
save(raster_high, file = "./07_map/07_kde_high.rdata") # 최고가 래스터 저장
rm(list=ls()) # 메모리 정리 (모든 변수 제거, 빗자루 모양)

######################################################################
## 7-2 요즘 뜨는 지역은 어디일까?
# 일정 기간 동안 가장 많이 오른 지역을 특정하는 것

load("./06_geodataframe/06_apt_price.rdata")
grid <- st_read("data/seoul/seoul.shp") # 서울시 1km 격자 불러오기
apt_price <- st_join(apt_price, grid, join=st_intersects) # 실거래+그리드 결합
head(apt_price,2)

kde_before <- subset(apt_price, ymd<"2021-07-01") # 이전 데이터 필터링
kde_before <- aggregate(kde_before$py, by=list(kde_before$ID),mean) # 전반기 ID별 가격 평균 집계
colnames(kde_before) <- c("ID","before") # 컬럼명 변경

kde_after <- subset(apt_price, ymd>="2021-07-01") # 이후 데이터 필터링
kde_after <- aggregate(kde_after$py, by=list(kde_after$ID),mean) # 전반기 ID별 가격 평균 집계
colnames(kde_after) <- c("ID","after") # 컬럼명 변경

head(kde_before,2)
head(kde_after,2)

kde_diff <- merge(kde_before, kde_after, by="ID")
kde_diff$diff <- round((((kde_diff$after - kde_diff$before)/kde_diff$before)*100),0) # 증가율
head(kde_diff, 2)

library(sf)
kde_diff <- kde_diff[kde_diff$diff>0,] # 상승 지역만 추출
kde_hot <- merge(grid, kde_diff, by="ID") # 그리드에 상승 지역 결합

# 4단계 지도 그리기
library(ggplot2)
library(dplyr)
kde_hot %>% ggplot(aes(fill=diff))+geom_sf()+scale_fill_gradient(low="white",high="red") # 그래프 시각화
# 색이 진할수록 가격이 많이 오른 지역, 흰색은 가격 정보가 아예 없거나 하락한 지역

# 5단계 지도의 경계
# 커널 밀도 추정을 이용 (대상 영역 설정 필요)

kde_hot_sp <- as(st_geometry(kde_hot),'Spatial') #sf형-> sp형 변환 : 지도작업을 수월하게 진행하기 위함

# 그리드 중심 x,y 좌표 추출
x <- coordinates(kde_hot_sp)[,1]
y <- coordinates(kde_hot_sp)[,2]

# bbox로 l1~l4까지 외곽끝점을 나타는 좌표 4개를 추출하는데 약간의 여유를 주고자 0.1% 를 추가함
l1 <- bbox(kde_hot_sp)[1,1] - (bbox(kde_hot_sp)[1,1]*0.0001)
l2 <- bbox(kde_hot_sp)[1,2] + (bbox(kde_hot_sp)[1,2]*0.0001)
l3 <- bbox(kde_hot_sp)[2,1] - (bbox(kde_hot_sp)[2,1]*0.0001)
l4 <- bbox(kde_hot_sp)[2,2] + (bbox(kde_hot_sp)[2,2]*0.0001)

# install.packages("spatstat")
library(spatstat)
win <- owin(xrange = c(l1,l2), yrange=c(l3,l4)) # 외곽 좌표를 연결하는 지도 경계선 생성
plot(win) # 지도 경계선 확인

# 필요 없는 변수 제거
rm(list = c("kde_hot_sp","kde_diff","l1","l2","l3","l4"))

# 6단계 밀도 그래프 표시
# 커널 밀도 추정을 할 때는 지도 경계선(win) 내의 포인트 분포 데이터로 커널 밀도를 계산해야함
p <- ppp(x,y,window=win) # 경계선 위에 좌푯값 포인트 생성
# ppp함수는 위도와 경도(x,y)를 포인트로 변환함
d <- density.ppp(p, weights = kde_hot$diff, sigma=bw.diggle(p), kernel='gaussian') # 커널 밀도 함수로 변환 (kde_high$avg_price 가중치)
plot(d) # 밀도 그래프 확인

rm(list=c("x","y","win","p")) # 변수 정리

# 7단계 픽셀이미지를 레스터 이미지로 변환
# 최종 결과물 도출하기 전에 의미 없는 노이즈를 제거하고 중요한 신호를 찾아내는 작업을 수행해야함
# 커널 밀도 데이터를 래스터 이미지로 변환한 후 노이즈가 제거된 결과 확인
d[d<quantile(d)[4] + (quantile(d)[4]*0.1)] <- NA # 노이즈 제거(전체 하위 75% NA 처리)

# install.packages("raster")
library(raster)
raster_hot <- raster(d) # 래스터 변환
plot(raster_hot)

# 8단계 클리핑
# 서울시 경계선을 기준으로 외곽의 불필요한 부분을 잘라내는 과정
bnd <- st_read("data/sigun_bnd/seoul.shp") # 서울시 경계선 불러오기
raster_hot <- crop(raster_hot,extent(bnd)) # 외곽선 자르기
crs(raster_hot) <- sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") # 좌표계를 정의
plot(raster_hot) # 지도 확인
plot(bnd, col=NA, border = 'red', add=TRUE)

# 9단계 지도그리기
# install.packages("rgdal")
library(rgdal) # 지리 공간 정보를 가지는 레스터 데이터 처리 라아브러리
library(leaflet)

# 지도 위에 래스터 이미지 올리기
leaflet() %>% 
  # 기본 지도 불러오기
  addProviderTiles(providers$CartoDB.Positron) %>%
  # 서울시 경계선 불러오기
  addPolygons(data=bnd, weight=3, color="red", fill=NA) %>%
  # 래스터 이미지 불러오기
  addRasterImage(raster_hot, colors=colorNumeric(c("blue","green","yellow","red"), values(raster_hot), na.color="transparent"),opacity=0.4)

save(raster_hot, file="./07_map/07_kde_hot.rdata")

######################################################################
## 7-3 우리 동네가 옆 동네보다 비쌀까?

# 평당 실거래가 평균을 직접 지도 위에 표시해야함
# 서로 겹쳐서 정보를 명확하게 전달 할 수 없는데 지도에 표시할 데이터를 적절하게 조절해주기
# 여러 데이터를 그룹화하여 대푯값 하나로 만들어주기
# 마커 클러스터링 : 지도에 표시되는 마커가 너무 많을 때 특정한 기준으로 마커들을 하나의 무리로 묶어주는 방법
rm(list=ls())

# 1단계 데이터 준비
load("./06_geodataframe/06_apt_price.rdata")
load("./07_map/07_kde_high.rdata")
load("./07_map/07_kde_hot.rdata")

library(sf)
bnd <- st_read("data/sigun_bnd/seoul.shp")
grid <- st_read("data/seoul/seoul.shp")

# 마커 클러스터링 옵션 설정

# 이상치 설정 (평당 가격의 하위10%, 상위 90%)
pcnt_10 <- as.numeric(quantile(apt_price$py,probs=seq(.1,.9,by=.1))[1])
pcnt_90 <- as.numeric(quantile(apt_price$py,probs=seq(.1,.9,by=.1))[9])

# 마커 클러스터링 함수 등록
load("./data/circle_marker.rdata")

# 마커 클러스터링 색상 설정 : 상(r), 중(g), 하(b)
# 가장 낮은 지점 10% 초록색, 중간 10%이상에서 90%까지는 노란색, 상위 10%는 주황색으로 표현하도록 설정
circle.colors <- sample(x=c("red","green","blue"), size=1000, replace=TRUE)

# 마커 클러스터링 시각화
# leaflet()으로 나타낸 지도에 addCircleMarker()로 avg.formula라는 마커 클러스터링 기능을 추가

library(purrr)
leaflet() %>% 
  # 오픈스트리트맵 불러오기
  addTiles() %>% 
  # 서울시 경계선 불러오기
  addPolygons(data=bnd, weight=3, color="red",fill=NA) %>% 
  # 최고가 래스터 이미지 불러오기
  addRasterImage(raster_high,
                 colors=colorNumeric(c("blue","green","yellow","red"),
                                     values(raster_high), 
                                     na.color="transparent"),
                 opacity=0.4, group="2021 최고가") %>% 
  # 급등지 래스터 이미지 불러오기
  addRasterImage(raster_hot,
                 colors=colorNumeric(c("blue","green","yellow","red"),
                                     values(raster_hot), 
                                     na.color="transparent"),
                 opacity=0.4, group="2021 급등지") %>% 
  #최고가/급등지 선택 옵션 추가하기
  addLayersControl(baseGroups= c("2021 최고가","2021 급등지"), 
                   options = layersControlOptions(collapsed=FALSE)) %>% 
  # 마커 클러스터링 불러오기
  addCircleMarkers(data=apt_price, 
                   lng=unlist(map(apt_price$geometry,1)),
                   lat=unlist(map(apt_price$geometry,2)),
                   radius=10, stroke = FALSE, fillOpacity = 0.6, 
                   fillColor = circle.colors, weight=apt_price$py,
                   clusterOptions = markerClusterOptions(iconCreateFunction=JS(avg.formula)))













