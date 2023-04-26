from tkinter import *
from tkinter import messagebox # 메시지 상자를 사용하기 위해 불러옴

def clickButton():
    messagebox.showinfo('버튼클릭', '버튼을 눌렀습니다.')

root = Tk()
root.geometry("200x200")
button1 = Button(root, text='여기를 클릭하세요.', fg='red', bg='yellow', command=clickButton)
button1.pack(expand=1) # expand=1 / 버튼을 화면 중앙에 표현하기 위함

root.mainloop()
