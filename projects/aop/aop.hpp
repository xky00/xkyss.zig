//
// Created by dev88 on 2024/1/24.
//

#ifndef KS_AOP_HPP
#define KS_AOP_HPP

#include <functional>
#include <map>

namespace ks_aop {

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// aopfy

    // 前置声明
    template<typename AopBase, template<typename> class... Aspects>
    struct aopfy;

    // parameter base wrap.
    template<typename Base, template<typename> class... Aspects>
    struct aopbase {
        using reference_t = aopfy<aopbase, Aspects...>;
        using base_t = Base;
    };

    // iteration template definition.
    template<typename AopBase, template<typename> class FirstAspects,
            template<typename> class... RestAspects>
    struct aopfy<AopBase, FirstAspects, RestAspects...> {
        using fulltype_t = FirstAspects<typename aopfy<AopBase, RestAspects...>::fulltype_t>;
        using this_t = typename AopBase::base_t;
    };

    // end of iteration template definition.
    template<typename AopBase>
    struct aopfy<AopBase> {
        using fulltype_t = typename AopBase::reference_t;
        using this_t = typename AopBase::base_t;
    };


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// Struct Decorate makes it easy to use.
    template<typename Base>
    struct Decorate {

        // keep the reference during iteration.
        template<template<typename> class... Aspects>
        struct remember {
            using reference_t = aopfy<aopbase<Base, Aspects...>, Aspects...>;
        };

        // 前置声明
        template<typename Remember, template<typename> class... Aspects>
        struct with_imp;

        template<template<typename> class... Aspects>
        struct with {
            using type = typename with_imp<remember<Aspects...>, Aspects...>::combined_t;
        };

        template<typename Remember, template<typename> class FirstAspect,
                template<typename> class... RestAspects>
        struct with_imp<Remember, FirstAspect, RestAspects...> {
            using combined_t = FirstAspect<typename with_imp<Remember, RestAspects...>::combined_t>;
        };

        template<typename Remember, template<typename> class LastAspect>
        struct with_imp<Remember, LastAspect> {
            using combined_t = LastAspect<typename Remember::reference_t>;
        };
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// Struct Combine is used to combine multiple aspects into one.
    //
    // Usage:
    // template <typename Class>
    // using AspectFooBar = Combine<AspectFoo, AspectBar>::combined<Class>;
    //
    // 前置声明
    template<template<typename> class... Aspects>
    struct Combine;

    template<template<typename> class FirstAspect,
            template<typename> class... RestAspects>
    struct Combine<FirstAspect, RestAspects...> {
        template<typename Class>
        using combined = FirstAspect<typename Combine<RestAspects...>::template combined<Class>>;
    };

    template<template<typename> class LastAspect>
    struct Combine<LastAspect> {
        template<typename Class>
        using combined = LastAspect<Class>;
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// static_member
    constexpr unsigned int Hash(char const *str, size_t seed) { // NOLINT(*-no-recursion)
        return (0 == *str)
               ? seed
               : Hash(str + 1, seed ^ (*str + 0x9e3779b9 + (seed << 6) + (seed >> 2)));
    }

    template<size_t N>
    constexpr unsigned int Name(const char (&str)[N]) {
        // auto type matching from char(&)[N] to const char *
        return Hash(str, 0);
    }

    template<typename Class, typename Type, unsigned int N>
    Type &static_member(Type il = Type()) {
        static Type object(il);
        return object;
    }

    template<typename Aspect>
    struct static_proxy {
        template<typename Type, unsigned int N>
        static Type &proxy(Type il = Type()) {
            return static_member<typename Aspect::fulltype_t, Type, N>(il);
        }
    };

    template<typename Class, typename Type, unsigned int N>
    Type &proxy(Type il = Type()) {
        return static_member<typename Class::fulltype_t, Type, N>(il);
    }

    template<typename T>
    void get_addr(T &&t, T *&aim, __attribute__((unused)) std::true_type a) {
        aim = &t;
    }

