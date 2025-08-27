#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>  
#include "add.h"  // 直接包含头文件

int main() {
    printf("你好世界 hello world。开始测试 在编译时链接 dll，静态加载dll。\n");
    // 直接调用函数，系统自动加载DLL 
	// 用户明显是在尝试动态链接一个DLL库，但遇到了"undefined reference to `__imp_add'"这个经典错误，看来是新手在Windows平台用MinGW开发时容易踩的坑。
	// ld.exe: test1.o:test1.cpp:(.text+0x29): undefined reference to `__imp_add`
    // 表明编译器找到了函数声明（通过 add.h），但链接器（ld.exe）在动态库中找不到函数 add 的实现符号。
    int result = add(3, 5);
    printf("计算结果: %d\n", result);
	/* 
	cp ../output/libadd.dll ./lib
	cp ../output/libadd.dll ./
	g++ -c -o test1.o test1.cpp -I../include
	g++ -o app.exe test1.o -Llib -ladd
	./app.exe
	你好世界 hello world。开始测试 在编译时链接 dll，静态加载dll。
	计算结果: 8 
	*/ 
}