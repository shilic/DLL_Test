# 构建过程不使用变量
all: build/add.o output/libadd.dll

# 编译源文件 -> 中间文件   
build/add.o: src/add.c
	gcc -c src/add.c -o build/add.o -Iinclude -DBUILDING_DLL

# 生成DLL -> output目录
output/libadd.dll: build/add.o
	gcc -shared -o output/libadd.dll build/add.o

# 清理生成文件
clean:
	rm -f build/add.o output/libadd.dll