# 7-1 스토어드 프로시저

# 기본 형식
DELIMITER $$
CREATE PROCEDURE 이름() -- 스토어드_프로시저_이름()
BEGIN
-- 쿼리문;
END $$
DELIMITER ;
CALL 이름(); -- 호출

USE market_db;
# member table 조회하는 스토어드 프로시저 만들기
DELIMITER $$
CREATE PROCEDURE user_proc()
BEGIN
	SELECT * FROM member;
END $$
DELIMITER ;
CALL user_proc(); -- 호출

# 스토어드 프로시저 삭제
DROP PROCEDURE IF EXISTS user_proc; -- 삭제할 때는 () 괄호를 붙히지 않음

# 입력 매개변수의 활용
DELIMITER $$
CREATE PROCEDURE user_proc1(IN userName VARCHAR(10)) -- 입력 매개변수 userName 대입
BEGIN
	SELECT * FROM member 
		WHERE mem_name = userName; -- 매개변수에 대한 조회
END $$
DELIMITER ;
CALL user_proc1('에이핑크'); -- 호출

# 2개 입력 매개변수
DELIMITER $$
CREATE PROCEDURE user_proc2(IN userNumber INT, IN userHeight INT) -- 입력 매개변수 userNumber, userHeight 대입
BEGIN
	SELECT * FROM member
		WHERE mem_number > userNumber AND height > userHeight; -- 매개변수에 대한 조회
END $$
DELIMITER ;
CALL user_proc2(6, 165); -- 호출

# 출력 매개변수의 활용
DELIMITER $$
CREATE PROCEDURE user_proc3(IN txtValue CHAR(10), OUT outValue INT) -- 입력 매개변수 txtValue, 출력 매개변수 outValue 대입
BEGIN
	INSERT INTO noTable VALUES(NULL, txtValue); -- noTable이 없지만 프로시저는 오류없이 만들어짐
    SELECT max(id) INTO outValue FROM noTABLE; -- id의 최대값을 outValue 변수에 넣어줌
END $$
DELIMITER ;
CALL user_proc3(); -- noTable이 없기 떄문에 호출하면 오류 발생

DESC noTable;

-- noTable 만들기
CREATE TABLE IF NOT EXISTS noTable(
	id INT AUTO_INCREMENT PRIMARY KEY, 
    txt CHAR(10));

CALL user_proc3('테스트1', @myValue); -- 테스트1이라는 데이터를 넣고 myValue 변수에 제일 마지막 ID 넣어줌 
SELECT concat('입력된 ID 값 ==>', @myValue);

# SQL 프로그래밍의 활용
DROP PROCEDURE IF EXISTS ifelse_proc;
DELIMITER $$
CREATE PROCEDURE ifelse_proc(IN memName VARCHAR(10))
BEGIN
	DECLARE debutYear INT; -- 변수 선언
    SELECT year(debut_date) INTO debutYear FROM member
		WHERE mem_name = memName;
	IF (debutYear >= 2015) THEN
		SELECT '신인 가수네요. 화이팅하세요.' AS '메시지';
	ELSE 
		SELECT '고참 가수네요. 수고하셨어요.' AS '메시지';
	END IF;
END $$
DELIMITER ;
CALL ifelse_proc('오마이걸'); 

# WHILE 1~100까지 합
# 1. 기본구조, 2. 변수선언 합, 증가될 i, 3. while~문 작성, 4. 콜 5050
# 4의 배수 제외, 합 1000넘으면 종료

# 동적 SQL 활용
DELIMITER $$
CREATE PROCEDURE while_proc()
BEGIN
	DECLARE hap INT;
    DECLARE num INT;
    SET hap = 0;
    SET num = 1;
    
    WHILE (num<=100) DO
		SET hap = hap + num;
        SET num = num + 1;
	END WHILE;
    SELECT hap AS '1~100 합계';
END $$
DELIMITER ;
CALL while_proc();

# 동적 SQL 활용
DROP PROCEDURE IF EXISTS dynamic_proc;
DELIMITER $$
CREATE PROCEDURE dynamic_proc(IN tableName VARCHAR(20))
BEGIN
	SET @sqlQuery = concat('select * from ', tableName);
    prepare myQuery From @sqlQuery;
    execute myQuery;
    deallocate prepare myQuery;
END $$
DELIMITER ;
CALL dynamic_proc('member');

