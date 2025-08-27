# hello: main.c message.c 的意思是告诉makefile，要编译的文件是main.c message.c。如果这两个文件存在更新的话，就编译，没有的话就不编译
# 编译器会先把main.c message.c编译成对象文件，然后链接成可执行文件 hello 。
hello: main.c message.c
#下边的语句 gcc main.c message.c -o hello 就是编译命令，前边只能是tab键，不能用空格
#这一个步骤把编译和链接写在一起了，更好的写法是分开写，这样编译和链接分开执行，这样编译和链接的错误会更清晰
	gcc main.c message.c -o hello