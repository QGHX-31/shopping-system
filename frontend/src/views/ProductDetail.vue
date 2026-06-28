<template>
  <div class="product-detail-page">
    <Header />
    <div class="container">
      <!-- 面包屑 -->
      <div class="breadcrumb">
        <span @click="goHome">首页</span>
        <span class="sep">/</span>
        <span @click="goSearch">商品</span>
        <span class="sep">/</span>
        <span class="current">{{ product?.name || '商品详情' }}</span>
      </div>

      <div v-if="loading" class="loading-wrap">
        <el-icon :size="48" class="loading-icon"><Loading /></el-icon>
        <p>加载中...</p>
      </div>

      <div v-else-if="error" class="loading-wrap">
        <el-icon :size="48" color="#f56c6c"><Warning /></el-icon>
        <p>商品加载失败</p>
        <p class="error-tip">{{ errorMessage }}</p>
        <el-button @click="loadProduct" type="primary">重新加载</el-button>
        <el-button @click="goHome">返回首页</el-button>
      </div>

      <div v-else-if="product" class="product-detail">
        <!-- 左侧：商品图片 -->
        <div class="product-image-section">
          <div class="main-image">
            <img
              :src="currentImage || product.imageUrl || defaultImage"
              :alt="product.name"
              @error="handleImageError"
            />
            <span v-if="product.isHot" class="badge hot-badge">热卖</span>
            <span v-if="product.isNew" class="badge new-badge">新品</span>
          </div>
          <div class="thumbnail-list" v-if="thumbnailList.length > 1">
            <div
              v-for="(img, idx) in thumbnailList"
              :key="idx"
              class="thumbnail-item"
              :class="{ active: currentImage === img }"
              @click="currentImage = img"
            >
              <img :src="img" @error="removeThumbnail(idx)" />
            </div>
          </div>
        </div>

        <!-- 右侧：商品信息 -->
        <div class="product-info-section">
          <h1 class="product-name">{{ product.name }}</h1>
          <p class="product-desc" v-if="product.description">{{ product.description }}</p>

          <!-- 活动信息区域 -->
          <div class="activity-info-section" v-if="seckillActivity || groupActivity || availableCoupons.length > 0">
            <div class="activity-item" v-if="seckillActivity">
              <el-icon class="activity-icon seckill-icon"><AlarmClock /></el-icon>
              <div class="activity-content">
                <span class="activity-name">限时秒杀</span>
                <span class="activity-price">秒杀价 ¥{{ formatPrice(seckillActivity.seckillPrice) }}</span>
                <span class="activity-tip">限时特惠，每人限购{{ seckillActivity.limitPerUser }}件</span>
              </div>
            </div>
            <div class="activity-item" v-if="groupActivity">
              <el-icon class="activity-icon group-icon"><UserFilled /></el-icon>
              <div class="activity-content">
                <span class="activity-name">{{ groupActivity.requiredNum }}人拼团</span>
                <span class="activity-price">拼团价 ¥{{ formatPrice(groupActivity.groupPrice) }}</span>
                <span class="activity-tip">邀请好友一起拼，更划算</span>
              </div>
            </div>
            <div class="active-groups" v-if="activeGroups.length > 0">
              <div class="active-groups-header">
                <span class="active-groups-title">👥 正在拼团</span>
                <span class="active-groups-more">共 {{ activeGroups.length }} 个拼团</span>
              </div>
              <div class="active-groups-list">
                <div 
                  v-for="item in activeGroups.slice(0, 3)" 
                  :key="item.team.id" 
                  class="group-item"
                >
                  <div class="group-avatars">
                    <el-avatar 
                      v-for="(m, idx) in item.members.slice(0, 3)" 
                      :key="m.id"
                      :size="24"
                      :src="m.avatar || ''"
                      class="group-avatar"
                      :style="{ zIndex: 3 - idx, marginLeft: idx > 0 ? '-8px' : '0' }"
                    >
                      {{ (m.nickname || m.userName || '用').charAt(0) }}
                    </el-avatar>
                    <span class="group-names">
                      {{ item.members.map(m => m.nickname || m.userName || ('用户' + (m.userId || '').toString().slice(-3))).join('、') }}
                    </span>
                  </div>
                  <div class="group-progress">
                    <span>还差 <strong>{{ item.team.requiredNum - item.team.currentNum }}</strong> 人成团</span>
                  </div>
                  <el-button 
                    type="success" 
                    size="small" 
                    round
                    @click="handleJoinGroup(item.team.teamNo)"
                  >
                    去拼团
                  </el-button>
                </div>
              </div>
            </div>
            <div class="activity-item coupon-item" v-if="availableCoupons.length > 0">
              <el-icon class="activity-icon coupon-icon"><Ticket /></el-icon>
              <div class="activity-content">
                <span class="activity-name">可领优惠券</span>
                <div class="coupon-list">
                  <span v-for="c in availableCoupons.slice(0, 3)" :key="c.id" class="coupon-tag">
                    {{ c.type === 1 ? `满${c.minAmount}减${c.discountAmount}` : `${Math.round((1-c.discountAmount)*100)}折` }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div class="product-price-box">
            <div class="price-label">价格</div>
            <div class="price-content">
              <span class="current-price">¥{{ formatPrice(showPrice) }}</span>
              <span v-if="showOriginalPrice && showOriginalPrice > showPrice" class="original-price">
                ¥{{ formatPrice(showOriginalPrice) }}
              </span>
              <span v-if="showOriginalPrice && showOriginalPrice > showPrice" class="discount-tag">
                立省 ¥{{ formatPrice(Number(showOriginalPrice) - Number(showPrice)) }}
              </span>
            </div>
          </div>

          <div class="product-promotion">
            <div class="promo-item">
              <span class="promo-label">销量</span>
              <span class="promo-value">{{ product.salesCount || 0 }} 件</span>
            </div>
            <div class="promo-item">
              <span class="promo-label">库存</span>
              <span class="promo-value">{{ currentStock || 0 }} 件</span>
            </div>
            <div class="promo-item" v-if="product.brand">
              <span class="promo-label">品牌</span>
              <span class="promo-value">{{ product.brand }}</span>
            </div>
          </div>

          <div class="shop-entry" v-if="shopInfo" @click="goShopDetail">
            <img :src="shopInfo.logo || defaultShopLogo" :alt="shopInfo.shopName" class="shop-entry-logo" />
            <div class="shop-entry-info">
              <span class="shop-entry-name">{{ shopInfo.shopName }}</span>
              <span class="shop-entry-tip">进店逛逛</span>
            </div>
            <el-icon class="shop-entry-arrow"><ArrowRight /></el-icon>
          </div>

          <div class="product-services">
            <div class="service-item">
              <el-icon><Check /></el-icon>
              <span>正品保证</span>
            </div>
            <div class="service-item">
              <el-icon><Box /></el-icon>
              <span>极速发货</span>
            </div>
            <div class="service-item">
              <el-icon><RefreshLeft /></el-icon>
              <span>七天无忧</span>
            </div>
            <div class="service-item">
              <el-icon><Service /></el-icon>
              <span>在线客服</span>
            </div>
          </div>

          <div v-if="skuList.length > 0" class="sku-selector">
            <div class="sku-group" v-for="(spec, specName) in specMap" :key="specName">
              <span class="sku-label">{{ specName }}：</span>
              <div class="sku-values">
                <span
                  v-for="val in spec"
                  :key="val"
                  :class="['sku-value', { active: selectedSpecs[specName] === val, disabled: !isSpecAvailable(specName, val) }]"
                  @click="selectSpec(specName, val)"
                >{{ val }}</span>
              </div>
            </div>
            <div v-if="selectedSku" class="selected-info">
              已选：<span class="selected-text">{{ selectedSpecText }}</span>
            </div>
          </div>

          <div class="product-quantity">
            <span class="qty-label">数量：</span>
            <el-input-number
              v-model="quantity"
              :min="1"
              :max="currentStock || 1"
              :disabled="!currentStock"
            />
            <span class="stock-text">库存 {{ currentStock || 0 }} 件</span>
          </div>

          <div class="action-buttons">
            <el-button
              v-if="groupActivity"
              type="success"
              size="large"
              class="group-btn"
              :disabled="!currentStock || !groupActivity.availableStock || (skuList.length > 0 && !selectedSku)"
              @click="handleStartGroup"
            >
              <el-icon><UserFilled /></el-icon>
              发起拼团
            </el-button>
            <el-button
              v-if="seckillActivity"
              type="danger"
              size="large"
              class="seckill-btn"
              :disabled="!currentStock || !seckillActivity.availableStock || (skuList.length > 0 && !selectedSku)"
              @click="handleSeckillBuy"
            >
              <el-icon><AlarmClock /></el-icon>
              秒杀抢购
            </el-button>
            <el-button
              type="warning"
              size="large"
              class="cart-btn"
              :disabled="!currentStock || (skuList.length > 0 && !selectedSku)"
              @click="handleAddToCart"
            >
              <el-icon><ShoppingCart /></el-icon>
              加入购物车
            </el-button>
            <el-button
              type="primary"
              size="large"
              class="buy-btn"
              :disabled="!currentStock || (skuList.length > 0 && !selectedSku)"
              @click="handleBuyNow"
            >
              <el-icon><Wallet /></el-icon>
              立即购买
            </el-button>
            <el-button
              :type="isFavorited ? 'danger' : 'default'"
              size="large"
              circle
              class="fav-btn"
              @click="handleAddToFavorite"
            >
              <el-icon><Star v-if="!isFavorited" /><StarFilled v-else /></el-icon>
            </el-button>
          </div>
        </div>
      </div>

      <!-- 推荐商品 -->
      <div v-if="product" class="recommend-section">
        <h3 class="section-title">看了又看</h3>
        <div v-if="loadingRecommend" class="loading-mini">加载中...</div>
        <div v-else-if="recommendList.length > 0" class="recommend-grid">
          <div
            v-for="item in recommendList"
            :key="item.id"
            class="recommend-card"
            @click="goProduct(item.id)"
          >
            <img :src="item.imageUrl || defaultImage" :alt="item.name" />
            <p class="r-name">{{ item.name }}</p>
            <p class="r-price">¥{{ formatPrice(item.price) }}</p>
          </div>
        </div>
        <div v-else class="empty-mini">暂无推荐</div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  ShoppingCart, Star, StarFilled, Wallet, Loading, Warning,
  Check, Box, RefreshLeft, Service, AlarmClock, UserFilled, Ticket, ArrowRight
} from '@element-plus/icons-vue'
import { useProductStore } from '@/stores/product'
import { useCartStore } from '@/stores/cart'
import { useFavoriteStore } from '@/stores/favorite'
import { useUserStore } from '@/stores/user'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()
const productStore = useProductStore()
const cartStore = useCartStore()
const favoriteStore = useFavoriteStore()
const userStore = useUserStore()

