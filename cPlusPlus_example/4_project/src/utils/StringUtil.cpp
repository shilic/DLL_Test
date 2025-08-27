#include "utils/StringUtil.h"

std::string StringUtil::toUpper(const std::string& str) {
    std::string upperStr;
    for (char c : str) {
        upperStr += toupper(c);
    }
    return upperStr;
}

void StringUtil::helloWorld() {
    printf("你好世界, hello world By Cpp Util\n"); 
}