project 3 是为了测试dll的生成和使用。

特别提醒，我使用的是windows下的gitbash终端进行的GCC编译，mingw64的版本使用的是w64devkit-x64，有了这两样东西之后，你可以直接在windiows环境下，凭借gitbash直接使用linux的命令，非常方便。

方式一： 生成dll + 使用HMODULE dll = LoadLibrary("libadd.dll");函数

    生成一个dll：使用本文件夹下的makefile进行编译，然后还有.h头文件。

    编译exe，此时使用test文件夹下的makefile进行EXE的编译，编译的时候，不进行任何头文件和库文件的链接。单纯只是编译EXE。然后将生成的

dll复制到运行文件夹下。在main函数中使用HMODULE dll = LoadLibrary("libadd.dll");动态加载dll。

适用于我知道函数签名，但是不知道dll文件名称的情况，需要用户动态加载dll的情况。

方式二：生成dll  +  编译时链接 + 使用头文件的方式。

    生成一个dll：使用本文件夹下的makefile进行编译，然后还有.h头文件。（这一步骤和上面的步骤一致）

    编译exe时，使用test.mk进行编译，需要-I../include链接头文件，然后在链接的时候，需要使用-Llib -ladd 链接库文件和dll库。GCC会自动到lib文件夹下去找你的add库（名称为libadd.dll，或者add.lib，最后才是寻找add.dll）。

    源代码里边，就不需要使用LoadLibrary函数进行dll的动态加载了。直接include头文件，然后像使用正常的函数一样使用头文件中的函数即可。

适用于我已经拿到用户的dll的情况。
