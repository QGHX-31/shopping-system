<template>
  <div class="coupon-page">
    <Header />
    <div class="banner">🎟️ 领券下单更优惠</div>
    <div class="container">
      <div class="tabs-wrapper">
        <el-tabs v-model="activeTab" @tab-change="handleTabChange">
          <el-tab-pane label="全部可领" name="all" />
          <el-tab-pane label="平台券" name="platform" />
          <el-tab-pane label="店铺券" name="merchant" />
          <el-tab-pane label="单品券" name="single" />
        </el-tabs>
        <el-button 
          type="danger" 
          :loading="receivingAll"
          :disabled="receivableCount === 0"
          class="receive-all-btn"
          @click="handleReceiveAll"
        >
          一键领取 ({{ receivableCount }})
        </el-button>
      </div>
      
      <div v-loading="loading" class="grid">
        <el-card v-for="t in filteredTemplates" :key="t.id" class="coupon-card" :class="getCouponClass(t)" shadow="hover">
          <div class="tag" v-if="t.couponLevel === 1 || (!t.couponLevel && (t.merchantId == null || t.merchantId === 0))">平台券</div>
          <div class="tag merchant" v-else-if="t.couponLevel === 2">店铺券</div>
          <div class="tag single" v-else-if="t.couponLevel === 3">单品券</div>
          <div class="tag merchant" v-else>店铺券</div>
          <div class="left">
            <div class="amount">
              <span v-if="t.type === 2">{{ (t.discountAmount * 10).toFixed(1) }}折</span>
              <template v-else>
                <span class="currency">¥</span>
                <span class="num">{{ t.discountAmount }}</span>
              </template>
            </div>
            <div class="condition">{{ t.minAmount && t.minAmount > 0 ? `满${t.minAmount}元可用` : '无门槛' }}</div>
          </div>
          <div class="right">
            <div class="name">{{ t.name }}</div>
            <div class="rules">
              <el-tag size="small" type="info">{{ getScopeText(t.scopeType) }}</el-tag>
              <el-tag size="small" type="warning" v-if="t.userType === 1">新人专享</el-tag>
              <el-tag size="small" type="success" v-if="t.mutuallyExclusive === 0">可叠加</el-tag>
            </div>
            <div class="time">至 {{ formatTime(t.endTime) }} 失效</div>
            <div class="desc">{{ t.description }}</div>
            <div class="stats">
              <span>剩余 {{ t.remainingCount }} 张</span>
              <span>每人限领 {{ t.perUserLimit || 1 }} 张</span>
            </div>
            <el-button type="danger" size="small" :disabled="!isReceivable(t)" @click="receive(t)">
              {{ getReceiveBtnText(t) }}
            </el-button>
          </div>
        </el-card>
      </div>
      <el-empty v-if="!loading && filteredTemplates.length === 0" description="暂无优惠券" />

      <h3 class="title" style="margin-top: 40px">我的优惠券</h3>
      <el-tabs v-model="tab" @tab-change="loadMine">
        <el-tab-pane label="未使用" :name="0" />
        <el-tab-pane label="已使用" :name="1" />
        <el-tab-pane label="已过期" :name="2" />
      </el-tabs>
      <el-empty v-if="!loading && mine.length === 0" description="暂无优惠券" />
      <div class="grid">
        <el-card v-for="c in mine" :key="c.id" class="coupon-card mine" :class="{ used: c.status !== 0 }" shadow="hover">
          <div class="left">
            <div class="amount">
              <span v-if="c.type === 2">{{ (c.discountAmount * 10).toFixed(1) }}折</span>
              <template v-else>
                <span class="currency">¥</span>
                <span class="num">{{ c.discountAmount }}</span>
              </template>
            </div>
            <div class="condition">{{ c.minAmount && c.minAmount > 0 ? `满${c.minAmount}元可用` : '无门槛' }}</div>
          </div>
          <div class="right">
            <div class="name">{{ c.name }}</div>
            <div class="time">至 {{ formatTime(c.expireTime) }} 失效</div>
            <el-tag :type="c.status === 0 ? 'success' : c.status === 1 ? 'info' : 'danger'" size="small">
              {{ ['未使用', '已使用', '已过期'][c.status] }}
            </el-tag>
          </div>
        </el-card>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const loading = ref(false)
