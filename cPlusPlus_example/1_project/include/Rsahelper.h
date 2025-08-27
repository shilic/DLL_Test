#pragma once
#include <string>

#ifdef _WIN32
#define EXPORT_API __declspec(dllexport)
#else
#define EXPORT_API __attribute__((visibility("default")))
#endif

class EXPORT_API RsaHelper {
public:
    void encrypt(const std::string& data);
    void decrypt(const std::string& data);
};