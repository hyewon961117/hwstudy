load("06_geodataframe/06_apt_price.rdata")
library(sf)
grid <- st_read("data/seoul/seoul.shp") # 서울시 1km 그리드 불러오기
apt_price <- st_join(apt_price,grid,join=st_intersects)

head(apt_price,2)

# 2단계 그리드 + 평균가격 결합
kde_high <- aggregate(apt_price$py, by=list(apt_price$ID),mean)
head(kde_high, 2)
colnames(kde_high) <- c("ID","avg_price")
head(kde_high,2)

# 3단계 그리드 + 평균가격 결합
kde_high <- merge(grid, kde_high, by="ID")

# 4단계 지도 그리기
library(ggplot2)
library(dplyr)
kde_high %>% ggplot(aes(fill=avg_price))+geom_sf()+scale_fill_gradient(low="white", high="red")

# 5단계 지도의 경계
kde_high_sp <- as(st_geometry(kde_high),'Spatial') #sf형-> sp형 변환 : 지도작업을 수월하게 진행하기 위함

# 그리드 중심 x,y 좌표 추출
x <- coordinates(kde_high_sp)[,1]
y <- coordinates(kde_high_sp)[,2]

# bbox로 l1~l4까지 외곽끝점을 나타는 좌표 4개를 추출하는데 약간의 여유를 주고자 0.1% 를 추가함
l1 <- bbox(kde_high_sp)[1,1] - (bbox(kde_high_sp)[1,1]*0.0001)
l2 <- bbox(kde_high_sp)[1,2] - (bbox(kde_high_sp)[1,2]*0.0001)
l3 <- bbox(kde_high_sp)[2,1] - (bbox(kde_high_sp)[2,1]*0.0001)
l4 <- bbox(kde_high_sp)[2,2] - (bbox(kde_high_sp)[2,2]*0.0001)

# install.packages("spatstat")
library(spatstat)
win <- owin(xrange = c(l1,l2), yrange=c(l3,l4))
plot(win)
