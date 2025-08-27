# 前情提要：编译环境使用 windows 下的 w64devkit-x64 ，终端使用的是 git bash
# ====================== 步骤1 - 项目设置 ======================
# 设置应用程序名
EXECUTABLE := app
# DLL_NAME := mylib
# DEBUG_TARGET := $(DLL_NAME)_test
# RELEASE_TARGET := $(DLL_NAME).dll
# 设置源文件目录
SRC_DIR := src
# 设置头文件，也就是你的.h文件存放的目录，一般是你自己写的代码的头文件(或者从网上复制粘贴的代码)
INC_DIRS := include
# 设置库文件目录，也就是别人的代码的存放目录，同样别人的.h头文件也会放到上边的 INC_DIRS 下
LIB_DIRS := lib
LIBS := 
# 设置 object 文件目录。也就是编译的中间变量(对象文件)存放的目录(目录后边不可以有空格)
BUILD_DIR := build
# $(Build_Debug_Dir) $(Build_Release_Dir)
Build_Debug_Dir := $(BUILD_DIR)/debug
Build_Release_Dir := $(BUILD_DIR)/release
# 设置可执行文件目录，
OUTPUT_DIR := output
# 定义一个头文件搜索路径变量。 $(patsubst pattern,replacement,text) 将 text中匹配 pattern的部分替换为 replacement。  模式匹配将 include 替换为 -Iinlude 
INCLUDE_PATHS := $(patsubst %,-I%, $(INC_DIRS))
# 定义一个库文件搜索路径变量。模式匹配将 lib 替换为 -Llib
LIBRARY_PATHS := $(patsubst %,-L%, $(LIB_DIRS))
# $(Output_Debug_Dir)    $(Output_Release_Dir) 
Output_Debug_Dir := $(OUTPUT_DIR)/debug
Output_Release_Dir := $(OUTPUT_DIR)/release
# 这个变量没有用到
SHELL := /bin/bash
# 指定源文件生成 DLL (可添加多个)
DLL_SOURCES := $(SRC_DIR)/add.c
# dll 输出目录  $(DLL_Out_Dir):= $(LIB_DIRS)
DLL_Out_Dir := $(Output_Debug_Dir)
# ====================== 步骤2 - 编译器设置 =======================
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


# ======================= 步骤3 - 检测终端类型，定义不同命令 ===============
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

#  根据SHELL_TYPE 终端类型 定义不同命令
#  windows 环境 
ifeq ($(SHELL_TYPE), Windows_NT)
	RM := del /Q /F
	MKDIR := mkdir
	CP := xcopy /E /I /Y /Q
# UNIX 环境(包括gitbash)
else
	RM := rm -f
	MKDIR := mkdir -p
	CP := cp -Rf
endif
# ========================= 步骤4 - 检测操作系统，链接so库，或者dll库 ==================
# 默认值处理
OS_Type := Unknown 
# 通过环境变量检测原生Windows
ifdef OS
	ifeq ($(OS),Windows_NT)
		OS_Type := Windows
	endif
else
# 通过特殊变量检测Windows
	ifdef COMSPEC
		OS_Type := Windows
	else
# 使用uname检测类Unix系统
#		UNAME := $(shell uname -s 2>/dev/null || echo Unknown) 
		ifeq ($(UNAME),Linux)
			OS_Type := Linux
		endif
		ifeq ($(UNAME),Darwin)
			OS_Type := macOS
		endif
# 检测Windows模拟环境
		ifneq (,$(findstring CYGWIN,$(UNAME)))
			OS_Type := Windows
		endif
		ifneq (,$(findstring MINGW,$(UNAME)))
			OS_Type := Windows
		endif
	endif
endif

#  根据 OS 不同操作系统 链接so库，或者dll库
#  windows 环境 ，链接.dll库
ifeq ($(OS_Type), Windows)
	LIBFILES := $(shell find $(LIB_DIRS) \( -name '*.dll' \) -printf '%f ')
	LIBNAMES := $(shell echo $(LIBFILES) | sed -e 's/\.dll[^ ]*//g')
	LIBNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(LIBNAMES) | sort -u))
	LIBS += $(addprefix -l, $(patsubst lib%, %, $(LIBNAMES_UNIQUE)))