# 7-2 스토어드 함수
# 기본 형식
DELIMITER $$
CREATE FUNCTION 함수이름(매개변수) -- 모두 입력 매개변수뿐, in 을 붙히지 않음
	RETURNS 반환형식 -- 반환할 값의 데이터 형식을 지정
BEGIN
	프로그래밍 코딩 -- SELECT문 사용 불가
	RETURN 반환값; -- 본문 안에서는 return문으로 하나의 값을 반환해야함
END $$
DELIMITER ;
SELECT 함수이름(매개변수) AS '컬럼이름'; -- SELECT 문으로 호출

# 함수생성을 위해 권한을 생성
SET GLOBAL log_bin_trust_function_creators = 1;

# 숫자 2개의 합계를 계산하는 스토어드 함수 만들기
DROP FUNCTION IF EXISTS sumFunc;
DELIMITER $$
CREATE FUNCTION sumFunc(number1 INT, number2 INT)
	RETURNS INT
BEGIN
	RETURN number1 + number2;
END $$
DELIMITER ;
SELECT sumFunc(100,200) AS '합계'; 

# 데뷔연도를 입력하면 활동기간을 출력하는 함수
DELIMITER $$
CREATE FUNCTION calcYearFunc(dYear INT)
	RETURNS INT
BEGIN
	DECLARE runYear INT; -- 활동기간 (연도)
    SET runYear = Year(curdate()) - dYear;
	RETURN runYear;
END $$
DELIMITER ;
SELECT calcYearFunc(2010) AS '활동 햇수';

# 함수 반환값을 SELECT~INTO~로 저장했다가 사용하기
SELECT calcYearFunc(2007) INTO @debut2007;
SELECT calcYearFunc(2013) INTO @debut2013;
SELECT @debut2007-@debut2013 AS '2007과 2013 차이';

# 각 회원별 활동 햇수 출력
SELECT mem_id, mem_name, calcYearFunc(year(debut_date)) as '활동 햇수' FROM member;

# 함수의 내용 확인
SHOW CREATE FUNCTION calcYearFunc;

# 함수 삭제
DROP FUNCTION calcYearFunc;

# 커서로 한행씩 처리하기
# 회원의 평균 인원수를 계산하기 위해 변수 준비
DECLARE memNumber int; -- 회원의 인원수
DECLARE cnt INT DEFAULT 0; -- 읽은 행의 변수 개수
DECLARE totNumber INT DEFAULT 0; -- 전체 인원의 합계

-- 행의 끝을 파악하기 위한 변수
DECLARE endOfRow boolean DEFAULT FALSE; -- 변수 값을 FALSE로 초기화 시킴 

# 커서 선언
-- 회원 테이블을 조회하는 구문을 커서로 만들어놓기
DECLARE memberCuror CURSOR FOR 
	SELECT mem_number FROM member;

# 반복조건 선언
-- 행의 끝이면 endoOfRow에 TRUE를 대입하라는 명령어 
DECLARE CONTINUE HANDLER
	FOR NOT FOUND SET endOfRow=TRUE;

# 커서 열기
OPEN memberCursor;

# 반복되는 부분에는 다음 코드가 필수로 들어가야함
-- 행의 끝에 다다르면 반복 조건을 선언한 3번에 의해서 endOfRow가 TRUE로 변경되고 반복하는 부분을 빠져나감
IF endOfRow THEN
	LEAVE cursor_loop;
END IF;

# 반복할 부분 전체 선언
cursor_loop: LOOP
	FETCH memberCursor INTO memNumber; -- 한 행씩 읽어오는 구문
    IF endOfRow THEN
		LEAVE cursor_loop;
	END IF;
    
    SET cnt = cnt + 1;
    SET totNumber = totNumber + memNumber;
END LOOP cusrsor_loop;

# 반복을 빠져나오면 평균 인원수를 계산
SELECT (totNumber/cnt) as '회원의 평균 인원 수 ';

# 모든 작업이 끝났으면 커서 닫기
CLOSE memberCursor;

# 커서의 통합코드
DROP PROCEDURE IF EXISTS cursor_proc;
DELIMITER $$
CREATE PROCEDURE cursor_proc()
BEGIN
	DECLARE memNumber int;
	DECLARE cnt INT DEFAULT 0;
	DECLARE totNumber INT DEFAULT 0; 
	DECLARE endOfRow boolean DEFAULT FALSE; 
    
    DECLARE memberCursor CURSOR FOR 
		SELECT mem_number FROM member;

	DECLARE CONTINUE HANDLER
		FOR NOT FOUND SET endOfRow=True;
    
    OPEN memberCursor;
    
    cursor_loop: LOOP
		FETCH memberCursor INTO memNumber;
		IF endOfRow THEN
			LEAVE cursor_loop;
		END IF;
		
		SET cnt = cnt + 1;
		SET totNumber = totNumber + memNumber;
	END LOOP cursor_loop;

	SELECT (totNumber/cnt) as '회원의 평균 인원 수 ';
	CLOSE memberCursor;
    
