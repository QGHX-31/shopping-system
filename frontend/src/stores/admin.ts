import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import request from '@/utils/request'

export const useAdminStore = defineStore('admin', () => {
  const token = ref(localStorage.getItem('admin_token') || '')
  const adminInfo = ref<any>(null)
  const menus = ref<any[]>([])
  const permissions = ref<string[]>([])

  const savedAdmin = localStorage.getItem('admin_info')
  if (savedAdmin) {
    try {
      adminInfo.value = JSON.parse(savedAdmin)
    } catch (e) {
      console.error('解析管理员信息失败', e)
    }
  }

  const savedMenus = localStorage.getItem('admin_menus')
  if (savedMenus) {
    try {
      menus.value = JSON.parse(savedMenus)
    } catch (e) {
      console.error('解析菜单失败', e)
    }
  }

  const isLogin = computed(() => !!token.value)

  async function login(username: string, password: string) {
    const res = await request.post('/admin/login', { username, password })
    token.value = res.data.token || 'admin-token-' + Date.now()
    adminInfo.value = res.data.admin || { id: res.data.adminId || 1, username, realName: '超级管理员', isSuper: 1 }
    localStorage.setItem('admin_token', token.value)
    localStorage.setItem('admin_info', JSON.stringify(adminInfo.value))

    try {
      const menuRes = await request.get('/admin/menus', { params: { adminId: adminInfo.value.id } })
      menus.value = menuRes.data || []
      localStorage.setItem('admin_menus', JSON.stringify(menus.value))
    } catch (e) {
      console.warn('加载菜单失败，使用默认菜单', e)
    }

    try {
      const permRes = await request.get('/admin/permissions', { params: { adminId: adminInfo.value.id } })
      permissions.value = permRes.data || []
    } catch (e) {
      console.warn('加载权限失败', e)
    }

    return res
  }

  async function logout() {
    token.value = ''
    adminInfo.value = null
    menus.value = []
    permissions.value = []
    localStorage.removeItem('admin_token')
    localStorage.removeItem('admin_info')
    localStorage.removeItem('admin_menus')
  }

  function hasPermission(code: string) {
    if (adminInfo.value?.isSuper === 1) return true
    return permissions.value.includes(code)
  }

  return {
    token,
    adminInfo,
    menus,
    permissions,
    isLogin,
    login,
    logout,
    hasPermission
  }
})
