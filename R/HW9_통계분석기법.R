library(ggplot2)
library(dplyr)
mpg <- as.data.frame(ggplot2::mpg)

#compact, suv 도시연비(cty)가 차이가 있는지 검증 추론통계(t-test 검정)
mpg_diff <- mpg %>% select(class,cty) %>% 
  filter(class %in% c("compact", "suv"))

head(mpg_diff)
table(mpg_diff$class)

# t.test
t.test(data = mpg_diff, cty~class, var.equal=T)
# p-value 값이 0.05보다 작으므로 귀무가설 기각, 통계적으로 유의하다는 결론

# 일반휘발유 고급휘발유 도시 연비 t검정
mpg_diff2 <- mpg %>% select(fl,cty) %>% filter(fl %in% c('r','p')) #regular, premium
table(mpg_diff2$fl)

t.test(data=mpg_diff2, cty~fl, var.equal=T)
# p-value 값이 0.05보다 크므로 귀무가설 채택, 통계적으로 유의하지않다는 결론

# 상관관계 분석 correlation
eco <- as.data.frame(ggplot2::economics)
cor.test(eco$unemploy, eco$pce)

# 상관관계행렬 히트맵 만들기
head(mtcars)
car_cor <- cor(mtcars) # 상관행렬 만들기
car_cor

install.packages("corrplot")
library(corrplot)
corrplot(car_cor)
corrplot(car_cor,method="number")

col <- colorRampPalette(c("#BB4444","#EE9988","#FFFFFF","#77AADD","#4477AA"))

corrplot(car_cor, method="color",    # 색깔로 표현
         col = col(200),             # 색상 200개 선정
         type = "lower",             # 왼쪽 아래 행렬만 표시
         order = "hclust",           # 유사한 상관계수끼리 군집화
         addCoef.col = "black",      # 변수명 색깔
         tl.col ="black",            # 변수명 색깔
         tl.srt = 45,                # 변수명 45도 기울임
         diag = F)                   # 대각 행렬 제외
