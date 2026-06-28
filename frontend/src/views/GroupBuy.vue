<template>
  <div class="group-page">
    <Header />
    <div class="banner">👥 拼团更优惠 · 邀好友一起买</div>
    <div class="container">
      <el-empty v-if="!loading && list.length === 0" description="暂无拼团活动" />
      <div v-loading="loading" class="product-grid">
        <div
          v-for="p in list"
          :key="p.id"
          class="product-card"
          @click="goProduct(p.productId)"
        >
          <div class="product-image">
            <img :src="p.imageUrl || defaultImg" :alt="p.productName" />
            <span class="group-tag">{{ p.requiredNum }}人成团</span>
          </div>
          <div class="product-body">
            <h4 class="product-name">{{ p.productName }}</h4>
            <div class="price-row">
              <span class="group-price">¥{{ Number(p.groupPrice).toFixed(2) }}</span>
              <span class="original-price">¥{{ Number(p.originalPrice).toFixed(2) }}</span>
            </div>
            <div class="stock-info">
              <span>库存 {{ p.availableStock }} 件</span>
            </div>
            <el-button
              type="success"
              style="width: 100%; margin-top: 10px"
              :disabled="p.availableStock <= 0"
              @click.stop="openGroup(p)"
            >
              发起拼团
            </el-button>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const list = ref<any[]>([])
const loading = ref(false)

const defaultImg = 'https://via.placeholder.com/240x240/f5f5f5/ccc?text=商品'

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

async function loadList() {
  loading.value = true
  try {
    const res = await request.get('/activity/group/active')
    list.value = res.data || []
  } finally { loading.value = false }
}

async function openGroup(p: any) {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (p.availableStock <= 0) return ElMessage.warning('库存不足')
  try {
    await ElMessageBox.confirm(`确认发起【${p.productName}】的拼团？`, '发起拼团', { type: 'success' })
    router.push({
      path: '/group/create',
      query: {
        productId: p.productId,
        activityId: p.id
      }
    })
  } catch (e: any) {
    if (e === 'cancel') return
    ElMessage.error(e?.message || '开团失败')
  }
}

onMounted(loadList)
</script>

<style lang="scss" scoped>
.group-page { min-height: 100vh; background: #f5f5f5; }
.banner {
  background: linear-gradient(135deg, #67c23a 0%, #95d475 100%);
  color: #fff; text-align: center; padding: 60px 0;
  font-size: 32px; font-weight: bold; letter-spacing: 4px;
}
.container { max-width: 1200px; margin: 0 auto; padding: 30px 20px; }

.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 16px;
}
.product-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s;
  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 16px rgba(103, 194, 58, 0.15);
  }
}
.product-image {
  position: relative;
  height: 220px;
  background: #f5f5f5;
  img { width: 100%; height: 100%; object-fit: cover; }
  .group-tag {
    position: absolute;
    top: 8px; left: 8px;
    background: #67c23a;
    color: #fff;
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 12px;
    font-weight: 600;
  }
}
.product-body { padding: 12px; }
.product-name {
  font-size: 14px;
  margin: 0 0 8px;
  height: 40px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
}
.price-row {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 6px;
}
.group-price {
  color: #67c23a;
  font-size: 22px;
  font-weight: bold;
}
.original-price {
  color: #999;
  text-decoration: line-through;
  font-size: 13px;
}
.stock-info {
  font-size: 12px;
  color: #999;
}
</style>