const templates = ref<any[]>([])
const mine = ref<any[]>([])
const tab = ref(0)
const activeTab = ref('all')
const receivingAll = ref(false)
const receivedTemplateIds = ref<Set<number>>(new Set())
const receivableTemplateIds = ref<Set<number>>(new Set())

const receivableCount = computed(() => {
  if (!userStore.isLogin) {
    return templates.value.filter(t => !isExpired(t)).length
  }
  return templates.value.filter(t => receivableTemplateIds.value.has(t.id)).length
})

const filteredTemplates = computed(() => {
  if (activeTab.value === 'all') return templates.value
  if (activeTab.value === 'platform') {
    return templates.value.filter(t => t.couponLevel === 1 || (!t.couponLevel && (t.merchantId == null || t.merchantId === 0)))
  }
  if (activeTab.value === 'merchant') {
    return templates.value.filter(t => t.couponLevel === 2)
  }
  if (activeTab.value === 'single') {
    return templates.value.filter(t => t.couponLevel === 3)
  }
  return templates.value
})

function formatTime(s: string) { return s ? s.replace('T', ' ').slice(0, 16) : '' }
function isExpired(t: any) { return new Date(t.endTime).getTime() < Date.now() }
function isReceived(t: any) { return receivedTemplateIds.value.has(t.id) }
function isReceivable(t: any) {
  if (isExpired(t)) return false
  if (!userStore.isLogin) return true
  return receivableTemplateIds.value.has(t.id)
}

function getReceiveBtnText(t: any) {
  if (isExpired(t)) return '已结束'
  if (isReceived(t)) return '已领取'
  if (!userStore.isLogin) return '立即领取'
  if (!isReceivable(t)) {
    if (t.userType === 1) return '新人专享'
    return '已领完'
  }
  return '立即领取'
}

function getScopeText(scope: number) {
  const scopes: Record<number, string> = {
    1: '全平台通用',
    2: '指定店铺',
    3: '指定商品',
    4: '指定类目'
  }
  return scopes[scope] || '通用'
}

function getCouponClass(t: any) {
  if (t.couponLevel === 1 || (!t.couponLevel && (t.merchantId == null || t.merchantId === 0))) {
    return 'platform-coupon'
  }
  if (t.couponLevel === 3) {
    return 'single-coupon'
  }
  return 'merchant-coupon'
}

async function loadTemplates() {
  loading.value = true
  try {
    const res = await request.get('/coupon/template/active')
    templates.value = res.data?.list || []
    
    if (userStore.isLogin && userStore.userInfo?.id) {
      const receivableRes = await request.get('/coupon/receivable', {
        params: { userId: userStore.userInfo.id }
      })
      const receivableList = receivableRes.data || []
      const ids = new Set<number>()
      for (const t of receivableList) {
        if (t.id != null) ids.add(Number(t.id))
      }
      receivableTemplateIds.value = ids
      await loadMine()
    } else {
      receivableTemplateIds.value = new Set()
    }
  } catch (e) {
    console.error('加载优惠券失败', e)
  } finally { 
    loading.value = false 
  }
}

watch(() => userStore.userInfo?.id, (newId) => {
  if (newId != null) {
    loadTemplates()
  }
})

async function loadMine() {
  if (!userStore.isLogin || !userStore.userInfo?.id) { mine.value = []; receivedTemplateIds.value = new Set(); return }
  loading.value = true
  try {
    const allRes = await request.get('/coupon/mine', { 
      params: { userId: userStore.userInfo.id, page: 1, size: 500 } 
    })
    const allCoupons = allRes.data?.list || []
    const ids = new Set<number>()
    for (const c of allCoupons) {
      if (c.templateId != null) ids.add(Number(c.templateId))
    }
    receivedTemplateIds.value = ids
    
    const res = await request.get('/coupon/mine', { 
      params: { userId: userStore.userInfo.id, status: tab.value, page: 1, size: 100 } 
    })
    mine.value = res.data?.list || []
  } catch (e) {
    console.error('加载我的优惠券失败', e)
  } finally { 
    loading.value = false 
  }
}

