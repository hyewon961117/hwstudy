# sakila 데이터
USE sakila;
SELECT * FROM actor;
SELECT * FROM address;
SELECT * FROM film;
SELECT * FROM film_actor;
SELECT * FROM customer;
SELECT * FROM staff;
SELECT * FROM rental;
SELECT * FROM inventory;

# 배우 이름을 합쳐서 '배우' 컬럼으로 조회 (대문자로)
SELECT upper(concat(first_name, ' ', last_name)) '배우' FROM actor;

# son으로 끝나는 성을 가진 배우 조회
SELECT * FROM actor
	WHERE last_name like '%son';
    
# actor film film_actor 테이블 연결
# 배우들이 출연한 영화 배우 이름을 합쳐서 '배우', title, release_year 3개 컬럼 조회
SELECT upper(concat(first_name, ' ', last_name)) '배우', F.title, F.release_year FROM actor A, film F, film_actor FA
	WHERE A.actor_id = FA.actor_id and F.film_id = FA.film_id;
    
# 성(last)name 별 배우 숫자 / last_name, 명 / 내림차순
SELECT last_name, count(*) '명' FROM actor
	GROUP BY last_name
    ORDER BY count(*) DESC, last_name ASC;
    
# country 테이블
DESCRIBE country;
SELECT * FROM country;

# ID와 국가를 조회 australia(호주) germany(독일) ID 몇번인지
SELECT country_id, country '국가' FROM country
	WHERE country in ('australia', 'germany');

# staff테이블, address 테이블
# 스테프테이블 성과 이름을 합치고 staff로 하고, staff와 address를 합치고 address, district, postal code, city_id를 조회
SELECT upper(concat(first_name,' ',last_name)) 'staff', A.address, A.district, A.postal_code, A.city_id FROM staff S
	LEFT JOIN address A on S.address_id = A.address_id;

# staff테이블, payment 테이블 staff S, payment P
# 스태프의 성과 이름을 합치고 payment(pay컬럼) 테이블과 합치고 staff 이름 기준으로 그룹화하여 2005년 7월 데이터 조회
# sum(amount)
SELECT * FROM payment;
SELECT concat(S.first_name,' ',S.last_name) "staff", sum(P.amount) FROM staff S
	LEFT JOIN payment P ON P.staff_id = S.staff_id
    WHERE MONTH(P.payment_date)=7 AND YEAR(P.payment_date) = 2005
    GROUP BY staff;
    
# 영화별 출연 배우의 수, film, film_actor
# 타이틀, 배우 수 컬럼명:'배우'
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT title, count(*) '배우' FROM film F
	INNER JOIN film_actor FA ON F.film_id = FA.film_id
    GROUP BY F.title
    ORDER BY 배우 DESC;

# 영화 제목이 halloween nuts 배우이름이 성과 이름이 합쳐서 나오도록 조회
# 서브쿼리 - 조건절에 쿼리를 새로 만들어야함
# film_actor / actor / film
SELECT * FROM film_actor;
SELECT * FROM film;
SELECT * FROM actor;

SELECT concat(first_name,' ',last_name) '배우' FROM actor
	WHERE actor_id in (SELECT actor_id FROM film_actor 
		WHERE film_id in(SELECT film_id FROM film 
			WHERE lower(title) = lower('halloween nuts')));

# 국가가 canada인 고객 이름을 서브쿼리로 찾기
# 고객 성과 이름을 합치고 고객, email
# customer address city country
SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

SELECT concat(first_name,' ',last_name) "고객", email FROM customer
	WHERE address_id in (SELECT address_id FROM address
		WHERE city_id in (SELECT city_id FROM city
			WHERE(country_id = (SELECT country_id FROM country WHERE country='canada'))));

# 조인을 활용해서 국가가 canada인 고객 이름
SELECT concat(CUS.first_name,' ',CUS.last_name) "고객", CUS.email FROM customer CUS
	LEFT JOIN address ADR ON CUS.address_id = ADR.address_id
    LEFT JOIN city CIT ON ADR.city_id = CIT.city_id
    LEFT JOIN country COU ON CIT.country_id = COU.country_id
    WHERE COU.country = 'canada';

