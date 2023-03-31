# 단계 구분도
install.packages("mapproj")
install.packages("ggiraphExtra")
library(ggiraphExtra)
str(USArrests)
head(USArrests)

library(tibble) # dplyr과 함께 설치됨
crime <- rownames_to_column(USArrests, var='state')
crime$state <- tolower(crime$state)
str(crime)

install.packages("maps") # 미국 위도경도 정보가 있는 패키지
library(ggplot2)
state_map <- map_data("state")
str(state_map)

ggChoropleth(data=crime, 
             aes(fill=Murder,   # 색깔로 표현할 변수
                 map_id=state), # 지역기준 변수
             map=state_map,     # 지도 데이터
             interactive=T)     # 인터랙티브

# 11-2 대한민국 시도별 인구 결핵환자
install.packages('stringi')
install.packages('devtools')
devtools::install_github("cardiomoon/kormaps2014")
library(kormaps2014)
str(changeCode(korpop1))

library(dplyr)
korpop1 <- rename(korpop1, pop=총인구_명, name=행정구역별_읍면동)

# 지역명이 깨지지 않도록 인코딩
korpop1$name <- iconv(korpop1$name,"UTF-8","CP949")
str(changeCode(kormap1))

library(ggiraphExtra)
ggChoropleth(data=korpop1, aes(fill=pop, map_id=code, tooltip=name),
             map = kormap1, interactive=T)

# 결핵환자 수 데이터
str(changeCode(tbc))
tbc$name <- iconv(tbc$name, "UTF-8","CP949")

# 12장 - 인터랙티브 그래프
install.packages("plotly")
library(plotly)
library(ggplot2)
ggplot(data=mpg,aes(x=displ, y=hwy, col=drv))+geom_point()

p <- ggplot(data=mpg,aes(x=displ, y=hwy, col=drv))+geom_point()
ggplotly(p)

# bar 그래프
d <- ggplot(data=diamonds, aes(x=cut,fill=clarity))+geom_bar(position="Dodge")
ggplotly(d)

# 시계열 그래프
install.packages("dygraphs")
library(dygraphs)
eco <- ggplot2::economics
head(eco)
library(xts) # 데이터를 xts타입으로 변경하기 위함
eco1 <- xts(eco$unemploy,order.by=eco$date)
dygraph(eco1)

# 날짜 범위 선택 기능
dygraph(eco1) %>% dyRangeSelector()

# 저축률
eco_a <- xts(eco$psavert, order.by=eco$date)
# 실업자수
eco_b <- xts(eco$unemploy/1000,order.by=eco$date)

# 두 데이터 가로로 결합
eco2 <- cbind(eco_a,eco_b)

# 컬럼명 바꾸기
# rename은 데이터프레임에서만 사용
# xts타입에서 rename 사용 불가능
colnames(eco2) <- c("psavert","unemploy")
head(eco2)

# 그래프 그리기
dygraph(eco2) %>% dyRangeSelector()
