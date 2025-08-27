# # 如果你的 makefiel改了名字， 可以使用 make -f checkShellType.mk 来指定文件。或者 make clean -f hello.mk
# 检测终端类型
.PHONY: shellType print_shellType
SHELL_TYPE := Unknown

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

# 示例：根据SHELL_TYPE定义不同命令
ifeq ($(SHELL_TYPE), PowerShell)
	PRINT_CMD = @echo "Running in PowerShell: Hello from PS!" > output.txt
else ifeq ($(SHELL_TYPE), GitBash)
	PRINT_CMD = @echo "Running in Git Bash: $$(date)" > output.txt
else ifeq ($(SHELL_TYPE), LinuxShell)
	PRINT_CMD = @echo "Running in Linux: $$(uname -a)" > output.txt
else
	PRINT_CMD = @echo "Unknown shell type" > output.txt
endif

# make -f checkShellType.mk 
# powershell 显示 Running in Linux UNAME = Windows_NT Type = UnixShell
# gitbash 显示 Detected shell Type = GitBash Detected shell Type = GitBash

shellType: 
	@echo "shell Type = $(SHELL_TYPE)"  
	$(if $(filter PowerShell,$(SHELL_TYPE)), @echo "Detected shell Type = PowerShell")
	$(if $(filter GitBash,$(SHELL_TYPE)), @echo "Detected shell Type = GitBash")
	$(if $(filter LinuxShell UnixShell,$(SHELL_TYPE)), @echo "Running in Linux UNAME = $(UNAME) Type = $(SHELL_TYPE)")

# 规则使用定义好的命令 make print_shellType -f checkShellType.mk 
print_shellType:
	$(PRINT_CMD)