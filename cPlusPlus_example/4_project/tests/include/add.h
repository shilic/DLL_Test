#ifdef BUILDING_DLL
    #define DLL_FUNC __declspec(dllexport)  // 导出
#else
    #define DLL_FUNC __declspec(dllimport)  // 导入
#endif

#ifdef __cplusplus
extern "C" {
#endif

DLL_FUNC int add(int a, int b);

#ifdef __cplusplus
}
#endif