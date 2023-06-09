# 회사별 hwy 평균이 가장 높은 회사 세곳 출력
# 각 회사별 compact 차종 수 내림차순 정렬 출력

# 6-7 데이터 합치기
# 가로합치기
# test1 <- data.frame(id=c(1,2,3,4,5), midterm=c(60,80,70,90,85))
# test2 <- data.frame(id=c(1,2,3,4,5), final= c(70,83,65,95,80))

# 담임선생님 명단 합치기
name <- data.frame(class=c(1,2,3,4,5), teacher=c('kim','lee','park','choi','jung'))

# 세로합치기
group_a <- data.frame(id=c(1,2,3,4,5), test=c(60,70,80,90,85))
group_b <- data.frame(id=c(1,2,3,4,5), test=c(63,73,83,93,89))
group_c <- data.frame(id=c(1,2,3,4,5), test1=c(63,73,83,93,89))

# 156p 문제 - mpg 데이터
# mpg 데이터에 price_fl 연료가격 변수 추가
# model, fl, price_fl 변수만 5개 행 추출

# 6장 ppt 마지막 문제 - 분석 도전 
# https://ggplot2.tidyverse.org/reference/midwest.html
# 미국 동북중구 437개 지역의 인구통계 정보를 담고있는 데이터

# 문제 1. popadults 는 해당 지역의 성인 인구, poptotal 은 전체 인구를 나타냅니다. midwest 데이터에'전체 인구 대비 미성년 인구 백분율' 변수를 추가하세요.
# 문제 2. 미성년 인구 백분율이 가장 높은 상위 5 개 county(지역)의 미성년 인구 백분율을 출력하세요.
# 문제 3. 분류표의 기준에 따라 미성년 비율 등급 변수를 추가하고, 각 등급에 몇 개의 지역이 있는지 알아보세요.
# 문제4. popasian은 해당 지역의 아시아인 인구를 나타냅니다. '전체 인구 대비 아시아인 인구 백분율' 변수를 추가하고, 하위 10개 지역의 state(주), county(지역명), 아시아인 인구 백분율을 출력하세요.

################ 데이터 정제 ##################
# df 변수에 sex열 M,F,NA,M,F , score열 5,4,3,4,NA 값인 데이터프레임 만들기
# df 값들의 결측치 여부 확인
# 각 열별로 결측치 여부 확인

# score가 NA값인 행 출력
# score가 NA값이 아닌 행 출력

# 하나라도 결측치 있는 행 모두 제거 (두가지 방법)

# score 열 결측치 제외하고 평균 산출
# score 열 결측치 제외하고 합계 산출

# exam 데이터 불러오기
exam <- read.csv("data/csv_exam.csv")

# 행 3,8,15의 math 컬럼에 NA값을 할당
# math 결측치를 제외하고 평균 산출 (하나의 dqlyr 구문으로)
# 평균, 합계, 중앙값 계산 (하나의 dqlyr 구문으로)
# 결측치 평균값으로 대체하기

# 170p - mpg데이터
# 우선 mpg 데이터를 불러와 몇 개의 값을 결측치로 만들겠습니다.
mpg <- as.data.frame(ggplot2::mpg) # mpg 데이터 불러오기
mpg[c(65, 124, 131, 153, 212), "hwy"] <- NA # NA 할당하기

# Q1. drv(구동방식)별로 hwy(고속도로 연비) 평균이 어떻게 다른지 알아보려고 합니다. 분석을 하기 전에 우선 두 변수에 결측치가 있는지 확인해야 합니다. drv 변수와 hwy 변수에 결측치가 몇 개 있는지 알아보세요.
# Q2. filter()를 이용해 hwy 변수의 결측치를 제외하고, 어떤 구동방식의 hwy 평균이 높은지 알아보세요. 하나의 dplyr 구문으로 만들어야 합니다.
# Q3. filter()를 이용하지 않는 방식

# 7-2 이상치 정제하기
outlier <- data.frame(sex=c(1,2,1,3,2,1), score = c(5,4,3,4,2,6))

# 각 열의 값들 확인

# sex열 3인것, score 6인것을 이상치로 보기
# sex 3이면 NA 할당
# score가 5보다 크면 NA 할당
# 결측치 제외하고 성별별 평균점수보기

# mpg 데이터 불러오기
# hwy 상자그래프 그려서 이상치 확인
# 통계치로 정상범위 판단하기
# 이상치 NA값으로 처리
# 결측치  확인하기

# 178p 문제 - mpg 데이터
mpg <- as.data.frame(ggplot2::mpg) # mpg 데이터 불러오기
mpg[c(10, 14, 58, 93), "drv"] <- "k" # drv 이상치 할당
mpg[c(29, 43, 129, 203), "cty"] <- c(3, 4, 39, 42) # cty 이상치 할당

