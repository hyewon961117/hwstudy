# install.packages('rstudioapi')
getwd() # 작업 폴더 확인

# 지역코드 불러오기
loc <- read.csv("data/sigun_code.csv", fileEncoding = "UTF-8")
class(loc$code) # 코드 정수형으로 되어있음
loc$code <- as.character(loc$code) # 타입 변경
class(loc$code)
head(loc,2)

# 수집기간 설정하기
datelist <- seq(as.Date('2021-01-01'),as.Date('2021-12-31'),'1 month')
# seq(from=, to=, by= )
datelist
datelist <- format(datelist,format='%Y%m') # Y 대문자
# %Y%m : (YYYY-MM-DD => YYYYMM)
datelist

service_key <- read.table("./R_샤이니/공공데이터포털_API.txt")
service_key <- service_key[1,]
service_key 

# 요청목록 빈리스트 만들기
url_list <- list()
cnt <- 0 # 반복문 제어변수 초기값 설정

# 요청목록 채우기
for (i in 1:nrow(loc)){ # 외부 반복 : 25개 자치구
  for (j in 1:length(datelist)){ # 내부 반복 : 12개월
    cnt <- cnt+1
    # URL 목록 채우기
    url_list[cnt] <- paste0("http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?",
    "LAWD_CD=",loc[i,1], # 지역 코드
    "&DEAL_YMD=", datelist[j], # 수집 월
    "&num0fRows=", 100, # 한 번에 가져올 최대 자료 수 
    "&serviceKey=", service_key)} # 인증키
  Sys.sleep(0.1) #0.1초간 멈춤
  msg <- paste0("[",i,"/",nrow(loc),"] ",loc[i,3],"의 크롤링 목록이 생성됨 => 총 [",cnt,"] 건") # 알림 메ㅣ지
  cat(msg, "\n\n") # 프린트 문
}

length(url_list) # 요청 목록 개수 확인
browseURL(paste0(url_list[1])) # 정상 동작 확인(웹 브라우저 실행)


# 크롤링
install.packages("XML")
install.packages("data.table")
install.packages("stringr")

library(XML)
library(data.table)
library(stringr)

# 임시저장 리스트 생성
raw_data <- list() # xml 임시저장소
root_Node <- list() # 거래내역 추출 임시저장
total <- list() # 거래내역 정리 임시저장
dir.create("01_hw") # 새로운 디렉토리 생성 (작업공간에 폴더 생성)

# 2단계 URL 요청 - XML 응답
for (i in 1:length(url_list)){
  raw_data[[i]] <- xmlTreeParse(url_list[i], useInternalNodes=TRUE, encoding="utf-8") # 결과 저장
  root_Node[[i]] <- xmlRoot(raw_data[[i]]) # xmlRoot로 루트 노드 이하 추출
  # 전체 거래내역 추출
  items <- root_Node[[i]][[2]][['items']]
  # 전체 거래 건수 확인
  size <- xmlSize(items)
  
  # 거래내역 추출
  item <- list()
  item_temp_dt <- data.table() # 세부거래 내역(item) 저장 임시테이블 생성
  Sys.sleep(.1)
  for (m in 1:size){
    item_temp <- xmlSApply(items[[m]], xmlValue)
    item_temp_dt <- data.table(year = item_temp[4], # 거래 연도
                               month = item_temp[7], # 거래 월
                               day = item_temp[8], # 거래 일
                               price = item_temp[1], # 거래 금액
                               code = item_temp[12], # 지역 코드
                               dong_nm = item_temp[5], # 법정동
                               jibun = item_temp[11], # 지번
                               con_year = item_temp[3], # 건축 연도
                               apt_nm = item_temp[6], # 아파트 이름
                               area = item_temp[9], # 전용 면적
                               floor = item_temp[13]) # 층수
    item[[m]] <- item_temp_dt} # 분리된 거래 내역 순서대로 저장
  apt_bind <- rbindlist(item) # 통합 저장
  
  region_nm <- subset(loc, code==str_sub(url_list[i],115,119))$addr_1 #지역명
  month <- str_sub(url_list[i],130,135) # 연월
  path <- as.character(paste0("./01_hw/", region_nm, "_", month, ".csv"))
  write.csv(apt_bind, path) # csv 파일로 저장
  msg <- paste("[",i,"/",length(url_list),"] 수집한 데이터를 [",path,"]에 저장 합니다.") # 알림 메시지
  cat(msg, "\n\n")
}


# 파일 통합하기
files <- dir('02_raw_data') # 폴더 내 모든 파일명 읽기
files
library(plyr)
apt_price <- ldply(as.list(paste0("./02_raw_data/",files)),read.csv) # 결합
apt_price

dir.create("./03_integrated")
save(apt_price, file="03_apt_price.rdata")
write.csv(apt_price, "03_apt_price.csv")

