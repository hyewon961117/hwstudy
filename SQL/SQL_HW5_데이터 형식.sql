# 4-1 데이터 형식

USE market_db;

# 정수형
-- 데이터 형식 / 바이트 수 / 숫자 범위
-- tinyint / 1 / -128 ~ 127
-- smallint / 2 / -32,768 ~ 32,767
-- int / 4 / 약 -21억 ~ 21억
-- bigint / 8 / 약 -900경 ~ 900경
-- unsigned 예약어 - 부분을 +으로 변경함, 범위 내 값 수 동일 but 음수 값은 없음

CREATE TABLE hongong4(
	tinyint_col tinyint,
    smallint_col smallint,
    int_col int,
    bigint_col bigint);

INSERT INTO hongong4 value(127, 32767, 2147483647,9000000000000000000);
SELECT * FROM hongong4;

# Out of range 오류 : 입력값의 범위를 벗어났다는 의미
INSERT INTO hongong4 value(128, 32767, 2147483647,90000000000000000000);
INSERT INTO hongong4 value(127, 32768, 2147483647,90000000000000000000);
INSERT INTO hongong4 value(127, 32767, 2147483648,90000000000000000000);
INSERT INTO hongong4 value(127, 32767, 2147483647,900000000000000000000);

DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id char(8) not null primary key, -- 회원 아이디(pk)
    mem_name varchar(10) not null, -- 이름 가변으로 들어갈 예정
    mem_number int not null, -- 인원수
    addr char(2) not null, -- 주소(경기, 서울, 경남 등 2글자만 입력)
    phone1 char(3), -- 연락처의 국번(02, 031, 055 등)
    phone2 char(8), -- 연락처의 나머지 전화번호(하이픈 제외)
    height smallint, -- 평균 키
    debut_date date); -- 데뷔일자

# 데이터타입을 더 효율적으로 적용하기
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    mem_number tinyint not null, -- 멤버수 127명 이상인 그룹이 없기 떄문
    addr char(2) not null,
    phone1 char(3),
    phone2 char(8),
    height tinyint unsigned, -- tinyint unsigned 예약어 -- 0 ~ 256으로 바꿈
    debut_date date);

# 문자형
-- 데이터 형식 / 바이트 수
-- char(개수) / 1 ~ 255
-- varchar(개수) / 1 ~ 16383

DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id char(8) not null primary key,
    mem_name varchar(10) not null,
    mem_number tinyint not null,
    addr char(2) not null,
    phone1 char(3),
    phone2 char(8),
    height tinyint unsigned,
    debut_date date);
    
# 대량의 데이터 형식
-- text / 1~ 65535
-- longtext / 1 ~ 4294967295
-- blob : 글자가 아닌 이미지, 동영상 등의 데이터(이진 데이터)
-- blob / 1~ 65535
-- longblob / 1 ~ 4294967295

CREATE DATABASE neflix_db;
USE neflix_db;
CREATE TABLE movie(
	movie_id int,
    movie_title varchar(30),
    movie_director varchar(30),
    movie_star varchar(30),
    movie_script longtext, -- 최대 42억자
    movie_film longblob); -- 최대 4G

# 실수형 : 소수점이 있는 숫자를 저장할 때 사용
-- 데이터 형식 / 바이트 수 / 설명
-- FLOAT / 4 / 소수점 아래 7자리까지 표현
-- DOUBLE / 8 / 소수점 아래 15자리까지 표현

# 날짜형  : 날짜 및 시간을 저장할 때 사용
-- 데이터 형식 / 바이트 수 / 설명
-- DATE / 3 / 날짜만 저장, YYYY-MM-DD 형식으로 사용
-- TIME / 3 / 시간만 저장, HH:MM:SS 형식으로 사용
-- DATETIME / 8 / 날짜 및 시간을 저장, YYYY-MM-DD HH:MM:SS 형식으로 사용
-- 날짜 또는 시간을 입력할 때는 문자와 마찬가지로 작은따옴표로 묶어줘야함

# 변수의 사용
# SET @변수이름 = 변수의 값; -- 변수 선언 및 값 대입
# SELECT @변수이름; -- 변수의 값 출력

USE market_db;
SET @myVar1 = 5;
SET @myVar2 = 4.52;

SELECT @myVar1;
SELECT @myVar1 + @myVar2;

SET @txt = "가수 이름 ==>";
SET @height = 166;
SELECT @txt, mem_name FROM member 
	WHERE height> @height; -- 변수가 대신 들어갈 수 있다.

SET @count = 3;
SELECT mem_name, height FROM member
	ORDER BY height 
    LIMIT @count; -- LIMIT에는 변수를 사용할 수 없기 때문에 오류 발생
 
# 이를 해결하는것이 PREPARE와 EXECUTE
# PREPARE는 실행하지 않고 SQL문만 준비해놓고 EXECUTE에서 실행하는 방식
SET @count = 3;
PREPARE mysql FROM 'SELECT mem_name, height FROM member ORDER BY height LIMIT ?';
EXECUTE mysql USING @count;
 
# 데이터 형 변환
-- CAST(값 AS 데이터형식(길이))
-- CONVERT(값, 데이터형식(길이))
SELECT avg(price) '평균가격' FROM buy;
# 실수를 정수로 형 변환 -- signed integer
SELECT CAST(avg(price) AS signed) '평균가격' FROM buy;
SELECT CONVERT(avg(price), signed) '평균가격' FROM buy;

# 다양한 구분자를 날짜형으로 변경
SELECT CAST('2022$12$12' AS DATE);
SELECT CAST('2022/12/12' AS DATE);
SELECT CAST('2022%12%12' AS DATE);
SELECT CAST('2022@12@12' AS DATE);

# concat() 함수는 문자를 이어주는 역할을 함
SELECT num, concat(CAST(price AS char), 'X', CAST(amount AS char), "=") '가격x수량', price*amount '구매액' FROM buy;

# 임시적인 변환 
-- CAST()나 CONVERT() 함수를 사용하지 않고도 자연스럽게 형이 변환되는것을 말함
SELECT '100'+'200'; -- 자동으로 형변환되어 계산값인 300 출력됨
SELECT concat('100','200'); -- concat으로 묶어 100200 출력
SELECT concat(100,'200'); -- concat으로 묶어 100200 출력
SELECT 1> '2mega'; -- 정수인 2로 변환해서 비교
SELECT 3> '2MEGA'; -- 정수인 2로 변환해서 비교
SELECT 0 = 'mega2'; -- 숫자를 뒤에 써주면 문자로 인식, 문자는 0으로 변환되어 비교