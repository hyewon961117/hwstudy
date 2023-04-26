# 6-1 인덱스 개념 파악
# 클러스터형 인덱스 : 자동으로 생성된 인덱스
USE market_db;
CREATE TABLE table1(
	col1 int primary key, -- 프라이머리키로 생성하면 자동으로 클러스터형 인덱스가 생산됨
    col2 int,
    col3 int);

# Key_name 체크
SHOW INDEX FROM table1;

CREATE TABLE table2(
	col1 int primary key, -- 프라이머리키로 생성하면 자동으로 클러스터형 인덱스가 생산됨
    col2 int unique, -- 고유키를 지정
    col3 int unique);
    
show index from table2;

DROP TABLE IF EXISTS buy, member;

CREATE TABLE member(
	mem_id CHAR(8), -- 기본키 지정 X
    mem_name VARCHAR(10),
    mem_nember INT,
    addr CHAR(2));
    
INSERT INTO member VALUES ('TWC', '트와이스', 9, '서울');
INSERT INTO member VALUES ('BLK', '블랙핑크', 4, '경남');
INSERT INTO member VALUES ('WMN', '여자친구', 6, '경기');
INSERT INTO member VALUES ('OMY', '오마이걸', 7, '서울');

SELECT * FROM member; -- 기본키를 지정하지않아 입력순으로 조회됨

# 기본키 지정
ALTER TABLE member
	add constraint
    primary key (mem_id);

SELECT * FROM member; -- 기본키 기준으로 인덱스가 생성되어 자동 정렬되어 조회됨

# 기본키 제거
ALTER TABLE member DROP primary key;

SELECT * FROM member; -- 인덱스 순으로 정렬된 순서대로 유지됨

# mem_name으로 기본키 설정
ALTER TABLE member
	add constraint
    primary key (mem_name);

SELECT * FROM member; -- 자동으로 기본키가 인덱스 되면서 mem_name 순으로 정렬됨

# 정렬되지않는 보조 인덱스
DROP TABLE IF EXISTS buy, member;

CREATE TABLE member(
	mem_id CHAR(8), -- 기본키 지정 X
    mem_name VARCHAR(10),
    mem_nember INT,
    addr CHAR(2));
    
INSERT INTO member VALUES ('TWC', '트와이스', 9, '서울');
INSERT INTO member VALUES ('BLK', '블랙핑크', 4, '경남');
INSERT INTO member VALUES ('WMN', '여자친구', 6, '경기');
INSERT INTO member VALUES ('OMY', '오마이걸', 7, '서울');

SELECT * FROM member;

# mem_id 고유키로 설정
ALTER TABLE member
	add constraint
    unique (mem_id); -- 유니크는 찾아보기가 여러개 만들어지는 것이지 내용의 순서가 바뀌지 않음

# mem_name 추가로 고유키로 설정 (고유키는 여러개 설정 가능)
ALTER TABLE member
	add constraint
    unique (mem_name); -- 유니크는 찾아보기가 여러개 만들어지는 것이지 내용의 순서가 바뀌지 않음

INSERT INTO member VALUES('GRL', '트와이스', 8, '서울');
SELECT * FROM member;

# 6-2 인덱스 내부 작동
CREATE TABLE cluster(-- 클러스터형 인덱스를 테스트하기 위한 테이블
	mem_id CHAR(8),
    mem_name VARCHAR(10));

INSERT INTO cluster VALUES('TWC', '트와이스');
INSERT INTO cluster VALUES('BLK', '블랙핑크');
INSERT INTO cluster VALUES('WMN', '여자친구');
INSERT INTO cluster VALUES('OMY', '오마이걸');
INSERT INTO cluster VALUES('GRL', '소녀시대');
INSERT INTO cluster VALUES('ITZ', '잇지');
INSERT INTO cluster VALUES('RED', '레드벨벳');
INSERT INTO cluster VALUES('APN', '에이핑크');
INSERT INTO cluster VALUES('SPC', '우주소녀');
INSERT INTO cluster VALUES('MMU', '마마무');

SELECT * FROM cluster; -- 기본키 및 인덱스를 지정하지않아 입력된 순서대로 값이 조회됨

# 클러스터형 인덱스 구성
ALTER TABLE cluster add constraint primary key(mem_id);
SELECT * FROM cluster; -- 클러스터형 인덱스가 생성되어 기본키 기준으로 오름차순 정렬됨

