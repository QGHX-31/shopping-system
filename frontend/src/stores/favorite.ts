import { defineStore } from 'pinia'
import { ref } from 'vue'
import request from '@/utils/request'

export interface FavoriteItem {
  id: number
  productId: number
  productName: string
  productImage: string
  price: number
  createdAt: string
}

export const useFavoriteStore = defineStore('favorite', () => {
  const favorites = ref<FavoriteItem[]>([])

  async function getFavoriteList() {
    const res = await request.get('/favorite/list')
    const list: any[] = res.data || []
    const enriched: FavoriteItem[] = []
    for (const item of list) {
      try {
        const productRes = await request.get(`/product/${item.productId}`)
        const product = productRes.data
        if (product) {
          enriched.push({
            id: item.id,
            productId: item.productId,
            productName: product.name,
            productImage: product.imageUrl,
            price: product.price,
            createdAt: item.createdAt
          })
        }
      } catch (e) {
        // 忽略查询失败的商品
      }
    }
    favorites.value = enriched
    return res
  }

  async function addFavorite(productId: number) {
    const res = await request.post('/favorite/add', { productId })
    await getFavoriteList()
    return res
  }

  async function removeFavorite(favoriteId: number) {
    const res = await request.delete(`/favorite/delete/${favoriteId}`)
    await getFavoriteList()
    return res
  }

  async function isFavorite(productId: number) {
    const res = await request.get(`/favorite/check`, { params: { productId } })
    return res.data?.isFavorite || res.data === true
  }

  return {
    favorites,
    getFavoriteList,
    addFavorite,
    removeFavorite,
    isFavorite
  }
})