#include <stdio.h>
#include <windows.h>
// 这里不使用#include <add.h>，使用 LoadLibrary("libadd.dll"); 加载

int main() {
	// 这种写法，不需要链接阶段操作​​：编译时不需指定DLL相关参数；运行时才检查DLL存在性​​：程序启动后才会检查DLL
    // 动态加载DLL
	printf("你好世界 hello world。\n开始测试使用 LoadLibrary 函数动态加载 dll。\n");
    HMODULE dll = LoadLibrary("libadd.dll");
    if (dll == NULL) {
        printf("加载DLL失败\n");
        return 1;
    }

    // 获取函数地址
    typedef int (*AddFunc)(int, int);
    AddFunc addFunc = (AddFunc)GetProcAddress(dll, "add");
    if (addFunc == NULL) {
        printf("获取函数地址失败\n");
        FreeLibrary(dll);
        return 1;
    }

    // 调用DLL函数
    int result = addFunc(3, 5);
    printf("计算结果: %d\n", result);
	// 测试成功
    // 释放资源
    FreeLibrary(dll);
    return 0;
}