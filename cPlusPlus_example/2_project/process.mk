# 该文档用于编译，并链接周立功的 dll ，使用不带变量的方式
# make -f process.mk  
# make clean -f process.mk   
# make run -f process.mk
# 最终可执行文件
all: copy_dlls output/debug/myapp.exe 

# 主程序编译
output/debug/myapp.exe: build/main.o build/message.o build/StringUtil.o 
#	g++ -o output/debug/myapp.exe build/main.o build/message.o build/StringUtil.o -L"lib/ControlCAN.dll"  # 确保路径用引号包裹
#	g++ -o output/debug/myapp.exe build/main.o build/message.o build/StringUtil.o  -Llib lib/ControlCAN.dll
# 直接链接 DLL 文件​
#	g++ -o output/debug/myapp.exe build/main.o build/message.o build/StringUtil.o  lib/ControlCAN.lib
#	g++ -o output/debug/myapp.exe build/main.o build/message.o build/StringUtil.o  ./lib/ControlCAN.dll
#   以下方式提示我库不兼容，原因是使用了32位的dll，而编译器是64位的，采用了64位的dll后，问题解除。  skipping incompatible lib\ControlCAN.lib when searching for -lControlCAN
	g++ -o output/debug/myapp.exe build/main.o build/message.o build/StringUtil.o  -Llib -lControlCAN
# 检查dll架构，输出的是lib/ControlCAN.dll: PE32 executable for MS Windows 5.00 (DLL), Intel i386, 5 sections
# 主文件编译
build/main.o: src/main.cpp
	g++ -c -o build/main.o src/main.cpp -Iinclude -Iinclude/utils

# 工具模块编译
build/message.o: src/utils/message.c
	g++ -c -o build/message.o src/utils/message.c -Iinclude -Iinclude/utils

build/StringUtil.o: src/utils/StringUtil.cpp
	g++ -c -o build/StringUtil.o src/utils/StringUtil.cpp -Iinclude -Iinclude/utils

# 测试模块编译
build/test1.o: test/test1.cpp
	g++ -c -o build/test1.o test/test1.cpp -Iinclude -Iinclude/utils

# 创建必要目录（如果不存在）
create_dirs:
	mkdir -p build
	mkdir -p output/debug

# 先创建 output/debug 目录，再 复制 lib 目录下的所有文件到 output/debug 。
copy_dlls:
	@echo "Copying DLLs to output directory..."
	mkdir -p output/debug 
	cp -R lib/. output/debug 

# 清理构建，
clean:
	rm -f build/*.o 
	rm -rf output/*

# 运行程序
run: all
	./output/debug/myapp.exe

.PHONY: all clean run create_dirs copy_dlls