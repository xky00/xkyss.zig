#include <iostream>
#include "aop.hpp"

void test01();

int main() {
    std::cout << "Main start." << std::endl;

    test01();

    std::cout << "Main end." << std::endl;
    return 0;
}

class Alice
{
public:
    void foo() {
        std::cout << "alice foo" << std::endl;
    }

    void bar() {
        std::cout << "alice bar" << std::endl;
    }
};


template <typename Base>
struct AspectFoo : public Base::this_t {

    using fulltype_t = typename Base::fulltype_t;
    using this_t = AspectFoo;

    AspectFoo() {
        std::cout << "[ctor for aspect]: " << typeid(this_t).name() << std::endl
                  << "  [fulltype is]: " << typeid(fulltype_t).name() << std::endl;
    }

    virtual fulltype_t somefunc(fulltype_t a) {
        return a;
    }

    // Aspect interface
    virtual void funcFoo() {
        std::cout
            << "[greeting from]: " << typeid(&AspectFoo::funcFoo).name() << std::endl;
    }

    virtual ~AspectFoo() {
        std::cout
            << "[dtor for aspect]: " << typeid(this_t).name() << std::endl
            << "  [fulltype is]: " << typeid(fulltype_t).name() << std::endl;
    }

    // static member support
    //static qaop::static_proxy<this_t> sp;
};

void test01() {
    using namespace ks_aop;
    using Combine = AspectFoo<aopfy<aopbase<Alice, AspectFoo>, AspectFoo>>::fulltype_t;
    Combine c;
    c.foo();
    c.bar();
}