const product = ref<any>(null)
const quantity = ref(1)
const isFavorited = ref(false)
const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')
const currentImage = ref('')
const recommendList = ref<any[]>([])
const loadingRecommend = ref(false)

const shopInfo = ref<any>(null)
const defaultShopLogo = 'https://dummyimage.com/80x80/ccc/fff&text=Shop'

const skuList = ref<any[]>([])
const selectedSpecs = ref<Record<string, string>>({})
const selectedSku = ref<any>(null)

// 活动相关
const seckillActivity = ref<any>(null)
const groupActivity = ref<any>(null)
const activeGroups = ref<any[]>([])
const availableCoupons = ref<any[]>([])
const loadingActivities = ref(false)

const defaultImage = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgZmlsbD0iI2Y1ZjVmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTgiIGZpbGw9IiM5OTkiPuaaguaXoOWbvueJhzwvdGV4dD48L3N2Zz4='

// 解析 detailImages 字符串为数组
const thumbnailList = computed(() => {
  if (!product.value) return []
  const list: string[] = []
  if (product.value.imageUrl) list.push(product.value.imageUrl)
  if (product.value.detailImages) {
    try {
      let imgs = product.value.detailImages
      if (typeof imgs === 'string') {
        imgs = JSON.parse(imgs)
      }
      if (Array.isArray(imgs)) {
        imgs.forEach((img: string) => {
          if (img && img !== product.value.imageUrl) list.push(img)
        })
      }
    } catch (e) {
      console.warn('detailImages 解析失败:', e)
    }
  }
  return list
})