    template<typename T>
    void get_addr(T &&t, T *&aim, __attribute__((unused)) std::false_type a) {
        *aim = t;
    }

    template<typename T>
    void get_addr(T &&t, T *&aim) {
        get_addr(std::forward<T &&>(t), aim, std::is_lvalue_reference<T &&>());
    }

    using func_t = std::function<int()>;


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// stub
    template<typename Fulltype>
    struct stub {
        using advice_t = std::function<func_t(Fulltype *, func_t &)>;

        // stub_r : 将成员函数包装为function (有返回值)
        template<typename Class, typename Ret, typename... Params>
        static std::function<int(Fulltype *, Ret *, Params...)> _r(__attribute__((unused)) Ret (Class::*mfp)(Params...),
                                                                   __attribute__((unused)) std::function<int()> f = nullptr) { // NOLINT(*-unnecessary-value-param)
            return [=](Fulltype *self, Ret *ret, Params... args) -> int {
                return (nullptr != f) ? f() : 0;
            };
        }

        // stub : 将成员函数包装为function (无返回值)
        template<typename Class, typename Ret, typename... Params>
        static std::function<int(Fulltype *, Params...)> _(__attribute__((unused)) Ret (Class::*mfp)(Params...),
                                                           __attribute__((unused)) std::function<int()> f = nullptr) { // NOLINT(*-unnecessary-value-param)
            return [=](Fulltype *self, Params... args) -> int {
                return (nullptr != f) ? f() : 0;
            };
        }

        // wrap_r : introduction for mem_func with return value
        template<typename Class, typename Ret, typename... Params>
        static std::function<int(Fulltype *, Ret *, Params...)>
        wrap_r(__attribute__((unused)) Ret (Class::*mfp)(Params...)) {
            return [=](Fulltype *self, Ret *ret, Params... args) -> int {
                get_addr((self->*mfp)(args...), ret);
                return 0;
            };
        }

        // wrap : introduction for mem_func return void
        template<typename Class, typename Ret, typename... Params>
        static std::function<int(Fulltype *, Params...)> wrap(__attribute__((unused)) Ret (Class::*mfp)(Params...)) {
            return [=](Fulltype *self, Params... args) -> int {
                (self->*mfp)(args...);
                return 0;
            };
        }

        // _advice wrap
        template<typename Class>
        static advice_t wrap(__attribute__((unused)) func_t (Class::*mfp)(func_t &)) {
            return [=](Fulltype *self, func_t &f) -> func_t {
                return (self->*mfp)(f);
            };
        }
    };


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// action is one of the concrete code executed at each jointpoint.
    template<typename Fulltype, typename Callable>
    struct action {
        using advice_t = std::function<func_t(Fulltype *, func_t &)>;

        static func_t default_advice(__attribute__((unused)) Fulltype *self, __attribute__((unused)) func_t &f) {
            return [=]() {
                f();
                return 0;
            };
        }

        action(Callable fn, advice_t ad = action::default_advice) // NOLINT(*-explicit-constructor)
                : _fn(fn), _advice(ad) {

        }

        template<typename... Params>
        void execute(Fulltype *self, Params... args) {
            _closure = std::bind(_fn, self, args...);
            if (nullptr != _advice)
                (_advice(self, _closure))();
            else
                _closure();
        }

        template<typename Ret, typename... Params>
        void execute_r(Fulltype *self, Ret *ret, Params... args) {
            _closure = std::bind(_fn, self, ret, args...);
            if (nullptr != _advice)
                (_advice(self, _closure))();
            else
                _closure();
        }

        template<typename Ret, typename... Params>
        func_t &bind(Fulltype *self, Ret *ret, Params... args) {
            _closure = std::bind(_fn, self, ret, args...);
            return _closure;
        }

    private:
        Callable _fn;
        func_t _closure;
        advice_t _advice;
    };

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// constants
    unsigned int SIG_OF_BEFORE = Name("::before");
    unsigned int SIG_OF_INSITU = Name("::insitu");
    unsigned int SIG_OF_AFTER = Name("::after");


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// invoke

