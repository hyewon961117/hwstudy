# 단축키 [Ctrl+Shit+M]으로 %>% 기호 입력
library(dplyr)
library(ggplot2)
exam <- read.csv('data/csv_exam.csv')
head(exam)
View(exam)

# exam에서 class가 1인 경우 추출
exam %>% filter(class==1)

# class 2반이 아닌 경우
exam %>% filter(class!=2)

# 1반이 아닌 경우 
exam %>% filter(class!=1)

# 3반이 아닌 경우
exam %>% filter(class!=3)

# 수학점수가 50점 초과한 경우
exam %>% filter(math>50)

# 수학점수가 50점 미만인 경우
exam %>% filter(math<50)

# 영어점수가 80점 이상인 경우
exam %>% filter(english>=80)

# 영어점수가 80점 미만인 경우
exam %>% filter(english<=80)

# and 조건
# 1반이면서 수학점수가 50점 이상
exam %>% filter(class==1&math>=50)

# 2반이면서 영어점수가 80점 이상
exam %>% filter(class==2&english>=80)

# or 조건
# 수학점수가 90점 이상이거나 영어점수가 90점 이상인 경우
exam %>% filter(math>=90|english>=90)

# 영어점수가 90점 미만이거나 과학점수가 50점 미만인경우
exam %>% filter(english<90|science<50)

# 3가지 조건
# 1,3,5 반에 해당되면 추출
exam %>% filter(class==1|class==3|class==5)
exam %>% filter(class %in% c(1,3,5))

# class가 1인 행을 추출해서 변수에 넣고 1반의 수학 평균 구하기
class1 <- exam %>% filter(class==1)
mean(class1$math)

#class 2인 행을 추출해서 2반의 수학 평균 구하기
class2 <- exam %>% filter(class==2)
mean(class2$math)

## mpg데이터를 이용해 분석 문제 해결하기
mpg = as.data.frame(ggplot2 :: mpg)
head(mpg)

# displ이 4 이하인 자동차와 5 이상인 자동차 중 어떤 자동차의 hwy가 평균적으로 더 높은지 알아보기

mpg_displ_4 <- mpg %>% filter(displ<=4)
mpg_displ_5 <- mpg %>% filter(displ>=5)

mean(mpg_displ_4$hwy) ; mean(mpg_displ_5$hwy)

# audi 와 toyota중 어느 manufacturer의 cty가 평균적으로 더 높은지 알아보기

mpg_audi <- mpg %>% filter(manufacturer=='audi')
mpg_toyota <- mpg %>% filter(manufacturer=='toyota')
mean(mpg_audi$cty) ; mean(mpg_toyota$cty)

# chevrolet, ford, honda 자동차의 고속도로 연비 평균 구하기
# 해당 회사들의 자동차를 추출한 뒤 hwy 전체 평균 구하기

table(mpg$manufacturer)
mpg_chevrolet <- mpg %>% filter(manufacturer == 'chevrolet')
mpg_ford <- mpg %>% filter(manufacturer == 'ford')
mpg_honda <- mpg %>% filter(manufacturer =='honda')

mean(mpg_chevrolet$hwy)
mean(mpg_ford$hwy)
mean(mpg_honda$hwy)

mpg_cfh <- mpg %>% filter(manufacturer %in% c('chevrolet','ford','honda'))
mean(mpg_cfh$hwy)

# 6-3 필요한 변수만 추출하기
# select 함수 select()
exam %>% select(math)
exam %>% select(english)
exam %>% select(class,math,english)
exam %>% select(-math)
exam %>% select(-math, -english)

# class가 1반이면서 english만 추출
exam %>% filter(class==1) %>% select(english)

# 가독성을 위해 줄바꿈
exam %>% 
  filter(class==1) %>%
  select(english)

# id, math를 추출 앞에 6개만 추출
head(exam %>% select(id,math))
head(exam %>% select(id,math),10)

