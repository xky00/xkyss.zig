#pragma once

#include <iostream>
#include <string>
#include <vector>

#include "User.h"

class Service {
private:
    std::vector<User> users;

public:
    // 添加用户
    void addUser(const User& user) {
        users.push_back(user);
    }

    // 根据姓名获取用户
    User getUser(const std::string& name) const {
        for (const auto& user : users) {
            if (user.getName() == name) {
                return user;
            }
        }
        // 如果找不到用户，返回一个空的User对象
        return User("", -1);
    }
};
