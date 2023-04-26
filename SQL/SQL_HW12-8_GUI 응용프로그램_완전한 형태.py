import pymysql
from tkinter import *
from tkinter import messagebox

# 입력 버튼을 클릭할때 실행되는 함수
def insertData():
    conn, cur = None, None
    data1, data2, data3, data4 = "","","",""
    sql = ""

    conn = pymysql.connect(host='127.0.0.1', user='user1', password='0000', db='soloDB', charset='utf8')
    cur = conn.cursor()

    # 화면의 4개 엔트리에서 값을 가져옴
    data1 = edt1.get()
    data2 = edt2.get()
    data3 = edt3.get()
    data4 = edt4.get()

    # 쿼리문을 만들어서 실행
    sql = "INSERT INTO userTable VALUES('" + data1 + "', '" + data2 + "', '" + data3 + "', " + data4 + ")"
    cur.execute(sql)

    conn.commit()
    conn.close()

    # 입력이 성공된것을 메시지 상자로 표시
    messagebox.showinfo('성공', '데이터 입력 성공')

# 조회 버튼을 클릭할때 실행되는 함수
def selectData():
    strData1, strData2, strData3, strData4 = [], [], [], []

    conn = pymysql.connect(host='127.0.0.1', user='user1', password='0000', db='soloDB', charset='utf8')
    cur = conn.cursor()
    cur.execute("SELECT * FROM userTable")

    strData1.append("사용자 ID")
    strData1.append("----------")
    strData2.append("사용자 이름")
    strData2.append("----------")
    strData3.append("사용자 이메일")
    strData3.append("----------")
    strData4.append("사용자 출생연도")
    strData4.append("----------")

    # 각각의 리스트에 사용자ID, 이름, 이메일, 출생연도끼리 각각 모아지게 데이터 저장
    while (True) :
        row = cur.fetchone()
        if row == None :
            break
        strData1.append(row[0])
        strData2.append(row[1])
        strData3.append(row[2])
        strData4.append(row[3])

    # 일단 화면에서 4개의 리스트박스를 모두 비움
    listData1.delete(0,listData1.size()-1)
    listData2.delete(0, listData2.size() - 1)
    listData3.delete(0, listData3.size() - 1)
    listData4.delete(0, listData4.size() - 1)

    # zip 함수는 동시에 여러 개의 리스트 항목에 접근하기 위해 사용
    for item1, item2, item3, item4 in zip(strData1, strData2, strData3, strData4):
        listData1.insert(END, item1)
        listData2.insert(END, item2)
        listData3.insert(END, item3)
        listData4.insert(END, item4)

    conn.close()

# GUI
root = Tk()
root.geometry("600x300")
root.title("완전한 GUI 응용프로그램")

edtFrame = Frame(root)
edtFrame.pack()
listFrame = Frame(root)
listFrame.pack(side=BOTTOM, fill=BOTH, expand=1)

edt1 = Entry(edtFrame, width=10)
edt2 = Entry(edtFrame, width=10)
edt3 = Entry(edtFrame, width=10)
edt4 = Entry(edtFrame, width=10)

edt1.pack(side=LEFT, padx=10, pady=10)
edt2.pack(side=LEFT, padx=10, pady=10)
edt3.pack(side=LEFT, padx=10, pady=10)
edt4.pack(side=LEFT, padx=10, pady=10)

btnInsert = Button(edtFrame, text='입력', command = insertData)
btnInsert.pack(side=LEFT, padx=10, pady=10)
btnSelect = Button(edtFrame, text='조회', command = selectData)
btnSelect.pack(side=LEFT, padx=10, pady=10)

listData1 = Listbox(listFrame, bg='yellow')
listData1.pack(side=LEFT, fill=BOTH, expand=1)
listData2 = Listbox(listFrame, bg='yellow')
listData2.pack(side=LEFT, fill=BOTH, expand=1)
listData3 = Listbox(listFrame, bg='yellow')
listData3.pack(side=LEFT, fill=BOTH, expand=1)
listData4 = Listbox(listFrame, bg='yellow')
listData4.pack(side=LEFT, fill=BOTH, expand=1)

root.mainloop()