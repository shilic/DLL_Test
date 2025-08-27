一、判断运行终端的类型

如果是linux终端则使用linuxshell脚本，如果是powershell环境，则使用powershell。特殊情况，如果是在windows环境下的gitbash终端，同样使用linuxshell脚本

```makefile
# 检测终端类型
SHELL_TYPE :=

# 检查是否在 PowerShell 环境下（通过环境变量和特有变量）
ifdef PSMODULEPATH
    SHELL_TYPE := PowerShell
else
    # 在类 Unix 环境中使用 uname 检测
    UNAME := $(shell uname -s 2>/dev/null || echo Unknown)
    # 例如 ：gitbash 环境下 uname -s 2>/dev/null || echo Unknown
    # 打印 : MINGW64_NT-10.0-19045


    # 检测 Git Bash（Windows 上的 MINGW 环境）
    ifneq (,$(findstring MINGW,$(UNAME)))
        SHELL_TYPE := GitBash
    else ifneq (,$(findstring MSYS,$(UNAME)))
        SHELL_TYPE := GitBash
    else
        # 检测 Linux 和其他 Unix 系统
        ifeq ($(UNAME), Linux)
            SHELL_TYPE := LinuxShell
        else
            SHELL_TYPE := UnixShell
        endif
    endif
endif

shellType:
    @echo "检测终端类型(Detected shell Type): $(DETECTED_SHELL)"
    # 根据终端类型执行不同操作
    ifeq ($(DETECTED_SHELL), PowerShell)
        powershell -Command "Write-Host '这是在 PowerShell 中运行'"
    else ifeq ($(DETECTED_SHELL), GitBash)
        bash -c "echo '这是在 Git Bash 中运行'"
    else
        echo "这是在 Linux/Unix shell 中运行: $$(uname -s)"
    endif
```

二、查找src 目录下的源代码

git bash 命令:

以下命令如果使用 `powershell`就会提示参数不正确。所以只可以使用 `gitbash`或者linux环境下的终端。

```bash

# 以下命令会查找所有c和cpp代码
find $(SRC_DIR) -name '*.cpp' -o -name '*.c'
find src -name '*.cpp' -o -name '*.c'
# 输出：
# src/main.cpp
# src/message.c
# src/utils/StringUtil.cpp


# 如果是只查找 cpp ，可以这样写。

find src -name '*.cpp'
# 输出：
# src/main.cpp
# src/utils/StringUtil.cpp

# 如果是只查找 c ，可以这样写。
find src -name '*.c'
# 输出： 
# src/message.c


```

powershell命令:

```powershell
Get-ChildItem -Path src -Filter *.cpp -Recurse -File | Select-Object FullName
```
