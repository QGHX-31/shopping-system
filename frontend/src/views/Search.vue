<template>
  <div class="search-page">
    <Header />
    <div class="container">
      <div class="search-header">
        <el-input
          v-model="keyword"
          placeholder="输入商品名称搜索"
          size="large"
          style="width: 500px"
        />
        <el-button type="primary" size="large" @click="handleSearch">搜索</el-button>
      </div>
      <div class="search-filters">
        <div class="filter-tags">
          <span v-if="keyword" class="filter-tag">
            关键词：{{ keyword }}
            <el-icon @click="clearKeyword"><Close /></el-icon>
          </span>
        </div>
        <div class="sort-options">
          <span>排序：</span>
          <el-radio-group v-model="sortBy" @change="handleSortChange">
            <el-radio-button label="default">默认</el-radio-button>
            <el-radio-button label="hot">热门</el-radio-button>
            <el-radio-button label="new">新品</el-radio-button>
            <el-radio-button label="price_asc">价格升序</el-radio-button>
            <el-radio-button label="price_desc">价格降序</el-radio-button>
          </el-radio-group>
        </div>
      </div>
      <div v-if="products.length === 0" class="empty-result">
        <el-icon :size="64" color="#ccc"><Search /></el-icon>
        <p>没有找到相关商品</p>
      </div>
      <div v-else class="product-grid">
        <div
          v-for="product in products"
          :key="product.id"
          class="product-card"
          @click="goProduct(product.id)"
        >
          <div class="product-image">
            <img :src="product.imageUrl || 'https://via.placeholder.com/200'" alt="" />
            <span v-if="product.isHot" class="hot-tag">热门</span>
            <span v-if="product.isNew" class="new-tag">新品</span>
            <span v-if="getProductActivity(product.id)?.type === 'seckill'" class="seckill-tag">秒杀</span>
            <span v-if="getProductActivity(product.id)?.type === 'group'" class="group-tag">拼团</span>
          </div>
          <h4 class="product-name">{{ product.name }}</h4>
          <p class="product-price">
            <span class="current-price">¥{{ product.price.toFixed(2) }}</span>
            <span v-if="product.originalPrice" class="original-price">¥{{ product.originalPrice.toFixed(2) }}</span>
          </p>
          <p class="product-sales">销量：{{ product.salesCount }}</p>
        </div>
      </div>
      <el-pagination
        v-if="total > pageSize"
        :current-page="currentPage"
        :page-size="pageSize"
        :total="total"
        layout="prev, pager, next"
        @current-change="handlePageChange"
      />
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { useRoute, useRouter, type RouteLocationNormalized } from 'vue-router'
import { useProductStore } from '@/stores/product'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { Search, Close } from '@element-plus/icons-vue'
import request from '@/utils/request'

const route = useRoute()
const router = useRouter()
const productStore = useProductStore()

const keyword = ref('')
const sortBy = ref('default')
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)
const products = ref<any[]>([])
const activityMap = ref<Map<number, { type: string; price: number }>>(new Map())

async function loadActivities() {
  try {
    const seckillRes = await request.get('/activity/seckill/active')
    const seckillList = seckillRes.data || []
    for (const item of seckillList) {
      activityMap.value.set(item.productId, { type: 'seckill', price: item.seckillPrice })
    }
    
    const groupRes = await request.get('/activity/group/active')
    const groupList = groupRes.data || []
    for (const item of groupList) {
      activityMap.value.set(item.productId, { type: 'group', price: item.groupPrice })
    }
  } catch (error) {
    console.error('加载活动信息失败', error)
  }
}

function getProductActivity(productId: number) {
  return activityMap.value.get(productId)
}

function handleSearch() {
  currentPage.value = 1
  router.push({ path: '/search', query: { keyword: keyword.value, sort: sortBy.value } })
  loadProducts()
}

function clearKeyword() {
  keyword.value = ''
  handleSearch()
}

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

function handlePageChange(page: number) {
  currentPage.value = page
  router.push({ path: '/search', query: { keyword: keyword.value, sort: sortBy.value, page: String(page) } })
  loadProducts()
}

function handleSortChange() {
  currentPage.value = 1
  router.push({ path: '/search', query: { keyword: keyword.value, sort: sortBy.value } })
  loadProducts()
}

async function loadProducts() {
  const params: any = {
    page: currentPage.value,
    size: pageSize.value,
    sortBy: sortBy.value
  }
  if (keyword.value) {
    params.keyword = keyword.value
  }
  const res = await productStore.getProducts(params)
  products.value = res.data.list || res.data
  total.value = res.data.total || 0
}

function syncFromRoute() {
  const newKeyword = (route.query.keyword as string) || ''
  const newSort = (route.query.sort as string) || 'default'
  const newPage = parseInt(route.query.page as string) || 1
  
  if (keyword.value !== newKeyword || sortBy.value !== newSort || currentPage.value !== newPage) {
    keyword.value = newKeyword
    sortBy.value = newSort
    currentPage.value = newPage
    loadProducts()
  }
}

onMounted(() => {
  syncFromRoute()
  loadActivities()
})

watch(() => ({ ...route.query }), () => {
  syncFromRoute()
}, { deep: true })
</script>

<style lang="scss" scoped>
.search-page {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.search-header {
  display: flex;
  justify-content: center;
  gap: 15px;
  margin-bottom: 30px;
}

.search-filters {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  .filter-tags {
    display: flex;
    gap: 10px;

    .filter-tag {
      display: flex;
      align-items: center;
      gap: 5px;
      background: #f5f5f5;
      padding: 5px 15px;
      border-radius: 20px;
      font-size: 14px;
    }
  }

  .sort-options {
    display: flex;
    align-items: center;
    gap: 10px;
  }
}

.empty-result {
  text-align: center;
  padding: 80px 0;

  p {
    margin: 20px 0;
    color: #999;
    font-size: 18px;
  }
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
}

.product-card {
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: transform 0.3s;

  &:hover {
    transform: translateY(-5px);
  }

  .product-image {
    position: relative;
    height: 200px;
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .hot-tag,
    .new-tag {
      position: absolute;
      top: 10px;
      left: 10px;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      color: #fff;
    }

    .hot-tag {
      background: #f56c6c;
    }

    .new-tag {
      background: #67c23a;
    }

    .seckill-tag {
      position: absolute;
      top: 10px;
      right: 10px;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      color: #fff;
      background: #e6a23c;
    }

    .group-tag {
      position: absolute;
      top: 10px;
      right: 10px;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      color: #fff;
      background: #409eff;
    }
  }

  .product-name {
    padding: 10px;
    font-size: 14px;
    font-weight: 500;
    margin: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .product-price {
    padding: 0 10px;
    margin: 5px 0;

    .current-price {
      color: #f56c6c;
      font-size: 18px;
      font-weight: bold;
    }

    .original-price {
      color: #999;
      font-size: 14px;
      text-decoration: line-through;
      margin-left: 10px;
    }
  }

  .product-sales {
    padding: 0 10px 10px;
    margin: 0;
    font-size: 12px;
    color: #999;
  }
}

:deep(.el-pagination) {
  display: flex;
  justify-content: center;
  margin-top: 30px;
}
</style>