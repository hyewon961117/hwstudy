# spss 통계 툴에서 사용하는 파일을 로드하기 위한 패키지 설치
# install.packages('foreign')

library(dplyr)
library(ggplot2)
library(readxl)
library(foreign)

# 데이터 불러오기
raw_welfare <- read.spss(file="data/Koweps_hpc10_2015_beta1.sav",
                         to.data.frame = T)
View(raw_welfare)

welfare <- raw_welfare # 복사본 만들기

# 데이터 탐색
head(welfare)
tail(welfare)
str(welfare)
summary(welfare)

# 열이름 변수명 바꿔보기
welfare <- rename(welfare, 
                  sex = h10_g3,
                  birth = h10_g4,
                  marriage=h10_g10,
                  religion = h10_g11,
                  income = p1002_8aq1,
                  code_job=h10_eco9,
                  code_region = h10_reg7)
View(welfare)

# 성별 변수 전처리

# 이상치 확인
table(welfare$sex)
class(welfare$sex) # sex 변수의 타입을 확인

# 이상치 결측치 처리
welfare$sex <- ifelse(welfare$sex==9,NA,welfare$sex)

# 결측치 확인
table(is.na(welfare$sex))

# 성별 항목 이름 부여
welfare$sex <- ifelse(welfare$sex==1,'male','female')
table(welfare$sex)
qplot(welfare$sex)

# 월급정보 전처리
class(welfare$income)
summary(welfare$income)
qplot(welfare$income)
qplot(welfare$income)+xlim(0,1000)

# 이상치 결측처리
welfare$income <- ifelse(welfare$income %in% c(0,9999),NA,welfare$income)

# 결측치 확인
table(is.na(welfare$income))

# 성별 월급 평균표 만들기
sex_income <- welfare %>% filter(!is.na(income)) %>% group_by(sex) %>% 
  summarise(mean_income=mean(income))
sex_income

ggplot(data=sex_income, aes(x=sex, y=mean_income))+geom_col()

# 나이와 월급의 관계
class(welfare$birth)
summary(welfare$birth)
qplot(welfare$birth)

# 나이 이상치 결측처리
welfare$birth <- ifelse(welfare$birth==9999,NA,welfare$birth)
table(is.na(welfare$birth))

# 나이추출
# 2023-1996+1
welfare$age <- 2015 - welfare$birth + 1
summary(welfare$age)
qplot(welfare$age)

age_income <- welfare %>% filter(!is.na(income)) %>% group_by(age) %>% 
  summarise(mean_income=mean(income))
age_income

ggplot(data=age_income, aes(x=age, y=mean_income)) + geom_line()

# 9-4 연령대에 따른 월급 차이

# ageg 파생변수 만들기
# 나이가 30살 미만이면 young, 59살 이하면 middle, 그 외 old
welfare <- welfare %>% 
  mutate(ageg = ifelse(age<30,'young',ifelse(age<=59,'middle','old')))
table(welfare$ageg)

# 막대그래프로 확인하기
qplot(welfare$ageg)

# 연령대에 따른 월급 차이 분석
ageg_income <- welfare %>% filter(!is.na(income)) %>% 
  group_by(ageg) %>% summarise(mean_income = mean(income))

ggplot(data=ageg_income, aes(x=ageg, y=mean_income)) + geom_col()

# 막대 변수 정렬 설정 - 'young','middle','old' 순으로 나오게
ggplot(data=ageg_income, aes(x=ageg, y=mean_income)) + geom_col() +
  scale_x_discrete(limits=c('young','middle','old'))

# 9-5 연령대 및 성별 월급 차이
sex_income <- welfare %>% filter(!is.na(income)) %>% 
  group_by(ageg, sex) %>% summarise(mean_income = mean(income))
sex_income

# 막대그래프에서 성별로 나누기 (누적)
ggplot(data=sex_income, aes(x=ageg, y=mean_income, fill=sex)) +
  geom_col() + scale_x_discrete(limits=c('young','middle','old'))

# 막대그래프에서 성별로 나누기
ggplot(data=sex_income, aes(x=ageg, y=mean_income, fill=sex)) +
  geom_col(position = 'dodge') + scale_x_discrete(limits=c('young','middle','old'))

# 나이 및 성별 월급 차이
sex_age <- welfare %>% filter(!is.na(income)) %>% 
  group_by(age, sex) %>% summarise(mean_income=mean(income))
sex_age 

ggplot(data=sex_age , aes(x=age, y=mean_income, col = sex)) + geom_line()

# 9-6 직업별 월급 차이
list_job <- read_excel('data/Koweps_Codebook.xlsx', 
                       col_names=T, sheet=2)


head(list_job)
dim(list_job)
class(list_job)
table(welfare$code_job)

welfare <- left_join(welfare, list_job, by="code_job")

welfare %>% filter(!is.na(code_job)) %>% 
  select(code_job, job) %>% head(10)

# 직업별 월급 차이를 분석
job_income <- welfare %>% filter(!is.na(job)&!is.na(income)) %>% 
  group_by(job) %>% summarise(mean_income = mean(income))
head(job_income)

top10 <- job_income %>% arrange(desc(mean_income)) %>% head(10)
top10

bottom10 <- job_income %>% arrange(mean_income) %>% head(10)
bottom10

ggplot(data=top10, aes(x=reorder(job, mean_income), y=mean_income)) + geom_col() + coord_flip()

ggplot(data=bottom10, aes(x=reorder(job, -mean_income), y=mean_income)) + geom_col() + coord_flip() + ylim(0,850)

# 9-7 성별 직업 빈도

# 남성 직업 빈도 상위 10개

job_male <- welfare %>% filter(!is.na(job)& sex=='male') %>% 
  group_by(job) %>% summarise(n=n()) %>% arrange(desc(n)) %>% head(10)

job_male

ggplot(data=job_male, aes(x=reorder(job,n),y=n)) + 
  geom_col() + coord_flip()

# 여성 직업 빈도 상위 10개

job_female <- welfare %>% filter(!is.na(job)& sex=='female') %>% 
  group_by(job) %>% summarise(n=n()) %>% arrange(desc(n)) %>% head(10)

job_female

ggplot(data=job_female, aes(x=reorder(job,n),y=n)) + 
  geom_col() + coord_flip()

# 9-8 종교에 따른 이혼율
class(welfare$religion)
table(welfare$religion)

# 종교유무에 이름부여
welfare$religion <- ifelse(welfare$religion==1,"yes","no")
table(welfare$religion)
qplot(welfare$religion)

# 이혼 변수 만들기
class(welfare$marriage)
table(welfare$marriage)

welfare$group_marriage <- ifelse(welfare$marriage ==1, 'marriage', ifelse(welfare$marriage==3, 'divorce',NA))

table(welfare$group_marriage)
table(is.na(welfare$group_marriage))
qplot(welfare$group_marriage)