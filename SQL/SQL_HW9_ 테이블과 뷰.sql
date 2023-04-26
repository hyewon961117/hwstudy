# 5-1 테이블 만들기

# 데이터베이스 생성하기
CREATE DATABASE naver_db;
USE naver_db;

# GUI로 테이블 만들기
-- member 테이블 만들기
CREATE TABLE `naver_db`.`member` (
  `mem_id` CHAR(8) NOT NULL,
  `mem_name` VARCHAR(10) NOT NULL,
  `mem_number` TINYINT NOT NULL,
  `addr` CHAR(2) NOT NULL,
  `phone1` CHAR(3) NULL,
  `phone2` CHAR(8) NULL,
  `height` TINYINT UNSIGNED NULL,
  `debut_date` DATE NULL,
  PRIMARY KEY (`mem_id`));

-- buy테이블 만들기
CREATE TABLE `naver_db`.`buy` (
  `num` INT NOT NULL AUTO_INCREMENT,
  `mem_id` CHAR(8) NOT NULL,
  `prod_name` CHAR(6) NOT NULL,
  `group_name` CHAR(4) NULL,
  `price` INT UNSIGNED NULL,
  `amount` SMALLINT UNSIGNED NULL,
  PRIMARY KEY (`num`),
  FOREIGN KEY(mem_id) REFERENCES member(mem_id));
  
-- 값 넣기
INSERT INTO `naver_db`.`member` (`mem_id`, `mem_name`, `mem_number`, `addr`, `phone1`, `phone2`, `height`, `debut_date`) VALUES ('TWC', '트와이스', '9', '서울', '02', '11111111', '167', '2015.10.19');
INSERT INTO `naver_db`.`member` (`mem_id`, `mem_name`, `mem_number`, `addr`, `phone1`, `phone2`, `height`, `debut_date`) VALUES ('BLK', '블랙핑크', '4', '경남', '055', '22222222', '163', '2016.08.08');
INSERT INTO `naver_db`.`member` (`mem_id`, `mem_name`, `mem_number`, `addr`, `phone1`, `phone2`, `height`, `debut_date`) VALUES ('WMN', '여자친구', '6', '경기', '031', '33333333', '166', '2015.01.15');

INSERT INTO `naver_db`.`buy` (`mem_id`, `prod_name`, `price`, `amount`) VALUES ('BLK', '지갑', '30', '2');
INSERT INTO `naver_db`.`buy` (`mem_id`, `prod_name`, `group_name`, `price`, `amount`) VALUES ('BLK', '맥북프로', '디지털', '1000', '1');

# 테이블 지우기
DROP TABLE IF EXISTS buy, member;

# 코드로 테이블 만들기
# 기본키 설정 방법 1
CREATE TABLE member(
	mem_id CHAR(8) not null primary key,
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned null);

DESCRIBE member; -- 표를 요약해서 볼 수 있음 

# 테이블 지우기
DROP TABLE IF EXISTS buy, member;

# 기본키 설정 방법 2
CREATE TABLE member(
	mem_id CHAR(8) not null,
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned,
    primary key(mem_id));

# 테이블 지우기
DROP TABLE IF EXISTS buy, member;

# 기본키 설정 방법 3
# primary key 나중에 지정
CREATE TABLE member(
	mem_id CHAR(8) not null,
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned);
-- ALTER 쿼리를 활용해서 지정
ALTER TABLE member -- 멤버테이블을 변경
	ADD CONSTRAINT -- 제약 조건 추가
	primary key(mem_id);
DESCRIBE member; -- 프라이머리키 지정되었는지 확인


DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null,
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned,
    CONSTRAINT primary key PK_member_mem_id (mem_id)); -- 기본키에 별도의 이름 설정
DESCRIBE member;

# 외래키
# 외래키 설정 방법1
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null, -- 기본키가 없음
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned);

CREATE TABLE buy(
	num INT auto_increment not null primary key,
	mem_id CHAR(8) not null,
    prod_name CHAR(6) not null,
    FOREIGN KEY(mem_id) REFERENCES member(mem_id)); -- 오류 / member table에 기본키가 없어서 외래키를 지정할 수 없음

# member 테이블에 기본키를 추가한 뒤 buy테이블에 외래키 연결
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null primary key, -- 기본키 지정
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned);

