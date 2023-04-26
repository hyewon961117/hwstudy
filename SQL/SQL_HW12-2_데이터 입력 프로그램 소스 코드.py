import pymysql

# 전역변수 선언부
conn, cur = None, None
data1, data2, data3, data4 = "","","",""
sql = ""

# 메인코드
conn = pymysql.connect(host='127.0.0.1', user='user1', password='0000', db='soloDB', charset='utf8')
cur = conn.cursor()


while True:
    data1 = input("사용자 ID ==> ")
    if data1 == "":
        break
    data2 = input("사용자 이름 ==> ")
    data3 = input("이메일 ==> ")
    data4 = input("출생연도 ==> ")
    sql = "insert into userTable values('" + data1 + "', '" + data2 + "', '" + data3 + "', " + data4 + ")"
    cur.execute(sql)
conn.commit()
conn.close()