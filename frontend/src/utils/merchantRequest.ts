import request from '@/utils/request'

const MERCHANT_TOKEN_KEY = 'merchant_token'
const MERCHANT_ID_KEY = 'merchant_id'

export const merchantRequest = {
  get<T = any>(url: string, config?: any): Promise<T> {
    const token = localStorage.getItem(MERCHANT_TOKEN_KEY)
    return request.get(url, {
      ...config,
      headers: { ...(config?.headers || {}), Authorization: token ? `Bearer ${token}` : '' }
    })
  },
  post<T = any>(url: string, data?: any, config?: any): Promise<T> {
    const token = localStorage.getItem(MERCHANT_TOKEN_KEY)
    return request.post(url, data, {
      ...config,
      headers: { ...(config?.headers || {}), Authorization: token ? `Bearer ${token}` : '' }
    })
  },
  put<T = any>(url: string, data?: any, config?: any): Promise<T> {
    const token = localStorage.getItem(MERCHANT_TOKEN_KEY)
    return request.put(url, data, {
      ...config,
      headers: { ...(config?.headers || {}), Authorization: token ? `Bearer ${token}` : '' }
    })
  },
  delete<T = any>(url: string, config?: any): Promise<T> {
    const token = localStorage.getItem(MERCHANT_TOKEN_KEY)
    return request.delete(url, {
      ...config,
      headers: { ...(config?.headers || {}), Authorization: token ? `Bearer ${token}` : '' }
    })
  }
}

export function getMerchantId(): number {
  return Number(localStorage.getItem(MERCHANT_ID_KEY) || 0)
}
