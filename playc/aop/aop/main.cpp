#include <iostream>
#include <functional>
#include "User.h"
#include "Service.h"


// 通用的日志记录函数
void log(const std::string& message) {
    std::cout << "Logging: " << message << std::endl;
}

// AOP函数，接受原始函数和日志函数，返回一个新的函数对象
auto addLogging(const std::function<User(const std::string&)>& originalFunction, const std::string& message) {
    return [=](const std::string& name) {
        log(message);
        return originalFunction(name);
        };
}


int main() {
    // 创建原始的Service对象
    Service service;

    // 添加一些用户到Service
    service.addUser(User("John", 1234));
    service.addUser(User("Alice", 5678));

    // 使用AOP增加日志记录功能
    auto getUserWithLogging = addLogging(std::bind(&Service::getUser, service, std::placeholders::_1), "Before calling getUser for name");

    // 根据姓名获取用户
    std::string searchName = "Alice";
    User foundUser = getUserWithLogging(searchName);

    if (foundUser.getName() != "") {
        std::cout << "User found: " << foundUser.getName() << ", Code: " << foundUser.getCode() << std::endl;
    }
    else {
        std::cout << "User with name " << searchName << " not found." << std::endl;
    }

    return 0;
}