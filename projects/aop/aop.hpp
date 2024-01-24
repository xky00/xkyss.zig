//
// Created by dev88 on 2024/1/24.
//

#ifndef AOP_AOP_HPP
#define AOP_AOP_HPP

namespace ks_aop {

    //////////////////////////////////////////////////////////////////////////////////////////////////////
    /// aopfy

    // 前置声明
    template <typename AopBase, template <typename> class... Aspects>
    struct aopfy;

    // parameter base wrap.
    template <typename Base, template <typename> class... Aspects>
    struct aopbase {
        using reference_t = aopfy<aopbase, Aspects...>;
        using base_t = Base;
    };

    // iteration template definition.
    template <typename AopBase, template <typename> class FirstAspects, template <typename> class... RestAspects>
    struct aopfy<AopBase, FirstAspects, RestAspects...> {
        using fulltype_t = FirstAspects<typename aopfy<AopBase, RestAspects...>::fulltype_t>;
        using this_t = typename AopBase::base_t;
    };

    // end of iteration template definition.
    template <typename AopBase>
    struct aopfy<AopBase> {
        using fulltype_t = typename AopBase::reference_t;
        using this_t = typename AopBase::base_t;
    };


    //////////////////////////////////////////////////////////////////////////////////////////////////////
    ///
    // Struct Decorate makes it easy to use.
    template <typename Base>
    struct Decorate {

        // keep the reference during iteration.
        template <template <typename> class... Aspects>
        struct remember {
            using reference_t = aopfy<aopbase<Base, Aspects...>, Aspects...>;
        };

        // 前置声明
        template <typename Remember, template <typename> class... Aspects>
        struct with_imp;

        template <template <typename> class... Aspects>
        struct with {
            using type = typename with_imp<remember<Aspects...>, Aspects...>::combined_t;
        };

        template <typename Remember, template <typename> class FirstAspect, template <typename> class... RestAspects>
        struct with_imp<Remember, FirstAspect, RestAspects...> {
            using combined_t = FirstAspect<typename with_imp<Remember, RestAspects...>::combined_t>;
        };

        template <typename Remember, template <typename> class LastAspect>
        struct with_imp<Remember, LastAspect> {
            using combined_t = LastAspect<typename Remember::reference_t>;
        };
    };

}

#endif //AOP_AOP_HPP