END $$
DELIMITER ;
CALL cursor_proc();

# 7-3 트리거
# 테스트로 사용할 간단한 테이블 만들기
CREATE TABLE IF NOT EXISTS trigger_table(
	id int, 
	txt varchar(10));

INSERT INTO trigger_table VALUES(1, '레드벨벳');
INSERT INTO trigger_table VALUES(2, '잇지');
INSERT INTO trigger_table VALUES(3, '블랙핑크');

SELECT * FROM trigger_table;

# 트리거 만들기
DELIMITER $$
 CREATE TRIGGER myTrigger
	AFTER DELETE -- 삭제 후에 작동하도록 지정 
		ON trigger_table -- 트리거를 부착할 테이블을 지정
		FOR EACH ROW -- 각 행마다 적용시킨다는 의미, 트리거에는 항상 써주는 코드
BEGIN
	SET @msg = '가수 그룹이 삭제됨' ; -- 트리거 실행 시 작동되는 코드들
    -- 전역변수로 사용할거라서 @로 변수 선언
END $$
DELIMITER ;

# INSERT UPDATE 시에는 트리거 작동 하지 않음
SET @msg='';
INSERT INTO trigger_table values(4, '마마무');
SELECT @msg;
SET SQL_SAFE_UPDATES=0;
UPDATE trigger_table SET txt = '블핑' WHERE id=3;
SELECT @msg;

# 삭제하면 트리거가 작동해 @msg 변수에 트리거에서 설정한 내용이 입력됨
DELETE FROM trigger_table WHERE id = 4;
SELECT @msg;

# 트리거 활용
# 기존 테이블의 정보를 복사해서 실습 데이터 만들기
CREATE TABLE singer(SELECT mem_id, mem_name, mem_number, addr FROM member);
SELECT * FROM singer;

# 백업된 정보가 들어갈 테이블 만들기
CREATE TABLE backup_singer(
	mem_id CHAR(8) NOT NULL,
    mem_name VARCHAR(10) NOT NULL,
    mem_number INT NOT NULL,
    addr CHAR(2) NOT NULL,
    modType CHAR(2), -- 변경된 타입 '수정', '삭제'
    modDate DATE, -- 변경된 날짜
    modUser VARCHAR(30)); -- 변경한 사용자

# 트리거 생성
# 수정했을때 작동하는 트리거 생성
DELIMITER $$
 CREATE TRIGGER singer_updateTrg
	AFTER UPDATE -- 수정 후에 작동하도록 지정 
		ON singer -- 트리거를 부착할 테이블을 지정
		FOR EACH ROW -- 각 행마다 적용시킨다는 의미, 트리거에는 항상 써주는 코드
BEGIN
	INSERT INTO backup_singer VALUES(OLD.mem_id, OLD.mem_name, OLD.mem_number, OLD.addr, '수정', CURDATE(), CURRENT_USER());
END $$
DELIMITER ;

# 삭제가 발생했을때 작동하는 트리거 생성
DELIMITER $$
 CREATE TRIGGER singer_deleteTrg
	AFTER DELETE -- 삭제 후에 작동하도록 지정 
		ON singer -- 트리거를 부착할 테이블을 지정
		FOR EACH ROW -- 각 행마다 적용시킨다는 의미, 트리거에는 항상 써주는 코드
BEGIN
	INSERT INTO backup_singer VALUES(OLD.mem_id, OLD.mem_name, OLD.mem_number, OLD.addr, '삭제', CURDATE(), CURRENT_USER());
END $$
DELIMITER ;

# 데이터 변경해보기
UPDATE singer SET addr='영국' WHERE mem_id = 'BLK';
DELETE FROM singer WHERE mem_number >=7;

# 수정 또는 삭제된 내용이 잘 보관되어있는지 결과 확인
SELECT * FROM backup_singer;

# DELETE 대신에 TRUNCATE TABLE 문으로 삭제
TRUNCATE TABLE singer;
SELECT * FROM backup_singer; -- 삭제는 되지만 트리거는 작동하지 않음 (트리거는 DELETE 문에서만 작동함)












