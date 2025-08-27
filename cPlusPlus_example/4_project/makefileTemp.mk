# 这是一个非常详细的makefile模版，可以同时编译c和cpp，经测试，测试通过
#  make -f makefileTemp.mk    make clean -f makefileTemp.mk 
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
 
# 设置源文件目录
SRC_DIR := src
# 设置目标文件目录 BUILD_DIR
BUILD_DIR := build
# 设置头文件和库文件目录
INC_DIRS := include
LIB_DIRS := lib
 
LIBS := 
 
# 设置应用程序名
EXECUTABLE := app
 
 
# 定义一个头文件搜索路径变量。 $(patsubst pattern,replacement,text) 将 text中匹配 pattern的部分替换为 replacement。  模式匹配将 include 替换为 -Iinlude
INCLUDE_PATHS := $(patsubst %,-I%, $(INC_DIRS))
 
# 定义一个库文件搜索路径变量。模式匹配将 lib 替换为 -Llib
LIBRARY_PATHS := $(patsubst %,-L%, $(LIB_DIRS))

# 这个变量没有用到
SHELL := /bin/bash
# 根据库文件路径查找动态库或静态库
# $(shell ...)​​执行括号内的Shell命令，并将其输出结果返回给Makefile变量。
# find $(LIB_DIRS)​​在LIB_DIRS变量指定的目录（可能包含多个路径）中递归搜索文件。
# \( -name '*.a' -o -name '*.so*' \)​​指定搜索条件（分组逻辑）：
# -name '*.a'：匹配所有​​静态库​​文件（后缀为.a）。
# -o：逻辑“或”运算符。
# -name '*.so*'：匹配所有​​共享库​​文件（后缀为.so或包含版本号如.so.1）。
# 括号()在Shell中是特殊字符（用于子进程执行），需用反斜杠\`转义，告诉find`它们是命令的分组符号
# 测试命令 find lib -name '*.dll' -printf '%f '
LIBFILES := $(shell find $(LIB_DIRS) \( -name '*.a' -o -name '*.so*' \) -printf '%f ')
#	$(info LIBFILES = $(LIBFILES))
# 在 Linux Shell 和各种命令行工具中，​​竖线符号 |称为管道（Pipe）​​，它是用于​​命令间数据传递​​的核心操作符。用于将一个命令的输出作为下一个命令的输入。
# echo $(LIBFILES)​​输出LIBFILES变量中的库文件名列表（如："libmath.a libnet.so libnet.so.1"）
# sed -e 's/\.so[^ ]*//g' -e 's/\.a//g'​​将库文件名列表中的.so和.a后缀去除，得到库文件名列表（如："libmath libnet"）
# echo $(LIBFILES) | sed -e 's/\.dll[^ ]*//g' 
# echo "lib/ControlCAN.dll lib/kerneldlls/CAN232.dll" | sed -e 's/\.dll[^ ]*//g' 
# 输出例如 lib/ControlCAN \n lib/kerneldlls/CAN232 
# LIBNAMES := $(shell echo $(LIBFILES) | sed -e 's/\.dll[^ ]*//g')
LIBNAMES = $(shell echo $(LIBFILES) | sed -e 's/\.so[^ ]*//g' -e 's/\.a//g')
#	$(info LIBNAMES = $(LIBNAMES))
# 这句Makefile语句的作用是​​去除变量 LIBNAMES中的重复值，并将结果存储到 LIBNAMES_UNIQUE变量中​​。 sort：对输入行进行排序  -u：去重（unique），仅保留唯一值
# echo $(shell printf '%s\n' "lib/ControlCAN \n lib/kerneldlls/CAN232" | sort -u)
# printf '%s\n' "lib/ControlCAN lib/ControlCAN lib/kerneldlls/CAN232" | sort -u
LIBNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(LIBNAMES) | sort -u))
# $(info LIBNAMES_UNIQUE = $(LIBNAMES_UNIQUE))
# 将 LIBNAMES_UNIQUE中形如 lib% 的值转换为 -l% 的格式 ，去掉前缀lib，加上-l  += 保留已有的链接选项并追加
# 连接器会按顺序优先查找动态链接库 优先查找文件格式： Windows libname.dll→ name.dll ； Linux/macOS  libname.so→ libname.a→ name ；
# 这里存在的问题是，如果库不是标准定义，没有lib前缀，将会有问题，所以正确的做法是去掉所有lib前缀，然后统一加上-l
# LIBS += $(addprefix -l, $(patsubst lib%, %, $(LIBNAMES_UNIQUE)))
LIBS += $(patsubst lib%, -l%, $(LIBNAMES_UNIQUE))
# $(info LIBS = $(LIBS))
 





 
# 使用 find 命令查找所有符合条件的源文件，并设置为对象文件
# find src -type f -name '*.cpp' -o -name '*.c'
SOURCES = $(shell find $(SRC_DIR) -type f \( -name "*.c" -o -name "*.cpp" \))