// 解析规格映射
const specMap = computed(() => {
  const map: Record<string, string[]> = {}
  skuList.value.forEach(sku => {
    const specs = parseSpecValues(sku.specValues || sku.specifications || '')
    Object.keys(specs).forEach(key => {
      if (!map[key]) map[key] = []
      if (!map[key].includes(specs[key])) {
        map[key].push(specs[key])
      }
    })
  })
  return map
})

// 当前库存
const currentStock = computed(() => {
  if (selectedSku.value) {
    return selectedSku.value.stock || 0
  }
  if (skuList.value.length > 0) {
    return skuList.value.reduce((sum: number, sku: any) => sum + (sku.stock || 0), 0)
  }
  return product.value?.stock || 0
})

// 显示价格
const showPrice = computed(() => {
  if (selectedSku.value?.price != null) {
    return selectedSku.value.price
  }
  return product.value?.price || 0
})

// 显示原价
const showOriginalPrice = computed(() => {
  if (selectedSku.value?.originalPrice != null) {
    return selectedSku.value.originalPrice
  }
  return product.value?.originalPrice || 0
})

// 已选规格文本
const selectedSpecText = computed(() => {
  const parts: string[] = []
  Object.keys(selectedSpecs.value).forEach(key => {
    parts.push(`${key}: ${selectedSpecs.value[key]}`)
  })
  return parts.join('，')
})

