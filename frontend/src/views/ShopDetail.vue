<template>
  <div class="shop-detail-page">
    <Header />
    <div class="container">
      <div v-loading="loading" class="shop-detail">
        <div class="shop-banner">
          <div class="shop-banner-content">
            <img
              :src="shop.logo || defaultLogo"
              :alt="shop.shopName"
              class="shop-logo"
            />
            <div class="shop-info">
              <h1 class="shop-name">{{ shop.shopName }}</h1>
              <p class="shop-desc">店铺等级: {{ shop.level }} 级</p>
              <p v-if="shop.address" class="shop-address">
                地址: {{ shop.address }}
              </p>
            </div>
          </div>
        </div>

        <div class="shop-main">
          <div class="shop-tabs">
            <div
              class="tab-item"
              :class="{ active: activeTab === 'all' }"
              @click="activeTab = 'all'"
            >
              全部商品
            </div>
            <div
              class="tab-item"
              :class="{ active: activeTab === 'new' }"
              @click="activeTab = 'new'"
            >
              新品上架
            </div>
          </div>

          <div class="product-grid">
            <div
              v-for="product in products"
              :key="product.id"
              class="product-card"
              :class="{ 'sold-out': product.stock === 0 }"
              @click="goProductDetail(product.id)"
            >
              <div class="product-img-wrapper">
                <img
                  :src="product.imageUrl || defaultImg"
                  :alt="product.name"
                  class="product-img"
                />
                <div v-if="product.stock === 0" class="sold-out-mask">
                  <span>售罄</span>
                </div>
              </div>
              <div class="product-info">
                <h3 class="product-name">{{ product.name }}</h3>
                <div class="product-price-row">
                  <span class="product-price">
                    ¥{{ formatPrice(product.price) }}
                  </span>
                  <span class="product-sales">
                    已售{{ product.sales || 0 }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div v-if="!loading && products.length === 0" class="empty-state">
            <el-empty description="该店铺暂无商品" />
          </div>

          <div v-if="total > pageSize" class="pagination">
            <el-pagination
              v-model:current-page="page"
              v-model:page-size="pageSize"
              :page-sizes="[12, 24, 48]"
              :total="total"
              layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleSizeChange"
              @current-change="handlePageChange"
            />
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const shop = ref<any>({})
const products = ref<any[]>([])
const activeTab = ref('all')
const page = ref(1)
const pageSize = ref(12)
const total = ref(0)

const defaultLogo = 'https://dummyimage.com/80x80/ccc/fff&text=Shop'
const defaultImg = 'https://dummyimage.com/200x200/ccc/fff&text=Product'

function formatPrice(price: any) {
  if (!price) return '0.00'
  return Number(price).toFixed(2)
}

async function loadShopDetail() {
  const shopId = route.params.id
  if (!shopId) return
  
  loading.value = true
  try {
    const res: any = await request.get(`/merchant/${shopId}`)
    shop.value = res.data || {}
  } catch (e) {
    console.error('加载店铺详情失败', e)
  } finally {
    loading.value = false
  }
}

async function loadProducts() {
  const shopId = route.params.id
  if (!shopId) return
  
  try {
    const res: any = await request.get('/merchant/product/list', {
      params: {
        merchantId: shopId,
        page: page.value,
        size: pageSize.value
      }
    })
    const list = res.data?.list || []
    products.value = list.filter((p: any) => p.status === 1)
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('加载商品列表失败', e)
  }
}

function goProductDetail(id: number) {
  router.push(`/product/${id}`)
}

function handlePageChange(p: number) {
  page.value = p
  loadProducts()
}

function handleSizeChange(s: number) {
  pageSize.value = s
  page.value = 1
  loadProducts()
}

onMounted(() => {
  loadShopDetail()
  loadProducts()
})
</script>

<style scoped lang="scss">
.shop-detail-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.shop-detail {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
}

.shop-banner {
  background: linear-gradient(135deg, #f56c6c 0%, #ff8e8e 100%);
  padding: 30px 40px;
}

.shop-banner-content {
  display: flex;
  align-items: center;
  gap: 20px;
}

.shop-logo {
  width: 100px;
  height: 100px;
  border-radius: 12px;
  object-fit: cover;
  background: #fff;
  border: 4px solid #fff;
}

.shop-info {
  color: #fff;
  
  .shop-name {
    margin: 0 0 8px 0;
    font-size: 24px;
    font-weight: 700;
  }
  
  .shop-desc {
    margin: 0 0 4px 0;
    font-size: 14px;
    opacity: 0.9;
  }
  
  .shop-address {
    margin: 0;
    font-size: 13px;
    opacity: 0.85;
  }
}

.shop-main {
  padding: 20px 30px 40px;
}

.shop-tabs {
  display: flex;
  gap: 30px;
  margin-bottom: 20px;
  border-bottom: 1px solid #f0f0f0;
}

.tab-item {
  padding: 12px 0;
  font-size: 15px;
  color: #666;
  cursor: pointer;
  position: relative;
  transition: color 0.2s;
  
  &:hover {
    color: #f56c6c;
  }
  
  &.active {
    color: #f56c6c;
    font-weight: 600;
    
    &::after {
      content: '';
      position: absolute;
      bottom: -1px;
      left: 0;
      right: 0;
      height: 2px;
      background: #f56c6c;
    }
  }
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.product-card {
  background: #fff;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s;
  
  &:hover {
    border-color: #ffb4b4;
    box-shadow: 0 4px 12px rgba(245, 108, 108, 0.1);
    transform: translateY(-2px);
  }
  
  &.sold-out {
    opacity: 0.6;
    
    .product-img-wrapper {
      background: #f5f5f5;
    }
  }
}

.product-img-wrapper {
  position: relative;
  width: 100%;
  aspect-ratio: 1;
  overflow: hidden;
  background: #f9f9f9;
}

.product-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s;
  
  .product-card:hover & {
    transform: scale(1.05);
  }
}

.sold-out-mask {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  
  span {
    color: #fff;
    font-size: 18px;
    font-weight: 600;
  }
}

.product-info {
  padding: 10px 12px 14px;
}

.product-name {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #333;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  line-height: 1.4;
  height: 39px;
}

.product-price-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-price {
  font-size: 16px;
  color: #f56c6c;
  font-weight: 700;
}

.product-sales {
  font-size: 12px;
  color: #999;
}

.empty-state {
  padding: 60px 0;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

@media (max-width: 900px) {
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 600px) {
  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .shop-banner {
    padding: 20px;
  }
  
  .shop-logo {
    width: 70px;
    height: 70px;
  }
  
  .shop-info .shop-name {
    font-size: 18px;
  }
  
  .shop-main {
    padding: 16px;
  }
}
</style>
