<template>
  <div class="seckill-page">
    <Header />
    <div class="banner">⚡ 限时秒杀 · 抢到就是赚到</div>
    <div class="container">
      <el-empty v-if="!loading && list.length === 0" description="暂无秒杀商品" />
      <div v-loading="loading" class="product-grid">
        <div
          v-for="p in list"
          :key="p.id"
          class="product-card"
          @click="goProduct(p.productId)"
        >
          <div class="product-image">
            <img :src="p.imageUrl || defaultImg" :alt="p.productName" />
            <span class="discount-tag">{{ calcDiscount(p) }}折</span>
          </div>
          <div class="product-body">
            <h4 class="product-name">{{ p.productName }}</h4>
            <div class="price-row">
              <span class="seckill-price">¥{{ Number(p.seckillPrice).toFixed(2) }}</span>
              <span class="original-price">¥{{ Number(p.originalPrice).toFixed(2) }}</span>
            </div>
            <div class="progress-bar">
              <div class="bar" :style="{ width: progress(p) + '%' }"></div>
              <span class="bar-text">已抢 {{ p.salesCount || 0 }} 件</span>
            </div>
            <el-button
              type="danger"
              style="width: 100%; margin-top: 10px"
              :disabled="p.availableStock <= 0"
              @click.stop="handleSeckill(p)"
            >
              {{ p.availableStock <= 0 ? '已抢光' : '立即抢' }}
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
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const list = ref<any[]>([])
const loading = ref(false)

const defaultImg = 'https://via.placeholder.com/240x240/f5f5f5/ccc?text=商品'

function calcDiscount(p: any) {
  if (!p.originalPrice) return '0'
  return (Number(p.seckillPrice) / Number(p.originalPrice) * 10).toFixed(1)
}

function progress(p: any) {
  if (!p.totalStock) return 0
  return Math.min(100, Math.round((p.salesCount || 0) / p.totalStock * 100))
}

function goProduct(id: number) {
  router.push(`/product/${id}`)
}

async function loadList() {
  loading.value = true
  try {
    const res = await request.get('/activity/seckill/active')
    list.value = res.data || []
  } finally { loading.value = false }
}

async function handleSeckill(p: any) {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  if (p.availableStock <= 0) return ElMessage.warning('已抢光')
  try {
    await ElMessageBox.confirm(`确认以 ¥${p.seckillPrice} 抢购？`, '秒杀下单', { type: 'warning' })
    router.push({
      path: '/checkout',
      query: {
        productId: p.productId,
        quantity: 1,
        seckillId: p.id
      }
    })
  } catch (e: any) {
    if (e === 'cancel') return
    ElMessage.error(e?.message || '抢购失败')
  }
}

onMounted(loadList)
</script>

<style lang="scss" scoped>
.seckill-page { min-height: 100vh; background: #f5f5f5; }
.banner {
  background: linear-gradient(135deg, #f56c6c 0%, #ff9a9e 100%);
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
    box-shadow: 0 4px 16px rgba(245, 108, 108, 0.15);
  }
}
.product-image {
  position: relative;
  height: 220px;
  background: #f5f5f5;
  img { width: 100%; height: 100%; object-fit: cover; }
  .discount-tag {
    position: absolute;
    top: 8px; left: 8px;
    background: #f56c6c;
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
  margin-bottom: 8px;
}
.seckill-price {
  color: #f56c6c;
  font-size: 22px;
  font-weight: bold;
}
.original-price {
  color: #999;
  text-decoration: line-through;
  font-size: 13px;
}
.progress-bar {
  position: relative;
  background: #ffe5e0;
  height: 18px;
  border-radius: 9px;
  overflow: hidden;
  .bar {
    position: absolute;
    top: 0; left: 0;
    height: 100%;
    background: linear-gradient(90deg, #ff8a8a, #f56c6c);
    border-radius: 9px;
  }
  .bar-text {
    position: absolute;
    width: 100%;
    text-align: center;
    line-height: 18px;
    font-size: 11px;
    color: #fff;
    text-shadow: 0 0 2px rgba(0, 0, 0, 0.4);
  }
}
</style>