// 解析规格值字符串
function parseSpecValues(specStr: string): Record<string, string> {
  if (!specStr) return {}
  const result: Record<string, string> = {}
  try {
    if (typeof specStr === 'string' && (specStr.startsWith('{') || specStr.startsWith('['))) {
      const parsed = JSON.parse(specStr)
      if (Array.isArray(parsed)) {
        parsed.forEach((item: any) => {
          if (item.name && item.value != null) {
            result[item.name] = String(item.value)
          }
        })
      } else if (typeof parsed === 'object') {
        Object.keys(parsed).forEach(key => {
          result[key] = String(parsed[key])
        })
      }
      return result
    }
  } catch (e) {
    // 不是JSON，继续用其他方式解析
  }
  if (typeof specStr === 'string') {
    const hasColon = /[:：]/.test(specStr)
    const hasSemicolon = /[;；]/.test(specStr)
    if (hasColon || hasSemicolon) {
      const pairs = specStr.split(/[;；]/).filter(Boolean)
      pairs.forEach(pair => {
        const [key, value] = pair.split(/[:：]/)
        if (key && value) {
          result[key.trim()] = value.trim()
        }
      })
    } else {
      result['规格'] = specStr.trim()
    }
  }
  return result
}

// 根据选中规格查找SKU
function findSkuBySpecs(specs: Record<string, string>): any | null {
  const specKeys = Object.keys(specs)
  if (specKeys.length === 0) return null
  for (const sku of skuList.value) {
    const skuSpecs = parseSpecValues(sku.specValues || sku.specifications || '')
    let match = true
    for (const key of specKeys) {
      if (skuSpecs[key] !== specs[key]) {
        match = false
        break
      }
    }
    if (match && Object.keys(skuSpecs).length === specKeys.length) {
      return sku
    }
  }
  return null
}

// 判断某个规格值是否可选
function isSpecAvailable(specName: string, specValue: string): boolean {
  const testSpecs = { ...selectedSpecs.value, [specName]: specValue }
  const sku = findSkuBySpecs(testSpecs)
  return !!(sku && sku.stock > 0)
}

// 选择规格
function selectSpec(specName: string, specValue: string) {
  if (selectedSpecs.value[specName] === specValue) {
    delete selectedSpecs.value[specName]
  } else {
    selectedSpecs.value[specName] = specValue
  }
  selectedSpecs.value = { ...selectedSpecs.value }
  const found = findSkuBySpecs(selectedSpecs.value)
  selectedSku.value = found
  if (found?.image) {
    currentImage.value = found.image
  }
  quantity.value = 1
}

// 加载SKU列表
async function loadSkus(productId: number) {
  try {
    const res = await request.get('/sku/list', { params: { productId } })
    skuList.value = res.data || []
    console.log('SKU列表:', skuList.value)
    selectedSpecs.value = {}
    selectedSku.value = null
    if (skuList.value.length > 0) {
      const firstSku = skuList.value[0]
      const firstSpecs = parseSpecValues(firstSku.specValues || firstSku.specifications || '')
      console.log('第一个SKU规格:', firstSku.specValues, firstSku.specifications, firstSpecs)
      selectedSpecs.value = { ...firstSpecs }
      selectedSku.value = firstSku
    }
  } catch (e) {
    console.warn('加载SKU失败:', e)
    skuList.value = []
  }
}

function formatPrice(price: any): string {
  if (price == null) return '0.00'
  return Number(price).toFixed(2)
}

function handleImageError(e: Event) {
  const img = e.target as HTMLImageElement
  if (img.src !== defaultImage) {
    img.src = defaultImage
  }
}

function removeThumbnail(idx: number) {
  // 简单的图片加载失败处理
}

async function loadProduct() {
  const id = parseInt(route.params.id as string)
  if (!id || isNaN(id)) {
    error.value = true
    errorMessage.value = '商品ID无效'
    loading.value = false
    return
  }
  loading.value = true
  error.value = false
  errorMessage.value = ''
  try {
    const res = await productStore.getProductDetail(id)
    if (res && res.data) {
      product.value = res.data
      currentImage.value = res.data.imageUrl || ''
      // 加载SKU
      loadSkus(id)
      // 加载活动信息
      loadActivities(id)
      // 加载店铺信息
      loadShopInfo(res.data.merchantId)
      // 加载完后检查收藏状态
      if (userStore.isLogin) {
        checkFavorite()
      }
      // 加载推荐商品
      loadRecommend()
    } else {
      error.value = true
      errorMessage.value = '商品不存在或已下架'
    }
  } catch (e: any) {
    error.value = true
    errorMessage.value = e?.message || '网络错误，请稍后重试'
    console.error('加载商品失败:', e)
  } finally {
    loading.value = false
  }
}

