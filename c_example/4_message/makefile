# 使用 PHONY 来指定一个伪目标。make就不会把clean当作文件来处理，使用 make clean 来清理
.PHONY: clean all

# 可以在 make 文件中定义编译参数，也就是变量，这样，你可以在编译时改变参数。
CFLAGS = -Wall -g 
# 正式开发中，可以把目标文件（exe），源文件（c代码），中间文件（对象文件）都定义成变量
targets = hello world
sources = main.c message.c
objects = main.o message.o

# make 命令默认会执行第一个目标，你也可以使用make hello 来执行hello目标。下边的每一个目标文件都可以单独编译
# 使用 @ 符号来隐藏命令行输出
all : $(targets)
	@echo "完成 all done"
# 3. 最终会在这里将两份对象文件链接成可执行文件
# hello: main.o message.o 
# 	gcc main.o message.o -o hello
# world: main.o message.o 
# 	gcc main.o message.o -o world
# 你也可以像这样写 $@ 是一个自动变量，表示当前正在编译的目标文件。
$(targets):  $(objects)
	gcc $(CFLAGS)  $(objects) -o $@

# 1. 下边的语句就是编译main.c为的对象文件，gcc -c main.c  就是只编译成.o文件，而不进行链接
# main.o: main.c
# # 可以使用 自动变量 $< 获取当前正在处理的文件名。也就是 main.c
# # $< -o $@的意思是告诉编译器，将 $<编译成对象文件，并保存为 $@  ，也就是 main.o
# 	gcc $(CFLAGS) -c $< -o $@
# # 2. 分别将两份源码编译为各自的对象文件
# message.o: message.c
# 	gcc $(CFLAGS) -c $< -o $@

# 比如，刚才这两行编译main.o和编译message.o的语句，他们的规则是完全相同的。
# 故可以简化成下边的语句，就表示所有的.o文件，都是由对应的.c文件生成的

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@
# make 使用缩进来管理块，所以一定要缩进
# 可以使用伪目标来执行一些操作，例如清理缓存 使用 make clean 来清理
clean:
#	cmd /c "del /F /Q *.o hello.exe 2> nul"
#  cmd语法
#	del /Q *.o hello.exe world.exe 2>NUL
#linux系统使用该命令	
	rm -f *.o hello world