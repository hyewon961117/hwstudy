# cmd창에서 pymysql 설치
# CREATE DATABASE soloDB; -- SQL에서 실행

# 파이썬하고 SQL하고 연동
import pymysql
conn = pymysql.connect(host='127.0.0.1', user='user1', password='0000', db='soloDB', charset='utf8')
# 커서는 데이터베이스에 SQL문을 실행하거나 실행된 결과를 돌려받는 통로로 생각하면됨
cur = conn.cursor()
# SQL 구문 입력 : 세미콜론 넣지않음
cur.execute("create table userTable(id char(4), userName char(15), email char(20), birthYear int)")
cur.execute("insert into userTable values('hong','홍지윤','hong@naver.com',1996)")
cur.execute("insert into userTable values('kim','김태연','kim@daum.net',2011)")
cur.execute("insert into userTable values('star','별사랑','star@paran.com',1990)")
cur.execute("insert into userTable values('yang','양지은','yang@gmail.com',1993)")
# 확실하게 저장/ 데이터베이스 내 적용
conn.commit()
# 연결한 데이터베이스 닫기
conn.close()