async function loadActivities(productId: number) {
  loadingActivities.value = true
  try {
    // 加载秒杀活动
    const seckillRes = await request.get(`/activity/seckill/product/${productId}`)
    if (seckillRes.data && seckillRes.data.length > 0) {
      seckillActivity.value = seckillRes.data[0]
    }
    // 加载拼团活动
    const groupRes = await request.get(`/activity/group/product/${productId}`)
    if (groupRes.data && groupRes.data.length > 0) {
      groupActivity.value = groupRes.data[0]
      // 加载正在进行的拼团
      loadActiveGroups(productId)
    }
    // 加载可用优惠券
    const couponRes = await request.get(`/activity/coupon/product/${productId}`)
    availableCoupons.value = couponRes.data || []
  } catch (e) {
    console.warn('加载活动信息失败:', e)
  } finally {
    loadingActivities.value = false
  }
}

async function loadShopInfo(merchantId: number) {
  if (!merchantId) return
  try {
    const res: any = await request.get(`/merchant/${merchantId}`)
    shopInfo.value = res.data || null
  } catch (e) {
    console.warn('加载店铺信息失败:', e)
  }
}

function goShopDetail() {
  if (shopInfo.value?.id) {
    router.push(`/shop/${shopInfo.value.id}`)
  }
}

async function checkFavorite() {
  if (userStore.isLogin && product.value?.id) {
    try {
      isFavorited.value = await favoriteStore.isFavorite(product.value.id)
    } catch (e) {
      console.warn('检查收藏状态失败:', e)
    }
  }
}

async function loadRecommend() {
  loadingRecommend.value = true
  try {
    await productStore.getHotProducts()
    recommendList.value = (productStore.hotProducts || [])
      .filter((p: any) => p.id !== product.value?.id)
      .slice(0, 4)
  } catch (e) {
    recommendList.value = []
  } finally {
    loadingRecommend.value = false
  }
}

async function handleAddToCart() {
  if (!userStore.isLogin) {
    try {
      await ElMessageBox.confirm('您还未登录，是否前往登录？', '提示', {
        confirmButtonText: '去登录',
        cancelButtonText: '取消',
        type: 'warning'
      })
      router.push({
        path: '/login',
        query: { redirect: route.fullPath }
      })
    } catch {
      // 用户取消
    }
    return
  }
  if (!product.value?.id) return
  try {
    await cartStore.addToCart(product.value.id, quantity.value)
    ElMessage.success(`已加入购物车 × ${quantity.value}`)
  } catch (e: any) {
    ElMessage.error(e?.message || '加入购物车失败')
  }
}

async function handleBuyNow() {
  if (!userStore.isLogin) {
    try {
      await ElMessageBox.confirm('您还未登录，是否前往登录？', '提示', {
        confirmButtonText: '去登录',
        cancelButtonText: '取消',
        type: 'warning'
      })
      router.push({
        path: '/login',
        query: { redirect: route.fullPath }
      })
    } catch {
      // 用户取消
    }
    return
  }
  if (!product.value?.id) return
  // 跳转到结算页，传递商品ID和数量
  router.push({
    path: '/checkout',
    query: {
      productId: product.value.id,
      quantity: quantity.value
    }
  })
}

