import { defineStore } from 'pinia'
import { ref } from 'vue'
import request from '@/utils/request'

export interface Product {
  id: number
  name: string
  categoryId: number
  brand: string
  price: number
  originalPrice: number
  stock: number
  salesCount: number
  description: string
  imageUrl: string
  detailImages: string[]
  isHot: boolean
  isNew: boolean
  status: boolean
}

export interface Category {
  id: number
  name: string
  parentId: number
  icon: string
  children?: Category[]
}

export const useProductStore = defineStore('product', () => {
  const products = ref<Product[]>([])
  const categories = ref<Category[]>([])
  const hotProducts = ref<Product[]>([])
  const newProducts = ref<Product[]>([])

  async function getCategories() {
    const res = await request.get('/category/list')
    categories.value = res.data
    return res
  }

  async function getProducts(params?: { categoryId?: number; keyword?: string; page?: number; size?: number }) {
    const res = await request.get('/product/list', { params })
    products.value = res.data.list
    return res
  }

  async function getHotProducts() {
    const res = await request.get('/product/hot')
    hotProducts.value = res.data
    return res
  }

  async function getNewProducts() {
    const res = await request.get('/product/new')
    newProducts.value = res.data
    return res
  }

  async function getProductDetail(id: number) {
    const res = await request.get(`/product/${id}`)
    return res
  }

  return {
    products,
    categories,
    hotProducts,
    newProducts,
    getCategories,
    getProducts,
    getHotProducts,
    getNewProducts,
    getProductDetail
  }
})