#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <atomic>
#include <thread>
#include <chrono>
#include <ctime>
#include <future>

// 这里使用相对路径来指定头文件。使用  g++ -MM src/main.cpp 语句时，可以输出用户导入的头文件。
/* 这里输出 main.o: src/main.cpp src/../include/utils/StringUtil.h \
 src/../include/utils/message.h src/../include/add.h  */
//#include "../include/utils/StringUtil.h"
#include "../include/add.h" 
// 特例，如果是C代码和CPP代码混写，在头文件引用时，C代码的头文件需要使用extern "C"包裹。 修改：使用extern "C"包裹C语言实现的头文件
//#include "../include/utils/message.h" 

int main() {
	// 如果是使用cpp代码的头文件，则不需要使用extern "C"包裹
    //StringUtil::helloWorld();
	// Cpp在使用C代码时，需要在头文件中使用 extern "C"  包裹C头文件(已经在头文件处理了)
    //HelloWorld();  
	int result = add(3, 5);
    printf("调用库函数进行计算，计算结果: %d\n", result);
}