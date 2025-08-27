可以再项目目录下新建一个build目录

然后执行 cmake .. 就会调用上级目录下的CMakeLists.txt 来构建项目，然后在这个build目录下生成中间变量 和目标文件。
