#pragma once
#include <iostream>
#include <string>
#include <vector>

class User {
private:
    std::string name;
    int code;

public:
    // 构造函数
    User(std::string n, int c) : name(n), code(c) {}

    // 获取姓名
    std::string getName() const {
        return name;
    }

    // 获取代码
    int getCode() const {
        return code;
    }

    // 设置姓名
    void setName(const std::string& n) {
        name = n;
    }

    // 设置代码
    void setCode(int c) {
        code = c;
    }
};