<template>
  <header class="header">
    <!-- 顶部条 -->
    <div class="header-top">
      <div class="container">
        <div class="header-top-left">
          <span>欢迎来到购物商城</span>
          <el-button v-if="!userStore.isLogin" type="text" class="login-link" @click="goLogin">请登录</el-button>
          <el-button v-if="!userStore.isLogin" type="text" class="register-link" @click="goRegister">免费注册</el-button>
        </div>
        <ul class="header-top-right">
          <li v-if="userStore.isLogin" class="user-item">
            <el-dropdown>
              <span class="user-info">
                <el-avatar :size="20" :src="userStore.userInfo?.avatar" />
                <span>{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</span>
                <el-icon><ArrowDown /></el-icon>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="goMember">个人中心</el-dropdown-item>
                  <el-dropdown-item @click="goFavorite">我的收藏</el-dropdown-item>
                  <el-dropdown-item @click="goCoupon">我的优惠券</el-dropdown-item>
                  <el-dropdown-item divided @click="handleLogout">退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </li>
          <li><router-link to="/member?tab=orders" class="top-link">我的订单</router-link></li>
          <li><router-link to="/cart" class="top-link"><el-icon><ShoppingCart /></el-icon> 购物车 <el-tag v-if="cartStore.totalCount > 0" type="danger" size="small" round>{{ cartStore.totalCount }}</el-tag></router-link></li>
          <li><router-link to="/favorite" class="top-link">收藏夹</router-link></li>
          <li class="divider">|</li>
          <li><router-link to="/coupon" class="top-link">领券中心</router-link></li>
          <li><router-link to="/seckill" class="top-link">限时秒杀</router-link></li>
          <li><router-link to="/group" class="top-link">拼团活动</router-link></li>
        </ul>
      </div>
    </div>

    <!-- 主体：Logo + 搜索 + 大导航 -->
    <div class="header-main">
      <div class="container">
        <div class="logo-area" @click="goHome">
          <div class="logo-icon"><el-icon :size="36"><ShoppingCart /></el-icon></div>
          <div class="logo-text">
            <h1>购物商城</h1>
            <span class="slogan">品质优选 · 实惠购物</span>
          </div>
        </div>

        <div class="search-area">
          <div class="search-tabs">
            <span :class="{ active: searchTab === 'product' }" @click="switchSearchTab('product')">商品</span>
            <span :class="{ active: searchTab === 'shop' }" @click="switchSearchTab('shop')">店铺</span>
          </div>
          <div class="search-box">
            <el-input
              v-model="searchKeyword"
              placeholder="搜索商品 店铺"
              size="large"
              @keyup.enter="handleSearch"
            >
              <template #append>
                <el-button @click="handleSearch"><el-icon><Search /></el-icon>搜索</el-button>
              </template>
            </el-input>
          </div>
          <div class="hot-keywords">
            <span class="label">热搜：</span>
            <a v-for="(kw, i) in hotKeywords" :key="i" @click="quickSearch(kw)">{{ kw }}</a>
          </div>
        </div>

        <div class="cart-area" @click="goCart">
          <el-icon :size="22"><ShoppingCart /></el-icon>
          <span>我的购物车</span>
          <em v-if="cartStore.totalCount > 0">{{ cartStore.totalCount }}</em>
        </div>
      </div>
    </div>

    <!-- 主导航条 -->
    <nav class="nav-bar">
      <div class="container">
        <ul class="nav-list">
          <li>
            <router-link to="/" class="nav-link home">
              <el-icon><HomeFilled /></el-icon> 首页
            </router-link>
          </li>
          <li><router-link to="/seckill" class="nav-link"><el-icon><AlarmClock /></el-icon> 限时秒杀</router-link></li>
          <li><router-link to="/coupon" class="nav-link"><el-icon><Ticket /></el-icon> 领券中心</router-link></li>
          <li><router-link to="/group" class="nav-link"><el-icon><UserFilled /></el-icon> 拼团活动</router-link></li>
          <li><router-link to="/shops" class="nav-link"><el-icon><Shop /></el-icon> 店铺列表</router-link></li>
          <li><router-link :to="{ path: '/search', query: { sort: 'hot' } }" class="nav-link" active-class="" :class="{ active: activeNav === 'hot' }">热卖商品</router-link></li>
          <li><router-link :to="{ path: '/search', query: { sort: 'new' } }" class="nav-link" active-class="" :class="{ active: activeNav === 'new' }">新品上市</router-link></li>
          <li class="spacer"></li>
          <li class="nav-extra">
            <el-icon><ChatLineRound /></el-icon> 客服
          </li>
        </ul>
      </div>
    </nav>
  </header>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import {
  Search, ShoppingCart, ArrowDown, HomeFilled, Shop,
  AlarmClock, Ticket, UserFilled, ChatLineRound
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const cartStore = useCartStore()

const searchKeyword = ref('')
const searchTab = computed<'product' | 'shop'>(() => {
  if (route.path.startsWith('/shops') || route.path.startsWith('/shop/')) return 'shop'
  return 'product'
})
const hotKeywords = ref(['iPhone 16', '运动鞋', '连衣裙', '家电', '零食大礼包', '美妆', '笔记本电脑', '童装'])

const activeNav = computed(() => {
  const path = route.path
  const sort = route.query.sort
  if (path === '/search' && sort === 'hot') return 'hot'
  if (path === '/search' && sort === 'new') return 'new'
  return ''
})

function goHome() { router.push('/') }
function goLogin() { router.push('/login') }
function goRegister() { router.push('/register') }
function goMember() { router.push('/member') }
function goFavorite() { router.push('/favorite') }
function goCoupon() { router.push('/coupon') }
function goCart() { router.push('/cart') }

function switchSearchTab(tab: 'product' | 'shop') {
  if (tab === 'shop') {
    router.push('/shops')
  } else {
    router.push('/')
  }
}

function handleSearch() {
  const kw = searchKeyword.value.trim()
  if (searchTab.value === 'shop') {
    router.push({ path: '/shops', query: { keyword: kw || undefined } })
  } else {
    if (kw) router.push({ path: '/search', query: { keyword: kw } })
  }
}
function quickSearch(kw: string) {
  searchKeyword.value = kw
  handleSearch()
}

async function handleLogout() {
  await userStore.logout()
  goHome()
}

onMounted(async () => {
  if (userStore.isLogin) {
    await userStore.getUserInfo()
    await cartStore.getCartList()
  }
})
</script>

<style lang="scss" scoped>
.header {
  background: #fff;
  border-bottom: 1px solid #f0f0f0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* ========== 顶部条 ========== */
.header-top {
  background: #f5f5f5;
  font-size: 12px;
  color: #666;
  border-bottom: 1px solid #eee;
}
.header-top > .container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 32px;
}
.header-top-left {
  display: flex;
  align-items: center;
  gap: 8px;
  .login-link, .register-link {
    color: #ff4400;
    font-size: 12px;
  }
}
.header-top-right {
  display: flex;
  align-items: center;
  list-style: none;
  margin: 0;
  padding: 0;
  li {
    position: relative;
    .top-link {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 0 12px;
      color: #666;
      text-decoration: none;
      line-height: 32px;
      &:hover { color: #ff4400; }
      &.router-link-active { color: #ff4400; font-weight: 600; }
    }
  }
  .divider {
    color: #ddd;
    padding: 0 4px;
  }
}
.user-info {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  padding: 0 12px;
  line-height: 32px;
  color: #ff4400;
  &:hover { color: #ff6600; }
}

/* ========== 主体 ========== */
.header-main {
  background: #fff;
  padding: 24px 0 16px;
}
.header-main > .container {
  display: flex;
  align-items: center;
  gap: 40px;
}

.logo-area {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  user-select: none;
  .logo-icon {
    width: 56px;
    height: 56px;
    background: linear-gradient(135deg, #ff5000, #ff8a00);
    color: #fff;
    font-size: 36px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 12px;
    font-family: 'STKaiti', 'KaiTi', serif;
  }
  .logo-text h1 {
    margin: 0;
    font-size: 26px;
    color: #ff4400;
    font-weight: bold;
  }
  .slogan {
    font-size: 12px;
    color: #999;
    letter-spacing: 1px;
  }
}

.search-area {
  flex: 1;
  .search-tabs {
    display: flex;
    gap: 18px;
    margin-bottom: 8px;
    span {
      font-size: 14px;
      color: #ff4400;
      cursor: pointer;
      padding: 4px 6px;
      border-bottom: 2px solid transparent;
      &.active { border-bottom-color: #ff4400; font-weight: 600; }
      &:not(.active) { color: #666; }
    }
  }
  :deep(.el-input-group__append) {
    background: #ff4400;
    color: #fff;
    .el-button {
      color: #fff;
      background: transparent;
      border: none;
      font-weight: 600;
      &:hover { background: rgba(255, 255, 255, 0.1); }
    }
  }
  .hot-keywords {
    margin-top: 8px;
    font-size: 12px;
    color: #999;
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
    .label { color: #999; }
    a {
      color: #666;
      cursor: pointer;
      &:hover { color: #ff4400; }
    }
  }
}

.cart-area {
  position: relative;
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 24px;
  background: #fff;
  border: 2px solid #ff4400;
  border-radius: 6px;
  color: #ff4400;
  font-size: 14px;
  cursor: pointer;
  em {
    position: absolute;
    top: -8px;
    right: -8px;
    background: #ff4400;
    color: #fff;
    border-radius: 50%;
    padding: 0 6px;
    min-width: 20px;
    height: 20px;
    line-height: 20px;
    font-size: 12px;
    font-style: normal;
    text-align: center;
  }
}

/* ========== 主导航 ========== */
.nav-bar {
  background: #fff;
  border-top: 1px solid #f0f0f0;
  border-bottom: 1px solid #f0f0f0;
}
.nav-bar > .container {
  display: flex;
  align-items: center;
  height: 40px;
}
.nav-list {
  display: flex;
  align-items: center;
  list-style: none;
  margin: 0;
  padding: 0;
  flex: 1;
  li {
    margin: 0 14px;
  }
  .spacer { flex: 1; }
  .nav-extra {
    color: #999;
    font-size: 13px;
    display: flex;
    align-items: center;
    gap: 4px;
    cursor: pointer;
    &:hover { color: #ff4400; }
  }
}
.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 10px 6px;
  color: #333;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  border-bottom: 2px solid transparent;
  transition: color 0.2s;
  &:hover { color: #ff4400; }
  &.router-link-active,
  &.active {
    color: #ff4400;
    border-bottom-color: #ff4400;
  }
  &.home {
    color: #ff4400;
    font-weight: bold;
  }
}
</style>
