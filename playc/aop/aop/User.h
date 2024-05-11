#pragma once
#include <iostream>
#include <string>
#include <vector>

class User {
private:
    std::string name;
    int code;

public:
    // ���캯��
    User(std::string n, int c) : name(n), code(c) {}

    // ��ȡ����
    std::string getName() const {
        return name;
    }

    // ��ȡ����
    int getCode() const {
        return code;
    }

    // ��������
    void setName(const std::string& n) {
        name = n;
    }

    // ���ô���
    void setCode(int c) {
        code = c;
    }
};