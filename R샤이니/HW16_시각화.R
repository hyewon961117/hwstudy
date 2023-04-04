## 8-1 관심 지역 데이터만 추출하기

library(raster)
library(sp)
library(sf)
load("06_geodataframe/06_apt_price.rdata") # 실거래 데이터
load("07_map/07_kde_high.rdata") # 최고가 래스터 이미지
grid <- st_read("data/seoul/seoul.shp") # 서울시 그리드

# 서울에서 가장 비싼 지역을 쉽게 찾을 수 있도록 지도로 시각화
# install.packages("tmap")
library(tmap) # 지도 위에 라벨값을 표현할때 leaflet보다 편리
tmap_mode("view") # tmap 사용시 기본 모드를 view로 설정해 주어야함
tm_shape(grid)+tm_borders()+tm_text("ID",col="red") +
  # 래스터 이미지 그리기
  tm_shape(raster_high)+
  # 래스터 이미지 색상 패턴 설정
  tm_raster(palette=c("blue","green","yellow","red"),alpha=.4)+
  # 기본 지도 설정
  tm_basemap(server=c('OpenStreetMap'))
# tm_borders() : 경계선 추가
# tm_text() : 지도 위에 표현할 텍스트를 설정하는 옵션
# tm_raster() : 최고가 레스터 이미지를 그리는데 색상 패턴은 4단계로 설정, alpha 값으로 지도에 표현할 그리드 파일의 투명도 설정
# tm_basemap() : 기본(배경) 지도를 설정

# 전체지역 / 관심지역 저장
# 아파트 실거래 정보가 어떤 그리드에 속하는지 매칭하고자 공간 결합
library(dplyr)
apt_price <- st_join(apt_price, grid, join=st_intersects) # 실거래 + 그리드 결합
apt_price <- apt_price %>% st_drop_geometry() # 실거래에서 공간 속성 지우기 (좌푯값 속성을 지워 일반 데이터프레임으로 변환하기)
all <- apt_price # 전체 지역 추출
sel <- apt_price %>% filter(ID==81016) # 관심지역 추출

dir.create("08_chart")
save(all, file="./08_chart/all.rdata")
save(sel, file="./08_chart/sel.rdata")
rm(list =ls())

#####################################################################
## 8-2 확률 밀도 함수 : 이 지역 아파트는 비싼 편일까?
# 히스토그램 : 데이터가 어떻게 분포되었는지 살펴보는 가장 일반적인 방법
# 히스토그램은 구간의 너비를 어떻게 잡는지에 따라 전혀 다른 모양이 될 수 있다는 한계가 있음
# 확률 밀도 함수를 이용하여 커널 밀도 추정으로 데이터 왜곡 문제를 해결
# 확률 밀도 함수 : 구간을 가정하지 않고 모든 데이터의 상대적인 위치를 추정

load("./08_chart/all.rdata") # 전체 지역
load("./08_chart/sel.rdata") # 관심 지역

# density() 함수로 각각의 데이터 분포를 확률 밀도 분포로 변환
max_all <- density(all$py)
max_sel <- density(sel$py)
max_all ; max_sel

# max()로 가장 큰 값을 찾기
max_all <- max(max_all$y)
max_sel <- max(max_sel$y)
max_all ; max_sel

# 서울시 전체와 관심 지역의 y축 가운데 최대값을 찾아서 그래프의 최대 y값으로 입력
plot_high <- max(max_all, max_sel) # y축 최대값 찾기

# 메모리 절약을 위한 필요 없는 변수 제거
rm(list=c("max_all","max_sel"))

# mean()으로 관심 지역과 서울시 전체의 아파트 평당 평균 가격을 산출
avg_all <- mean(all$py)
avg_sel <- mean(sel$py)
avg_all ; avg_sel ; plot_high

# 확률 밀도함수 그리기
# col= 색상 , lwd= 두께, lty=2 타입 파선

# 전체 지역 밀도 함수 띄우기
plot(stats::density(all$py),ylim=c(0,plot_high), col="blue",lwd=3, main=NA)
# 전체 지역 평균 수직선 그리기
abline(v=mean(all$py),lwd=2, col="blue",lty=2)
# 전체 지역 평균 텍스트 입력
text(avg_all +(avg_all)*0.15, plot_high*0.1, sprintf("%.0f",avg_all),srt=0.2,col="blue")

# 관심 지역 확률 밀도 함수 띄우기
lines(stats::density(sel$py),col="red",lwd=3)
# 관심 지역 평균 수직선 그리기
abline(v=avg_sel, lwd=2, col="red", lty=2)
# 관심 지역 평균 텍스트 입력
text(avg_sel + avg_sel*0.15, plot_high*0.1, sprintf("%.0f",avg_sel, srt=0.2, col="red"))

########################################################################
## 8-3 회귀분석 : 이 지역은 일년에 얼마나 오를까?
# 확률 밀도 함수는 현재 상황을 직관적으로 보여줄 뿐 과거와 미래의 변화에 대한 정보까지는 제공하지 않음
# 과거와 미래의 변화를 살펴보려면 회귀분석같은 시계열 분석 방법을 활용하는것이 좋음

# 회귀분석 : 독립변수(x)의 변화에 따른 종속변수(y)의 변화를 수리적 모형으로 설명한 모델링
# 시간이라는 독립변수의 변화에 따라 아파트 평당 가격이라는 종속 변수의 변화가 어떻게 되었는지 살펴보는 방법

load("./08_chart/all.rdata") # 전체 지역
load("./08_chart/sel.rdata") # 관심 지역

