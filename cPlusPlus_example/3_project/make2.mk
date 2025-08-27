# make -f make2.mk  make clean -f make2.mk 
all: build/add.o output/libadd.dll output/libadd.lib

# 生成导入库(.lib)
output/libadd.lib: build/add.o
	dlltool --dllname libadd.dll --input-def libadd.def --output-lib output/libadd.lib

# 生成DLL定义文件
libadd.def: build/add.o
	dlltool -e build/add.o --output-def libadd.def

build/add.o: src/add.c
	gcc -c src/add.c -o build/add.o -Iinclude -DBUILDING_DLL -DLIBADD_EXPORTS

# 生成DLL
output/libadd.dll: build/add.o
	gcc -shared -o output/libadd.dll build/add.o
    
clean:
	rm -f build/add.o output/* libadd.def