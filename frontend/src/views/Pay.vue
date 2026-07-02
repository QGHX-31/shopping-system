<template>
  <div class="pay-page">
    <Header />
    <div class="container">
      <div v-if="loading" class="loading-wrap">
        <el-icon :size="48" class="loading-icon"><Loading /></el-icon>
        <p>加载中...</p>
      </div>
      
      <div v-else-if="error" class="loading-wrap">
        <el-icon :size="48" color="#f56c6c"><Warning /></el-icon>
        <p>{{ errorMessage }}</p>
        <el-button type="primary" @click="goBack">返回</el-button>
      </div>

      <div v-else-if="order" class="pay-content">
        <div class="pay-success-icon" v-if="paid">
          <el-icon :size="64" color="#67c23a"><CircleCheck /></el-icon>
          <h2>支付成功！</h2>
          <p>订单号：{{ order.orderNo }}</p>
        </div>
        
        <template v-else>
          <h2 class="page-title">订单支付</h2>
          
          <div class="order-info-card">
            <div class="info-header">
              <span class="label">订单号</span>
              <span class="value">{{ order.orderNo }}</span>
            </div>
            <div class="info-header">
              <span class="label">收货地址</span>
              <span class="value">{{ addressText }}</span>
            </div>
          </div>
          
          <div class="amount-card">
            <div class="amount-row">
              <span>商品总额</span>
              <span>¥{{ formatPrice(order.totalAmount) }}</span>
            </div>
            <div class="amount-row" v-if="order.discountAmount && order.discountAmount > 0">
              <span>优惠抵扣</span>
              <span class="discount">-¥{{ formatPrice(order.discountAmount) }}</span>
            </div>
            <div class="amount-row">
              <span>运费</span>
              <span>{{ order.freightAmount === 0 ? '免邮' : '¥' + formatPrice(order.freightAmount) }}</span>
            </div>
            <div class="amount-row total">
              <span>实付金额</span>
              <span class="total-price">¥{{ formatPrice(order.payAmount) }}</span>
            </div>
          </div>
          
          <div class="pay-methods">
            <h3>选择支付方式</h3>
            <div class="method-list">
              <div
                v-for="method in payMethods"
                :key="method.id"
                class="method-item"
                :class="{ active: selectedMethod === method.id }"
                @click="selectedMethod = method.id"
              >
                <div class="method-icon" :style="{ background: method.color }">
                  {{ method.label }}
                </div>
                <span class="method-name">{{ method.name }}</span>
                <el-radio :model-value="selectedMethod" :label="method.id" class="method-radio" />
              </div>
            </div>
          </div>
          
          <div class="pay-footer">
            <div class="pay-amount">
              <span>实付：</span>
              <span class="price">¥{{ formatPrice(order.payAmount) }}</span>
            </div>
            <el-button
              type="danger"
              size="large"
              class="pay-btn"
              :loading="paying"
              :disabled="!selectedMethod"
              @click="handlePay"
            >
              立即支付
            </el-button>
          </div>
        </template>
        
        <div class="back-links">
          <el-button link @click="goBack">返回订单列表</el-button>
          <el-button link @click="goHome">返回首页</el-button>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Loading, Warning, CircleCheck } from '@element-plus/icons-vue'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const error = ref(false)
const errorMessage = ref('')
const order = ref<any>(null)
const paying = ref(false)
const paid = ref(false)
const selectedMethod = ref(1)

const payMethods = [
  { id: 1, name: '微信支付', label: '微', color: '#07c160' },
  { id: 2, name: '支付宝', label: '支', color: '#1677ff' },
  { id: 3, name: '余额支付', label: '余', color: '#ff7700' }
]

const addressText = computed(() => {
  if (!order.value) return ''
  const name = order.value.receiverName || ''
  const phone = order.value.receiverPhone || ''
  const addr = order.value.receiverAddress || ''
  return `${name} ${phone} ${addr}`.trim()
})

function formatPrice(price: any): string {
  if (price == null) return '0.00'
  return Number(price).toFixed(2)
}

async function loadOrder() {
  const orderNo = route.query.orderNo
  if (!orderNo) {
    error.value = true
    errorMessage.value = '订单号无效'
    loading.value = false
    return
  }
  
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  
  loading.value = true
  error.value = false
  try {
    const res = await request.get('/order/detail', { params: { orderNo } })
    console.log('订单详情返回:', res)
    const orderData = res.data?.order || res.data
    console.log('解析后的订单数据:', orderData)
    order.value = orderData
  } catch (e: any) {
    console.error('加载订单失败:', e)
    error.value = true
    errorMessage.value = e?.message || '加载订单失败'
  } finally {
    loading.value = false
  }
}

