
#include <iostream>
#include <nlohmann/json.hpp>
#include <catch2/catch_test_macros.hpp>

using json = nlohmann::json;

namespace test2 {
    // a simple struct to model a person
    struct person {
        std::string name;
        std::string address;
        int age;
    };

    NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE(person, name, address, age);
}

TEST_CASE("NLOHMANN_DEFINE_TYPE_NON_INTRUSIVE简化to_json/from_json")
{
    // create a person
    test2::person p{ "Ned Flanders Test2", "744 Evergreen Terrace", 60 };

    // conversion: person -> json
    json j = p;

    std::cout << j << std::endl;
    // {"address":"744 Evergreen Terrace","age":60,"name":"Ned Flanders"}

    // conversion: json -> person
    auto p2 = j.get<test2::person>();

    REQUIRE(p.name == p2.name);
    REQUIRE(p.age == p2.age);
    REQUIRE(p.address == p2.address);
};