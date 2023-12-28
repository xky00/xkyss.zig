// main.cpp : 此文件包含 "main" 函数。程序执行将在此处开始并结束。
//

#include <iostream>
#include <assert.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace ns {
    // a simple struct to model a person
    struct person {
        std::string name;
        std::string address;
        int age;
    };

    void to_json(json& j, const person& p) {
        j = json{ {"name", p.name}, {"address", p.address}, {"age", p.age} };
    }

    void from_json(const json& j, person& p) {
        j.at("name").get_to(p.name);
        j.at("address").get_to(p.address);
        j.at("age").get_to(p.age);
    }
}

int main()
{
    // create a person
    ns::person p{ "Ned Flanders", "744 Evergreen Terrace", 60 };

    // conversion: person -> json
    json j = p;

    std::cout << j << std::endl;
    // {"address":"744 Evergreen Terrace","age":60,"name":"Ned Flanders"}

    // conversion: json -> person
    auto p2 = j.get<ns::person>();

    assert(p.name == p2.name);
    assert(p.age == p2.age);
    assert(p.address == p2.address);
};