    template<typename Class, typename Ret, typename... Params>
    unsigned int FuncHash(Ret (Class::*mf)(Params...)) {
        auto f = reinterpret_cast<char *>(reinterpret_cast<void *>(&mf));
        return Hash(f, 0);
    }

    template<typename Class, typename... Params>
    unsigned int FuncHash(void (Class::*mf)(Params...)) {
        auto f = reinterpret_cast<char *>(reinterpret_cast<void *>(&mf));
        return Hash(f, 0);
    }

    template<typename Fulltype, typename Class, typename Ret, typename... Params>
    Ret &invoke(Fulltype *self, Ret (Class::*mf)(Params...), Params... args) {

        using action_t = action<Fulltype, std::function<int(Fulltype *, Params...)>>;
        using action_r_t = action<Fulltype, std::function<int(Fulltype *, Ret *, Params...)>>;

        // here we use action_t (without ret) signature for "::before",
        // because before the call process, the ret value is meaningless.
        auto range = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_BEFORE>().equal_range(FuncHash(mf));
        for (auto it = range.first; it != range.second; it++) {
            it->second->execute(self, args...);
        }

        // default dummy action
        std::function<int()> f = []() { return 0; };
        static Ret temp;
        Ret *ret = &temp;

        // Here we must use advice, which is higer order fucntion
        // f = advice(self,f);  in this way we got recursive calls executed;
        auto range_i = proxy<Fulltype, std::multimap<unsigned int, action_r_t *>, SIG_OF_INSITU>().equal_range(FuncHash(mf));
        for (auto it = range_i.first; it != range_i.second; it++) {
            // Until the recursive all ends, we bind the real parameters and ret
            if (nullptr == it->second->advice)
                f = it->second->bind(self, ret, args...);
            else
                f = (it->second->advice)(self, f);
        }
        f();

        // Now we use action_t_r (with ret) signature for "::after",
        // because the ret value is available now.
        auto range_r = proxy<Fulltype, std::multimap<unsigned int, action_r_t *>, SIG_OF_AFTER>().equal_range(FuncHash(mf));
        for (auto it = range_r.first; it != range_r.second; it++) {
            it->second->execute_r(self, ret, args...);
        }

        return *ret;
    }