async function handlePay() {
  if (!order.value || paying.value) return
  
  console.log('开始支付，订单数据:', order.value)
  console.log('订单ID:', order.value.id)
  console.log('订单号:', order.value.orderNo)
  console.log('支付方式:', selectedMethod.value)
  
  paying.value = true
  try {
    const createRes = await request.post('/payment/create', null, { 
      params: { orderId: order.value.id, payMethod: selectedMethod.value } 
    })
    console.log('创建支付返回:', createRes)
    
    const callbackRes = await request.post('/payment/mockCallback', null, {
      params: { orderNo: order.value.orderNo, payMethod: selectedMethod.value }
    })
    console.log('支付回调返回:', callbackRes)
    
    const groupTeamNo = route.query.groupTeamNo
    if (groupTeamNo) {
      try {
        await request.post(`/group/confirm/${groupTeamNo}`, null, {
          params: { userId: userStore.userInfo?.id, orderNo: order.value.orderNo }
        })
      } catch (e) {
        console.error('确认拼团加入失败:', e)
      }
    }
    
    paid.value = true
    ElMessage.success('支付成功！')
  } catch (e: any) {
    console.error('支付失败:', e)
    console.error('错误详情:', e?.response?.data || e?.message)
    const errorMsg = e?.response?.data?.message || e?.message || '支付失败'
    ElMessage.error(errorMsg)
  } finally {
    paying.value = false
  }
}

function goBack() {
  router.push({ path: '/member', query: { tab: 'orders' } })
}

function goHome() {
  router.push('/')
}

onMounted(() => {
  loadOrder()
})
</script>

<style lang="scss" scoped>
.pay-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.container {
  max-width: 800px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-title {
  font-size: 24px;
  margin-bottom: 20px;
  color: #333;
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
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.pay-content {
  background: #fff;
  border-radius: 12px;
  padding: 30px;
}

.pay-success-icon {
  text-align: center;
  padding: 40px 0;
  
  h2 {
    margin: 16px 0 8px;
    font-size: 28px;
    color: #67c23a;
  }
  p {
    color: #666;
    margin: 0;
  }
}

.order-info-card {
  background: #f9f9f9;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
  
  .info-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    
    &:last-child { margin-bottom: 0; }
    
    .label { color: #999; font-size: 14px; }
    .value { color: #333; font-size: 14px; }
  }
}

.amount-card {
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 30px;
  
  .amount-row {
    display: flex;
    justify-content: space-between;
    padding: 8px 0;
    color: #666;
    font-size: 14px;
    
    &.total {
      border-top: 1px solid #eee;
      padding-top: 16px;
      margin-top: 8px;
      font-size: 16px;
      font-weight: 600;
      color: #333;
      
      .total-price {
        color: #f56c6c;
        font-size: 24px;
      }
    }
    
    .discount {
      color: #67c23a;
    }
  }
}

.pay-methods {
  margin-bottom: 30px;
  
  h3 {
    font-size: 16px;
    margin-bottom: 16px;
    color: #333;
  }
  
  .method-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
  
  .method-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px 20px;
    border: 2px solid #eee;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
    
    &:hover {
      border-color: #ffb4b4;
      background: #fff8f8;
    }
    
    &.active {
      border-color: #f56c6c;
      background: #fff5f5;
    }
    
    .method-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      color: #fff;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
      font-weight: bold;
      flex-shrink: 0;
    }
    
    .method-name {
      flex: 1;
      font-size: 15px;
      color: #333;
    }
    
    .method-radio {
      margin-left: auto;
    }
    
    .method-radio :deep(.el-radio__label) {
      display: none;
    }
  }
}

.pay-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 20px;
  border-top: 1px solid #eee;
  
  .pay-amount {
    display: flex;
    align-items: baseline;
    gap: 8px;
    
    .price {
      color: #f56c6c;
      font-size: 28px;
      font-weight: bold;
    }
  }
  
  .pay-btn {
    width: 180px;
    height: 48px;
    font-size: 16px;
  }
}

.back-links {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}
</style>
