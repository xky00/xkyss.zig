#include <iostream>
#include <functional>
#include "User.h"
#include "Service.h"


#define GENERATE_PROXY_CACHE_CLASS_BEGIN(TOriginal) \
    struct TOriginal##Proxy : public TOriginal { \
        using Original = TOriginal;

#define GENERATE_PROXY_CACHE_CLASS_END() }

#define GENERATE_PROXY_CACHE_GETTER0(MethodName, TReturn) \
    TReturn MethodName() { \
            std::cout << "Aspect: " << #MethodName  << std::endl; \
            return Original::MethodName(); \
    }

#define GENERATE_PROXY_CACHE_GETTER1(MethodName, TReturn, TParam1) \
    TReturn MethodName(TParam1 param1) { \
            std::cout << "Aspect: " << #MethodName << "(" << param1 << ")" << std::endl; \
            return Original::MethodName(param1); \
    }

#define GENERATE_PROXY_CACHE_GETTER2(MethodName, TReturn, TParam1, TParam2) \
    TReturn MethodName(TParam1 param1, TParam2 param2) { \
            std::cout << "Aspect: " << #MethodName << "(" << param1 << ", " << param2 << ")" << std::endl; \
            return Original::MethodName(param1, param2); \
    }

GENERATE_PROXY_CACHE_CLASS_BEGIN(Service)
    GENERATE_PROXY_CACHE_GETTER1(getUser, User, const std::string&)
    GENERATE_PROXY_CACHE_GETTER2(getUser2, User, const std::string&, const int)
GENERATE_PROXY_CACHE_CLASS_END();


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