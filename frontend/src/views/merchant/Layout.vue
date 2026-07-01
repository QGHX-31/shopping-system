<template>
  <div class="merchant-layout">
    <aside class="sidebar">
      <div class="logo">
        <span class="logo-icon">{{ merchantStore.merchantInfo?.isAdmin ? '🛡️' : '🏪' }}</span>
        <span class="logo-text">{{ merchantStore.merchantInfo?.isAdmin ? '平台运营' : '商家后台' }}</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        background-color="#1f2d3d"
        text-color="#bfcbd9"
        active-text-color="#409eff"
        router
      >
        <el-menu-item index="/merchant/dashboard">
          <el-icon><DataLine /></el-icon>
          <span>数据看板</span>
        </el-menu-item>
        <el-menu-item index="/merchant/product">
          <el-icon><Goods /></el-icon>
          <span>商品管理</span>
        </el-menu-item>
        <el-menu-item index="/merchant/sku">
          <el-icon><Box /></el-icon>
          <span>SKU库存</span>
        </el-menu-item>
        <el-menu-item index="/merchant/order">
          <el-icon><Ticket /></el-icon>
          <span>订单管理</span>
        </el-menu-item>
        <el-menu-item index="/merchant/refund">
          <el-icon><Reading /></el-icon>
          <span>退款管理</span>
        </el-menu-item>
        <el-menu-item index="/merchant/exchange">
          <el-icon><RefreshLeft /></el-icon>
          <span>换货管理</span>
        </el-menu-item>
        <el-sub-menu index="marketing">
          <template #title>
            <el-icon><Promotion /></el-icon>
            <span>营销活动</span>
          </template>
          <el-menu-item index="/merchant/marketing/seckill">秒杀活动</el-menu-item>
          <el-menu-item index="/merchant/marketing/group">拼团活动</el-menu-item>
          <el-menu-item index="/merchant/marketing/coupon">优惠券</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </aside>
    <div class="main">
      <header class="header">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>{{ merchantStore.merchantInfo?.isAdmin ? '平台运营中心' : '商家后台' }}</el-breadcrumb-item>
            <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="user-area">
          <el-dropdown @command="handleCommand">
            <span class="user-name">
              <el-icon><User /></el-icon>
              {{ merchantStore.merchantInfo?.shopName || '商家' }}
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <div class="content">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { DataLine, Goods, Box, Promotion, User, Ticket, Reading, RefreshLeft } from '@element-plus/icons-vue'
import { useMerchantStore } from '@/stores/merchant'

const route = useRoute()
const router = useRouter()
const merchantStore = useMerchantStore()

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => (route.meta?.title as string) || '首页')

async function handleCommand(cmd: string) {
  if (cmd === 'logout') {
    await merchantStore.logout()
    ElMessage.success('已退出登录')
    router.push('/login')
  }
}
</script>

<style lang="scss" scoped>
.merchant-layout {
  display: flex;
  min-height: 100vh;
}

.sidebar {
  width: 220px;
  background: #1f2d3d;
  color: #fff;
  display: flex;
  flex-direction: column;

  .logo {
    height: 60px;
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 0 20px;
    border-bottom: 1px solid #2d3e54;

    .logo-icon { font-size: 24px; }
    .logo-text { font-size: 18px; font-weight: bold; color: #fff; }
  }

  .el-menu {
    border-right: none;
  }
}

.main {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #f0f2f5;
}

.header {
  height: 60px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);

  .user-name {
    display: flex;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    color: #333;
  }
}

.content {
  flex: 1;
  padding: 20px;
  overflow: auto;
}
</style>
