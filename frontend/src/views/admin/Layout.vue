<template>
  <div class="admin-layout">
    <aside class="sidebar">
      <div class="logo">
        <span class="logo-icon">🛒</span>
        <span class="logo-text">运营后台</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        background-color="#1f2d3d"
        text-color="#bfcbd9"
        active-text-color="#409eff"
        router
      >
        <template v-for="menu in menuList" :key="menu.id || menu.path">
          <el-sub-menu v-if="menu.children && menu.children.length > 0" :index="menu.name || menu.path">
            <template #title>
              <el-icon><component :is="menu.icon" /></el-icon>
              <span>{{ menu.title }}</span>
            </template>
            <el-menu-item
              v-for="child in menu.children"
              :key="child.id || child.path"
              :index="child.path"
            >
              {{ child.title }}
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="menu.path">
            <el-icon><component :is="menu.icon" /></el-icon>
            <span>{{ menu.title }}</span>
          </el-menu-item>
        </template>
      </el-menu>
    </aside>
    <div class="main">
      <header class="header">
        <div class="breadcrumb">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>运营后台</el-breadcrumb-item>
            <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-tooltip content="回到前台" placement="bottom">
            <el-icon class="header-icon" @click="goFront"><House /></el-icon>
          </el-tooltip>
          <el-dropdown @command="handleCommand">
            <span class="user-name">
              <el-avatar :size="28" style="background: #409eff;">
                {{ adminStore.adminInfo?.realName?.charAt(0) || adminStore.adminInfo?.username?.charAt(0) || 'A' }}
              </el-avatar>
              <span class="username-text">{{ adminStore.adminInfo?.realName || adminStore.adminInfo?.username || '管理员' }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
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
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  DataAnalysis, Tickets, Goods, Promotion, User, Setting, House
} from '@element-plus/icons-vue'
import { useAdminStore } from '@/stores/admin'

const route = useRoute()
const router = useRouter()
const adminStore = useAdminStore()

const iconMap: Record<string, any> = {
  DataAnalysis,
  Tickets,
  Goods,
  Promotion,
  User,
  Setting,
  House
}

const defaultMenus = [
  { id: 1, title: '数据大盘', path: '/admin/dashboard', icon: 'DataAnalysis' },
  {
    id: 2, title: '订单管理', name: 'order', icon: 'Tickets',
    children: [
      { id: 21, title: '全部订单', path: '/admin/order/list' },
      { id: 22, title: '退款管理', path: '/admin/refund/list' }
    ]
  },
  {
    id: 3, title: '商品管理', name: 'product', icon: 'Goods',
    children: [
      { id: 31, title: '商品列表', path: '/admin/product/list' },
      { id: 32, title: '商品分类', path: '/admin/category/list' },
      { id: 33, title: '商家管理', path: '/admin/merchant/list' }
    ]
  },
  {
    id: 4, title: '营销管理', name: 'marketing', icon: 'Promotion',
    children: [
      { id: 41, title: '优惠券模板', path: '/admin/coupon/list' },
      { id: 42, title: '活动配置', path: '/admin/activity/list' }
    ]
  },
  { id: 5, title: '用户管理', path: '/admin/user/list', icon: 'User' },
  {
    id: 6, title: '系统管理', name: 'system', icon: 'Setting',
    children: [
      { id: 61, title: '管理员', path: '/admin/admin/list' },
      { id: 62, title: '角色管理', path: '/admin/role/list' },
      { id: 63, title: '权限管理', path: '/admin/permission/list' }
    ]
  }
]

const menuList = computed(() => {
  if (adminStore.adminInfo?.isSuper === 1) {
    return defaultMenus
  }
  const backendMenus = adminStore.menus || []
  if (backendMenus.length > 0) {
    return buildMenus(backendMenus)
  }
  return defaultMenus
})

function buildMenus(list: any[]): any[] {
  return list.map(item => {
    const menu: any = {
      id: item.id,
      title: item.title || item.name,
      path: item.path,
      name: item.name,
      icon: item.icon || 'Setting'
    }
    if (item.children && item.children.length > 0) {
      menu.children = buildMenus(item.children)
    }
    return menu
  })
}

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => (route.meta?.title as string) || '首页')

function goFront() {
  router.push('/')
}

async function handleCommand(cmd: string) {
  if (cmd === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      await adminStore.logout()
      ElMessage.success('已退出登录')
      router.push('/admin/login')
    } catch {
    }
  } else if (cmd === 'profile') {
    ElMessage.info('个人信息功能开发中')
  }
}

onMounted(() => {
  if (!adminStore.isLogin) {
    router.push('/admin/login')
  }
})
</script>

<style lang="scss" scoped>
.admin-layout {
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
    flex: 1;
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

  .header-right {
    display: flex;
    align-items: center;
    gap: 20px;
  }

  .header-icon {
    font-size: 20px;
    color: #666;
    cursor: pointer;
    transition: color 0.2s;

    &:hover { color: #409eff; }
  }

  .user-name {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    color: #333;
  }

  .username-text {
    font-size: 14px;
  }
}

.content {
  flex: 1;
  padding: 20px;
  overflow: auto;
}
</style>
