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
 
# 设置头文件和库文件目录
INCDIRS := include
LIBDIRS := lib
 
LIBS :=
 
# 设置应用程序名
EXECUTABLE := app
 
 
# 定义一个头文件搜索路径变量
INCLUDE_PATHS := $(patsubst %,-I%, $(INCDIRS))
 
# 定义一个库文件搜索路径变量
LIBRARY_PATHS := $(patsubst %,-L%, $(LIBDIRS))
 
SHELL := /bin/bash
# 根据库文件路径查找动态库或静态库
LIBFILES := $(shell find $(LIBDIRS) \( -name '*.a' -o -name '*.so*' \) -printf '%f ')
#$(info LIBFILES = $(LIBFILES))
LIBNAMES = $(shell echo $(LIBFILES) | sed -e 's/\.so[^ ]*//g' -e 's/\.a//g')
#$(info LIBNAMES = $(LIBNAMES))
LIBNAMES_UNIQUE := $(shell echo $(shell printf '%s\n' $(LIBNAMES) | sort -u))
#$(info LIBNAMES_UNIQUE = $(LIBNAMES_UNIQUE))
LIBS += $(patsubst lib%, -l%, $(LIBNAMES_UNIQUE))
#$(info LIBS = $(LIBS))
 
# 设置目标文件目录
OBJDIR := build
 
# 使用 find 命令查找所有符合条件的源文件并设置为对象文件
SOURCES = $(shell find $(SRCDIR) -type f \( -name "*.c" -o -name "*.cpp" \))
 
ifeq ($(MAKECMDGOALS), release)
	RELEASE_EXECUTABLE := $(EXECUTABLE)
	RELEASE_OBJFILES = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/release/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/release/%.o, $(filter %.cpp,$(SOURCES)))
else
	DEBUG_EXECUTABLE := $(EXECUTABLE)
	DEBUG_OBJFILES = $(patsubst $(SRCDIR)/%.c, $(OBJDIR)/debug/%.o, $(filter %.c, $(SOURCES))) \
          $(patsubst $(SRCDIR)/%.cpp, $(OBJDIR)/debug/%.o, $(filter %.cpp,$(SOURCES)))
endif
 
 
# 编译规则
debug: $(DEBUG_EXECUTABLE)
 
$(DEBUG_EXECUTABLE): $(DEBUG_OBJFILES)
	@mkdir -p output/debug
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(DEBUG_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/debug/$(DEBUG_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! debug $(EXECUTABLE) \033[0m"
 
$(OBJDIR)/debug/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_DEBUG) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(OBJDIR)/debug/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_DEBUG) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
release: $(RELEASE_EXECUTABLE)
 
$(RELEASE_EXECUTABLE): $(RELEASE_OBJFILES)
	@mkdir -p output/release
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) $(LIBRARY_PATHS) $(RELEASE_OBJFILES) -Wl,--start-group $(LIBS) -Wl,--end-group -o output/release/$(RELEASE_EXECUTABLE)
	@echo -e "\033[32m Compilation successful! release $(EXECUTABLE) \033[0m"
 
$(OBJDIR)/release/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(C_FLAGS_RELEASE) $(CFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
$(OBJDIR)/release/%.o: $(SRCDIR)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXX_FLAGS_RELEASE) $(CXXFLAGS) $(INCLUDE_PATHS) -c $< -o $@
 
 
# 清理规则
clean:
	rm -rf output/debug/$(DEBUG_EXECUTABLE) output/release/$(RELEASE_EXECUTABLE) $(OBJDIR)/debug/* $(OBJDIR)/release/*
 
# 提供一个伪目标，使 clean 不会与文件夹同名冲突
.PHONY: clean