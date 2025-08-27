#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include "RsaHelper.h"
#include <StringUtil.h>

int main() {
    RsaHelper helper;
    printf("你好世界 hello world");
    helper.encrypt("Hello, World!");
    helper.decrypt("Encrypted Data");
    StringUtil::helloWorld();
    return 0;
}