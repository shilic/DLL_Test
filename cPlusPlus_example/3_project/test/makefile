# 构建测试程序
all: copy main.exe

# 编译测试代码
main.exe: main.c
	gcc -o main.exe main.c

# 复制DLL到测试目录
copy: 
	cp ../output/libadd.dll ./

# 运行测试程序
run: all
	./main.exe

# 清理测试目录
clean:
	rm -f  ./main.exe ./libadd.dll  