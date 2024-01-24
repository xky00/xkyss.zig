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

}

#endif //AOP_AOP_HPP