async function handleAddToFavorite() {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    return router.push({
      path: '/login',
      query: { redirect: route.fullPath }
    })
  }
  if (!product.value?.id) return
  try {
    if (isFavorited.value) {
      const favorite = favoriteStore.favorites.find((f: any) => f.productId === product.value.id)
      if (favorite) {
        await favoriteStore.removeFavorite(favorite.id)
        isFavorited.value = false
        ElMessage.success('取消收藏成功')
      }
    } else {
      await favoriteStore.addFavorite(product.value.id)
      isFavorited.value = true
      ElMessage.success('收藏成功')
    }
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

// 发起拼团
async function handleStartGroup() {
  if (!userStore.isLogin) {
    try {
      await ElMessageBox.confirm('您还未登录，是否前往登录？', '提示', {
        confirmButtonText: '去登录',
        cancelButtonText: '取消',
        type: 'warning'
      })
      router.push({
        path: '/login',
        query: { redirect: route.fullPath }
      })
    } catch {
      // 用户取消
    }
    return
  }
  if (!product.value?.id || !groupActivity.value) return
  // 跳转到拼团页面
  router.push({
    path: '/group/create',
    query: {
      productId: product.value.id,
      activityId: groupActivity.value.id
    }
  })
}

async function loadActiveGroups(productId: number) {
  try {
    const res: any = await request.get(`/group/teams/product/${productId}`, {
      params: { page: 1, size: 5 }
    })
    activeGroups.value = res.data?.list || []
  } catch (e) {
    console.warn('加载拼团列表失败:', e)
  }
}

async function handleJoinGroup(teamNo: string) {
  if (!userStore.isLogin) {
    try {
      await ElMessageBox.confirm('您还未登录，是否前往登录？', '提示', {
        confirmButtonText: '去登录',
        cancelButtonText: '取消',
        type: 'warning'
      })
      router.push({
        path: '/login',
        query: { redirect: route.fullPath }
      })
    } catch {
      // 用户取消
    }
    return
  }
  try {
    await ElMessageBox.confirm('确认加入该拼团？', '加入拼团', { type: 'success' })

    // 1. 加入拼团团队
    const joinForm = new FormData()
    joinForm.append('userId', String(userStore.userInfo?.id))
    const joinRes: any = await request.post(`/group/join/${teamNo}`, joinForm)
    const team = joinRes.data?.team
    if (!team) {
      throw new Error('加入拼团失败')
    }

    // 2. 查询默认地址
    const addrRes: any = await request.get('/address/list', {
      params: { userId: userStore.userInfo?.id }
    })
    const addresses = addrRes.data || []
    const defaultAddr = addresses.find((a: any) => a.isDefault) || addresses[0]
    if (!defaultAddr) {
      ElMessage.warning('请先添加收货地址')
      router.push({ path: '/member', query: { tab: 'address' } })
      return
    }

    // 3. 创建关联订单
    const orderData = {
      userId: userStore.userInfo?.id,
      items: [{
        productId: product.value.id,
        quantity: 1
      }],
      addressId: defaultAddr.id,
      groupTeamNo: teamNo
    }
    const orderRes = await request.post('/order/create', orderData)

    ElMessage.success('加入拼团成功！')
    router.push({
      path: '/order/pay',
      query: { orderNo: orderRes.data?.orderNo, groupTeamNo: teamNo }
    })
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e?.response?.data?.message || e?.message || '加入拼团失败')
    }
  }
}

// 秒杀抢购
async function handleSeckillBuy() {
  if (!userStore.isLogin) {
    try {
      await ElMessageBox.confirm('您还未登录，是否前往登录？', '提示', {
        confirmButtonText: '去登录',
        cancelButtonText: '取消',
        type: 'warning'
      })
      router.push({
        path: '/login',
        query: { redirect: route.fullPath }
      })
    } catch {
      // 用户取消
    }
    return
  }
  if (!product.value?.id || !seckillActivity.value) return
  // 跳转到秒杀结算页
  router.push({
    path: '/checkout',
    query: {
      productId: product.value.id,
      quantity: 1,
      seckillId: seckillActivity.value.id
    }
  })
}

function goHome() {
  router.push('/')
}

function goSearch() {
  router.push('/search')
}

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

watch(() => route.params.id, (newId, oldId) => {
  if (newId && newId !== oldId) {
    product.value = null
    currentImage.value = ''
    loadProduct()
  }
})

onMounted(() => {
  loadProduct()
})
</script>