function handleTabChange() {
  // 切换分类tab时不需要额外操作，computed会自动过滤
}

async function receive(t: any) {
  if (!userStore.isLogin || !userStore.userInfo?.id) { 
    ElMessage.warning('请先登录')
    router.push('/login')
    return 
  }
  try {
    await request.post('/coupon/receive', null, { 
      params: { userId: userStore.userInfo.id, templateId: t.id } 
    })
    ElMessage.success('领取成功')
    await loadTemplates()
  } catch (e: any) {
    ElMessage.error(e?.message || '领取失败')
  }
}

async function handleReceiveAll() {
  if (!userStore.isLogin || !userStore.userInfo?.id) { 
    ElMessage.warning('请先登录')
    router.push('/login')
    return 
  }
  receivingAll.value = true
  try {
    const res: any = await request.post('/coupon/receive-all', null, { 
      params: { userId: userStore.userInfo.id } 
    })
    const successCount = res.data?.successCount || 0
    if (successCount > 0) {
      ElMessage.success(`成功领取 ${successCount} 张优惠券`)
      await loadTemplates()
    } else {
      ElMessage.info('没有可领取的优惠券')
    }
  } catch (e: any) {
    ElMessage.error(e?.message || '领取失败')
  } finally {
    receivingAll.value = false
  }
}

onMounted(async () => {
  await loadTemplates()
})
</script>

<style lang="scss" scoped>
.coupon-page { min-height: 100vh; background: #f5f5f5; }
.banner {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: #fff; text-align: center; padding: 60px 0;
  font-size: 32px; font-weight: bold; letter-spacing: 4px;
}
.container { max-width: 1200px; margin: 0 auto; padding: 30px 20px; }
.tabs-wrapper {
  background: #fff;
  border-radius: 8px;
  padding: 0 20px;
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  :deep(.el-tabs__item) {
    font-size: 15px;
  }
  :deep(.el-tabs__header) {
    margin-bottom: 0;
  }
  .receive-all-btn {
    flex-shrink: 0;
  }
}
.title { font-size: 22px; margin-bottom: 20px; }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 16px; }
.coupon-card {
  display: flex !important;
  align-items: stretch;
  position: relative;
  overflow: hidden;
  
  &.used { opacity: 0.5; }
  
  .tag {
    position: absolute;
    top: 0;
    right: 0;
    padding: 3px 10px;
    font-size: 11px;
    color: #fff;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 0 4px 0 8px;
    z-index: 1;
    
    &.merchant {
      background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
    
    &.single {
      background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
    }
  }
  
  .left {
    background: linear-gradient(135deg, #f56c6c, #ff9a9e);
    color: #fff;
    width: 130px;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    border-radius: 4px 0 0 4px;
    .amount { font-size: 26px; font-weight: bold; display: flex; align-items: baseline; }
    .currency { font-size: 14px; }
    .num { font-size: 30px; }
    .condition { font-size: 12px; margin-top: 6px; opacity: 0.9; }
  }
  
  &.platform-coupon .left {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
  
  &.merchant-coupon .left {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }
  
  &.single-coupon .left {
    background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
  }
  
  .right {
    flex: 1; padding: 12px 16px 12px 14px;
    display: flex; flex-direction: column; gap: 4px;
    .name { font-size: 15px; font-weight: 600; color: #333; margin-top: 16px; }
    .rules {
      display: flex; gap: 4px; flex-wrap: wrap;
      :deep(.el-tag) {
        transform: scale(0.85);
        transform-origin: left;
      }
    }
    .time { color: #999; font-size: 12px; }
    .desc { color: #666; font-size: 12px; line-height: 1.4; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .stats {
      display: flex; gap: 12px;
      font-size: 11px; color: #999;
    }
  }
}
</style>