library(dplyr)
library(lubridate)

# 월당 평당 가격 요약하여 저장
all <- all %>% group_by(month=floor_date(ymd, "month")) %>% summarise(all_py = mean(py)) # 전체 지역 카운팅
sel <- sel %>% group_by(month=floor_date(ymd, "month")) %>% summarise(sel_py = mean(py)) # 관심 지역 카운팅

# 회귀식 모델링
# 시간 변화에 따른 평당 평균 가격 변화라는 변수 관계를 회귀식으로 모델링

# lm(종속변수~독립변수) : 종속 변수와 독립 변수의 관계를 선형으로 모델링
fit_all <- lm(all$all_py~all$month) # 서울 전체 지역 회귀식
fit_sel <- lm(sel$sel_py~sel$month) # 개포동 지역 회귀식

# summary(회귀모형)$coefficients[2]로 일별 변화량을 계산하고 365를 곱하여 연도별 가격 변화를 산출
coef_all <- round(summary(fit_all)$coefficients[2],1)*365 # 전체 회귀 계수
coef_sel <- round(summary(fit_sel)$coefficients[2],1)*365 # 관심 회귀 계수

# 회귀 분석 그리기
# textGrob() : 회귀 분석 결과 차트 위에 회귀식을 표현하려면 사용
# textGrob()으로 회귀 계숫값을 텍스트로 만들어서 grob_1과 grob_2에 저장하고 ggplot()으로 회귀 분석 차트를 그림
# aes(x=qrt,y=sel)로 x축과 y축을 설정한 다음 geom_line()으로 선을 그림

# 분기별 평당 가격 변화 주석 만들기

library(grid)
grob_1 <- grobTree(textGrob(paste0("전체 지역: ", coef_all, "만원(평당)"), x=0.05, y=0.88, hjust=0, gp=gpar(col="blue",fontsize=13, fontface="italic")))
grob_2 <- grobTree(textGrob(paste0("관심 지역: ", coef_sel, "만원(평당)"), x=0.05, y=0.95, hjust=0, gp=gpar(col="red",fontsize=16, fontface="bold")))

# 관심 지역 회귀선 그리기
# install.packages("ggpmisc")
library(ggpmisc)
gg <- ggplot(sel, aes(x=month, y=sel_py))+
  geom_line() + xlab("월") +ylab("가격") + theme(axis.text.x=element_text(angle=90))+stat_smooth(method='lm',colour="dark grey", linetype="dashed")+theme_bw()

# 전체 지역 회귀선 그리기
gg + geom_line(color="red",size=1.5)+
  geom_line(data=all, aes(x=month, y=all_py),color="blue",size=1.5)+
  # 주석 추가하기
  annotation_custom(grob_1)+annotation_custom(grob_2)

# 관심지역(빨강)은 1년에 평당 2810만원이 올랐으며, 서울시 전체지역(파랑)은 같은 기간에 평당 547.5만원이 오른것으로 나타남
# 이는 2021년 한 해 동안 개포동 일대의 아파트 가격 상승률이 서울시 전체 평균보다 5배 이상 더 높다는 것을 의미

######################################################################
## 8-4 주성분 분석(PCA) : 이 동네 단지별 특징은 무엇일까?
# 주성분 분석 : 다차원 정보를 효과적으로 요약하기 위한 대표적인 차원 축소 기법
# 주요 변동 방향과 크기를 알면 이 데이터 분포가 어떤 형태인지를 단순함ㄴ서도 직관적으로 설명 가능

load("08_chart/sel.rdata") # 관심 지역 데이터 불러오기

# 관심 지역 (sel) 내 아파트 이름을 기준으로 주성분별 평균값 구하기
pca_01 <- aggregate(list(sel$con_year, sel$floor, sel$py, sel$area), by=list(sel$apt_nm),mean) # 아파트별 평균값 구하기
head(pca_01,2)
colnames(pca_01) <- c("apt_nm","신축","층수","가격","면적") # 컬럼명 변경
head(pca_01,2)

# prcomp()로 주성분 분석 실시
m <- prcomp(~신축+층수+가격+면적,data=pca_01,scale=T) # 주성분 분석

# 주성분 결과는 summary()로 확인 가능
summary(m)

# Comulative Proportion 누적비율
# 첫번째와 두번째 성분만으로도 90.9%를 설명할 수 있음
# 주요 성분 2개를 각각의 축으로 설정하여 분석 그래프로 그려보기

# 주성분 분석 시각화

# 바이플롯 (biplot) : 각 변수와 주성분과의 관계를 설명하는 주성분 계수를 하나의 차트에 동시에 그려서 이들의 관계를 살펴보려는 다변량 그래프 분석 기법
# 화살표 방향일수록 해당 성분의 영향이 크다는 의미
# 화살표가 길수록 다른 성분보다 영향력이 크다는 의미
# install.packages("ggfortify")
library(ggfortify)
autoplot(m, loadings.label=T, loadings.label.size=6)+ geom_label(aes(label=pca_01$apt_nm),size=4)
# autoplot() : 주성분 분석 시각화 도구 시작
# loadings.label : 화살표와 텍스트 라벨 표시 유무
# geom_label : 아파트 이름을 표시

# 결과
# 개포우성1과 선경2차는 평당 가격대가 높은것으로 나타났으며, 동부센트레빌 아파트는 다른 아파트보다 신축이면서도 면적도 크고 층수가 높은 모습을 보이는 반면, 상지 리츠빌은 신축이면서도 면적이 넓은 것을 알 수 있음


# 주성분분석 : 이미지 분석, 전처리때 주로 쓰임