CREATE TABLE buy(
	num INT auto_increment not null primary key,
	user_id CHAR(8) not null,
    prod_name CHAR(6) not null,
    FOREIGN KEY(user_id) REFERENCES member(mem_id)); -- 기준테이블과 참조테이블의 외래키의 컬럼명이 같을 필요는 없다.

# 외래키 설정 방법2
DROP TABLE IF EXISTS buy;
CREATE TABLE buy(
	num INT auto_increment not null primary key,
	mem_id CHAR(8) not null,
    prod_name CHAR(6) not null);
DESCRIBE buy;
ALTER TABLE buy
	ADD CONSTRAINT
    FOREIGN KEY(mem_id) REFERENCES member(mem_id);
DESCRIBE buy;

INSERT INTO member VALUES('BLK', '블랙핑크', 163);
INSERT INTO buy values(null, 'BLK', '지갑');
INSERT INTO buy values(null, 'BLK', '맥북');

SELECT * FROM member;
SELECT * FROM buy;

# 기본키 - 외래키로 맺어진 후에는 기준 테이블의 열 이름이 변경되지않음
UPDATE member SET mem_id='PINK' WHERE mem_id="BLK"; -- 변경 불가 오류
DELETE FROM member WHERE mem_id = 'BLK'; -- 삭제 불가 오류

# 기준 테이블의 열 이름이 변경될 때 참조 테이블의 열 이름이 자동으로 변경되게 하는 구문
DROP TABLE IF EXISTS buy;
CREATE TABLE buy(
	num INT auto_increment not null primary key,
	mem_id CHAR(8) not null,
    prod_name CHAR(6) not null);
DESCRIBE buy;
ALTER TABLE buy
	ADD CONSTRAINT
    FOREIGN KEY(mem_id) REFERENCES member(mem_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE;
DESCRIBE buy;
INSERT INTO buy values(null, 'BLK', '지갑');
INSERT INTO buy values(null, 'BLK', '맥북');

UPDATE member SET mem_id='PINK' WHERE mem_id="BLK";
DELETE FROM member WHERE mem_id = 'PINK';

SELECT * FROM member;
SELECT * FROM buy;

# UNIQUE 제약조건
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null primary key, 
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned null,
    email CHAR(30) null unique); -- 이메일 중복 안됨 지정
INSERT INTO member VALUES('BLK', '블랙핑크', 163, 'pink@gmail.com');
INSERT INTO member VALUES('TWC', '트와이스', 167, null);
INSERT INTO member VALUES('APN', '에이핑크', 164, 'pink@gmail.com'); -- 오류 / 이메일 중복값이 들어가기때문 (null값은 중복 가능)

# CHECK 제약조건
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null primary key, 
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned null check (height >= 100),
    phone1 CHAR(3) null);
INSERT INTO member VALUES('BLK', '블랙핑크', 163, null);
INSERT INTO member VALUES('TWC', '트와이스', 99, null); -- 오류 / check문에서 거짓이기 때문에 에러

# 테이블을 만든 후 제약조건 추가 가능
ALTER TABLE member
	ADD CONSTRAINT
    CHECK (phone1 IN ('02', '031', '032', '054', '055', '061'));

INSERT INTO member VALUES('TWC', '트와이스', 167, '02');
INSERT INTO member VALUES('OMY', '오마이걸', 167, '010'); -- 오류 / check문에서 거짓이기 때문에 에러

# 기본값 제약조건
DROP TABLE IF EXISTS buy, member;
CREATE TABLE member(
	mem_id CHAR(8) not null primary key, 
    mem_name VARCHAR(10) not null,
    height TINYINT unsigned default 160, -- 160이라는 값을 디폴트값으로 지정
    phone1 CHAR(3) null);
    
# 테이블을 만든 후 제약조건 추가 가능
ALTER TABLE member
	ALTER COLUMN phone1 SET DEFAULT '02'; -- 입력하지 않으면 자동으로 02가 입력되도록 설정

INSERT INTO member VALUES('RED', '레드벨벳', 161, '054');
INSERT INTO member VALUES('SPC', '우주소녀', default, default);
INSERT INTO member VALUES('OMY', '오마이걸', null, null);

SELECT * FROM member;

# 5-3 가상의 테이블 뷰
-- market_db 초기화 후 진행하기
USE market_db; 
SELECT mem_id, mem_name, addr FROM member;

