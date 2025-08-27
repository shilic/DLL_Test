# ===== 项目设置 =====
# 设置应用程序名
EXECUTABLE := app
PROJECT_NAME := mylib
DEBUG_TARGET := $(PROJECT_NAME)_test
RELEASE_TARGET := $(PROJECT_NAME).dll
# 设置源文件目录
SRC_DIR := src
# 设置头文件和库文件目录
INC_DIR := include
LIB_DIR := lib
# 设置 object 文件目录
BUILD_DIR := build
DEBUG_DIR := $(BUILD_DIR)/debug
RELEASE_DIR := $(BUILD_DIR)/release
OUTPUT_DIR := output

# ======== 编译器设置 ========
# C 编译器
CC := gcc
C_FLAGS_DEBUG := -g -O0
C_FLAGS_RELEASE := -O2
CFLAGS := -Wall -Wextra -Wfatal-errors -std=gnu99 -pthread
CFLAGS += -D BUILD_TIME="\"$(shell date +'%Y-%m-%d %H:%M:%S')\""
 
# C++ 编译器
CXX := g++
CXX_FLAGS_DEBUG := -g -O0
CXX_FLAGS_RELEASE := -O2
CXXFLAGS := -Wall -Wextra -Wfatal-errors -std=c++11 -pthread
CXXFLAGS += -D BUILD_TIME="\"$(shell date +'%Y-%m-%d %H:%M:%S')\""


# ======= 检测运行环境 =======
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

#  根据SHELL_TYPE定义不同命令
#  windows 环境 
ifeq ($(SHELL_TYPE), Windows_NT)
	RM := del /Q /F
	MKDIR := mkdir
	CP := copy
# UNIX 环境
else
	RM := rm -f
	MKDIR := mkdir -p
	CP := cp -f
endif













# gitbash 环境下 SHELL_TYPE = UnixShell UNAME = MINGW64_NT-10.0-19045
# SHELL_TYPE = Windows_NT UNAME = Windows_NT
shellType:
	@echo "SHELL_TYPE = $(SHELL_TYPE) UNAME = $(UNAME)"