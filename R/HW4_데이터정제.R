library(dplyr)
library(ggplot2)
library(readxl)

# 7 데이터 정제
# 7-1 결측치 정제하기
df <- data.frame(sex = c("M","F",NA,"M","F"),
                 score = c(5,4,3,4,NA)) # NA는 따옴표 없이 입력
df

is.na(df) # df 값들의 결측치 여부 확인
table(is.na(df))
table(is.na(df$sex))
table(is.na(df$score))

df %>% filter(is.na(score)) # score가 NA값인 행 출력
df %>% filter(!is.na(score)) # score가 NA값이 아닌 행 출력

df_nomiss <- df %>% filter(!is.na(score))
df_nomiss

df_nomiss <- df %>% filter(!is.na(score)&!is.na(sex))
df_nomiss

df_nomiss2 <- na.omit(df) # 하나라도 결측치 있는 행 모두 제거
df_nomiss2

mean(df$score, na.rm=T) # 결측치 제외하고 평균 산출
sum(df$score, na.rm=T) # 결측치 제외하고 합계 산출

exam <- read.csv("data/csv_exam.csv")
View(exam)

# 행 3,8,15의 math 컬럼에 NA값을 할당
exam[c(3,8,15),"math"] <- NA
View(exam)

exam %>% summarise(mean_math = mean(math)) # 결측치가 있기때문에 결과 X

# math 결측치를 제외하고 평균 산출
exam %>% summarise(mean_math = mean(math, na.rm=T))

# 평균, 합계, 중앙값 계산
exam %>% summarise(mean_math = mean(math, na.rm=T),
                   sum_math = sum(math, na.rm=T),
                   median_math = median(math, na.rm=T))

# 평균값을 대체하기
mean(exam$math, na.rm=T)
table(is.na(exam$math))
exam$math <- ifelse(is.na(exam$math),55,exam$math)
table(is.na(exam$math))
View(exam)
mean(exam$math)

# 170p - mpg데이터
# 우선 mpg 데이터를 불러와 몇 개의 값을 결측치로 만들겠습니다.
mpg <- as.data.frame(ggplot2::mpg) # mpg 데이터 불러오기
mpg[c(65, 124, 131, 153, 212), "hwy"] <- NA # NA 할당하기

# Q1. drv(구동방식)별로 hwy(고속도로 연비) 평균이 어떻게 다른지 알아보려고 합니다. 분석을 하기 전에 우선 두 변수에 결측치가 있는지 확인해야 합니다. drv 변수와 hwy 변수에 결측치가 몇 개 있는지 알아보세요.
table(is.na(mpg$drv))
table(is.na(mpg$hwy))

# Q2. filter()를 이용해 hwy 변수의 결측치를 제외하고, 어떤 구동방식의 hwy 평균이 높은지 알아보세요. 하나의 dplyr 구문으로 만들어야 합니다.
mpg %>% filter(!is.na(hwy)) %>% group_by(drv) %>%
  summarise(mean=mean(hwy))

# Q3. filter()를 이용하지 않는 방식
mpg %>% group_by(drv) %>%
  summarise(mean=mean(hwy, na.rm=T))

# 7-2 이상치 정제하기
outlier <- data.frame(sex=c(1,2,1,3,2,1), score = c(5,4,3,4,2,6))
outlier

table(outlier$sex)
table(outlier$score)

# sex 3이면 NA 할당
outlier$sex <- ifelse(outlier$sex==3,NA,outlier$sex)
table(is.na(outlier$sex))

# score가 5보다 크면 NA 할당
outlier$score <- ifelse(outlier$score>5, NA, outlier$score)
table(is.na(outlier$score))

# 결측치 제외하고 분석 (결측치 제외하고 성별별 평균점수보기)
outlier %>% filter(!is.na(sex)&!is.na(score)) %>% 
  group_by(sex) %>% summarise(mean_score=mean(score))

mpg <- as.data.frame(ggplot2::mpg)
boxplot(mpg$hwy)

# 12~37을 벗어나면 NA값을 할당
mpg$hwy <- ifelse(mpg$hwy<12|mpg$hwy>37,NA,mpg$hwy)

# 결측치 확인
table(is.na(mpg$hwy))
mpg %>% group_by(drv) %>% summarise(mean_hwy = mean(hwy, na.rm=T))

# 178p 문제 - mpg 데이터
mpg <- as.data.frame(ggplot2::mpg) # mpg 데이터 불러오기
mpg[c(10, 14, 58, 93), "drv"] <- "k" # drv 이상치 할당
mpg[c(29, 43, 129, 203), "cty"] <- c(3, 4, 39, 42) # cty 이상치 할당

# Q1. drv 에 이상치가 있는지 확인하세요. 이상치를 결측 처리한 다음 이상치가 사라졌는지 확인하세요. 결측 처리 할 때는 %in% 기호를 활용하세요.
table(mpg$drv)
mpg$drv <- ifelse(mpg$drv=="k",NA,mpg$drv)
table(mpg$drv)

# 답
# drv 4 f r 이면 값을 유지하고 그 외 NA 할당
mpg$drv <- ifelse(mpg$drv %in% c("4","f","r"),mpg$drv,NA)
table(mpg$drv)

# Q2. 상자 그림을 이용해서 cty 에 이상치가 있는지 확인하세요. 상자 그림의 통계치를 이용해 정상 범위를 벗어난 값을 결측 처리한 후 다시 상자 그림을 만들어 이상치가 사라졌는지 확인하세요.
boxplot(mpg$cty)
boxplot(mpg$cty)$stats
mpg$cty <- ifelse(mpg$cty<9|mpg$cty>26,NA,mpg$cty)
boxplot(mpg$cty)

# Q3. 두 변수의 이상치를 결측처리 했으니 이제 분석할 차례입니다. 이상치를 제외한 다음 drv 별로 cty 평균이 어떻게 다른지 알아보세요. 하나의 dplyr 구문으로 만들어야 합니다.
mpg %>% filter(!is.na(drv)&!is.na(cty)) %>% group_by(drv) %>% 
  summarise(mean = mean(cty))

