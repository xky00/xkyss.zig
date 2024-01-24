#include <iostream>
#include "aop.hpp"

void test01();
void test02();

int main() {
    std::cout << "Main start." << std::endl;

    // test01();
    test02();

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
                  << "  [fulltype is]: "   << typeid(fulltype_t).name() << std::endl;
    }

    virtual fulltype_t somefunc(fulltype_t a) {
        return a;
    }

    // Aspect interface
    virtual void funcFoo() {
        std::cout << "[greeting from]: " << typeid(&AspectFoo::funcFoo).name() << std::endl;
    }

    virtual ~AspectFoo() {
        std::cout << "[dtor for aspect]: " << typeid(this_t).name() << std::endl
                  << "  [fulltype is]: "   << typeid(fulltype_t).name() << std::endl;
    }

    // static member support
    static ks_aop::static_proxy<this_t> sp;
};


template <typename Base>
struct AspectBar : public Base::this_t {

    using fulltype_t = typename Base::fulltype_t;
    using this_t = AspectBar;

    AspectBar() {
        std::cout << "[ctor for aspect]: " << typeid(this_t).name() << std::endl
                  << "  [fulltype is]: "   << typeid(fulltype_t).name() << std::endl;
    }

    virtual fulltype_t somefunc(fulltype_t a) {
        return a;
    }

    // Aspect interface
    virtual void funcFoo() {
        std::cout << "[greeting from]: " << typeid(&AspectFoo::funcFoo).name() << std::endl;
    }

    virtual ~AspectBar() {
        std::cout << "[dtor for aspect]: " << typeid(this_t).name() << std::endl
                  << "  [fulltype is]: "   << typeid(fulltype_t).name() << std::endl;
    }

    // static member support
    static ks_aop::static_proxy<this_t> sp;
};

void test01() {
    using namespace ks_aop;
    using Aspected = AspectFoo<aopfy<aopbase<Alice, AspectFoo>, AspectFoo>>::fulltype_t;
    Aspected a;
    a.foo();
    a.bar();
}

void test02() {
    using namespace ks_aop;
    using Aspected = Decorate<Alice>::with<AspectFoo>::type;
    Aspected a;
    a.foo();
    a.bar();
}

void test03() {
    using namespace ks_aop;
}