# 답
exam %>% select(id,math) %>% head
exam %>% select(id,math) %>% head(10)

# 138p 문제
# mpg 데이터에서 class,cty 변수를 추출해 새로운 데이터 생성
# 새로 만든 데이터의 일부를 출력해서 두 변수로만 구성되어있는지 확인

mpg_new <- mpg %>% select(class, cty)
head(mpg_new)

# class가 suv인 자동차와 compact인 자동차중 어떤 자동차의 cty가 더 높은지 알아보기

mpg_suv <- mpg_new %>% filter(class=='suv')
mpg_compact <- mpg_new %>% filter(class=='compact')
mean(mpg_suv$cty) ; mean(mpg_compact$cty)

# 6-4
# arrange 함수 : 순서대로 정렬하기
# 내림차순 desc - descending 약자
exam %>% arrange(math)
exam %>% arrange(desc(math))
exam %>% arrange(class,math) # class먼저 오름차순, 그 안에서 math 오름차순
exam %>% arrange(desc(class),desc(math)) # class먼저 내림차순, 그 안에서 math 내림차순

# 146p
# mpg데이터에서 audi에서 생상한 자동차중 어떤 모델 hwy가 높은지 알아보기
# audi에서 생상한 자동차 중 hwy가 1~5위에 해당하는 자동차의 데이터 출력

mpg_audi <- mpg %>% filter(manufacturer=='audi')
head(mpg_audi %>% arrange(desc(hwy)),5)

# 답
mpg %>% filter(manufacturer=='audi') %>% arrange(desc(hwy)) %>% head(5)

# 6-5
# mutate() : 파생변수 추가하기
exam %>% mutate(total = math + english + science) %>% head

exam %>% mutate(total = math + english + science,
                mean = (math + english + science)/3) %>% head

exam %>% mutate(total = math + english + science) %>% 
  arrange(desc(total))

# science <= 60 pass fail 조건문
exam %>% mutate(test = ifelse(science>=60, 'pass','fail'))
exam

# 144p
# hwy, cty 변수 이용해서 파생변수 만들기

mpg_df <- mpg

mpg_df <- mpg_df %>%  mutate('합산연비변수' = cty+hwy)
head(mpg_df)

mpg_df <- mpg_df %>% mutate('평균연비변수'= (cty+hwy)/2)
head(mpg_df)

mpg_df %>% arrange(desc(평균연비변수)) %>% head

mpg %>% mutate(total = cty +hwy,
               mean = total/2) %>% 
  arrange(desc(mean)) %>% head(3)

# 6-6
# 집단별로 요약하기
# groupby() , summarise

exam %>% summarise(mean_math =mean(math))

exam %>% group_by(class) %>% 
  summarise(mean_math=mean(math))

exam %>% group_by(class) %>% 
  summarise(mean_math=mean(math),
            sum_math=sum(math))

exam %>% group_by(class) %>% 
  summarise(mean_math=mean(math),
            sum_math=sum(math),
            median_mah=median(math),
            n=n()) # n 개수 (몇명의 값인지)

mpg %>% group_by(manufacturer) %>%
  mutate(tot=(cty+hwy)/2) %>% 
  summarise(mean_tot=mean(tot)) %>% 
  arrange(desc(mean_tot)) %>% head

mpg %>% group_by(manufacturer) %>%
  filter(class=='suv') %>% 
  mutate(tot=(cty+hwy)/2) %>% 
  summarise(mean_tot=mean(tot)) %>% 
  arrange(desc(mean_tot)) %>% head

# 150p
# mpg 데이터 이용해서 분석 문제 해결
# class별 cty 평균 구하기
# cty 평균이 높은순으로
mpg %>% group_by(class) %>% 
  summarise(mean_cty=mean(cty)) %>% 
  arrange(desc(mean_cty))