# UNIX 环境 链接.so库
else
	LIBFILES := $(shell find $(LIB_DIRS) \( -name '*.a' -o -name '*.so*' \) -printf '%f ')
	LIBNAMES = $(shell echo $(LIBFILES) | sed -e 's/\.so[^ ]*//g' -e 's/\.a//g')
	LIBNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(LIBNAMES) | sort -u))
	LIBS += $(addprefix -l, $(patsubst lib%, %, $(LIBNAMES_UNIQUE)))
endif

# 使用 find 命令查找所有符合条件的源文件，并设置为对象文件
# find src -type f -name '*.cpp' -o -name '*.c'
SOURCES = $(shell find $(SRC_DIR) -type f \( -name "*.c" -o -name "*.cpp" \))

# 实际上这种写法不好，这种写法将所有的.o文件都链接到了一起，这样会导致编译速度变慢。正确的做法是使用 -MMD 命令生成依赖关系文件，然后使用 -include 命令引入依赖关系文件，这样编译速度就会大大提升。
ifeq ($(MAKECMDGOALS), release)
	RELEASE_EXECUTABLE := $(EXECUTABLE)
	RELEASE_OBJFILES = $(patsubst $(SRC_DIR)/%.c, $(Build_Release_Dir)/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRC_DIR)/%.cpp, $(Build_Release_Dir)/%.o, $(filter %.cpp,$(SOURCES)))
else
	DEBUG_EXECUTABLE := $(EXECUTABLE)
# $(filter %.c, $(SOURCES)) 从SOURCES变量中筛选所有.c文件  patsubst函数 将源文件路径替换为目标文件路径。最终，所有的.c文件和.cpp文件都生成了相应的.o文件并存放在DEBUG_OBJFILES中
	DEBUG_OBJFILES = $(patsubst $(SRC_DIR)/%.c, $(Build_Debug_Dir)/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRC_DIR)/%.cpp, $(Build_Debug_Dir)/%.o, $(filter %.cpp,$(SOURCES)))
endif

# 这是我备注的
# $ make -f makefileTemp.mk
# gcc -g -O0 -Wall -Wextra -Wfatal-errors -std=gnu99 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/message.c -o build/debug/utils/message.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/main.cpp -o build/debug/main.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/StringUtil.cpp -o build/debug/utils/StringUtil.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -Llib  build/debug/utils/message.o  build/debug/main.o  build/debug/utils/StringUtil.o -Wl,--start-group  -Wl,--end-group -o $(Output_Debug_Dir)/app

# 编译规则
debug: copy_dlls $(DEBUG_EXECUTABLE) 
# 这里的 DEBUG_OBJFILES 实际上就已经包含了所有的源代码文件，包括.c和.cpp的源代码文件，经过上一步骤，都变成了.o的文件后缀
# 这里就相当于是 app : build/debug/utils/message.o  build/debug/main.o  build/debug/utils/StringUtil.o 
# 链接步骤，将所有的.o文件链接成一个exe可执行文件
$(DEBUG_EXECUTABLE): $(DEBUG_OBJFILES)
	@$(MKDIR) $(Output_Debug_Dir)
# 混合C/C++项目，这里只能使用 g++ 来编译，不能使用 gcc
# INCLUDE_PATHS = -Iinclude ; LIBRARY_PATHS = -Llib ; DEBUG_OBJFILES 就不再赘述了，上边有提到。 LIBS = -lmylib1 -lmylib2 ，就相当于是外部的so库或者dll库。这里也是全部都链接上了。
# -o $(Output_Debug_Dir)/$(DEBUG_EXECUTABLE)  ​作用​​: 将编译链接生成的可执行文件命名为 $(Output_Debug_Dir)/目录下的 $(DEBUG_EXECUTABLE)变量指定的名字。
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(DEBUG_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o $(Output_Debug_Dir)/$(DEBUG_EXECUTABLE)
# 输出一段成功的提示符。
	@echo -e "\033[32m Compilation successful! debug $(EXECUTABLE) \033[0m"

# 编译步骤，分别对应的编译.c文件和.cpp文件
$(Build_Debug_Dir)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) $(C_FLAGS_DEBUG) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(Build_Debug_Dir)/%.o: $(SRC_DIR)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@

