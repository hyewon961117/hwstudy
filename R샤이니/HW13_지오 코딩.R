load("./04_pre_process/04_preprocess.rdata")
apt_juso <- data.frame(apt_price$juso_jibun)
apt_juso <- data.frame(apt_juso[!duplicated(apt_juso),]) # unique한 주소를 추출 (중복 제거)
head(apt_juso, 2)

# 주소를 좌표로 변환하는 지오코딩
add_list <- list()
cnt <- 0
kakao_key <- read.table("./R_샤이니/카카오API.txt")
kakao_key <- kakao_key[1,]

# install.packages('httr')
# install.packages("RJSONIO")
library(httr)
library(RJSONIO)
library(data.table)
library(dplyr)

for (i in 1:nrow(apt_juso)){
  # 예외처리 구문 시작
  tryCatch(
    {
      lon_lat <- GET(url="https://dapi.kakao.com/v2/local/search/address.json", query=list(query=apt_juso[i,]), add_headers(Authorization=paste0("KakaoAK ",kakao_key)))
      # 위도 경도만 추출해서 저장
      coordxy <- lon_lat %>% content(as='text') %>% fromJSON()
      cnt=cnt+1
      # 주소 경도 위도 정보를 리스트로 저장
      add_list[[cnt]] <- data.table(apt_juso = apt_juso[i,],
                                    coord_x=coordxy$documents[[1]]$address[['x']],
                                    coord_y=coordxy$documents[[1]]$address[['y']])
      message <- paste0("[",i,"/",nrow(apt_juso),"] 번째 (", 
                    round(i/nrow(apt_juso)*100,2),"%) [",apt_juso[i,]
                    ,"] 지오 코딩 중입니다: X=", add_list[[cnt]]$coord_x,
                    " / Y= ",add_list[[cnt]]$coord_y)
      cat(message,"\n\n")
      # 예외처리 구문 종료
    }, error = function(e){cat("ERROR :",conditionMessage(e),"\n")}
  )
}

for(i in 1:nrow(apt_juso)){
  tryCatch(
   {
    lon_lat <- GET(url = "https://dapi.kakao.com/v2/local/search/address.json",query=list(query=apt_juso[i,]),
                                                                                         add_headers(Authorization=paste0("KakaoAk ",kakao_key)))
                                                                                                                          #위도 경도만 추출해서 저장
    coordxy <- lon_lat %>% content(as = 'text') %>% fromJSON()
    cnt = cnt+1
    #주소 경도 위도 정보를 리스트로 저장
    add_list[[cnt]] <- data.table(apt_juso = apt_juso[i,],
    coordx = coordxy$documents[[1]]$address[['x']],
    coordy = coordxy$documents[[1]]$address[['y']])
    msg <- paste0("[",i,"/",nrow(apt_juso),"] 번째 (",round(i/nrow(apt_juso)*100,2),"%) [", apt_juso[i,],"] 지오코딩중입니다.:X=",add_list[[cnt]]$coordx,"/ Y=",add_list[[cnt]]$coordy)
    cat(msg,"\n\n")
                                                          #예외처리
                                                            
  
   },error=function(e){cat("ERROR:",conditionMessage(e),"\n")}
  )
}

# 3단계 지오코딩 결과 저장
juso_geocoding <- rbindlist(add_list)
juso_geocoding$coord_x <- as.numeric(juso_geocoding$coord_x)
juso_geocoding$coord_y <- as.numeric(juso_geocoding$coord_y)
head(juso_geocoding,2)
juso_geocoding <- na.omit(juso_geocoding) # 결측치 제거
dir.create("./05_geocoding")
save(juso_geocoding, file="./05_geocoding/05_juso_geocoding.rdata")
write.csv(juso_geocoding,"./05_geocoding/05_juso_geocoding.csv")

inputs <- list(1,2,3,'four',5,6)
for(input in inputs){
  print(paste(input, "의 로그값은 =>",log(input)))} # 4에서 오류가 나면서 멈춤

for (input in inputs){
  tryCatch({
    print(paste(input,"의 로그값은=>",log(input)))
  }, error = function(e){cat("ERROR: ", conditionMessage(e),"\n")})}
# 4에서 오류가 나지만 에러 문구 띄우고 다음것 계속 진행