# 1. 영화에서 PG등급 G등급 조회
# rating, count(*) 수량 film
SELECT * FROM film;
SELECT rating '등급', count(*) '수량' FROM film
	WHERE rating in('PG', 'G')
    GROUP BY rating;

# 2. PG등급 또는 G등급 영화 이름, rating, title, release_year
SELECT rating '등급', title '영화제목', release_year FROM film
	WHERE rating in('PG', 'G');
    
# 3. 등급별 rating, count
SELECT rating 등급, count(*) 수량 FROM film
    GROUP BY rating;

# rental_rate가 1보다 크고 6이하인 등급별(rating) 영화의 수를 출력
SELECT * FROM film;
SELECT rating '등급', count(*) '영화수' FROM film
	WHERE rental_rate>1.0 and rental_rate < 6.0
	GROUP BY rating;

# 1. 등급별 영화 수 합계, 평균, 최대, 최소 / 그룹 rating, rental_rate / 평균렌탈비용 내림차순
SELECT * FROM film;
SELECT rating, count(*), sum(rental_rate), avg(rental_rate), max(rental_rate), min(rental_rate)  FROM film
	GROUP BY rating, rental_rate
    ORDER BY avg(rental_rate) DESC;

# 2. 등급별 영화 개수, 등급, 평균 렌탈 rate를 조회하고 평균렌탈 rate를 내림차순으로 조회
SELECT count(*) '영화 개수', rating '등급', avg(rental_rate) '평균 렌탈' FROM film
	GROUP BY rating
    ORDER BY avg(rental_rate) DESC;

# 3. 분류가 family인 film테이블에서 서브쿼리를 이용해 조회
# film, film_category, category 테이블 활용
SELECT * FROM film;
SELECT * FROM film_category;
SELECT * FROM category;

SELECT film_id, title, release_year FROM film
	WHERE film_id in (SELECT film_id FROM film_category
		WHERE category_id = (SELECT category_id FROM category WHERE name = "Family"));


# 4. action 영화 이름, 영화수, 합계(rental_rate), 평균, 최소, 최대 집계
# film, film_category, category 테이블 활용
SELECT C.name, count(F.film_id) 영화수, sum(F.rental_rate) 합계, avg(F.rental_rate) 평균, 
		max(F.rental_rate) 최대, min(F.rental_rate) 최소 FROM film F, film_category FC
    join category C on FC.category_id = C.category_id
    WHERE FC.film_id = F.film_id
    GROUP BY C.name, F.rental_rate
    HAVING C.name = 'action'
    ORDER BY 평균 DESC;
    
# 5. 가장 대여비가 높은 영화 분류 조회 2개(name, sum(ifnull, 0으로)을 사용 payment 테이블에서 amount 합계 
# name은 category_name으로 합계는 revenue로 별칭)
# category film_category inventory payment rental 테이블 조인후 name으로 그룹분석 후 revenue로 내림차순
SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;
SELECT * FROM inventory;
SELECT * FROM payment;
SELECT * FROM rental;

SELECT C.name 'category_name', sum(ifnull(P.amount, 0)) 'revenue' FROM category C
	LEFT JOIN film_category FC ON C.category_id = FC.category_id
    LEFT JOIN film F ON FC.film_id = F.film_id
    LEFT JOIN inventory I ON F.film_id = I.film_id
    LEFT JOIN rental R ON I.inventory_id = R.inventory_id
    LEFT JOIN payment P ON R.rental_id = P.rental_id
    GROUP BY C.name
    ORDER BY revenue DESC;

# 6. 위 쿼리문 결과를 뷰로 생성
# v_cat_revenue로 하고 뷰를 조회하기
CREATE VIEW v_cat_revenue AS 
	SELECT C.name 'category_name', sum(ifnull(P.amount, 0)) 'revenue' FROM category C
		LEFT JOIN film_category FC ON C.category_id = FC.category_id
		LEFT JOIN film F ON FC.film_id = F.film_id
		LEFT JOIN inventory I ON F.film_id = I.film_id
		LEFT JOIN rental R ON I.inventory_id = R.inventory_id
		LEFT JOIN payment P ON R.rental_id = P.rental_id
		GROUP BY C.name
		ORDER BY revenue DESC;
SELECT * FROM v_cat_revenue limit 10;













