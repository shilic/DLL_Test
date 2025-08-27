#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <atomic>
#include <thread>
#include <chrono>
#include <ctime>
#include <future>

#include "utils/StringUtil.h"
#include "ControlCAN.h"

#pragma comment(lib, "ControlCAN.lib")

// 设备打开状态
bool openStatus = false;
// 4 表示 ZLG设备类型
UINT zlgDeviceType = 4;
// 设备索引
UINT deviceIndex = 0;
// 保留参数 = 0
UINT Reserved = 0;
UINT canIndex = 0;
UINT const WaitTime = 400;


// 线程执行的任务函数
void threadFunction(int id, std::string message) {
    std::cout << "线程 " << id << " 启动: " << message << std::endl;
    // 模拟耗时操作
    std::this_thread::sleep_for(std::chrono::seconds(1));
    std::cout << "线程 " << id << " 结束" << std::endl;
}
int main() {
    printf("开始测试 周立功dll 调用程序\n");
    StringUtil::helloWorld();
	printf("zlgDeviceType = %d\n", zlgDeviceType);
	// 1. 打开设备
	UINT open = VCI_OpenDevice(zlgDeviceType, deviceIndex, Reserved);
	openStatus = (open == 1 ? true : false);
	if (openStatus) {
		printf("✅设备打开成功\n");
	}
	else {
		printf("❌设备打开失败\n");
		return -1;
	}
	// 2. 设置波特率
	VCI_INIT_CONFIG config = VCI_INIT_CONFIG();
	config.AccCode = 0x00000000;// 默认值，不要动
	config.AccMask = 0xFFFFFFFF;// 默认值，不要动
	config.Timing0 = 0x00; // 0x00
	config.Timing1 = 0x1C;// 0x1C
	config.Filter = 0x01;// 默认值，不要动
	config.Mode = 0x00; // 默认值，不要动
	//config.Reserved = 0x00;
	// 3. 使用波特率参数，初始化设备
	UINT ini = VCI_InitCAN(zlgDeviceType, deviceIndex, canIndex, &config);
	if (ini == 1) {
		printf("✅初始化设备成功。\n");
	} else {
		printf("❌初始化设备失败。");
		return -1;
	}
	// 4. 启动CAN设备
	UINT start = VCI_StartCAN(zlgDeviceType, deviceIndex, canIndex);
	if (start == 1) {
		printf("✅启动设备 成功。\n");
	}
	else {
		printf("❌启动设备 失败。\n");
		return -1;
	}
	// // 启动异步任务（自动在新线程执行）
    // auto future = std::async(std::launch::async, []{
    //     std::cout << "异步线程开始工作..." << std::endl;
    //     std::this_thread::sleep_for(std::chrono::seconds(2));
    //     return 42; // 返回值
    // });
	std::atomic<bool> running(true); 
    // 创建定时器线程
    std::thread timer_thread([&] {
        std::this_thread::sleep_for(std::chrono::seconds(30));
        running = false;
    });
    
    std::cout << "程序开始运行，30秒后将自动退出...\n" << std::endl;
    
    // 主循环
    while (running) {
        // 在此执行需要完成的任务
        //std::cout << "运行中..." << std::endl;
		UINT maxlen = VCI_GetReceiveNum(zlgDeviceType, deviceIndex, canIndex);
		if (maxlen <= 0 ) {
			continue;
		}
		VCI_CAN_OBJ canObj[maxlen] ;
		UINT receiveNum = VCI_Receive(zlgDeviceType, deviceIndex, canIndex, canObj, maxlen, WaitTime);
		for (size_t i = 0; i < maxlen; i++) {
			VCI_CAN_OBJ obj = canObj[i];
			std::string message = "ID:" + std::to_string(obj.ID) + "  Data:" + std::to_string(obj.Data[0]) + " " + std::to_string(obj.Data[1]) + " " + std::to_string(obj.Data[2]) + " " + std::to_string(obj.Data[3]) + " "
			 + std::to_string(obj.Data[4]) + " " + std::to_string(obj.Data[5]) + " " + std::to_string(obj.Data[6]) + " " + std::to_string(obj.Data[7]) + " \n";
			//printf("CANID = 0x%X, %X %X %X %X %X %X %X %X \n", obj.ID, obj.Data[0], obj.Data[1], obj.Data[2], obj.Data[3], obj.Data[4], obj.Data[5], obj.Data[6], obj.Data[7]);
			std::cout << message << std::endl;
		} 
        //std::this_thread::sleep_for(1);
    }
    
    timer_thread.join();
    std::cout << "程序已运行30秒，正常退出！\n" << std::endl;

	/* 经过测试，可以正常打开周立功设备，并接收报文。 
	开始测试 周立功dll 调用程序
		hello world By Util
		zlgDeviceType = 4
		✅设备打开成功
		✅初始化设备成功。
		✅启动设备 成功。
		程序开始运行，10秒后将自动退出...

		ID:287454020  Data:0 1 2 3 4 5 6 17

		ID:287454020  Data:0 1 2 3 4 5 6 17

		ID:287454020  Data:0 1 2 3 4 5 6 17

		ID:287454020  Data:0 1 2 3 4 5 6 16

		ID:287454020  Data:0 1 2 3 4 5 6 1

		ID:287454020  Data:0 1 2 3 4 5 6 1

		ID:287454020  Data:0 1 2 3 4 5 6 1
	 */
    return 0;
}