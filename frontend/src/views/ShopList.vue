<template>
  <div class="shop-list-page">
    <Header />
    <div class="container">
      <div class="page-header">
        <h2>店铺列表</h2>
        <div class="search-bar">
          <el-input
            v-model="keyword"
            placeholder="搜索店铺"
            clearable
            style="width: 300px"
            @keyup.enter="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch">搜索</el-button>
            </template>
          </el-input>
        </div>
      </div>

      <div v-loading="loading" class="shop-grid">
        <div
          v-for="shop in shops"
          :key="shop.id"
          class="shop-card"
          @click="goShopDetail(shop.id)"
        >
          <div class="shop-header">
            <img
              :src="shop.logo || defaultLogo"
              :alt="shop.shopName"
              class="shop-logo"
            />
            <div class="shop-info">
              <h3 class="shop-name">{{ shop.shopName }}</h3>
              <p class="shop-desc">店铺等级: {{ shop.level }} 级</p>
            </div>
          </div>
          <div class="shop-products">
            <div
              v-for="product in shop.products?.slice(0, 3)"
              :key="product.id"
              class="shop-product-item"
            >
              <img
                :src="product.imageUrl || defaultImg"
                :alt="product.name"
                class="shop-product-img"
              />
              <p class="shop-product-price">
                ¥{{ formatPrice(product.price) }}
              </p>
            </div>
            <div v-if="(shop.products?.length || 0) < 3" v-for="i in 3 - (shop.products?.length || 0)" :key="'empty-' + i" class="shop-product-item empty">
              <span>暂无商品</span>
            </div>
          </div>
          <div class="shop-footer">
            <el-button type="danger" size="small" round>进入店铺</el-button>
          </div>
        </div>
      </div>

      <div v-if="!loading && shops.length === 0" class="empty-state">
        <el-empty description="暂无店铺" />
      </div>

      <div v-if="total > size" class="pagination">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="size"
          :page-sizes="[10, 20, 30]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const shops = ref<any[]>([])
const keyword = ref('')
const page = ref(1)
const size = ref(20)
const total = ref(0)

const defaultLogo = 'https://dummyimage.com/80x80/ccc/fff&text=Shop'
const defaultImg = 'https://dummyimage.com/200x200/ccc/fff&text=Product'

function formatPrice(price: any) {
  if (!price) return '0.00'
  return Number(price).toFixed(2)
}

async function loadShops() {
  loading.value = true
  try {
    const res: any = await request.get('/merchant/list', {
      params: {
        page: page.value,
        size: size.value,
        keyword: keyword.value || undefined
      }
    })
    shops.value = res.data?.list || []
    total.value = res.data?.total || 0
    
    for (const shop of shops.value) {
      await loadShopProducts(shop)
    }
  } catch (e) {
    console.error('加载店铺列表失败', e)
  } finally {
    loading.value = false
  }
}

async function loadShopProducts(shop: any) {
  try {
    const res: any = await request.get('/merchant/product/list', {
      params: {
        merchantId: shop.id,
        page: 1,
        size: 3
      }
    })
    shop.products = res.data?.list?.filter((p: any) => p.status === 1) || []
  } catch (e) {
    shop.products = []
  }
}

function goShopDetail(id: number) {
  router.push(`/shop/${id}`)
}

function handleSearch() {
  page.value = 1
  loadShops()
}

function handlePageChange(p: number) {
  page.value = p
  loadShops()
}

function handleSizeChange(s: number) {
  size.value = s
  page.value = 1
  loadShops()
}

onMounted(() => {
  const kw = route.query.keyword
  if (typeof kw === 'string' && kw) {
    keyword.value = kw
  }
  loadShops()
})
</script>

<style scoped lang="scss">
.shop-list-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  
  h2 {
    margin: 0;
    color: #333;
  }
}

.shop-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.shop-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.3s;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
  }
}

.shop-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;
}

.shop-logo {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  flex-shrink: 0;
}

.shop-info {
  flex: 1;
  min-width: 0;
  
  .shop-name {
    margin: 0 0 4px 0;
    font-size: 16px;
    color: #333;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  
  .shop-desc {
    margin: 0;
    font-size: 12px;
    color: #999;
  }
}

.shop-products {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  margin-bottom: 12px;
}

.shop-product-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  
  &.empty {
    justify-content: center;
    aspect-ratio: 1;
    background: #f9f9f9;
    border-radius: 6px;
    
    span {
      font-size: 12px;
      color: #ccc;
    }
  }
}

.shop-product-img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 6px;
  margin-bottom: 4px;
}

.shop-product-price {
  margin: 0;
  font-size: 12px;
  color: #f56c6c;
  font-weight: 600;
}

.shop-footer {
  text-align: center;
}

.empty-state {
  padding: 60px 0;
  background: #fff;
  border-radius: 12px;
}

.pagination {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}

@media (max-width: 900px) {
  .shop-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 600px) {
  .shop-grid {
    grid-template-columns: 1fr;
  }
}
</style>
