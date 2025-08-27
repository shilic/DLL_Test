# 构建测试程序 make clean -f test.mk    make run -f test.mk
all: copy app.exe
app.exe: test1.o 
#	g++ -o app.exe test1.o -Llib/libadd.dll  # ❌ 错误写法 
#   若问题仍存在，可直接静态链接 DLL（不推荐长期方案）：
#   g++ -o app.exe test1.o ./lib/libadd.dll  # ✅ 直接指定DLL文件
#  # ✅ 正确写法 使用编译期链接的方式，直接使用静态链接
#	g++ -o app.exe test1.o -Llib -ladd  
	g++ -o app.exe test1.o -L../output -ladd 
# test1 主函数编译成 test1.o
test1.o: test1.cpp
	g++ -c -o test1.o test1.cpp -I../include 
# 复制DLL到测试目录。 lib 目录是为了在编译时进行链接，而不是运行时使用。而测试目录(./)下的DLL是运行时使用的。编译完成后，lib目录下的dll可以删除，而测试目录下的dll必须保留。
copy: 
#	cp ../output/libadd.dll ./lib
	cp ../output/libadd.dll ./

# 运行测试程序
run: all
	./app.exe

# 清理测试目录
clean:
	rm -f  ./app.exe ./main.exe ./libadd.dll  ./test1.o ./lib/libadd.dll