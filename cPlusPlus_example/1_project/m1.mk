# ===== 项目设置 =====
PROJECT_NAME := mylib
DEBUG_TARGET := $(PROJECT_NAME)_test
RELEASE_TARGET := $(PROJECT_NAME).dll
SRC_DIR := src
INC_DIR := include
LIB_DIR := lib
BUILD_DIR := build
DEBUG_BUILD_DIR := $(BUILD_DIR)/debug
RELEASE_BUILD_DIR := $(BUILD_DIR)/release
OUTPUT_DIR := dist

# ===== 工具链设置 =====
CXX := g++
RM := rm -rf
MKDIR := mkdir -p
FIND := find
CP := cp -f
MAKE_DIR = @$(MKDIR) $(@D) # 创建目标目录的函数

# ===== 文件查找 =====
# 所有源文件 (包括子目录)
SRCS := $(shell $(FIND) $(SRC_DIR) -type f -name '*.cpp' 2>/dev/null || true)

# 对象文件
# 保留源文件结构生成 .o 文件列表
DEBUG_OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(DEBUG_BUILD_DIR)/%.o,$(SRCS))
RELEASE_OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(RELEASE_BUILD_DIR)/%.o,$(SRCS))

# 测试文件 (如果有)
TEST_SRCS := $(shell $(FIND) tests -type f -name '*.cpp' 2>/dev/null || true)
TEST_OBJS := $(patsubst tests/%.cpp, $(DEBUG_BUILD_DIR)/tests/%.o, $(TEST_SRCS))