# 뷰를 만드는 형식
CREATE VIEW v_member 
	AS SELECT mem_id, mem_name, addr FROM member;

# 마치 테이블이 있는것처럼 불러올 수 있음. but 테이블은 아니고 바로가기 형태 느낌
SELECT * FROM v_member;

SELECT mem_name, addr FROM v_member
	WHERE addr in ('서울', '경기');
    
# 뷰를 사용하는 이유
-- 보안에 도움이됨
-- 복잡한 SQL을 단순하게 만들 수 있음
SELECT B.mem_id, M.mem_name, B.prod_name, M.addr, concat(M.phone1, M.phone2) '연락처' FROM buy B
	INNER JOIN member M 
    ON B.mem_id = M.mem_id;

# 복잡한 SQL을 뷰로 만들기
CREATE VIEW v_memberbuy
	AS SELECT B.mem_id, M.mem_name, B.prod_name, M.addr, concat(M.phone1, M.phone2) '연락처' FROM buy B
		INNER JOIN member M 
		ON B.mem_id = M.mem_id;

SELECT * FROM v_memberbuy WHERE mem_name = '블랙핑크';

# 뷰의 생성
CREATE VIEW v_viewtest1
	AS SELECT B.mem_id 'Member ID', M.mem_name as 'Member Name', B.prod_name 'Prodict Name', concat(M.phone1, M.phone2) as 'Office Phone' FROM buy B
		INNER JOIN member M 
		ON B.mem_id = M.mem_id;
SELECT * FROM v_viewtest1;
SELECT `Member ID`, `Member Name` FROM v_viewtest1; -- 별칭으로 뷰를 조회할 때는 열 이름에 공백이 있으면 `(백틱)으로 묶어줘야함

# 뷰 수정
ALTER VIEW v_viewtest1
	AS SELECT B.mem_id '회원 ID', M.mem_name as '회원 이름', B.prod_name '제품 이름', concat(M.phone1, M.phone2) as '연락처' FROM buy B
		INNER JOIN member M 
		ON B.mem_id = M.mem_id;
SELECT * FROM v_viewtest1;
SELECT DISTINCT `회원 ID`, `회원 이름` FROM v_viewtest1; -- 별칭으로 뷰를 조회할 때는 열 이름에 공백이 있으면 `(백틱)으로 묶어줘야함

# 뷰의 삭제
DROP VIEW v_viewtest1;

# CREATE VIEW 와 다르게 기존에 뷰가 있으면 덮어씀 (오류 발생X)
CREATE OR REPLACE VIEW v_viewtest2
	AS SELECT mem_id, mem_name, addr FROM member;

# 뷰도 테이블과 동일하게 정보를 보여줌
DESCRIBE v_viewtest2; -- 주의 : 기본 키 등의 정보는 확인할 수 없음
DESCRIBE member;

# 뷰의 소스 코드 확인
-- 코드 실행 후 Form Editor 클릭
SHOW CREATE VIEW v_viewtest2;

# 뷰를 통한 데이터의 수정 : 원본이 바뀌지 않음
SELECT * FROM v_member;
UPDATE v_member SET addr='부산' WHERE mem_id='BLK';
SELECT * FROM v_member;

# 값 추가 -- 뷰를 통해 데이터를 입력하려면 보이지않는 테이블의 열에 NOT NULL값이 없어야함
INSERT INTO v_member(mem_id, mem_name, addr) VALUES ('BTS', '방탄소년단', '경기'); -- 오류 

# 키가 167이상인 뷰를 만들어보자
CREATE VIEW v_height167
	AS SELECT * FROM member WHERE height>=167;

# 키가 167 이하인 데이터 삭제
SELECT @@sql_safe_updates; -- unsafe 옵션 : 지우기 방지 옵션
SET sql_safe_updates=0; -- 지우면 안된다는 옵션이 켜져있어서 꺼야 삭제 가능 (껐다 키면 다시 켜짐)
DELETE FROM v_height167 WHERE height < 167; -- 지워지는 동작은 하지만 조건에 맞는 데이터가 없어 0개가 지워짐

# 데이터를 입력
INSERT INTO v_height167 VALUES('TRA', '티아라', 6, '서울', null, null, 159, '2005-01-01');
-- 167 이하인 테이블인데 값이 들어감

