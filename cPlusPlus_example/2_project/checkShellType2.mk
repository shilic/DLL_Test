# 使用 make -f checkShellType2.mk 来指定文件
# 检测终端类型
.PHONY: shellType

SHELL_TYPE := Unknown 
# 在类 Unix 环境中使用 uname 检测
UNAME := $(shell uname -s 2>/dev/null || echo Unknown) 
# 检测 Git Bash（Windows 上的 MINGW 环境）
ifneq (,$(findstring MINGW,$(UNAME)))
	SHELL_TYPE := UnixShell
else ifneq (,$(findstring MSYS,$(UNAME)))
	SHELL_TYPE := UnixShell
else ifneq (,$(findstring CYGWIN,$(UNAME)))
	SHELL_TYPE := UnixShell
else
	ifeq ($(UNAME), Windows_NT)
		SHELL_TYPE := Windows_NT
    # 检测 Linux 和其他 Unix 系统
	else ifeq ($(UNAME), Linux)
		SHELL_TYPE := UnixShell
	else 
		SHELL_TYPE := UnixShell
	endif
endif
# gitbash 环境下 SHELL_TYPE = UnixShell UNAME = MINGW64_NT-10.0-19045
# SHELL_TYPE = Windows_NT UNAME = Windows_NT
shellType:
	@echo "SHELL_TYPE = $(SHELL_TYPE) UNAME = $(UNAME)"