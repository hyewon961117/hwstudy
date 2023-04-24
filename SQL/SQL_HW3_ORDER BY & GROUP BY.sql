USE market_db;

SELECT * FROM member;

# ORDER BY 절
#  데뷔일자 기준 오름차순 정렬 (기본값 - ASC)
SELECT mem_id, mem_name, debut_date FROM member
	ORDER BY debut_date;
#  데뷔일자 기준 내림차순 정렬
SELECT mem_id, mem_name, debut_date FROM member
	ORDER BY debut_date DESC;

# 키가 164 이상인 걸그룹 중 키가 큰 순서대로 정렬
SELECT mem_id, mem_name, debut_date, height FROM member
	ORDER BY height DESC
    WHERE height >= 164; -- 오류

-- WHERE 조건절이 무조건 ORDER BY 절보다 앞에 있어야함
SELECT mem_id, mem_name, debut_date, height FROM member
	WHERE height >= 164
	ORDER BY height DESC;

# 키가 164 이상이면서 내림차순 정렬(DESC), 데뷔일이 오름차순(ASC) 
SELECT mem_id, mem_name, debut_date, height FROM member
	WHERE height >= 164
	ORDER BY height DESC, debut_date ASC; -- 오름차순은 ASC 안써도 정렬됨

# LIMIT  : 출력 개수 제한 -- 형식 : LIMIT 시작, 개수
SELECT * FROM member
	LIMIT 3;

# 데뷔날짜로 오름차순으로 정렬후에 3개만 출력
SELECT mem_name, debut_date FROM member
	ORDER BY debut_date LIMIT 3;

# 걸그룹명과 키를 키 내림차순으로 정렬하는데 4번째부터 2개 뽑기
SELECT mem_name, height FROM member
	ORDER BY height DESC
    LIMIT 3, 2;

-- 인덱스 0부터 시작인것
SELECT mem_name, height FROM member
	ORDER BY height DESC
    LIMIT 5;
    
# DISTINCT : 중복된 결과를 제거
SELECT * FROM member;

# 주소만 뽑아서 오름차순 정렬
SELECT addr FROM member 
	ORDER BY addr;

# 주소 중복제거를 하고 유니크한 값만 출력
SELECT DISTINCT addr FROM member 
	ORDER BY addr;

# GROUP BY절
# buy 테이블에서 멤버id순으로 정렬하고 멤버id amount 출력
SELECT mem_id, amount FROM buy
	ORDER BY mem_id;

# 그룹별 amount의 총합 조회
SELECT mem_id, sum(amount) FROM buy
	GROUP BY mem_id;
    
# 그룹별 amount의 총합 조회, 컬럼명 변경하여 출력
SELECT mem_id "회원 아이디", sum(amount) "총 구매 개수" FROM buy
	GROUP BY mem_id;

# 그룹별 총 구매 금액 조회
SELECT mem_id "회원 아이디", sum(price*amount) "총 구매금액" FROM buy
	GROUP BY  mem_id;
    
# 평균 구매 개수
SELECT avg(amount) "평균 구매 개수" FROM buy;

# 그룹별로 평균 구매 개수 조회
SELECT mem_id, avg(amount) "평균 구매 개수" FROM buy
	GROUP BY mem_id;

# 전체 회원 수 (모든 행의 개수)
SELECT count(*) FROM member;

# 연락처가 있는 회원의 수 카운트 (PHONE1열의 값 중 NULL값 제외하고 카운트됨)
SELECT count(phone1) "연락처가 있는 회원" FROM member;

# 총 구매금액이 1000이상인 회원 조회
SELECT mem_id "회원 아이디", sum(price*amount) "총 구매금액" FROM buy
	WHERE SUM(price*amount)>1000
	GROUP BY  mem_id; -- 오류
    
-- GROUP BY절에는 WHERE 조건절 사용할 수 없음, HAVING 절 사용
-- HAVING 절은 반드시 GROUP BY 절 다음에 나와야함
SELECT mem_id "회원 아이디", sum(price*amount) "총 구매금액" FROM buy
	GROUP BY  mem_id
    HAVING SUM(price*amount)>1000;

# 구매액이 가장 큰 사용자부터 정렬
SELECT mem_id "회원 아이디", sum(price*amount) "총 구매금액" FROM buy
	GROUP BY  mem_id
    HAVING SUM(price*amount)>1000
    ORDER BY SUM(price*amount) DESC;

# 실습
-- 1. bookstore DB 선택
-- 2. book 테이블에서 도서를 이름순으로 검색
-- 3. book 테이블에서 도서를 가격순으로 검색하고 가격이 같으면 이름순으로 검색
-- 4. book 테이블에서 도서를 가격의 내림차순으로 검색하고 만약 가격이 같다면 출판사의 오름차순으로 검색
-- 5. orders 테이블에서 주문일자를 내림차순으로 정렬
-- 6. book 테이블에서 bookname이 '썬'이 들어가있고 가격이 20000원 이하인 책을 출판사 이름으로 내림차순 조회 (모든 컬럼 조회)
-- 7. orders 테이블에서 saleprice가 1000원 이상인 데이터를 book id 오름차순으로 조회 (모든 컬럼 조회)

#  1. bookstore DB 선택
USE bookstore;

# 2. book 테이블에서 도서를 이름순으로 검색
SELECT * FROM book
	ORDER BY bookname;

# 3. book 테이블에서 도서를 가격순으로 검색하고 가격이 같으면 이름순으로 검색
SELECT * FROM book
	ORDER BY price, bookname;

# 4. book 테이블에서 도서를 가격의 내림차순으로 검색하고 만약 가격이 같다면 출판사의 오름차순으로 검색
SELECT * FROM book
	ORDER BY price DESC, publisher ASC;

# 5. orders 테이블에서 주문일자를 내림차순으로 정렬
SELECT * FROM orders
	ORDER BY orderdate DESC;

# 6. book 테이블에서 bookname이 '썬'이 들어가있고 가격이 20000원 이하인 책을 출판사 이름으로 내림차순 조회 (모든 컬럼 조회)
SELECT * FROM book
	WHERE bookname like "%썬%" and price <= 20000
	ORDER BY publisher DESC;

# 7. orders 테이블에서 saleprice가 1000원 이상인 데이터를 book id 오름차순으로 조회 (모든 컬럼 조회)
SELECT * FROM orders
	WHERE saleprice > 1000
    ORDER BY bookid ASC;