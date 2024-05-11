#pragma once

#include <iostream>
#include <string>
#include <vector>

#include "User.h"

class Service {
private:
    std::vector<User> users;

public:
    // ����û�
    void addUser(const User& user) {
        users.push_back(user);
    }

    // ����������ȡ�û�
    User getUser(const std::string& name) const {
        for (const auto& user : users) {
            if (user.getName() == name) {
                return user;
            }
        }
        // ����Ҳ����û�������һ���յ�User����
        return User("", -1);
    }
};
