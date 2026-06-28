import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse } from 'axios'

const service: AxiosInstance = axios.create({
  baseURL: '/api',
  timeout: 10000
})

service.interceptors.request.use(
  (config: AxiosRequestConfig) => {
    const isMerchantApi = config.url?.startsWith('/merchant') || config.url?.startsWith('/sku')
    const isAdminApi = config.url?.startsWith('/admin')
    const token = isMerchantApi
      ? localStorage.getItem('merchant_token')
      : isAdminApi
      ? localStorage.getItem('admin_token')
      : localStorage.getItem('token')
    if (token) {
      config.headers = config.headers || {}
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

service.interceptors.response.use(
  (response: AxiosResponse) => {
    const res = response.data
    if (res.code !== 200) {
      return Promise.reject(new Error(res.message || 'Error'))
    }
    return res
  },
  (error) => {
    return Promise.reject(error)
  }
)

export default service