# Q1. drv 에 이상치가 있는지 확인하세요. 이상치를 결측 처리한 다음 이상치가 사라졌는지 확인하세요. 결측 처리 할 때는 %in% 기호를 활용하세요.
# Q2. 상자 그림을 이용해서 cty 에 이상치가 있는지 확인하세요. 상자 그림의 통계치를 이용해 정상 범위를 벗어난 값을 결측 처리한 후 다시 상자 그림을 만들어 이상치가 사라졌는지 확인하세요.
# Q3. 두 변수의 이상치를 결측처리 했으니 이제 분석할 차례입니다. 이상치를 제외한 다음 drv 별로 cty 평균이 어떻게 다른지 알아보세요. 하나의 dplyr 구문으로 만들어야 합니다.

################ 시각화 ##################
# 그린 그래프는 export로 이미지파일, pdf 파일로 저장가능

# mpg 산점도 그리기
# x 축 displ, y 축 hwy 산점도
# x 축 범위 3~6, y 축 범위 10~30 으로 지정

# 188p 문제
# Q1. mpg 데이터의 cty(도시 연비)와 hwy(고속도로 연비) 간에 어떤 관계가 있는지 알아보려고 합니다. x 축은 cty, y 축은 hwy 로 된 산점도를 만들어 보세요.
# Q2. 미국 지역별 인구통계 정보를 담은 ggplot2 패키지의 midwest 데이터를 이용해서 전체 인구와 아시아인 인구 간에 어떤 관계가 있는지 알아보려고 합니다. x 축은 poptotal(전체 인구), y 축은 popasian(아시아인 인구)으로 된 산점도를 만들어 보세요. 전체 인구는 50 만 명 이하, 아시아인 인구는 1 만 명 이하인 지역만 산점도에 표시되게 설정하세요.

# 집계를해서 막대그래프를 그린다면 geom_col()
# 그렇지 않다면 원데이터를 이용해서 geom_bar()

# 평균 막대 그래프 생성하기
# x 축 범주 변수, y 축 빈도
# df_mpg 변수에 drv 별로 hwy평균 데이터 넣기
# x=drv, y=mean_hwy 평균 막대 그래프 생성하되 평균이 높은것부터 낮은순으로 그래프 만들기

# 빈도 막대 그래프 생성하기
# x 축 연속 변수, y 축 빈도
# hwy의 빈도 막대 그래프 생성하기 (y축 count)

# 193p 문제
# Q1. 어떤 회사에서 생산한 "suv" 차종의 도시 연비가 높은지 알아보려고 합니다. "suv" 차종을 대상으로 평균 cty(도시 연비)가 가장 높은 회사 다섯 곳을 막대 그래프로 표현해 보세요. 막대는 연비 가 높은 순으로 정렬하세요.
# Q2. 자동차 중에서 어떤 class(자동차 종류)가 가장 많은지 알아보려고 합니다. 자동차 종류별 빈도를 표현한 막대 그래프를 만들어 보세요.

# 선그래프 생성하기
# https://ggplot2.tidyverse.org/reference/economics.html
economics <- as.data.frame(ggplot2::economics)
# x축 date, y축 unemploy 선그래프 그리기

# 195p 문제
# Q1. psavert(개인 저축률)가 시간에 따라서 어떻게 변해왔는지 알아보려고 합니다. 시간에 따른 개인 저축률의 변화를 나타낸 시계열 그래프를 만들어 보세요.

# 상자그림 그리기
# mpg데이터 x축 drv, y축 hwy 상자그림 그리기

# 198p 문제
# Q1. class(자동차 종류)가 "compact", "subcompact", "suv"인 자동차의 cty(도시 연비)가 어떻게 다른지 비교해보려고 합니다. 세 차종의 cty를 나타낸 상자 그림을 만들어보세요.

################ 데이터 분석 ##################
# spss 통계 툴에서 사용하는 파일을 로드하기 위한 패키지 설치
# install.packages('foreign')

library(dplyr)
library(ggplot2)
library(readxl)
library(foreign)

# spss 데이터 데이터프레임으로 불러오기 (파일명 : Koweps_hpc10_2015_beta1.sav)
raw_welfare <- read.spss(file="data/Koweps_hpc10_2015_beta1.sav",
                         to.data.frame = T)

# welfare 변수에 복사본 만들기

# 열이름 변수명 바꿔보기
welfare <- rename(welfare, 
                  sex = h10_g3,
                  birth = h10_g4,
                  marriage=h10_g10,
                  religion = h10_g11,
                  income = p1002_8aq1,
                  code_job=h10_eco9,
                  code_region = h10_reg7)

# 성별 변수 전처리 (sex)
# 이상치 확인
# 변수의 타입 확인
# 이상치 결측치 처리 (9)
# 결측치 확인
# 성별 항목 이름 부여 (1 male, 2 female)
# 성별 그래프 간단 확인

# 월급정보 전처리 (income)
# 월급 변수 타입 확인
# 간단한 그래프 확인, x축 0~1000까지만 그리기
# 이상치 결측처리 (0, 9999)
# 결측치 확인
# 성별 월급 평균표 만들기
# 평균 막대 그래프 그리기

