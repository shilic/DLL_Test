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
SRCDIR := src
# 设置目标文件目录 BUILD_DIR
BUILD_DIR := build
# 设置头文件和库文件目录
INCDIRS := include
LIBDIRS := lib
 
LIBS := 
 
# 设置应用程序名
EXECUTABLE := app
 
 
# 定义一个头文件搜索路径变量。模式匹配将 include 替换为 -Iinlude
INCLUDE_PATHS := $(patsubst %,-I%, $(INCDIRS))
 
# 定义一个库文件搜索路径变量。模式匹配将 lib 替换为 -Ilib
LIBRARY_PATHS := $(patsubst %,-L%, $(LIBDIRS))

# 这个变量没有用到
SHELL := /bin/bash
# 根据库文件路径查找动态库或静态库
LIBFILES := $(shell find $(LIBDIRS) \( -name '*.a' -o -name '*.so*' \) -printf '%f ')
#	$(info LIBFILES = $(LIBFILES))
LIBNAMES = $(shell echo $(LIBFILES) | sed -e 's/\.so[^ ]*//g' -e 's/\.a//g')
#	$(info LIBNAMES = $(LIBNAMES))
LIBNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(LIBNAMES) | sort -u))
# $(info LIBNAMES_UNIQUE = $(LIBNAMES_UNIQUE))
LIBS += $(patsubst lib%, -l%, $(LIBNAMES_UNIQUE))
# $(info LIBS = $(LIBS))
 

 
# 使用 find 命令查找所有符合条件的源文件，并设置为对象文件
SOURCES = $(shell find $(SRCDIR) -type f \( -name "*.c" -o -name "*.cpp" \))
 
ifeq ($(MAKECMDGOALS), release)
	RELEASE_EXECUTABLE := $(EXECUTABLE)
	RELEASE_OBJFILES = $(patsubst $(SRCDIR)/%.c, $(BUILD_DIR)/release/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRCDIR)/%.cpp, $(BUILD_DIR)/release/%.o, $(filter %.cpp,$(SOURCES)))
else
	DEBUG_EXECUTABLE := $(EXECUTABLE)
	DEBUG_OBJFILES = $(patsubst $(SRCDIR)/%.c, $(BUILD_DIR)/debug/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRCDIR)/%.cpp, $(BUILD_DIR)/debug/%.o, $(filter %.cpp,$(SOURCES)))
endif
 
 
# 编译规则
debug: $(DEBUG_EXECUTABLE)

# $ make -f makefileTemp.mk
# gcc -g -O0 -Wall -Wextra -Wfatal-errors -std=gnu99 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/message.c -o build/debug/utils/message.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/main.cpp -o build/debug/main.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -c src/utils/StringUtil.cpp -o build/debug/utils/StringUtil.o
# g++ -g -O0 -Wall -Wextra -Wfatal-errors -std=c++11 -pthread -D BUILD_TIME="\"2025-06-28 10:48:02\"" -Iinclude -Llib  build/debug/utils/message.o  build/debug/main.o  build/debug/utils/StringUtil.o -Wl,--start-group  -Wl,--end-group -o output/debug/app

 
$(DEBUG_EXECUTABLE): $(DEBUG_OBJFILES)
	@mkdir -p output/debug
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(DEBUG_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/debug/$(DEBUG_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! debug $(EXECUTABLE) \033[0m"
 
$(BUILD_DIR)/debug/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_DEBUG) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(BUILD_DIR)/debug/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
release: $(RELEASE_EXECUTABLE)
 
$(RELEASE_EXECUTABLE): $(RELEASE_OBJFILES)
	@mkdir -p output/release
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(RELEASE_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/release/$(RELEASE_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! release $(EXECUTABLE) \033[0m"
 
$(BUILD_DIR)/release/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_RELEASE) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(BUILD_DIR)/release/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
 
# 清理规则
clean:
	rm -rf output/debug/$(DEBUG_EXECUTABLE) output/release/$(RELEASE_EXECUTABLE) $(BUILD_DIR)/debug/* $(BUILD_DIR)/release/*
 
# 提供一个伪目标，使 clean 不会与文件夹同名冲突
.PHONY: clean