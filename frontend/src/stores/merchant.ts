import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import request from '@/utils/request'

export const useMerchantStore = defineStore('merchant', () => {
  const token = ref(localStorage.getItem('merchant_token') || '')
  const merchantInfo = ref<any>(null)

  const savedMerchant = localStorage.getItem('merchant_info')
  if (savedMerchant) {
    try {
      merchantInfo.value = JSON.parse(savedMerchant)
    } catch (e) {
      console.error('解析商家信息失败', e)
    }
  }

  const isLogin = computed(() => !!token.value)

  async function login(loginForm: { username: string; password: string }) {
    const res = await request.post('/merchant/login', loginForm)
    token.value = res.data.token
    merchantInfo.value = res.data.merchant
    localStorage.setItem('merchant_token', token.value)
    localStorage.setItem('merchant_id', String(res.data.merchant.id))
    localStorage.setItem('merchant_info', JSON.stringify(res.data.merchant))
    return res
  }

  async function register(registerForm: {
    username: string
    password: string
    shopName: string
    contactName: string
    contactPhone: string
    email?: string
  }) {
    const res = await request.post('/merchant/register', registerForm)
    return res
  }

  async function logout() {
    await request.post('/merchant/logout')
    token.value = ''
    merchantInfo.value = null
    localStorage.removeItem('merchant_token')
    localStorage.removeItem('merchant_id')
  }

  return {
    token,
    merchantInfo,
    isLogin,
    login,
    register,
    logout
  }
})
