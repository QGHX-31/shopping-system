import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import request from '@/utils/request'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref<any>(null)
  const memberInfo = ref<any>(null)

  const isLogin = computed(() => !!token.value)

  async function login(loginForm: { username: string; password: string }) {
    const res = await request.post('/user/login', loginForm)
    token.value = res.data.token
    localStorage.setItem('token', token.value)
    await getUserInfo()
    return res
  }

  async function register(registerForm: { username: string; password: string; email?: string; phone?: string }) {
    const res = await request.post('/user/register', registerForm)
    return res
  }

  async function getUserInfo() {
    const res = await request.get('/user/info')
    userInfo.value = res.data
    return res
  }

  async function getMemberInfo() {
    const res = await request.get('/member/info')
    memberInfo.value = res.data
    return res
  }

  async function logout() {
    await request.post('/user/logout')
    token.value = ''
    userInfo.value = null
    memberInfo.value = null
    localStorage.removeItem('token')
  }

  return {
    token,
    userInfo,
    memberInfo,
    isLogin,
    login,
    register,
    getUserInfo,
    getMemberInfo,
    logout
  }
})