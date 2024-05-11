#include <iostream>
#include <functional>
#include "User.h"
#include "Service.h"


#define GENERATE_PROXY_CACHE_CLASS_BEGIN(TOriginal) \
    class TOriginal##Proxy : public TOriginal { 

#define GENERATE_PROXY_CACHE_CLASS_END() }

#define GENERATE_PROXY_CACHE_GETTER0(TOriginal, MethodName, TReture) \
    public: \
    TReture MethodName() { \
            std::cout << "Aspect: " << #MethodName  << std::endl; \
            return TOriginal::MethodName(); \
    }

#define GENERATE_PROXY_CACHE_GETTER1(TOriginal, MethodName, TReture, TParam1) \
    public: \
    TReture MethodName(TParam1 param1) { \
            std::cout << "Aspect: " << #MethodName << "(" << param1 << ")" << std::endl; \
            return TOriginal::MethodName(param1); \
    }

#define GENERATE_PROXY_CACHE_GETTER2(TOriginal, MethodName, TReture, TParam1, TParam2) \
    public: \
    TReture MethodName(TParam1 param1, TParam2 param2) { \
            std::cout << "Aspect: " << #MethodName << "(" << param1 << ", " << param2 << ")" << std::endl; \
            return TOriginal::MethodName(param1, param2); \
    }

GENERATE_PROXY_CACHE_CLASS_BEGIN(Service)
    GENERATE_PROXY_CACHE_GETTER1(Service, getUser, User, const std::string&)
    GENERATE_PROXY_CACHE_GETTER2(Service, getUser2, User, const std::string&, const int)
GENERATE_PROXY_CACHE_CLASS_END();

#define COUNT(...) std::tuple_size<decltype(std::make_tuple(__VA_ARGS__))>::value

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