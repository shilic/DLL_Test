#include "utils/StringUtil.h"

std::string StringUtil::toUpper(const std::string& str) {
    std::string upperStr;
    for (char c : str) {
        upperStr += toupper(c);
    }
    return upperStr;
}

void StringUtil::helloWorld() {
    printf("hello world\n");
    
}