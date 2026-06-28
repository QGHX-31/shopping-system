<template>
  <div class="favorite-page">
    <Header />
    <div class="container">
      <h2 class="page-title">我的收藏</h2>
      <div v-if="favoriteStore.favorites.length === 0" class="empty-favorite">
        <el-icon :size="64" color="#ccc"><Star /></el-icon>
        <p>还没有收藏任何商品</p>
        <el-button type="primary" @click="goShopping">去购物</el-button>
      </div>
      <div v-else class="favorite-grid">
        <div
          v-for="favorite in favoriteStore.favorites"
          :key="favorite.id"
          class="favorite-card"
        >
          <div class="favorite-image" @click="goProduct(favorite.productId)">
            <img :src="favorite.productImage || 'https://via.placeholder.com/200'" alt="" />
          </div>
          <div class="favorite-info">
            <h4 class="favorite-name" @click="goProduct(favorite.productId)">{{ favorite.productName }}</h4>
            <p class="favorite-price">¥{{ favorite.price.toFixed(2) }}</p>
            <p class="favorite-time">{{ formatTime(favorite.createdAt) }}</p>
            <div class="favorite-actions">
              <el-button type="primary" size="small" @click="goProduct(favorite.productId)">去购买</el-button>
              <el-button type="danger" size="small" @click="handleRemove(favorite.id)">取消收藏</el-button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useFavoriteStore } from '@/stores/favorite'
import { useUserStore } from '@/stores/user'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { Star } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const favoriteStore = useFavoriteStore()
const userStore = useUserStore()

function goShopping() {
  router.push('/')
}

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

async function handleRemove(favoriteId: number) {
  await favoriteStore.removeFavorite(favoriteId)
  ElMessage.success('取消收藏成功')
}

function formatTime(dateStr: string) {
  const date = new Date(dateStr)
  return date.toLocaleDateString('zh-CN')
}

onMounted(async () => {
  if (userStore.isLogin) {
    await favoriteStore.getFavoriteList()
  }
})
</script>

<style lang="scss" scoped>
.favorite-page {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-title {
  font-size: 24px;
  margin-bottom: 30px;
}

.empty-favorite {
  text-align: center;
  padding: 80px 0;

  p {
    margin: 20px 0;
    color: #999;
    font-size: 18px;
  }
}

.favorite-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}

.favorite-card {
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);

  .favorite-image {
    height: 200px;
    overflow: hidden;
    cursor: pointer;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .favorite-info {
    padding: 15px;

    .favorite-name {
      font-size: 16px;
      font-weight: 500;
      margin-bottom: 10px;
      cursor: pointer;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .favorite-price {
      color: #f56c6c;
      font-size: 18px;
      font-weight: bold;
      margin-bottom: 5px;
    }

    .favorite-time {
      color: #999;
      font-size: 12px;
      margin-bottom: 15px;
    }

    .favorite-actions {
      display: flex;
      gap: 10px;
    }
  }
}
</style>