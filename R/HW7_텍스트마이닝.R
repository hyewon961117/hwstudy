# Tolls, global 옵션, code, saving, defalt encoding UTF-8
# p265 힙합 가사 텍스트 마이닝
library(dplyr)
library(ggplot2)
library(readxl)

install.packages("multilinguer")
library(multilinguer)
install_jdk(run='yes') # 자바 개발 도구 설치
install.packages(c("stringr","hash","tau","Sejong","RSQLite","decvtools"), type="binary") # 한글 분석을 위한 패키지 설치
install.packages("remotes") # 깃허브하고 연결하는 패키지 설치
remotes::install_github("haven-jeon/KoNLP",upgrade="never",INSTALL_opts=c("--no-multiarch"))
library(KoNLP)
useNIADic()

txt <- readLines("data/hiphop.txt")
head(txt)
library(stringr)
txt <- str_replace_all(txt,"\\W"," ") # \\W 특수문자제거, 공백으로 구분하겠다.

extractNoun("대한민국의 영토는 한반도와 그 부속 도서로 한다") # 명사만 추출, 조사는 빠짐

nouns <- extractNoun(txt)

# 추출한 명사 list를 문자열 벡터로 변환, 단어별 빈도표 생성
wordcount <- table(unlist(nouns))
wordcount

# 데이터 프레임으로 변환
df_word <- as.data.frame(wordcount,stringsAsFactors = F)

# 변수명 수정
df_word <- rename(df_word, word=Var1, freq = Freq)

# 두 글자 이상 단어 추출
df_word <- filter(df_word,nchar(word)>=2)

# 빈도순으로 정렬한 후 상위 20개 단어 추출
top_20 <- df_word %>% arrange(desc(freq)) %>% head(20)
top_20

# 워드 클라우드 만들기
install.packages("wordcloud")
library(wordcloud)
library(RColorBrewer)
pal <- brewer.pal(8,"Dark2")
set.seed(2023)
wordcloud(words=df_word$word,      # 단어
          freq = df_word$freq,     # 빈도
          min.freq = 2,            # 최소 단어 빈도
          max.words = 200,         # 표현 단어 수
          random.order = F,        # 고빈도 단어 중앙 배치
          rot.per = .1,            # 회전 단어 비율
          scale = c(4, 0.3),       # 단어 크기 범위
          colors = pal)            # 색상 목록

pal2 <- brewer.pal(9,"Blues")[5:9]
set.seed(1234)
wordcloud(words=df_word$word,      # 단어
          freq = df_word$freq,     # 빈도
          min.freq = 2,            # 최소 단어 빈도
          max.words = 200,         # 표현 단어 수
          random.order = F,        # 고빈도 단어 중앙 배치
          rot.per = .1,            # 회전 단어 비율
          scale = c(4, 0.3),       # 단어 크기 범위
          colors = pal2)            # 색상 목록


# p273 국정원 트윗 텍스트 마이닝

library(dplyr)
library(multilinguer)
library(KoNLP)
library(stringr)
library(wordcloud)
library(RColorBrewer)
useNIADic()

twitter <- read.csv("data/twitter.csv", header=T, fileEncoding="UTF-8")
View(twitter)

# 변수명 수정
twitter <- rename(twitter, no=번호, id=계정이름, date=작성일, tw=내용)
View(twitter)

# 특수문자 제거
twitter$tw <- str_replace_all(twitter$tw, "\\W"," ")

# 트윗에서 명사 추출
nouns <- extractNoun(twitter$tw)

# 추출한 명사 list를 문자열 벡터로 변환, 단어별 빈도표 생성
wordcount <- table(unlist(nouns))

# 데이터 프레임으로 변환
df_word <- as.data.frame(wordcount, stringsAsFactors=F)
head(df_word)

# 변수명 수정
df_word <- rename(df_word, word=Var1, freq=Freq)

# 두 글자 이상 단어만 추출
df_word <- filter(df_word, nchar(word)>=2)

# 상위 20개 추출
top_20 <- df_word %>% arrange(desc(freq)) %>% head(10)
top_20

# 빈도 순서 변수 생성
order <- arrange(top_20,freq)$word
order

# 빈도 순 가로 막대 그래프
ggplot(data=top_20, aes(x=word,y=freq)) + geom_col()+ 
  ylim(0,2500) + coord_flip() + scale_x_discrete(limit=order) + 
  geom_text(aes(label=freq),hjust=-0.3)

# 워드 클라우드 만들기
pal <- brewer.pal(8,"Dark2")
set.seed(2023)
wordcloud(words=df_word$word, 
          freq=df_word$freq, 
          min.freq=10,
          max.words=200,
          random.order =F, 
          rot.per=0,
          scale=c(6,0.5),
          colors=pal)