# 나이와 월급의 관계 (birth)
# 생년월일 변수의 타입 확인
# 간단한 그래프 확인
# 이상치 결측처리
# age 변수를 추가해서 나이 계산해서 넣기
# 간단한 그래프 확인
# 나이 월급 평균표 만들기
# 선그래프 그리기

# 연령대에 따른 월급 차이
# ageg 파생변수 만들기
# 나이가 30살 미만이면 young, 59살 이하면 middle, 그 외 old
# 간단한 그래프 확인
# 연령대에 따른 월급 차이 분석
# 평균 막대 그래프 그리기
# 막대 변수 정렬 설정 - 'young','middle','old' 순으로 나오게

# 9-5 연령대 및 성별 월급 차이
# sex_income 변수에 연령대 및 성별별 income 평균 데이터 넣기
# 막대그래프에서 성별로 나누기 (누적)
# 막대그래프에서 성별로 나누기 (누적X)

# 나이 및 성별 월급 차이
# sex_age 변수에 나이 및 성별별 income 평균 데이터 넣기
# 선그래프에서 성별로 나누기

# 9-6 직업별 월급 차이
list_job <- read_excel('data/Koweps_Codebook.xlsx', 
                       col_names=T, sheet=2)

# welfare 변수와 list_job 열 합치기
# code_job이 결측치가 없는 행 code_job과 job 변수만 출력 

# 직업별 월급 차이를 분석
# job_income 변수에 job과 income 이 결측치가 없는 행 중 직업별로 income 평균 넣기

# top10 변수 (직업별 수입 상위 10개)
# bottom10 변수 (직업별 수입 하위 10개)
# 각각 가로 막대 그래프 그리기, y축 0~850 까지 지정

# 9-7 성별 직업 빈도

# 남성 직업 빈도 상위 10개 (job_male 변수, 가로막대그래프)
# 여성 직업 빈도 상위 10개 (job_female 변수, 가로막대그래프)

# 9-8 종교에 따른 이혼율 (religion)
# 종교 변수 타입 확인
# 값의 빈도 확인
# 종교 유무에 이름 부여 : 종교가 1이면 yes, 아니면 no 로 값 변경
# 값의 빈도 확인
# 간단한 그래프 확인

# 이혼 변수 만들기 (marriage)
# 결혼 변수 타입 확인
# 값의 빈도 확인
# group_marriage 변수에 marriage가 1이면 marriage, 3이면 divorce, 그 외 NA 처리하기
# 값의 빈도 확인
# 결측값 빈도 확인
# 간단한 그래프 확인

# 종교여부에 따른 이혼율 분석
# religion_marriage 변수에 marriage 결측값 없고 religion과 group_marriage로 빈도수 집계해서 합을 파생변수 tot_group에 넣기, pct 파생변수 추가해서 이혼율 반올림해서 넣기
# 이혼 추출
# divorce 변수에 group_marriagerk divorce인 행만 추출하기 , 열은 religion, pct만 출력
# 종교와 이혼율 관계 그래프 그리기

# 연령대에 따른 이혼율 분석
# ageg_marriage 변수에 marriage 결측값 없고 ageg과 group_marriage로 빈도수 집계해서 합을 파생변수 tot_group에 넣기, pct 파생변수 추가해서 이혼율 반올림해서 넣기 (count 함수 이용)
# 초년 제외, 이혼 추출
# ageg_divorce 변수에 연령대 young, 이혼한 값 넣기, 열은 연령대와 이혼율만 추출
# 연령대와 이혼율 관계 그래프 그리기

# 연령대, 종교유무, 결혼상태별 비율표 만들기
# ageg_religion_marriage 변수에 group_marriage 결측값 없고, 연령대 young인 행만 연령대, 종교, 결혼상태 빈도수 집계해서 합을 파생변수 tot_group에 넣기, pct 파생변수 추가해서 이혼율 반올림해서 넣기

# 연령대 및 종교 유무별 이혼율 표 만들기
# ageg_religion_marriage 변수에서 divorce 인 행만 추출, 열은 연령대와 종교, 이혼율만 추출
# 종교별 연령대 이혼율 그래프 그리기, 누적X

# 9-9 지역별 연령대 비율
# code_region 변수 값이 빈도 확인
# 지역코드 목록 만들기
# 지역 = c('서울','수도권(인천/경기)','부산/경남/울산','대구/경북','대전,충남','강원/충북','광주/전남/전북/제주도')
list_region <- data.frame(code_region=c(1:7), region = 지역)
# welfare 변수에 지역명 변수를 추가
# region_ageg 변수에 종교와 연령대의 빈도수 집계해서 합을 파생변수 tot_group에 넣기, pct 파생변수 추가해서 이혼율 반올림해서 넣기
# 연령대별 종교 이혼율 그래프 그리기, 가로 막대 그래프

# 노년층 비율을 오름차순 (list_order_old 변수)
# 지역명 순서 변수 만들기 (order변수)
# 연령대별 종교 이혼율 그래프 그리기, 가로 막대 그래프, x축 오름차순 되게