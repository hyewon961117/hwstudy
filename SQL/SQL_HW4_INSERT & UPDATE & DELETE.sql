# 3장 3절 -- 데이터 변경을 위한 SQL 문
use market_db;

# 데이터 입력 : INSERT INTO ~ VALUE ~
CREATE TABLE hongong1 (toy_id INT, toy_name CHAR(4), age INT);
INSERT INTO hongong1 VALUE (1, '우디', 25);
SELECT * FROM hongong1;

# 아이디와 이름만 입력하고 나이는 입력하지 않음
INSERT INTO hongong1 (toy_id, toy_name) VALUE(2, '버즈'); -- 3번째 값을 입력하지않아 NULL값으로 들어감
SELECT * FROM hongong1;
# 삭제하고 싶을때 언세이프 옵션을 끄기 쿼리
# DELETE FROM hongong1 WHERE toy_name = "우디" SET SQL_SAFE_UPDATES=0;

# 열의 순서를 바꿔서 입력하고 싶을때는 열 이름과 값을 원하는 순서에 맞춰 써주면 됨
INSERT INTO hongong1(toy_name, age, toy_id) VALUE('제시', 20, 3);
SELECT * FROM hongong1;

CREATE TABLE hongong2(
	toy_id INT auto_increment PRIMARY KEY,
    toy_name CHAR(4),
    age INT);
SELECT * FROM hongong2;
INSERT INTO hongong2 VALUE(NULL, '보핍', 25);
INSERT INTO hongong2 VALUE(NULL, '슬랭키', 22);
INSERT INTO hongong2 VALUE(NULL, '렉스', 21);
SELECT * FROM hongong2;

# 어느 숫자까지 증가되었는지 확인
SELECT last_insert_id(); -- 마지막 인덱스 아이디 확인

# ALTER TABLE ~
# auto_increment로 입력되는 다음 값을 100부터 시작하도록 변경
ALTER TABLE hongong2 auto_increment=100;
INSERT INTO hongong2 VALUE(NULL, '재남', 35);
SELECT * FROM hongong2;

# 처음부터 입력되는 값을 1000으로 지정
CREATE TABLE hongong3(
	toy_id INT auto_increment PRIMARY KEY,
    toy_name CHAR(4),
    age INT);
ALTER TABLE hongong3 auto_increment = 1000;
set @@auto_increment_increment=3; -- 증가값이 3씩 증가하도록 지정

# @@ 골뱅이 두개는 시스템 변수
# 전체 시스템 변수의 종류 확인 
SHOW GLOBAL VARIABLES;

SELECT * FROM hongong3;
INSERT INTO hongong3 VALUE(NULL, '토마스', 20);
INSERT INTO hongong3 VALUE(NULL, '제임스', 23);
INSERT INTO hongong3 VALUE(NULL, '고든', 25);
SELECT * FROM hongong3;

# 다른 테이블의 데이터를 한번에 입력하는 INSERT INTO ~ SELECT
# USE world를 하지 않고 wolrd 데이터베이스의 city 테이블에 접근
SELECT world.city;
SELECT count(*) FROM world.city;

# DESC -- describe의 약자 (내림차순과 헷갈리지 않게 주의)
DESC world.city;

SELECT * FROM world.city
	LIMIT 5;

CREATE TABLE city_popul(
	city_name CHAR(35),
    population INT);

# SELECT문으로 데이터 입력
INSERT INTO city_popul
	SELECT Name, Population FROM world.city;

SELECT * FROM city_popul limit 5;

# 데이터 수정 : UPDATE

SELECT * FROM city_popul
	WHERE city_name = 'Seoul';
    
# Seoul을 서울로 변경 -- 영어를 한국어로 수정
update city_popul
	SET city_name = '서울'
	WHERE city_name = 'Seoul';

SELECT * FROM city_popul
	WHERE city_name = 'Seoul';

SELECT * FROM city_popul
	WHERE city_name = '서울';
    
# 뉴욕(New York)을 찾아서 한국어 뉴욕으로 바꾸고 인구수도 0으로 만드시오.
SELECT * FROM city_popul
	WHERE city_name = "New York";

UPDATE city_popul
	SET city_name = "뉴욕", population = 0
	WHERE city_name = "New York";

SELECT * FROM city_popul
	WHERE city_name = "뉴욕";

# 모든 인구 열을 한꺼번에 10000으로 나누기
SELECT * FROM city_popul
	LIMIT 5;

UPDATE city_popul
	set population = population / 10000; -- where절 입력하지 않아서 모든 행의 값이 변경됨
    
SELECT * FROM city_popul
	LIMIT 5;

# 주의 : WHERE가 없는 UPDATE문
-- WHERE절을 생략하면 테이블의 모든 행의 값이 변경됨
SELECT * FROM city_popul
	LIMIT 20;

UPDATE city_popul
	set city_name = '서울';

SELECT * FROM city_popul
	LIMIT 20;

# 데이터 삭제 : DELETE 
DELETE FROM city_popul 
	WHERE city_name like 'New%';

DELETE FROM city_popul 
	WHERE city_name like 'New%' 
    LIMIT 5; -- limit로 삭제 개수 제한 걸 수 있음 (상위 5건만 삭제)

# 대용량 데이터 만들기
CREATE TABLE big_table1(
	SELECT * FROM world.city, sakila.country);

CREATE TABLE big_table2(
	SELECT * FROM world.city, sakila.country);
    
CREATE TABLE big_table3(
	SELECT * FROM world.city, sakila.country);

SELECT count(*) FROM big_table1;

# 동일한 내용의 대용량 테이블 3개를 각각 다른 방법으로 삭제해보기
-- DELETE : 속도가 오래 걸림, 빈 테이블이 남음
-- RUNCATE와의 차이 : 조건문 가능, 속도 느림
DELETE FROM big_table1; -- 시간이 조금 걸림
SELECT * FROM big_table1; -- 모든 행의 값은 지워졌지만 열들은 남아있음

-- DROP : 테이블 자체를 삭제
DROP TABLE big_table2; -- 거의 바로 실행됨

-- TRUNCATE : 빈 테이블이 남음
-- DELETE와의 차이 : 조건문 불가, 속도 빠름
TRUNCATE TABLE big_table3;
SELECT * FROM big_table3;