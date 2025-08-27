// // 特例，如果是C代码和CPP代码混写，cpp代码如果想要使用C代码的方法，在头文件引用时，C代码的头文件需要使用extern "C"包裹。 修改：使用extern "C"包裹C语言实现的头文件
#ifdef __cplusplus
extern "C" {
#endif

void HelloWorld();

#ifdef __cplusplus
}
#endif
// void HelloWorld();