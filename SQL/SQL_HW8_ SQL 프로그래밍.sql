# 4-3 SQL 프로그래밍

# 스토어드 프로시저 : MYSQL에서 프로그래밍 기능이 필요할 때 사용하는 데이터베이스 개체
# 기본 구조
DELIMITER $$
CREATE PROCEDURE ifProc1() -- 스토어드_프로시저_이름()
BEGIN
-- 이 부분에 SQL 프로그래밍 코딩
END $$
DELIMITER ;
CALL ifProc1(); -- 스토어드_프로시저_이름();

# 예시
DELIMITER $$
CREATE PROCEDURE ifProc1() -- 스토어드_프로시저_이름()
BEGIN
	IF 100=100 THEN
		SELECT '100은 100과 같다';
	END IF;
END $$
DELIMITER ;
CALL ifProc1(); -- 스토어드_프로시저_이름();

# 만든 프로시저 삭제
DROP PROCEDURE IF EXISTS ifProc2;

# IF~ELSE 문
DELIMITER $$
CREATE PROCEDURE ifProc2()
BEGIN
	-- 변수선언, 함수 밖 : @ / 함수 안 : DECLARE
	DECLARE myNum INT; -- DECLARE 예약어를 사용해서 myNum 변수를 선언, 데이터형식은 INT로 지정
    SET mtNum = 200; -- SET 예약어로 변수에 200대입
    IF myNum = 100 THEN -- myNum이 100인지 아닌지를 구분
		SELECT '100입니다.';
	ELSE
		SELECT '100이 아닙니다.';
	END IF;
END $$
DELIMITER ;
CALL ifProc2();

# 간단한 IF문 축약형
SELECT IF (100>300, '크다', '작다');

USE market_db;
SELECT * FROM member;

# IF문 활용
DELIMITER $$
CREATE PROCEDURE ifProc3()
BEGIN
	DECLARE debutDate DATE; -- 데뷔일 변수 준비
    DECLARE curDate DATE; -- 오늘
    DECLARE days INT; -- 활동한 일수
    
    SELECT debut_date INTO debutDate -- 데뷔데이트 컬럼을 변수에 넣음
		FROM market_db.member
        WHERE mem_id = 'APN';
	SET curDate = current_date(); -- 현재날짜
    SET days = datediff(curDate, debutDate); -- 두 날짜의 차이, 일 단위
	
    IF (days/365) >=5 THEN
		SELECT concat('데뷔한 지', days, '일이나 지났습니다. 축하합니다!');
	ELSE
		SELECT '데뷔한 지' + days + '일밖에 안됐네요. 화이팅!';
	END IF;
END $$
DELIMITER ;
CALL ifProc3();

# 다중 분기
# CASE문의 기본형식
SELECT
CASE 100
	WHEN 10 THEN '십'
    WHEN 50 THEN '오십'
    WHEN 100 THEN '일백'
    ELSE '기타'
END
AS '결과';
    
# 예시
DELIMITER $$
CREATE PROCEDURE caseProc()
BEGIN
	DECLARE point INT;
    DECLARE credit CHAR(1);
    SET point = 88;
    
    CASE
		WHEN point>=90 THEN
			SET credit = 'A';
		WHEN point>=80 THEN
			SET credit = 'B';
		WHEN point>=70 THEN
			SET credit = 'C';
		WHEN point>=60 THEN
			SET credit = 'D';
		ELSE
			SET credit = 'F';
	END CASE;
    SELECT concat('취득점수==>', point), concat('학점==>', credit);
END $$
DELIMITER ;
CALL caseProc();

# CASE 문 활용
-- 구매액 기준 회원 등급을 만들어보자
SELECT mem_id, sum(price*amount) '총구매액' FROM buy
	GROUP BY mem_id;

-- 총구매액 기준 내림차순 정렬
SELECT mem_id, sum(price*amount) '총구매액' FROM buy
	GROUP BY mem_id
    ORDER BY sum(price*amount) DESC;

-- 구매테이블과 회원테이블 조인
SELECT B.mem_id, M.mem_name, sum(price*amount) '총구매액' FROM buy B
	INNER JOIN member M
    ON B.mem_id=M.mem_id
    GROUP BY B.mem_id
    ORDER BY sum(price*amount) DESC;

-- 한번도 안산 사람도 나오게 조인
SELECT M.mem_id, M.mem_name, sum(price*amount) '총구매액' FROM buy B
	RIGHT OUTER JOIN member M
    ON B.mem_id=M.mem_id
    GROUP BY M.mem_id
    ORDER BY sum(price*amount) DESC;

-- 셀렉트 문안에 조건문을 써줌
SELECT M.mem_id, M.mem_name, sum(price*amount) '총구매액',
		CASE
			WHEN (sum(price*amount) >= 1500) THEN '최우수고객'
			WHEN (sum(price*amount) >= 1000) THEN '우수고객'
			WHEN (sum(price*amount) >= 1) THEN '일반고객'
			ELSE '유령고객'
		END '회원등급'
	FROM buy B
		RIGHT OUTER JOIN member M
		ON B.mem_id=M.mem_id
	GROUP BY M.mem_id
	ORDER BY sum(price*amount) DESC;

# WHILE문
DELIMITER $$
CREATE PROCEDURE whileProc()
BEGIN
	DECLARE i INT; -- 1에서 100까지 증가할 변수
    DECLARE hap INT; -- 더한 값을 누적할 변수
    SET i = 1;  -- 변수 초기값 할당
    SET hap = 0;
    
    WHILE (i<=100) DO
		SET hap = hap + i; -- hap의 원래 값에 i를 더해서 다시 hap에 넣으라는 의미
        SET i = i + 1; -- i의 원래값에 1을 더해서 다시 i에 넣으라는 의미
	END WHILE;
    SELECT '1부터 100까지의 합 ==>', hap;
END $$
DELIMITER ;
CALL whileProc();

# WHILE문 응용
DELIMITER $$
CREATE PROCEDURE whileProc2()
BEGIN
	DECLARE i INT; -- 1에서 100까지 증가할 변수
    DECLARE hap INT; -- 더한 값을 누적할 변수
    SET i = 1;  -- 변수 초기값 할당
    SET hap = 0;
    
    myWhile:
    WHILE (i<=100) DO
		IF (i % 4 = 0) THEN -- 4의 배수이면
			SET i = i + 1;
            ITERATE myWhile; -- 지정한 label문으로 가서 계속 진행
		END IF;
        SET hap = hap + i;
        IF (hap > 1000) THEN
			LEAVE myWhile; -- 지정한 label문을 떠남. 즉 While문 종료
		END IF;
        SET i = i + 1;
	END WHILE;
    SELECT '1부터 100까지의 합(4의 배수 제외), 1000 넘으면 종료 ==>', hap;
END $$
DELIMITER ;
CALL whileProc2();

# 동적 SQL
PREPARE myQuery FROM 'SELECT * FROM member WHERE mem_id = "BLK"';
EXECUTE myQuery;
DEALLOCATE PREPARE myQuery; -- 메모리상 남아있기때문에 동적 SQL 해제하는 구문

# 동적 SQL의 활용
-- 출입문 내역
DROP TABLE IF EXISTS gate_table;
CREATE TABLE gate_table(
	id INT auto_increment primary key,
    entry_time datetime);
-- 3번 반복
SET @curDate = current_timestamp(); -- 현재날짜와 시간
PREPARE myQuery FROM 'INSERT INTO gate_table VALUES(NULL, ?)';
EXECUTE myQuery USING @curDate;
DEALLOCATE PREPARE myQuery;

-- 테이블 조회
SELECT * FROM gate_table;