release: copy_dlls $(RELEASE_EXECUTABLE)
 
$(RELEASE_EXECUTABLE): $(RELEASE_OBJFILES)
	@$(MKDIR) $(Output_Release_Dir)
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(RELEASE_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o $(Output_Release_Dir)/$(RELEASE_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! release $(EXECUTABLE) \033[0m"
 
$(Build_Release_Dir)/%.o: $(SRC_DIR)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) $(C_FLAGS_RELEASE) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(Build_Release_Dir)/%.o: $(SRC_DIR)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@

# windows环境多一个步骤，将拷贝dll到output目录
copy_dlls:
ifeq ($(OS_Type), Windows)
	@echo "Copying DLLs to output directory..."
	@$(MKDIR) $(Output_Debug_Dir)  
	@$(MKDIR) $(Output_Release_Dir)
	@$(CP) lib/. $(Output_Debug_Dir) 
	@$(CP) lib/. $(Output_Release_Dir)
endif



# 所有build下的 .o文件都是由src下的.c文件编译而来(编译规则已经写了)
# 将要生成的 dll 文件都由对应的 o 文件生成。关键语句： gcc -shared -o output/libadd.dll build/add.o
# 为指定 DLL 源文件生成目标文件列表  $(patsubst $(SRC_DIR)/%.c, $(Build_Debug_Dir)/%.o, $(filter %.c, $(SOURCES)))
DLL_OBJS = $(patsubst $(SRC_DIR)/%.c, $(Build_Debug_Dir)/%.o, $(filter %.c, $(DLL_SOURCES)))
DLL_OBJS += $(patsubst $(SRC_DIR)/%.cpp, $(Build_Debug_Dir)/%.o, $(filter %.cpp, $(DLL_SOURCES)))

DLLNAMES := $(shell echo $(DLL_OBJS) | sed -e 's/\.o[^ ]*//g')
DLLNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(DLLNAMES) | sort -u))
# 使用 notdir 获取文件名,basename去除后缀名
DLL_Names_Base := $(basename $(notdir $(DLLNAMES_UNIQUE)))
DLL_TARGETS += $(patsubst %, $(DLL_Out_Dir)/lib%.dll, $(DLL_Names_Base))
# 生成 DLL 输出路径 (每个源文件生成独立的 DLL) 

# 默认目标: 构建所有对象文件和 DLL
dll: $(DLL_OBJS) $(DLL_TARGETS)
# 编译步骤，分别对应的编译.c文件和.cpp文件 (规则已经在上边写了)
# dll的编译步骤: 所有dll都由对应的.o文件生成 output/libadd.dll: build/add.o    gcc -shared -o output/libadd.dll build/add.o
$(DLL_Out_Dir)/lib%.dll: $(Build_Debug_Dir)/%.o
	$(CXX) -shared -o $@ $< -DBUILDING_DLL
#	$(CC) -shared -o $@ $< -DBUILDING_DLL
	@echo -e "\033[32m DLL Compilation: $@ \033[0m"








# 清理规则
clean:
	rm -rf $(Output_Debug_Dir)/$(DEBUG_EXECUTABLE) $(Output_Release_Dir)/$(RELEASE_EXECUTABLE) $(Build_Debug_Dir)/* $(Build_Release_Dir)/*
clean_dll:
	rm -rf $(Output_Debug_Dir)/*.dll $(Output_Release_Dir)/*.dll 
# gitbash 环境下 SHELL_TYPE = UnixShell UNAME = MINGW64_NT-10.0-19045 
shellType:
	@echo "SHELL_TYPE = $(SHELL_TYPE) UNAME = $(UNAME) MKDIR = $(MKDIR)"
# OS = Windows
OSType: 
	@echo "OS = $(OS_Type)"
# 测试用代码
_DEBUG_OBJFILES:
	@echo "DEBUG_OBJFILES = $(DEBUG_OBJFILES)"
run:
	@./$(Output_Debug_Dir)/$(DEBUG_EXECUTABLE)
debugAndRun: debug run
releaseAndRun: release run
.PHONY: shellType OSType clean debug release run debugAndRun releaseAndRun dll