# 实际上这种写法不好，这种写法将所有的.o文件都链接到了一起，这样会导致编译速度变慢。正确的做法是使用 -MMD 命令生成依赖关系文件，然后使用 -include 命令引入依赖关系文件，这样编译速度就会大大提升。
ifeq ($(MAKECMDGOALS), release)
	RELEASE_EXECUTABLE := $(EXECUTABLE)
	RELEASE_OBJFILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/release/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/release/%.o, $(filter %.cpp,$(SOURCES)))
else
	DEBUG_EXECUTABLE := $(EXECUTABLE)
# $(filter %.c, $(SOURCES)) 从SOURCES变量中筛选所有.c文件  patsubst函数 将源文件路径替换为目标文件路径。最终，所有的.c文件和.cpp文件都生成了相应的.o文件并存放在DEBUG_OBJFILES中
	DEBUG_OBJFILES = $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/debug/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRC_DIR)/%.cpp, $(BUILD_DIR)/debug/%.o, $(filter %.cpp,$(SOURCES)))
endif
 
# 这是我备注的
# $ make -f makefileTemp.mk
# gcc -g -O0 -Wall -Wextra -Wfatal-errors -std=gnu99 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/message.c -o build/debug/utils/message.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/main.cpp -o build/debug/main.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/StringUtil.cpp -o build/debug/utils/StringUtil.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -Llib  build/debug/utils/message.o  build/debug/main.o  build/debug/utils/StringUtil.o -Wl,--start-group  -Wl,--end-group -o output/debug/app

# 编译规则
debug: $(DEBUG_EXECUTABLE)

# 这里的 DEBUG_OBJFILES 实际上就已经包含了所有的源代码文件，包括.c和.cpp的源代码文件，经过上一步骤，都变成了.o的文件后缀
# 这里就相当于是 app : build/debug/utils/message.o  build/debug/main.o  build/debug/utils/StringUtil.o 
# 链接步骤，将所有的.o文件链接成一个exe可执行文件
$(DEBUG_EXECUTABLE): $(DEBUG_OBJFILES)
	@mkdir -p output/debug
# 混合C/C++项目，这里只能使用 g++ 来编译，不能使用 gcc
# INCLUDE_PATHS = -Iinclude ; LIBRARY_PATHS = -Llib ; DEBUG_OBJFILES 就不再赘述了，上边有提到。 LIBS = -lmylib1 -lmylib2 ，就相当于是外部的so库或者dll库。这里也是全部都链接上了。
# -o output/debug/$(DEBUG_EXECUTABLE)  ​作用​​: 将编译链接生成的可执行文件命名为 output/debug/目录下的 $(DEBUG_EXECUTABLE)变量指定的名字。
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(DEBUG_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/debug/$(DEBUG_EXECUTABLE)
# 输出一段成功的提示符。
	@echo -e "\033[32m Compilation successful! debug $(EXECUTABLE) \033[0m"

# 编译步骤，分别对应的编译.c文件和.cpp文件
$(BUILD_DIR)/debug/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_DEBUG) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(BUILD_DIR)/debug/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
release: $(RELEASE_EXECUTABLE)
 
$(RELEASE_EXECUTABLE): $(RELEASE_OBJFILES)
	@mkdir -p output/release
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(RELEASE_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/release/$(RELEASE_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! release $(EXECUTABLE) \033[0m"
 
$(BUILD_DIR)/release/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_RELEASE) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(BUILD_DIR)/release/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
 
# 清理规则
clean:
	rm -rf output/debug/$(DEBUG_EXECUTABLE) output/release/$(RELEASE_EXECUTABLE) $(BUILD_DIR)/debug/* $(BUILD_DIR)/release/*
 
# 提供一个伪目标，使 clean 不会与文件夹同名冲突
.PHONY: clean