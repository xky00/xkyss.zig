#include <iostream>
#include <functional>
#include "User.h"
#include "Service.h"


class ServiceProxy : public Service {
public:
    // 添加用户
    void addUser(const User& user) {
        // 在调用原始Service对象之前添加额外逻辑
        std::cout << "Adding user: " << user.getName() << std::endl;
        Service::addUser(user);
    }

    // 根据姓名获取用户
    User getUser(const std::string& name) const {
        // 在调用原始Service对象之前添加额外逻辑
        std::cout << "Getting user: " << name << std::endl;
        return Service::getUser(name);
    }
};

int main() {
    // 创建Service代理对象
    ServiceProxy serviceProxy;

    // 添加一些用户到Service
    serviceProxy.addUser(User("John", 1234));
    serviceProxy.addUser(User("Alice", 5678));

    // 根据姓名获取用户
    std::string searchName = "Alice";
    User foundUser = serviceProxy.getUser(searchName);

    if (foundUser.getName() != "") {
        std::cout << "User found: " << foundUser.getName() << ", Code: " << foundUser.getCode() << std::endl;
    }
    else {
        std::cout << "User with name " << searchName << " not found." << std::endl;
    }

    return 0;
}