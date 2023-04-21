USE market_db; -- market_db 스키마를 사용하겠다.

SELECT * FROM member; -- member 테이블에서 전체 컬럼을 가져온다

# sakila 스키마 더블클릭으로 선택해놓고 아래 구문 돌리기
SELECT * FROM market_db.member; -- 다른 스키마에서 불러오기 (use한 스키마가 변경이 되진 않음)

SELECT addr, debut_date, mem_name FROM member;

SELECT addr, debut_date "데뷰 일자", mem_name FROM member;

SELECT * FROM member WHERE mem_name = '블랙핑크';

# 멤버수가 4명인 그룹의 모든 컬럼을 가져오기
SELECT * FROM member WHERE mem_number = 4;

SELECT mem_id, mem_name FROM member WHERE height >162;

# 키가 165 초과 그리고 멤버수가 6명 이상인 동시에 만족하는 그룹
# 이름 키 멤버수 가져오기
SELECT mem_name, height, mem_number 
	FROM member 
    WHERE height>165 and mem_number>=6;
    
# 키가 165 초과 또는 멤버수가 6명 이상인 그룹
SELECT mem_name, height, mem_number 
	FROM member 
    WHERE height>165 or mem_number>=6;
    
# 키가 163 이상 165이하의 멤버 이름 키를 출력
SELECT mem_name, height 
	FROM member 
	WHERE height >= 163 and height <= 165;

SELECT mem_name, height 
	FROM member 
	WHERE height between 163 and 165;
    
# addr 경기 전남 경남 하나인 그룹의 이름과 주소를 조회
SELECT mem_name, addr
	FROM member
    WHERE addr = '경기' or addr = '전남' or addr = '경남';

SELECT mem_name, addr
	FROM member
    WHERE addr IN('경기','경남','전남');

# LIKE
SELECT *
	FROM member
    WHERE mem_name like '우%';
    
SELECT *
	FROM member
    WHERE mem_name like '__핑크';

SELECT *
	FROM member
    WHERE mem_name like '%랙%';
    
# 서브쿼리
SELECT height FROM member WHERE mem_name = '에이핑크';

# 에이핑크의 키보다 큰 그룹을 찾는 쿼리
SELECT mem_name, height
	FROM member
    WHERE height > (SELECT height FROM member WHERE mem_name = '에이핑크');
    
# bookstore 라는 스키마를 만들고 3개의 테이블 생성
CREATE SCHEMA bookstore; -- CREATE DATABASE bookstore;
USE bookstore;
CREATE TABLE Book(
	bookid INT PRIMARY KEY,
    bookname VARCHAR(40),
    publisher VARCHAR(40),
    price INT);

CREATE TABLE Customer(
	custid INT PRIMARY KEY,
    username VARCHAR(40),
    address VARCHAR(50),
    phone VARCHAR(20));

CREATE TABLE Orders(
	orderid INT PRIMARY KEY,
    custid INT,
    bookid INT,
    saleprice INT,
    orderdate DATE,
    FOREIGN KEY (custid) REFERENCES Customer(custid),
	FOREIGN KEY (bookid) REFERENCES Book(bookid));

INSERT INTO Book values(1,'철학의 역사','정론사',7500);
INSERT INTO Book values(2,'3D 모델링 시작하기','한비사',15000);
INSERT INTO Book values(3,'SQL의 이해','새미디어',2200);
INSERT INTO Book values(4,'텐서플로우 시작','새미디어',3500);
INSERT INTO Book values(5,'인공지능 개론','정론사',8000);
INSERT INTO Book values(6,'파이썬 고급','정론사',8000);
INSERT INTO Book values(7,'객체지향 Java','튜링사',20000);
INSERT INTO Book values(8,'C++ 중급','튜링사',18000);
INSERT INTO Book values(9,'Secure 코딩','정보사',7500);
INSERT INTO Book values(10,'Machine learning 이해','새미디어',32000);

SELECT * FROM Book;

INSERT INTO Customer values(1,'박지성','영국 맨체스타','010-1234-1010');
INSERT INTO Customer values(2,'김연아','대한민국 서울','010-1223-3456');
INSERT INTO Customer values(3,'장미란','대한민국 강원도','010-4878-1901');
INSERT INTO Customer values(4,'추신수','대한민국 부산','010-8000-8765');
INSERT INTO Customer values(5,'박세리','대한민국 대전',NULL);

