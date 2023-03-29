# 4장
# 4-1 데이터프레임
# 콘솔 창 지우는 단축키 : ctrl + L

english <- c(90,80,60,70)
math <- c(50, 60, 100, 20)

# 데이터프레임 생성
df_midterm <- data.frame(english, math)
df_midterm

class <- c(1,1,2,2)
df_midterm <- data.frame(english,math,class)
df_midterm

df_midterm2 <- data.frame(english = c(90,80,70),
                          math = c(20,30,40),
                          class = c(1,2,3))

# 4-3 외부데이터 이용하기

# 불러오기
# 엑셀을 불러오려면 패키지를 설치해야함
# install.packages("readxl")
library(readxl)
df_exam <- read_excel("data/excel_exam.xlsx")
df_exam

df_exam$english
mean(df_exam$english)

mean(df_exam$science)

# 엑셀안에 컬럼명 없는 경우
df_exam_novar <- read_excel("data/excel_exam_novar.xlsx",
                            col_names =F)
df_exam_novar

# 엑셀 속 시트3을 가져오기
df_exam_sheet <- read_excel("data/excel_exam_sheet.xlsx",
                            sheet =3)
df_exam_sheet

# 저장하기
write.csv(df_midterm, file='df_midterm.csv')

saveRDS(df_midterm, file='df_midterm2.rds')

# 변수 지정해서 지우기
rm(df_midterm)
rm(df_midterm2)

# RDS 파일 불러오기
df_midterm = readRDS('df_midterm2.rds')
df_midterm

# 데이터 정보 확인 기본
exam <- read.csv("data/csv_exam.csv")
head(exam) # default : 6행
head(exam, 10) # 10행
tail(exam) # 뒤에서 6개행
tail(exam, 10) # 뒤에서 10개행

View(exam) # view v 대문자
# 뷰 창에서 데이터 확인

dim(exam) # 행, 열 출력 shape
str(exam) # 데이터 속성 확인 dtype
summary(exam) # 최대~최소 4분위수 중앙값 평균 등 describe

# ggplot mpg데이터 데이터프레임 형태로 불러오기
mpg <- as.data.frame(ggplot2::mpg) # :: ggplot2안에있는 mpg데이터 
head(mpg)
tail(mpg,2)
View(mpg)
dim(mpg)
summary(mpg)

# 5-2 변수명 바꾸기
# 데이터 조작이 가능한 패키지
# install.packages('dplyr')
library(dplyr)

df_raw <- data.frame(var1=c(1,2,3), var2=c(2,3,4))
df_raw

df_new <- df_raw # 파이썬이랑 다르게 독립된 테이블이 만들어짐
df_new

df_new <- rename(df_new, v2 = var2)
df_new

mpg_df = as.data.frame(ggplot2::mpg)
head(mpg_df)
mpg_df <- rename(mpg_df, city=cty, highway=hwy)
head(mpg_df,1)

# 5-3 파생변수만들기
df <- data.frame(var1=c(4,3,8), var2=c(2,6,1))
df

df$var_sum <- df$var1+df$var2
df

df$var_mean <- (df$var1 + df$var2) / 2
df

# total 컬럼을 만들고 통합연비평균을 넣으시오
head(mpg)
mpg$total <- (mpg$cty +mpg$hwy)/2
head(mpg)
head(mpg$total)
summary(mpg$total)

# 히스토그램
hist(mpg$total) # 대부분 연비가 20~25 사이임

# 조건문 만들기
# total을 기준으로 A,B,c 등급부여
mpg$grade <- ifelse(mpg$total>=30, 'A', 
                    ifelse(mpg$total>=20, 'B', 'C'))
head(mpg,20)
table(mpg$grade) #count_values
qplot(mpg$grade) #막대그래프

# grade2라는 컬럼을 만들어서 d등급까지 만들기
# >=30 A, >=25 B, >=20 C, D

mpg$grade2 <- ifelse(mpg$total>=30,'A',ifelse(mpg$total>=25,"B",
                     ifelse(mpg$total>=20, 'C', 'D')))
head(mpg)
table(mpg$grade2)
qplot(mpg$grade2)

# test라는 컬럼을 만들기
# total >=20 pass / 그 외 fail

mpg$test <- ifelse(mpg$total>=20,"pass",'fail')
table(mpg$test)
qplot(mpg$test)




