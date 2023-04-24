# TRIM() 문자열 좌우 공백제거 -> 파이썬 strip과 같음
SELECT TRIM('안녕하세요');
# 문자열 좌우 문자 제거 (BOTH)
SELECT TRIM(both '안' FROM '안녕하세요안');

# 문자열 좌측 공백 제거
SELECT TRIM(leading FROM ' 안녕하세요  ');
# 문자열 우측 공백 제거
SELECT TRIM(trailing FROM '   안녕하세요  ');

# 문자열 좌측 문자 제거
SELECT TRIM(leading '안' FROM '안녕하세요안');
# 문자열 우측 문자 제거
SELECT TRIM(trailing '안' FROM '안녕하세요안');

# TRIM으로 왼쪽, 오른쪽 공백 제거
SELECT LTRIM('   안녕하세요   ');
SELECT RTRIM('   안녕하세요   ');

# 문자열 길이 세는 함수
SELECT length('안녕'); -- 바이트 기준으로 개수가 나옴 (한국엉에 문제가 생김)
SELECT char_length('안녕');
SELECT character_length('안녕');

# 대소문자
SELECT upper('sql로 시작하는 하루');
SELECT lower('A에서 Z까지');

# 추출
SELECT substring('안녕하세요', 2, 3);
SELECT substring_index('안.녕.하.세.요', '.',2); -- 2번째 점 만나기 전까지 추출
SELECT substring_index('안.녕.하.세.요', '.',-3); -- 뒤에서 3번째 점 만나기 전까지 추출

# 왼, 오른쪽 글자수 기준 추출
SELECT LEFT('안녕하세요', 3);
SELECT RIGHT('안녕하세요', 3);

# 결합
SELECT concat('홍길동', '모험');
SELECT concat_ws('/','홍길동', '모험'); -- 홍길동/모험
SELECT '홍길동', '모험'; -- 테이블 형태로 나옴

# 책이름, 출판사 결합
SELECT concat_ws(':', bookname, publisher) '책이름:출판사' FROM book;
SELECT bookname, ":", publisher FROM book;

# customer의 name과 phone을 ':'로 묶기
SELECT group_concat(username, ':', phone) AS '전화' FROM customer; -- 한 행으로 들어감
SELECT concat_ws(':', username, phone) AS '전화' FROM customer; -- 행마다 쪼개짐

SELECT NOW(), sysdate(), current_timestamp;
SELECT curtime(), current_time; -- 시간대만

# 날짜 시간 증감 함수
SELECT adddate('2021-08-31', interval 5 day);
SELECT adddate('2021-08-31', interval 1 month);
SELECT addtime('2021-01-01 23:59:59', '1:1:1');
SELECT addtime('09:00:00', '2:10:10');

# 날짜/시간 사이 차이
SELECT datediff('2022-01-01', now());
SELECT timediff('23:23:59', '2:1:1');

# 날짜/시간 생성
SELECT makedate(2021, 55);
SELECT date_format(makedate(2021,55), '%Y.%m.%d');
SELECT maketime(11, 11, 10);
SELECT quarter('2021-04-04'); -- 분기별로 구분하기

# 데이터 형식 변환 함수
SELECT avg(saleprice) AS '평균 구매 가격' FROM orders;
# 평균 구매 가격을 정수로
SELECT CAST(avg(saleprice) AS signed integer) AS '평균 구매 가격' FROM orders;

# 조인을 쓰지않고 테이블 결합
SELECT username, saleprice FROM customer C, orders O
	WHERE C.custid = O.custid;
# join을 활용 -- 기본값이 inner join
SELECT username, saleprice FROM customer C
	JOIN orders O ON C.custid = O.custid;

# 실습
# 도서 가격이 20000원 이상인 도서를 주문한 고객의 이름, 주문 도서 이름을 출력 WHERE 조건만 사용
SELECT C.username AS '이름', B.bookname AS '도서명' FROM customer C, orders O, book B
	WHERE C.custid = O.custid and O.bookid = B.bookid and B.price>20000;

# 고객별로 주문도서의 총판매액, 고객 이름을 주문일자로 정렬(group by 집계후 order by로 정렬)
SELECT username, sum(saleprice) FROM customer C, orders O
	WHERE C.custid = O.custid
    GROUP BY C.username
    ORDER BY O.orderdate;
    
# 외부조인 도서를 구매하지 않은 고객을 포함해 고객 이름/전번과 주문도서의 판매가격을 출력
SELECT C.username, O.saleprice FROM customer C
	LEFT OUTER JOIN orders O
    ON C.custid = O.custid;



