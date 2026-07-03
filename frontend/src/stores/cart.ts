import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import request from '@/utils/request'
import { useProductStore } from './product'

export interface CartItem {
  id: number
  productId: number
  skuId?: number
  productName: string
  productImage: string
  price: number
  quantity: number
  selected: boolean
  categoryId: number
  merchantId: number
}

export const useCartStore = defineStore('cart', () => {
  const cartItems = ref<CartItem[]>([])

  const totalPrice = computed(() => {
    return cartItems.value
      .filter(item => item.selected)
      .reduce((sum, item) => sum + item.price * item.quantity, 0)
  })

  const totalCount = computed(() => {
    return cartItems.value.reduce((sum, item) => sum + item.quantity, 0)
  })

  const selectedCount = computed(() => {
    return cartItems.value.filter(item => item.selected).reduce((sum, item) => sum + item.quantity, 0)
  })

  async function getCartList() {
    const res = await request.get('/cart/list')
    const list = res.data || []
    // 后端Cart实体只包含基础字段，需要从product服务补全商品信息
    const productStore = useProductStore()
    cartItems.value = await Promise.all(list.map(async (item: any) => {
      let productInfo: any = { name: '', imageUrl: '', price: 0 }
      try {
        const detail = await productStore.getProductDetail(item.productId)
        productInfo = detail.data || productInfo
      } catch (e) {
        console.warn(`获取商品 ${item.productId} 信息失败:`, e)
      }
      return {
        id: item.id,
        productId: item.productId,
        skuId: item.skuId,
        productName: productInfo.name || `商品${item.productId}`,
        productImage: productInfo.imageUrl || '',
        price: productInfo.originalPrice != null ? productInfo.originalPrice : productInfo.price || 0,
        quantity: item.quantity,
        selected: item.selected === 1 || item.selected === true,
        categoryId: productInfo.categoryId || 0,
        merchantId: productInfo.merchantId || 0
      }
    }))
    return res
  }

  async function addToCart(productId: number, skuId: number | undefined, quantity: number = 1) {
    const body: any = { productId, quantity }
    if (skuId != null) {
      body.skuId = skuId
    }
    const res = await request.post('/cart/add', body)
    await getCartList()
    return res
  }

  async function updateCartItem(cartId: number, quantity: number) {
    const res = await request.put(`/cart/update/${cartId}`, { quantity })
    await getCartList()
    return res
  }

  async function deleteCartItem(cartId: number) {
    const res = await request.delete(`/cart/delete/${cartId}`)
    await getCartList()
    return res
  }

  async function batchDeleteCartItems(cartIds: number[]) {
    const res = await request.post('/cart/batch-delete', { cartIds })
    await getCartList()
    return res
  }

  async function toggleSelect(cartId: number) {
    const item = cartItems.value.find(i => i.id === cartId)
    if (item) {
      const res = await request.post(`/cart/select/${cartId}`, { selected: !item.selected })
      await getCartList()
      return res
    }
    return null
  }

  async function toggleSelectAll(selected: boolean) {
    const res = await request.post('/cart/select/all', { selected })
    await getCartList()
    return res
  }

  return {
    cartItems,
    totalPrice,
    totalCount,
    selectedCount,
    getCartList,
    addToCart,
    updateCartItem,
    deleteCartItem,
    batchDeleteCartItems,
    toggleSelect,
    toggleSelectAll
  }
})