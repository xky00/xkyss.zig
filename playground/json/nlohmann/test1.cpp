
#include <iostream>
#include <nlohmann/json.hpp>
#include <catch2/catch_test_macros.hpp>

using json = nlohmann::json;

namespace test1 {
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

TEST_CASE("定义to_json/from_json")
{
    // create a person
    test1::person p{ "Ned Flanders Test1", "744 Evergreen Terrace", 60 };

    // conversion: person -> json
    json j = p;

    std::cout << j << std::endl;
    // {"address":"744 Evergreen Terrace","age":60,"name":"Ned Flanders"}

    // conversion: json -> person
    auto p2 = j.get<test1::person>();

    REQUIRE(p.name == p2.name);
    REQUIRE(p.age == p2.age);
    REQUIRE(p.address == p2.address);
};