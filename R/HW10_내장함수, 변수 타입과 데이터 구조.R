exam <- read.csv("data/csv_exam.csv")
head(exam)

exam[] # 전체 행과 전체 열 # 내장인덱싱 기능
exam[1,] # 1행 추출
exam[2,] # 2행 추출

# class가 1반인 행 추출
exam[exam$class==1,] # ,를 입력해야만 원하는 결과를 얻을 수 있음
exam[exam$math >=80,]

# 1반이면서 수학점수가 50점 이상
# 영어점수가 90점 미만이거나 과학점수가 50점 미만

exam[exam$class==1 & exam$math>=50,]
exam[exam$english<90 | exam$science<50,]

# exam 열 추출
exam[,1] # 첫번째 열
exam[,2] # 두번째 열
exam[,"class"] # class 변수
exam[,"math"]
exam[,c("math","english","science")]

# 행 변수 모두 가져오기
exam[1,3]

# 행인덱스 변수명(열이름)
exam[5, 'english']
exam[exam$math >= 50, 'english']
exam[exam$math >= 50, c('english', 'science')]

exam$tot <- (exam$math + exam$science + exam$english) / 3
head(exam)

# 수학 점수 50 이상, 영어 점수 80 이상인 학생들을 대상으로 각 반의 전 과목 총평균을 구하라.
aggregate(data=exam[exam$math>=50 & exam$english>=80, ], tot~class, mean)

library(dplyr)
exam %>% filter(math>=50&english>=80) %>%
  mutate(tot=(math+english+science)/3) %>%
  group_by(class) %>% summarise(mean=mean(tot))

# 15-2 변수 타입
var1 <- c(1,2,3,1,2) # numeric 연속변수
var2 <- factor(c(1,2,3,1,2)) # 범주형 변수 factor

var1 + 2
var2 + 2

class(var1) # 변수의 type(타입) 확인
class(var2)

levels(var1)
levels(var2)

var3 <- c("a","b","b","c")
var4 <- factor(c("a","b","b","c"))

class(var3)
class(val4)

mean(var1)
mean(var2)
mean(var3)
mean(var4)

# 타입변경
var2 <- as.numeric(var2)
class(var2)
mean(var2)
levels(var2)

# 문제 - 331p
library(ggplot2)
class(mpg)
class(mpg$drv)
mpg$drv <- as.factor(mpg$drv)
class(mpg$drv)
levels(mpg$drv)

# 15-3 데이터 구조
# 스칼라, 벡터 : 하나의 값 혹은 여러개의 값으로 구성된 데이터구조
a <- 1
a
b <- "hello"
b
class(a)
class(b)

# 데이터 프레임 : 행과 열로 구성된 2차원 데이터 구조 (다양한 변수 타입으로 구성 가능)
x1 <- data.frame(var1=c(1,2,3), var2=c("a","b","c"))
x1
class(x1)

# 매트릭스 : 행과 열로 구성된 2차원 데이터 구조 (한가지 변수 타입으로만 구성할 수 있음)
x2 <- matrix(c(1:12), ncol=2)
x2
class(x2)

# 어레이 : 2차원 이상으로 구성된 매트릭스 (한가지 변수 타입으로만 구성 가능)
x3 <- array(1:20, dim=c(2,5,3)) # 행, 열, 차원 순
x3
class(x3)

# 리스트 : 모든 데이터 구조를 포함하는 데이터 구조 (여러 데이터 구조를 합해 하나의 리스트로 만들 수 있음)
x4 <- list(f1=a, f2=x1, f3=x2, f4=x3)
x4
class(x4)

x <- boxplot(mpg$cty)
x$stats
x$stats[,1] # 요약통계량 추출
# 최소값, 1사분위수, 중앙값, 3사분위수, 최대값을 알 수 있음

x$stats[,1][3] #중앙값 median
x$stats[,1][2] # 1분위수
