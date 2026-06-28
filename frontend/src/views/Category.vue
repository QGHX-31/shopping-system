<template>
  <div class="category-page">
    <Header />
    <div class="container">
      <div class="category-layout">
        <div class="category-sidebar">
          <h3 class="sidebar-title">商品分类</h3>
          <el-tree
            :data="categoryTree"
            :props="{ label: 'name', children: 'children' }"
            :highlight-current="true"
            @node-click="handleCategoryClick"
          />
        </div>
        <div class="category-content">
          <div class="filter-bar">
            <el-select v-model="sortBy" placeholder="排序方式" @change="handleSortChange">
              <el-option label="默认排序" value="default" />
              <el-option label="价格从低到高" value="price_asc" />
              <el-option label="价格从高到低" value="price_desc" />
              <el-option label="销量从高到低" value="sales" />
            </el-select>
            <el-select v-model="priceRange" placeholder="价格区间" @change="handlePriceChange">
              <el-option label="全部" value="" />
              <el-option label="0-100" value="0-100" />
              <el-option label="100-500" value="100-500" />
              <el-option label="500-1000" value="500-1000" />
              <el-option label="1000以上" value="1000+" />
            </el-select>
          </div>
          <div class="product-grid">
            <div
              v-for="product in products"
              :key="product.id"
              class="product-card"
              @click="goProduct(product.id)"
            >
              <div class="product-image">
                <img :src="product.imageUrl || 'https://via.placeholder.com/200'" alt="" />
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
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProductStore } from '@/stores/product'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'

const route = useRoute()
const router = useRouter()
const productStore = useProductStore()

const categoryId = ref(0)
const sortBy = ref('default')
const priceRange = ref('')
const currentPage = ref(1)
const pageSize = ref(12)
const total = ref(0)
const products = ref<any[]>([])

watch(() => sortBy.value, () => {
  currentPage.value = 1
  loadProducts()
})

watch(() => priceRange.value, () => {
  currentPage.value = 1
  loadProducts()
})

const categoryTree = computed(() => {
  return productStore.categories.filter(c => c.parentId === 0).map(c => ({
    ...c,
    children: productStore.categories.filter(child => child.parentId === c.id)
  }))
})

function handleCategoryClick(data: any) {
  categoryId.value = data.id
  currentPage.value = 1
  loadProducts()
}

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

function handlePageChange(page: number) {
  currentPage.value = page
  loadProducts()
}

function handleSortChange() {
  currentPage.value = 1
  loadProducts()
}

function handlePriceChange() {
  currentPage.value = 1
  loadProducts()
}

async function loadProducts() {
  const params: any = {
    page: currentPage.value,
    size: pageSize.value,
    sortBy: sortBy.value
  }
  if (categoryId.value > 0) {
    params.categoryId = categoryId.value
  }
  if (priceRange.value) {
    const [min, max] = priceRange.value.split('-')
    if (min) params.priceMin = parseFloat(min)
    if (max && max !== '+') params.priceMax = parseFloat(max)
    if (priceRange.value.endsWith('+')) params.priceMin = parseFloat(priceRange.value)
  }
  const res = await productStore.getProducts(params)
  products.value = res.data.list || res.data
  total.value = res.data.total || 0
}

async function loadCategories() {
  await productStore.getCategories()
}

onMounted(async () => {
  const id = parseInt(route.params.id as string) || 0
  categoryId.value = id
  await loadCategories()
  await loadProducts()
})
</script>

<style lang="scss" scoped>
.category-page {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.category-layout {
  display: flex;
  gap: 30px;
}

.category-sidebar {
  width: 200px;
  background: #fff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);

  .sidebar-title {
    font-size: 18px;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 1px solid #eee;
  }
}

.category-content {
  flex: 1;

  .filter-bar {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
  }

  .product-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
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
      height: 200px;
      overflow: hidden;

      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
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
}
</style>