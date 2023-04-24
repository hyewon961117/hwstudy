# 4-2 두 테이블을 묶는 조인

USE market_db;
SELECT * FROM member;
SELECT * FROM buy;

# 내부조인 : INNER JOIN
SELECT * FROM buy
	INNER JOIN member
    ON buy.mem_id = member.mem_id
    WHERE buy.mem_id = 'GRL';

# mem_id -- 두개 테이블에 다 있기 때문에 테이블을 잡아줘야함
-- 별칭을 통해 테이블을 잡아줄 수 있음
SELECT B.mem_id, M.mem_name, B.prod_name, M.addr, concat(M.phone1, M.phone2) '연락처' FROM buy B
	INNER JOIN member M
    ON B.mem_id = M.mem_id;
    
# 중복 제거 : 1번이라도 구매한 이력이 있는 회원
SELECT DISTINCT M.mem_id, M.mem_name, M.addr FROM buy B
	INNER JOIN member M
    ON B.mem_id = M.mem_id;

# 외부조인 : OUTER JOIN
# 왼쪽에 있는 member 테이블을 기준으로 합침
SELECT M.mem_id, M.mem_name, B.prod_name, M.addr FROM member M
	LEFT OUTER JOIN buy B
    ON M.mem_id = B.mem_id;

# 오른쪽에 있는 member 테이블을 기준으로 합침
SELECT M.mem_id, M.mem_name, B.prod_name, M.addr FROM buy B
	RIGHT OUTER JOIN member M
    ON M.mem_id = B.mem_id;

# 회원가입 후 한번도 구매한 적이 없는 회원 목록
# 멤버 아이디 프로덕네임 멤버네임 멤버주소
SELECT DISTINCT M.mem_id, M.mem_name, B.prod_name, M.addr FROM member M
	LEFT OUTER JOIN buy B
    ON M.mem_id = B.mem_id
    WHERE prod_name IS NULL
    ORDER BY M.mem_id;
    
SELECT DISTINCT M.mem_id, M.mem_name, B.prod_name, M.addr FROM member M
	LEFT OUTER JOIN buy B
    ON M.mem_id = B.mem_id
    HAVING prod_name IS NULL
    ORDER BY M.mem_id;
    
# 기타조인 : 내용적인 의미는 없지만 대용량 데이터를 만들때 사용
SELECT * FROM buy 
	CROSS JOIN member;

SELECT count(*) FROM world.city;
SELECT count(*) FROM sakila.inventory
	CROSS JOIN world.city;
    
CREATE TABLE emp_table(
	emp char(4), 
    manager char(4), 
    phone varchar(8));

INSERT INTO emp_table VALUE ('대표', null, '0000');
INSERT INTO emp_table VALUE ('영업이사', '대표', '1111');
INSERT INTO emp_table VALUE ('관리이사', '대표', '2222');
INSERT INTO emp_table VALUE ('정보이사', '대표', '3333');
INSERT INTO emp_table VALUE ('영업과장', '영업이사', '1111-1');
INSERT INTO emp_table VALUE ('경리부장', '관리이사', '2222-1');
INSERT INTO emp_table VALUE ('인사부장', '관리이사', '2222-2');
INSERT INTO emp_table VALUE ('개발팀장', '정보이사', '3333-1');
INSERT INTO emp_table VALUE ('개발주임', '정보이사', '3333-1-1');

SELECT * FROM emp_table;

SELECT A.emp '직원', B.emp '직속상관', B.phone '직속상관연락처' FROM emp_table A
	INNER JOIN emp_table B
    ON A.manager = B.emp
    WHERE A.emp = '경리부장';

# 실습
USE bookstore;

-- 구매 고객이 가격 8000원 이상 도서를 2권 이상 주문한 고객 이름, 수량, 판매금액을 조회
SELECT * FROM customer;
SELECT * FROM orders;

SELECT C.username, O.custid, count(*) AS '수량', sum(O.saleprice) AS '판매액' FROM orders O
	LEFT JOIN customer C
    ON O.custid = C.custid
    WHERE saleprice >= 8000
    GROUP BY custid
    HAVING count(*)>=2;