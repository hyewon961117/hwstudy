# mutate() 변수 추가
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