# 회사별 hwy 평균이 가장 높은 회사 세곳 출력
mpg %>% group_by(manufacturer) %>% 
  summarise(mean_hwy=mean(hwy)) %>% 
  arrange(desc(mean_hwy)) %>% head(3)

# 각 회사별 compact 차종 수 내림차순 정렬 출력
mpg %>% group_by(manufacturer) %>% 
  filter(class=='compact') %>%
  summarise(n_compact=n()) %>% 
  arrange(desc(n_compact))

# 6-7 데이터 합치기

# 가로합치기
test1 <- data.frame(id=c(1,2,3,4,5), midterm=c(60,80,70,90,85))
test2 <- data.frame(id=c(1,2,3,4,5), final= c(70,83,65,95,80))
test1 ; test2
total <- left_join(test1,test2,by="id")  # by는 겹따옴표 사용하기
total

# 담임선생님 명단 만들기
name <- data.frame(class=c(1,2,3,4,5), 
                   teacher=c('kim','lee','park','choi','jung'))
name

exam <- read.csv("data/csv_exam.csv")

View(exam)
head(exam)

exam_new <- left_join(exam, name, by="class")
head(exam_new)

# 세로합치기
group_a <- data.frame(id=c(1,2,3,4,5), test=c(60,70,80,90,85))
group_b <- data.frame(id=c(1,2,3,4,5), test=c(63,73,83,93,89))
group_c <- data.frame(id=c(1,2,3,4,5), test1=c(63,73,83,93,89))
group_a ; group_b ; group_c

group_all <- bind_rows(group_a,group_b)
group_all

group_call <- bind_rows(group_a,group_c)
group_call

# 156p 문제 - mpg 데이터

mpg <- as.data.frame(ggplot2::mpg)
fuel <- data.frame(fl = c("c", "d", "e", "p", "r"),
                   price_fl = c(2.35, 2.38, 2.11, 2.76, 2.22),
                   stringsAsFactors = F)
fuel

# mpg 데이터에 price_fl 연료가격 변수 추가
# model, fl, price_fl 변수만 5개 행 추출

mpg_add <- left_join(mpg,fuel,by="fl")
mpg_add %>% select(c(model,fl,price_fl)) %>% head(5)

# 6장 ppt 마지막 문제 - 분석 도전 
# https://ggplot2.tidyverse.org/reference/midwest.html
# 미국 동북중구 437개 지역의 인구통계 정보를 담고있는 데이터
midwest <- as.data.frame(ggplot2::midwest)
View(midwest)

dim(midwest)
str(midwest)

# 문제 1. popadults 는 해당 지역의 성인 인구, poptotal 은 전체 인구를 나타냅니다. midwest 데이터에'전체 인구 대비 미성년 인구 백분율' 변수를 추가하세요.

midwest_df <- midwest %>% mutate(ratio_child = (poptotal-popadults)/poptotal*100)
head(midwest_df)

# 문제 2. 미성년 인구 백분율이 가장 높은 상위 5 개 county(지역)의 미성년 인구 백분율을 출력하세요.

midwest_df %>% select(county,ratio_child) %>% arrange(desc(ratio_child)) %>% head(5)

# 문제 3. 분류표의 기준에 따라 미성년 비율 등급 변수를 추가하고, 각 등급에 몇 개의 지역이 있는지 알아보세요.

midwest %>% 
  mutate(ratio_child = (poptotal-popadults)/poptotal*100, 
         grade = ifelse(ratio_child>=40,'large',ifelse(ratio_child>=30,'middle','small'))) %>% group_by(grade) %>% summarise(n=n())

# 문제4. popasian은 해당 지역의 아시아인 인구를 나타냅니다. '전체 인구 대비 아시아인 인구 백분율' 변수를 추가하고, 하위 10개 지역의 state(주), county(지역명), 아시아인 인구 백분율을 출력하세요.

midwest %>% mutate(ratio_asian = popasian/poptotal*100) %>% arrange(ratio_asian) %>% select(state, county, ratio_asian) %>% head(10)