# 第三方库的DLL
LIB_DLLS := $(wildcard $(LIB_DIR)/*.dll)
OUTPUT_DLLS := $(patsubst $(LIB_DIR)/%, $(OUTPUT_DIR)/%, $(LIB_DLLS))

# ===== 编译标志 =====
# 共享编译标志
# COMMON_FLAGS := -I$(INC_DIR) -I$(LIB_DIR) -Wall -Wextra -std=c++17 -MMD -MP
COMMON_FLAGS := -I$(INC_DIR) -I$(LIB_DIR) -Wall -Wextra -std=c++17

# 调试版本编译标志
DEBUG_FLAGS := -g -O0 -DDEBUG -ftest-coverage -fprofile-arcs

# 发布版本编译标志
EXPORT_MACRO := $(shell echo $(PROJECT_NAME) | tr '[:lower:]' '[:upper:]')_EXPORTS
RELEASE_FLAGS := -O3 -DNDEBUG -D$(EXPORT_MACRO)

# ===== 链接标志 =====
# 调试版本链接 (创建测试程序)
DEBUG_LDFLAGS :=
DEBUG_LDLIBS := -L$(LIB_DIR)

# 发布版本链接 (创建DLL)
RELEASE_LDFLAGS := -shared -Wl,--out-implib,$(OUTPUT_DIR)/lib$(RELEASE_TARGET).a
RELEASE_LDLIBS := -L$(LIB_DIR)

# 添加链接库 (如果需要)
# DEBUG_LDLIBS += -lthirdparty
# RELEASE_LDLIBS += -lthirdparty

# ===== 主要目标 =====
.PHONY: all debug release clean distclean run gdb test coverage 

# 默认目标 - 显示帮助
all:
	@echo "请指定构建目标:"
	@echo "  debug    - 编译调试版本(用于测试)"
	@echo "  release  - 编译发布版本(DLL)"
	@echo "  run      - 运行测试程序"
	@echo "  gdb      - 使用gdb调试程序"
	@echo "  test     - 编译并运行所有测试"
	@echo "  coverage - 生成代码覆盖率报告(debug后)"
	@echo "  clean    - 清理编译文件"
	@echo "  distclean- 清理所有生成内容"

# 调试构建 - 创建测试程序
debug: $(DEBUG_OBJS) $(TEST_OBJS) | $(OUTPUT_DIR)
	$(CXX) $^ $(DEBUG_LDFLAGS) $(DEBUG_LDLIBS) -o $(OUTPUT_DIR)/$(DEBUG_TARGET)
	@echo "✅ 调试构建完成: $(OUTPUT_DIR)/$(DEBUG_TARGET)"
	@echo "使用 'make run' 运行或 'make gdb' 调试"

# 发布构建 - 创建DLL
release: $(RELEASE_OBJS) | $(OUTPUT_DIR) 
	$(CXX) $^ $(RELEASE_LDFLAGS) $(RELEASE_LDLIBS) -o $(OUTPUT_DIR)/$(RELEASE_TARGET)
	@echo "✅ 发布构建完成: $(OUTPUT_DIR)/$(RELEASE_TARGET)"

# 复制第三方DLL规则 - 修复: 只保留一个实现
$(OUTPUT_DIR)/%.dll: $(LIB_DIR)/%.dll | $(OUTPUT_DIR)
	$(CP) $< $@
	@echo "✅ 已复制DLL: $(@F)"

# 运行测试程序
run: debug
	@echo "运行测试程序..."
	./$(OUTPUT_DIR)/$(DEBUG_TARGET)

# 使用gdb调试
gdb: debug
	@gdb -ex 'run' --args ./$(OUTPUT_DIR)/$(DEBUG_TARGET)

# 编译并运行测试
test: debug
ifneq ($(strip $(TEST_SRCS)),)
	@echo "运行所有测试..."
	./$(OUTPUT_DIR)/$(DEBUG_TARGET)
else
	@echo "⚠️ 未找到测试文件(tests目录)"
endif

# 生成覆盖率报告(需先运行测试)
coverage:
ifneq ($(strip $(TEST_SRCS)),)
	gcovr -r . --html --html-details -o $(OUTPUT_DIR)/coverage.html
	@echo "✅ 代码覆盖率报告生成: $(OUTPUT_DIR)/coverage.html"
else
	@echo "⚠️ 无法生成覆盖率报告：未找到测试文件"
endif

# ===== 构建规则 =====
# 调试对象文件
# $(DEBUG_BUILD_DIR)/%.o: $(SRC_DIR)/%cpp
$(DEBUG_BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(MAKE_DIR)
	$(CXX) $(COMMON_FLAGS) $(DEBUG_FLAGS) -c $< -o $@

# 发布对象文件
# $(RELEASE_BUILD_DIR)/%.o: $(SRC_DIR)/%cpp
$(RELEASE_BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	$(MAKE_DIR)
	$(CXX) $(COMMON_FLAGS) $(RELEASE_FLAGS) -c $< -o $@

# 创建输出目录
$(OUTPUT_DIR):
	$(MKDIR) $@

# 自动生成依赖
# -include $(DEBUG_OBJS:.o=.d)
# -include $(RELEASE_OBJS:.o=.d)
# -include $(TEST_OBJS:.o=.d)

# 测试对象文件
$(DEBUG_BUILD_DIR)/tests/%.o: tests/%.cpp
	$(MAKE_DIR)
	$(CXX) $(COMMON_FLAGS) $(DEBUG_FLAGS) -c $< -o $@




# ===== 清理目标 =====
clean:
	$(RM) $(DEBUG_OBJS) $(RELEASE_OBJS) $(TEST_OBJS)
	$(RM) $(OUTPUT_DIR)/$(DEBUG_TARGET) $(OUTPUT_DIR)/$(RELEASE_TARGET)
	$(RM) $(OUTPUT_DIR)/lib$(RELEASE_TARGET).a
	$(RM) $(OUTPUT_DLLS)
	# 清理覆盖率数据
	$(RM) $(DEBUG_BUILD_DIR)/*.gcda $(DEBUG_BUILD_DIR)/*.gcno
	$(RM) $(DEBUG_BUILD_DIR)/tests/*.gcda $(DEBUG_BUILD_DIR)/tests/*.gcno
	@echo "✅ 清理编译文件完成"

distclean: clean
	$(RM) -r $(BUILD_DIR) $(OUTPUT_DIR)
	@echo "✅ 清理所有生成内容完成"