from tkinter import *

root = Tk() # 기본이 되는 윈도를 반환
root.title("혼공 GUI 연습") # 윈도의 제목 표시
root.geometry("400x200") # 윈도의 초기 크기를 400*200으로 설정

# 라벨 : 문자를 표현할 수 있는 위젯
label1 = Label(root, text='혼공 SQL은')
label2 = Label(root, text='쉽습니다.', font=('궁서체',30), bg='blue', fg='yellow')
# font - 글꼴과 글자크기 / bg - 배경색 / fg - 글자색

# pack() 함수를 통해서 라벨을 화면에 표시
label1.pack()
label2.pack()

root.mainloop() # 키보드 누르기, 마우스 클릭 등의 다양한 이벤트를 처리하기 위해 필요한 부분