SELECT * FROM v_height167; -- 입력은 됐으나 뷰에서 167이상 조건에 걸려 보이지않음

ALTER VIEW v_height167
	AS SELECT * FROM member WHERE height >= 167 WITH CHECK OPTION; -- 뷰에 설정된 갑의 범위가 벗어나는 값은 입력되지않도록 설정

INSERT INTO v_height167 VALUES('TOB', '텔레토비', 4, '영국', NULL, NULL, 140, '1995-01-01'); -- 오류 / 167 이하 입력 불가

# 하나의 테이블로 만든 뷰 - 단순 뷰 : 입력/수정/삭제 가능
# 두 개 이상의 테이블로 만든 뷰 - 복합 뷰 : 입력/수정/삭제 불가
# 테이블 삭제시 뷰는?

CREATE VIEW v_complex
	AS SELECT B.mem_id, M.mem_name, B.Prod_name, M.addr FROM buy B
		INNER JOIN member M ON B.mem_id = M.mem_id;

SELECT * FROM member;

DROP TABLE IF EXISTS buy, member;

SELECT * FROM v_height167;

# 실습 --------------------------------------------------------
USE bookstore;
INSERT INTO book VALUES(12, 'OpenCV 파이썬', '포웨이', 23500);
INSERT INTO book VALUES(13, '자연어 처리 시작하기', '투시즌', 20000);
INSERT INTO book VALUES(14, 'SQL이해', '새미디어', 22000);

INSERT INTO customer VALUES(6, '박보영', '서울 서초구', '010-9999-5555');
INSERT INTO customer VALUES(7, '오정세', '서울 중구', '010-8888-4444');
INSERT INTO customer VALUES(8, '이병헌', '서울 성북구', '010-7777-3333');

INSERT INTO orders VALUES(11, 6, 12, 23500, STR_TO_DATE('2020-02-01','%Y-%m-%d'));
INSERT INTO orders VALUES(12, 6, 14, 44000, STR_TO_DATE('2020-02-03','%Y-%m-%d'));
INSERT INTO orders VALUES(13, 8, 13, 20000, STR_TO_DATE('2020-02-03','%Y-%m-%d'));
INSERT INTO orders VALUES(14, 3, 13, 20000, STR_TO_DATE('2020-02-04','%Y-%m-%d'));
INSERT INTO orders VALUES(15, 4, 12, 23500, STR_TO_DATE('2020-02-05','%Y-%m-%d'));
INSERT INTO orders VALUES(16, 5, 8, 35000, STR_TO_DATE('2020-02-07','%Y-%m-%d'));

SELECT * FROM book WHERE bookid in (12, 13, 14);

-- 1. v_orders 테이블 만들기 : orderid, custid(orders), username, bookid(orders), saleprice, orderdate 가져와서
-- custid(c) = custid(o) and bookid(b) = bookid(o)
SELECT * FROM customer;
SELECT * FROM book;
SELECT * FROM orders;
DROP VIEW v_orders;

CREATE VIEW v_orders
	AS SELECT orderid, O.custid, username, O.bookid, saleprice, orderdate FROM customer C, orders O, book B
		WHERE C.custid = O.custid and B.bookid = O.bookid;

SELECT * FROM v_orders;

-- 2. v_orders 도서가격이 20000 이상인 레코드로 변경
CREATE OR REPLACE VIEW v_orders(custid, username, address)
	AS SELECT C.custid, username, address FROM customer C, orders O, book B
		WHERE B.price>=20000;

SELECT * FROM v_orders;

ALTER VIEW v_orders
	AS SELECT orderid, O.custid, username, O.bookid, saleprice, orderdate FROM customer C, orders O, book B
		WHERE C.custid = O.custid and B.bookid = O.bookid and B.price>=20000;

-- 3. v.cust_purchase 테이블 생성
-- username(c) '고객', sum(o.saleprice) '구매액'
-- customer C, orders O / custid(c) = custid(o)
-- 집계 분석 - 고객을 기준으로 구매액을 내림차순 
DROP VIEW v_cust_purchase;
CREATE VIEW v_cust_purchase
	AS SELECT C.username '고객', sum(O.saleprice) '구매액' FROM customer C, orders O
		WHERE C.custid = O.custid
		GROUP BY 고객
		ORDER BY 구매액 DESC;
SELECT * FROM v_cust_purchase;











