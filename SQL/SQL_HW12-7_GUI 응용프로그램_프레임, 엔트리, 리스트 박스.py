from tkinter import *

root = Tk()
root.geometry("200x250")

# 프레임 : 화면을 여러 구역으로 나눌때 사용 (화면에는 표시 X)
upFrame = Frame(root)
upFrame.pack()
downFrame = Frame(root)
downFrame.pack()

# 엔트리 : 입력 상자를 표현
editBox = Entry(upFrame, width=10) # upFrame에 나오도록
editBox.pack(padx=20, pady=20)

# 리스트 박스 : 목록을 표현
listbox = Listbox(downFrame, bg='yellow') # downFrame에 나오도록
listbox.pack()

# 리스트박스에 데이터 입력
listbox.insert(END,"하나")
listbox.insert(END,"둘")
listbox.insert(END,"셋")ㅣ

root.mainloop()