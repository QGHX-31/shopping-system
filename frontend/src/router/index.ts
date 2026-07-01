import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'home',
    component: () => import('@/views/Home.vue')
  },
  {
    path: '/product/:id',
    name: 'product-detail',
    component: () => import('@/views/ProductDetail.vue')
  },
  {
    path: '/category/:id',
    name: 'category',
    component: () => import('@/views/Category.vue')
  },
  {
    path: '/search',
    name: 'search',
    component: () => import('@/views/Search.vue')
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('@/views/Register.vue')
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/member',
    name: 'member',
    component: () => import('@/views/Member.vue')
  },
  {
    path: '/cart',
    name: 'cart',
    component: () => import('@/views/Cart.vue')
  },
  {
    path: '/favorite',
    name: 'favorite',
    component: () => import('@/views/Favorite.vue')
  },
  {
    path: '/checkout',
    name: 'checkout',
    component: () => import('@/views/Checkout.vue')
  },
  {
    path: '/seckill',
    name: 'seckill',
    component: () => import('@/views/Seckill.vue')
  },
  {
    path: '/group',
    name: 'group',
    component: () => import('@/views/GroupBuy.vue')
  },
  {
    path: '/group/create',
    name: 'group-create',
    component: () => import('@/views/GroupCreate.vue')
  },
  {
    path: '/coupon',
    name: 'coupon',
    component: () => import('@/views/Coupon.vue')
  },
  {
    path: '/order/pay',
    name: 'order-pay',
    component: () => import('@/views/Pay.vue')
  },
  {
    path: '/shop/:id',
    name: 'shop-detail',
    component: () => import('@/views/ShopDetail.vue')
  },
  {
    path: '/shops',
    name: 'shop-list',
    component: () => import('@/views/ShopList.vue')
  },
  // ========== 商家后台 ==========
  {
    path: '/merchant/login',
    name: 'merchant-login',
    component: () => import('@/views/merchant/Login.vue')
  },
  {
    path: '/merchant',
    component: () => import('@/views/merchant/Layout.vue'),
    redirect: '/merchant/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'merchant-dashboard',
        component: () => import('@/views/merchant/Dashboard.vue'),
        meta: { title: '数据看板' }
      },
      {
        path: 'product',
        name: 'merchant-product',
        component: () => import('@/views/merchant/ProductList.vue'),
        meta: { title: '商品管理' }
      },
      {
        path: 'sku',
        name: 'merchant-sku',
        component: () => import('@/views/merchant/SkuList.vue'),
        meta: { title: 'SKU库存' }
      },
      {
        path: 'order',
        name: 'merchant-order',
        component: () => import('@/views/merchant/OrderList.vue'),
        meta: { title: '订单管理' }
      },
      {
        path: 'refund',
        name: 'merchant-refund',
        component: () => import('@/views/merchant/RefundList.vue'),
        meta: { title: '退款管理' }
      },
      {
        path: 'exchange',
        name: 'merchant-exchange',
        component: () => import('@/views/merchant/ExchangeList.vue'),
        meta: { title: '换货管理' }
      },
      {
        path: 'marketing/seckill',
        name: 'merchant-seckill',
        component: () => import('@/views/merchant/SeckillList.vue'),
        meta: { title: '秒杀活动' }
      },
      {
        path: 'marketing/group',
        name: 'merchant-group',
        component: () => import('@/views/merchant/GroupBuyList.vue'),
        meta: { title: '拼团活动' }
      },
      {
        path: 'marketing/coupon',
        name: 'merchant-coupon',
        component: () => import('@/views/merchant/CouponList.vue'),
        meta: { title: '优惠券管理' }
      }
    ]
  },
  // ========== 平台运营后台 ==========
  {
    path: '/admin/login',
    name: 'admin-login',
    component: () => import('@/views/admin/Login.vue')
  },
  {
    path: '/admin',
    component: () => import('@/views/admin/Layout.vue'),
    redirect: '/admin/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'admin-dashboard',
        component: () => import('@/views/admin/Dashboard.vue'),
        meta: { title: '数据大盘' }
      },
      {
        path: 'order/list',
        name: 'admin-order-list',
        component: () => import('@/views/admin/OrderList.vue'),
        meta: { title: '订单管理' }
      },
      {
        path: 'refund/list',
        name: 'admin-refund-list',
        component: () => import('@/views/admin/RefundList.vue'),
        meta: { title: '退款管理' }
      },
      {
        path: 'exchange/list',
        name: 'admin-exchange-list',
        component: () => import('@/views/admin/ExchangeList.vue'),
        meta: { title: '换货管理' }
      },
      {
        path: 'product/list',
        name: 'admin-product-list',
        component: () => import('@/views/admin/ProductList.vue'),
        meta: { title: '商品列表' }
      },
      {
        path: 'category/list',
        name: 'admin-category-list',
        component: () => import('@/views/admin/CategoryList.vue'),
        meta: { title: '商品分类' }
      },
      {
        path: 'merchant/list',
        name: 'admin-merchant-list',
        component: () => import('@/views/admin/MerchantList.vue'),
        meta: { title: '商家管理' }
      },
      {
        path: 'coupon/list',
        name: 'admin-coupon-list',
        component: () => import('@/views/admin/CouponList.vue'),
        meta: { title: '优惠券模板' }
      },
      {
        path: 'activity/list',
        name: 'admin-activity-list',
        component: () => import('@/views/admin/ActivityList.vue'),
        meta: { title: '活动配置' }
      },
      {
        path: 'user/list',
        name: 'admin-user-list',
        component: () => import('@/views/admin/UserList.vue'),
        meta: { title: '用户管理' }
      },
      {
        path: 'admin/list',
        name: 'admin-admin-list',
        component: () => import('@/views/admin/AdminList.vue'),
        meta: { title: '管理员' }
      },
      {
        path: 'role/list',
        name: 'admin-role-list',
        component: () => import('@/views/admin/RoleList.vue'),
        meta: { title: '角色管理' }
      },
      {
        path: 'permission/list',
        name: 'admin-permission-list',
        component: () => import('@/views/admin/PermissionList.vue'),
        meta: { title: '权限管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