# 새로운 테이블 생성
CREATE TABLE second(-- 클러스터형 인덱스를 테스트하기 위한 테이블
	mem_id CHAR(8),
    mem_name VARCHAR(10));

INSERT INTO second VALUES('TWC', '트와이스');
INSERT INTO second VALUES('BLK', '블랙핑크');
INSERT INTO second VALUES('WMN', '여자친구');
INSERT INTO second VALUES('OMY', '오마이걸');
INSERT INTO second VALUES('GRL', '소녀시대');
INSERT INTO second VALUES('ITZ', '잇지');
INSERT INTO second VALUES('RED', '레드벨벳');
INSERT INTO second VALUES('APN', '에이핑크');
INSERT INTO second VALUES('SPC', '우주소녀');
INSERT INTO second VALUES('MMU', '마마무');

SELECT * FROM second; 

# 보조 인덱스 구성하기
ALTER TABLE second add constraint unique (mem_id);
SELECT * FROM second; -- 정렬이 되진 않음

# 6-3 인덱스 생성과 제거
-- market_db 다시 불러오기

SELECT * FROM member;
SHOW INDEX FROM member; -- 인덱스 확인
SHOW TABLE STATUS LIKE 'member'; -- 인덱스의 크기 확인

# 주소에 중복을 허용하는 단순 보조 인덱스 생성
CREATE INDEX idx_member_addr
	ON member(addr);
    
SHOW INDEX FROM member;
analyze table member; -- 지금까지 생성한 인덱스를 실제로 적용
SHOW TABLE STATUS LIKE 'member'; -- Index_length : 보조 인덱스의 크기

# 중복을 허용하지않는 고유 보조 인덱스 생성
CREATE UNIQUE INDEX idx_member_mem_number ON member (mem_number); -- 오류 / 중복을 허용하지 않는 보조 인덱스이기 때문에 중복값이 있어 오류
CREATE UNIQUE INDEX idx_member_mem_name ON member (mem_name);
analyze table member; -- 금까지 생성한 인덱스를 실제로 적용
SHOW INDEX FROM member;
SHOW TABLE STATUS LIKE 'member'; -- Index_length : 보조 인덱스의 크기

INSERT INTO member VALUES('MOO', '마마무', 2, '태국', '001', '12341234', 155, '2020.10.10'); -- 오류 / 고유보조인덱스로 mem_name에 중복값을 입력할 수 없음
SHOW INDEX FROM member;
SHOW TABLE STATUS LIKE 'member';

SELECT mem_id, mem_name, addr FROM member
	WHERE mem_name = '에이핑크'; -- 인덱스를 사용하여 조회

CREATE INDEX idx_member_mem_number ON member (mem_number);
analyze table member; -- 지금까지 생성한 인덱스를 실제로 적용

SELECT mem_id, mem_name, addr FROM member
	WHERE mem_number >= 7; -- 인덱스를 사용하여 조회
    
SELECT mem_id, mem_name, addr FROM member
	WHERE mem_number >= 1; -- full scan : 값이 너무 많으면 인덱스로 조회하지않음

SELECT mem_id, mem_name, addr FROM member
	WHERE mem_number*2 >= 14; -- WHERE문에 연산이 가해지면 인덱스를 사용하지 않음

SELECT mem_id, mem_name, addr FROM member
	WHERE mem_number >= 14/2; -- 위와 같은 코드지만 인덱스를 사용하여 검색함

# 인덱스 제거
-- 먼저 인덱스 이름 확인
SHOW INDEX FROM member;
-- 클러스터형 인덱스와 보조 인덱스가 섞여 있을 때는 보조 인덱스를 먼저 제거하는것이 좋음
DROP INDEX idx_member_mem_name ON member;
DROP INDEX idx_member_addr ON member;
DROP INDEX idx_member_mem_number ON member;

ALTER TABLE member
	DROP primary key; -- 오류 / buy 테이블과 외래키 관계 때문에 삭제할 수 없음
    
-- 외래키 이름 확인
SELECT table_name, constraint_name
	FROM information_schema.referential_constraints
    WHERE constraint_schma = 'market_db';
    
-- 외래키를 제거하고 기본키를 제거
ALTER TABLE buy
	DROP FOREIGN KEY buy_ibfk_1;
ALTER TABLE member
	DROP Primary key;