<style lang="scss" scoped>
.product-detail-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.breadcrumb {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
  padding: 10px 0;

  span {
    cursor: pointer;
    &:hover { color: #ff4400; }
  }
  .sep { margin: 0 8px; color: #ccc; cursor: default; }
  .current { color: #333; cursor: default; }
}

.loading-wrap {
  text-align: center;
  padding: 100px 0;
  color: #999;
  background: #fff;
  border-radius: 8px;

  .loading-icon {
    animation: spin 1s linear infinite;
    color: #ff4400;
  }
  p { margin: 20px 0; font-size: 16px; }
  .error-tip { color: #999; font-size: 14px; margin: 10px 0 20px; }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.product-detail {
  display: flex;
  gap: 30px;
  background: #fff;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.product-image-section {
  width: 480px;
  flex-shrink: 0;

  .main-image {
    width: 100%;
    height: 480px;
    background: #f5f5f5;
    border-radius: 8px;
    overflow: hidden;
    position: relative;

    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
    }

    .badge {
      position: absolute;
      top: 15px;
      left: 15px;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 12px;
      color: #fff;
      font-weight: bold;
      &.hot-badge { background: linear-gradient(135deg, #ff7676, #f54e4e); }
      &.new-badge { background: linear-gradient(135deg, #67c23a, #5daf34); }
    }
  }

  .thumbnail-list {
    display: flex;
    gap: 10px;
    margin-top: 15px;
    overflow-x: auto;

    .thumbnail-item {
      width: 80px;
      height: 80px;
      border: 2px solid transparent;
      border-radius: 4px;
      overflow: hidden;
      cursor: pointer;
      flex-shrink: 0;
      background: #f5f5f5;

      &.active { border-color: #ff4400; }
      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
    }
  }
}

.product-info-section {
  flex: 1;
  min-width: 0;

  .product-name {
    font-size: 24px;
    color: #333;
    line-height: 1.4;
    margin-bottom: 10px;
  }

  .product-desc {
    font-size: 14px;
    color: #999;
    line-height: 1.6;
    margin-bottom: 20px;
  }

  // 活动信息区域样式
  .activity-info-section {
    background: #fff8f0;
    border: 1px solid #ffe0b0;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 20px;

    .activity-item {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 10px 0;
      border-bottom: 1px dashed #ffd0a0;

      &:last-child {
        border-bottom: none;
      }

      .activity-icon {
        font-size: 24px;
        margin-top: 2px;
      }

      .seckill-icon {
        color: #f56c6c;
      }

      .group-icon {
        color: #67c23a;
      }

      .coupon-icon {
        color: #e6a23c;
      }

      .activity-content {
        flex: 1;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 10px;

        .activity-name {
          font-size: 14px;
          font-weight: 600;
          color: #333;
          padding: 2px 8px;
          border-radius: 4px;
        }

        .activity-price {
          font-size: 18px;
          font-weight: bold;
          color: #ff4400;
        }

        .activity-tip {
          font-size: 12px;
          color: #999;
        }

        .coupon-list {
          display: flex;
          flex-wrap: wrap;
          gap: 8px;

          .coupon-tag {
            background: linear-gradient(135deg, #ff7676, #f54e4e);
            color: #fff;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
          }
        }
      }
    }
    
    .active-groups {
      background: #f0f9eb;
      border: 1px solid #b3e19d;
      border-radius: 8px;
      padding: 12px 15px;
      margin-bottom: 12px;
      
      .active-groups-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 10px;
        
        .active-groups-title {
          font-size: 14px;
          font-weight: 600;
          color: #67c23a;
        }
        
        .active-groups-more {
          font-size: 12px;
          color: #999;
        }
      }
      
      .active-groups-list {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
      
      .group-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 10px;
        background: #fff;
        border-radius: 6px;
        
        .group-avatars {
          display: flex;
          align-items: center;
          flex: 1;
          min-width: 0;
          
          .group-avatar {
            border: 2px solid #fff;
          }
          
          .group-names {
            margin-left: 8px;
            font-size: 12px;
            color: #666;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
        }
        
        .group-progress {
          font-size: 12px;
          color: #67c23a;
          
          strong {
            color: #f56c6c;
            font-size: 14px;
          }
        }
      }
    }
  }

  .product-price-box {
    background: linear-gradient(135deg, #fff5f0, #ffe8d9);
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;

    .price-label {
      font-size: 13px;
      color: #ff4400;
      margin-bottom: 8px;
    }
    .price-content {
      display: flex;
      align-items: baseline;
      gap: 12px;
      flex-wrap: wrap;
    }
    .current-price {
      font-size: 36px;
      color: #ff4400;
      font-weight: bold;
    }
    .original-price {
      font-size: 16px;
      color: #999;
      text-decoration: line-through;
    }
    .discount-tag {
      background: #ff4400;
      color: #fff;
      padding: 3px 10px;
      border-radius: 4px;
      font-size: 12px;
    }
  }

  .product-promotion {
    display: flex;
    gap: 30px;
    padding: 15px 0;
    border-bottom: 1px dashed #eee;
    margin-bottom: 20px;

    .promo-item {
      display: flex;
      align-items: center;
      gap: 8px;
      .promo-label {
        color: #999;
        font-size: 13px;
      }
      .promo-value {
        color: #333;
        font-size: 14px;
        font-weight: 500;
      }
    }
  }

  .shop-entry {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px;
    background: #fafafa;
    border-radius: 8px;
    cursor: pointer;
    margin-bottom: 16px;
    transition: background 0.2s;
    
    &:hover {
      background: #f5f5f5;
    }
    
    .shop-entry-logo {
      width: 48px;
      height: 48px;
      border-radius: 6px;
      object-fit: cover;
      flex-shrink: 0;
    }
    
    .shop-entry-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 4px;
      
      .shop-entry-name {
        font-size: 15px;
        font-weight: 600;
        color: #333;
      }
      
      .shop-entry-tip {
        font-size: 12px;
        color: #999;
      }
    }
    
    .shop-entry-arrow {
      color: #ccc;
      font-size: 18px;
    }
  }

  .product-services {
    display: flex;
    gap: 20px;
    padding: 15px 0;
    margin-bottom: 20px;

    .service-item {
      display: flex;
      align-items: center;
      gap: 6px;
      color: #666;
      font-size: 13px;
      .el-icon { color: #ff4400; }
    }
  }

  .sku-selector {
    padding: 15px 0;
    border-top: 1px dashed #eee;
    border-bottom: 1px dashed #eee;
    margin-bottom: 20px;

    .sku-group {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      margin-bottom: 12px;

      &:last-child {
        margin-bottom: 0;
      }

      .sku-label {
        color: #666;
        font-size: 14px;
        line-height: 32px;
        min-width: 50px;
      }

      .sku-values {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        flex: 1;

        .sku-value {
          padding: 6px 14px;
          border: 1px solid #ddd;
          border-radius: 4px;
          font-size: 13px;
          color: #333;
          cursor: pointer;
          transition: all 0.2s;
          background: #fff;

          &:hover {
            border-color: #ff4400;
            color: #ff4400;
          }

          &.active {
            border-color: #ff4400;
            background: #fff5f0;
            color: #ff4400;
            font-weight: 500;
          }

          &.disabled {
            color: #ccc;
            border-color: #eee;
            background: #f9f9f9;
            cursor: not-allowed;

            &:hover {
              border-color: #eee;
              color: #ccc;
            }
          }
        }
      }
    }

    .selected-info {
      margin-top: 10px;
      padding-top: 10px;
      border-top: 1px dashed #eee;
      font-size: 13px;
      color: #666;

      .selected-text {
        color: #ff4400;
        font-weight: 500;
      }
    }
  }

  .product-quantity {
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 20px 0;
    border-top: 1px dashed #eee;
    border-bottom: 1px dashed #eee;
    margin-bottom: 25px;

    .qty-label {
      color: #666;
      font-size: 14px;
    }
    .stock-text {
      color: #999;
      font-size: 13px;
    }
  }

  .action-buttons {
    display: flex;
    gap: 15px;
    align-items: center;

    .group-btn {
      height: 50px;
      font-size: 16px;
      font-weight: 500;
      background: linear-gradient(135deg, #67c23a, #5daf34);
      border: none;
      &:hover { opacity: 0.9; background: linear-gradient(135deg, #67c23a, #5daf34); }
    }
    .seckill-btn {
      height: 50px;
      font-size: 16px;
      font-weight: 500;
      background: linear-gradient(135deg, #f56c6c, #e64545);
      border: none;
      &:hover { opacity: 0.9; background: linear-gradient(135deg, #f56c6c, #e64545); }
    }
    .cart-btn, .buy-btn {
      flex: 1;
      height: 50px;
      font-size: 16px;
      font-weight: 500;
    }
    .cart-btn {
      background: linear-gradient(135deg, #ffb86c, #ff7e2d);
      border: none;
      color: #fff;
      &:hover { opacity: 0.9; background: linear-gradient(135deg, #ffb86c, #ff7e2d); }
    }
    .buy-btn {
      background: linear-gradient(135deg, #ff7676, #f54e4e);
      border: none;
      color: #fff;
      &:hover { opacity: 0.9; background: linear-gradient(135deg, #ff7676, #f54e4e); }
    }
    .fav-btn {
      width: 50px;
      height: 50px;
      font-size: 20px;
    }
  }
}

.recommend-section {
  margin-top: 20px;
  background: #fff;
  padding: 25px;
  border-radius: 8px;

  .section-title {
    font-size: 18px;
    color: #333;
    margin-bottom: 20px;
    padding-left: 10px;
    border-left: 4px solid #ff4400;
  }
  .loading-mini, .empty-mini {
    text-align: center;
    padding: 30px;
    color: #999;
  }
  .recommend-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
  }
  .recommend-card {
    cursor: pointer;
    transition: transform 0.2s;
    border-radius: 8px;
    overflow: hidden;
    &:hover { transform: translateY(-4px); }
    img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      background: #f5f5f5;
      border-radius: 8px;
    }
    .r-name {
      font-size: 14px;
      color: #333;
      margin: 10px 0 5px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .r-price {
      font-size: 18px;
      color: #ff4400;
      font-weight: bold;
    }
  }
}
</style>