    // void version.
    template<typename Fulltype, typename Class, typename... Params>
    void invoke(Fulltype *self, void (Class::*mf)(Params...), Params... args) {
        using action_t = action<Fulltype, std::function<int(Fulltype *, Params...)>>;

        auto range = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_BEFORE>().equal_range(FuncHash(mf));
        for (auto it = range.first; it != range.second; it++) {
            // invoke void ::f(args...) execute before
            it->second->execute(self, args...);
        }

        std::function<int()> f = []() { return 0; };

        auto range_i = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_INSITU>().equal_range(FuncHash(mf));
        for (auto it = range_i.first; it != range_i.second; it++) {
            if (nullptr == it->second->advice)
                f = it->second->bind(self, args...);
            else
                f = (it->second->advice)(self, f);
        }
        f();

        auto range_r = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_AFTER>().equal_range(FuncHash(mf));
        for (auto it = range_r.first; it != range_r.second; it++) {
            // invoke void ::f(args...) execute after
            it->second->execute(self, args...);
        }
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// Waven is responsible for preparing the actions & advices, it should be easier to use.

    template<typename Fulltype>
    struct waven {
        template<typename Ret, typename Class, typename... Params>
        static void before(Ret (Class::*func)(Params...), action<Fulltype, std::function<int(Fulltype *, Params...)>> *action0) {
            using action_t = action<Fulltype, std::function<int(Fulltype *, Params...)>>;
            auto &mp = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_BEFORE>();
            // add ret ::f(args...) before
            mp.insert(std::pair<unsigned int, action_t *>(FuncHash(func), action0));
        }

        template<typename Ret, typename Class, typename... Params>
        static void insitu(Ret (Class::*func)(Params...),
                           action<Fulltype, std::function<int(Fulltype *, Ret *, Params...)>> *action0) {
            using action_r_t = action<Fulltype, std::function<int(Fulltype *, Ret *, Params...)>>;
            auto &mp = proxy<Fulltype, std::multimap<unsigned int, action_r_t *>, SIG_OF_INSITU>();
            mp.insert(std::pair<unsigned int, action_r_t *>(HASHFUNC(func), action0));
        }

        template<typename Class, typename... Params>
        static void insitu(void (Class::*func)(Params...), action<Fulltype, std::function<int(Fulltype *, Params...)>> *action0) {
            using action_t = action<Fulltype, std::function<int(Fulltype *, Params...)>>;
            auto &mp = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_INSITU>();
            mp.insert(std::pair<unsigned int, action_t *>(HASHFUNC(func), action0));
        }


        template<typename Ret, typename Class, typename... Params>
        static void after(Ret (Class::*func)(Params...),
                          action<Fulltype, std::function<int(Fulltype *, Ret *, Params...)>> *action0) {
            using action_r_t = action<Fulltype, std::function<int(Fulltype *, Ret *, Params...)>>;
            auto &mp = proxy<Fulltype, std::multimap<unsigned int, action_r_t *>, SIG_OF_AFTER>();
            mp.insert(std::pair<unsigned int, action_r_t *>(HASHFUNC(func), action0));
        }

        template<typename Class, typename... Params>
        static void after(void (Class::*func)(Params...), action<Fulltype, std::function<int(Fulltype *, Params...)>> *action0) {
            using action_t = action<Fulltype, std::function<int(Fulltype *, Params...)>>;
            auto &mp = proxy<Fulltype, std::multimap<unsigned int, action_t *>, SIG_OF_AFTER>();
            mp.insert(std::pair<unsigned int, action_t *>(HASHFUNC(func), action0));
        }
    };


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// Clone & Take

    template<typename T>
    T *self_clone(T *const self) {
        return new T(*self);
    }

    template<typename T>
    T *default_create(T *const self) {
        return new T;
    }

    template<typename T>
    typename std::enable_if<
            !std::is_constructible<T>::value,
            typename std::add_pointer<typename std::decay<T>::type>::type>::type
    clone(T &obj) {
        using rval_t = typename std::decay<T>::type;
        using ptr_t = typename std::add_pointer<rval_t>::type;
        return dynamic_cast<ptr_t>(obj.clone());
    }

    template<typename T>
    typename std::enable_if<
            std::is_constructible<T>::value,
            typename std::add_pointer<typename std::decay<T>::type>::type>::type
    clone(T &obj) {
        using rval_t = typename std::decay<T>::type;
        return new rval_t(obj);
    }

    template<typename T>
    typename std::enable_if<
            !std::is_constructible<T>::value,
            typename std::add_pointer<typename std::decay<T>::type>::type>::type
    take(T &&obj) {
        using rval_t = typename std::decay<T>::type;
        using ptr_t = typename std::add_pointer<rval_t>::type;
        ptr_t temp = dynamic_cast<ptr_t>(obj.create_default());
        swap(*temp, obj);
        return temp;
    }

    template<typename T>
    typename std::enable_if<
            std::is_constructible<T>::value,
            typename std::add_pointer<typename std::decay<T>::type>::type>::type
    take(T &&obj) {
        using rval_t = typename std::decay<T>::type;
        using ptr_t = typename std::add_pointer<rval_t>::type;
        ptr_t temp = new rval_t();
        swap(*temp, obj);
        return temp;
    }

    template<typename T>
    T *clone_by_ptr(T *const pointer) {
        return clone(*pointer);
    }


    template<typename T>
    T *clone_by_ref(T &reference) {
        return clone(reference);
    }

    template<typename T>
    T *take_by_ptr(T *const pointer) {
        return take(std::move(*pointer));
    }

    template<typename T>
    T *take_by_ref(T &reference) {
        return take(std::move(reference));
    }
}

#endif //KS_AOP_HPP