SELECT * FROM Customer;

# orderid custid bookid saleprice orderdate
INSERT INTO Orders values(1,1,1,7500,str_to_date('2021-02-01','%Y-%m-%d'));
INSERT INTO Orders values(2,1,3,44000,str_to_date('2021-02-03','%Y-%m-%d'));
INSERT INTO Orders values(3,2,5,8000,str_to_date('2021-02-03','%Y-%m-%d'));
INSERT INTO Orders values(4,3,6,8000,str_to_date('2021-02-04','%Y-%m-%d'));
INSERT INTO Orders values(5,4,7,20000,str_to_date('2021-02-05','%Y-%m-%d'));
INSERT INTO Orders values(6,1,2,15000,str_to_date('2021-02-07','%Y-%m-%d'));
INSERT INTO Orders values(7,4,8,18000,str_to_date('2021-02-07','%Y-%m-%d'));
INSERT INTO Orders values(8,3,10,32000,str_to_date('2021-02-08','%Y-%m-%d'));
INSERT INTO Orders values(9,2,10,32000,str_to_date('2021-02-09','%Y-%m-%d'));
INSERT INTO Orders values(10,3,8,18000,str_to_date('2021-02-10','%Y-%m-%d'));

SELECT * FROM Orders;

/*1. 산술 연산자*/
select 1;
select 1+1;
select 0.1;
select 1-1;
select 100/20;
select 5.0/2;

USE bookstore;
/* book 테이블에서 price 값에 0.05*/
select price * 0.05 from book;
select price / 2 from book;
select (price/2) * 100 from book;

/* 2.비교 연산자*/
select 1>100;
select 1<100;
select 10=10;
select 101<>10; -- 같지 않다
select 101!=10; -- 같지 않다

/* 3.논리연산자 */
select (10>=10) and (5<10);
select (10>10) or (5<10);
select not (10>10);

/*4. 집계함수 */
# 북스토에서 판매한 건수
select count(*) from orders;

# 고객이 주문한 도서의 총 판매액을 구하시오
select sum(saleprice) from orders;

# 고객이 주문한 도서의 총 판매액인데 '총매출'로 표시
select sum(saleprice) as 총매출 from orders;
select avg(saleprice) as 매출평균 from orders;

# 판매액 합계, 평균, 최저, 최고가 구하기
select sum(saleprice) as 총매출액,
		avg(saleprice) as 매출평균, 
		min(saleprice) as 최저가,
        max(saleprice) as 최고가
	from orders;

# 1. 가격이 만원보다 크고 2만원 이하인 도서를 검색
# 2. 주문일자가 2021/02/01 에서 2021/02/07 내 주문내역 검색
# 3. 도서번호가 3,4,5,6인 주문목록 출력
# 4. 박씨성을 가진 고객 출력
# 5. 2번째 글자가 '지'인 고객출력
# 6. '철학의 역사'를 출간한 출판사 검색
# 7. 도서이름에 썬으로 일치하고 2000원 이상인 도서

-- 1. 가격이 만원보다 크고 2만원 이하인 도서를 검색
SELECT * FROM book
	WHERE price BETWEEN 10000 and 20000;

-- 2. 주문일자가 2021/02/01 에서 2021/02/07 내 주문내역 검색
SELECT * FROM Orders
	WHERE orderdate BETWEEN '2021-01-02' and '2021-02-07';

-- 3. 도서번호가 3,4,5,6인 주문목록 출력
SELECT * FROM Orders
	WHERE bookid IN (3,4,5,6);

-- 4. 박씨성을 가진 고객 출력
SELECT * FROM Customer
	WHERE username like "박%";

-- 5. 2번째 글자가 '지'인 고객출력
SELECT * FROM Customer
	WHERE username like "_지%";
    
-- 6. '철학의 역사'를 출간한 출판사 검색
SELECT publisher FROM book
	WHERE bookname = "철학의 역사"; -- WHERE bookname = like "철학의 역사"

-- 7. 도서이름에 썬으로 일치하고 2000원 이상인 도서
SELECT * FROM book
	WHERE bookname LIKE "%썬%" and price>=2000;
    
-- 8. 출판사 이름이 '정론사' 혹은 '새미디어'인 도서를 검색
SELECT * FROM book
	WHERE publisher = '정론사' or publisher = '새미디어';




