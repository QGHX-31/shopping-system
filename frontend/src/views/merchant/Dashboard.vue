<template>
  <div class="merchant-dashboard">
    <div class="stats-row">
      <div class="stat-card orders">
        <div class="stat-icon">📋</div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.todayOrders || 0 }}</div>
          <div class="stat-label">今日订单数</div>
        </div>
      </div>
      <div class="stat-card revenue">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <div class="stat-value">¥{{ formatAmount(dashboardData.todaySales) }}</div>
          <div class="stat-label">今日销售额</div>
        </div>
      </div>
      <div class="stat-card pending-ship">
        <div class="stat-icon">📦</div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.pendingShip || 0 }}</div>
          <div class="stat-label">待发货订单</div>
        </div>
      </div>
      <div class="stat-card pending-refund">
        <div class="stat-icon">↩️</div>
        <div class="stat-content">
          <div class="stat-value">{{ dashboardData.pendingRefund || 0 }}</div>
          <div class="stat-label">待退款订单</div>
        </div>
      </div>
    </div>

    <div class="chart-row">
      <div class="chart-card large">
        <div class="card-header">
          <h3>销售趋势</h3>
          <el-radio-group v-model="salesDays" size="small" @change="loadSalesTrend">
            <el-radio-button :value="7">近7天</el-radio-button>
            <el-radio-button :value="30">近30天</el-radio-button>
            <el-radio-button :value="90">近90天</el-radio-button>
          </el-radio-group>
        </div>
        <div ref="salesChartRef" class="chart-container"></div>
      </div>
      <div class="chart-card">
        <div class="card-header">
          <h3>订单状态分布</h3>
        </div>
        <div ref="orderPieRef" class="chart-container pie"></div>
      </div>
    </div>

    <div class="chart-row">
      <div class="chart-card full">
        <div class="card-header">
          <h3>热销商品TOP10</h3>
        </div>
        <div ref="topProductsChartRef" class="chart-container bar"></div>
      </div>
    </div>

    <div class="section-row">
      <div class="section-card">
        <h3>店铺信息</h3>
        <div class="shop-info">
          <div class="shop-item">
            <span class="label">店铺名称</span>
            <span class="value">{{ merchantStore.merchantInfo?.shopName }}</span>
          </div>
          <div class="shop-item">
            <span class="label">联系人</span>
            <span class="value">{{ merchantStore.merchantInfo?.contactName }}</span>
          </div>
          <div class="shop-item">
            <span class="label">联系电话</span>
            <span class="value">{{ merchantStore.merchantInfo?.contactPhone }}</span>
          </div>
          <div class="shop-item">
            <span class="label">店铺等级</span>
            <span class="value">{{ getLevelText(merchantStore.merchantInfo?.level) }}</span>
          </div>
        </div>
      </div>
      <div class="section-card">
        <h3>快捷操作</h3>
        <div class="quick-actions">
          <el-button type="primary" @click="goProduct">
            <el-icon><Goods /></el-icon>
            <span>商品管理</span>
          </el-button>
          <el-button @click="goSku">
            <el-icon><Box /></el-icon>
            <span>库存管理</span>
          </el-button>
          <el-button @click="goOrder">
            <el-icon><List /></el-icon>
            <span>订单管理</span>
          </el-button>
          <el-button @click="goRefund">
            <el-icon><RefreshLeft /></el-icon>
            <span>退款管理</span>
          </el-button>
          <el-button @click="goSeckill">
            <el-icon><Timer /></el-icon>
            <span>秒杀活动</span>
          </el-button>
          <el-button @click="goGroup">
            <el-icon><UserFilled /></el-icon>
            <span>拼团活动</span>
          </el-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { Goods, Box, Timer, UserFilled, List, RefreshLeft } from '@element-plus/icons-vue'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'
import * as echarts from 'echarts'

const router = useRouter()
const merchantStore = useMerchantStore()

const salesChartRef = ref<HTMLElement>()
const orderPieRef = ref<HTMLElement>()
const topProductsChartRef = ref<HTMLElement>()

let salesChart: echarts.ECharts | null = null
let orderPieChart: echarts.ECharts | null = null
let topProductsChart: echarts.ECharts | null = null

const salesDays = ref(7)

const dashboardData = reactive({
  todayOrders: 0,
  todaySales: 0,
  pendingShip: 0,
  pendingRefund: 0
})

function formatAmount(amount: any) {
  if (!amount) return '0.00'
  const num = parseFloat(amount)
  if (num >= 10000) {
    return (num / 10000).toFixed(2) + '万'
  }
  return num.toFixed(2)
}

function getLevelText(level: any) {
  const levels: Record<number, string> = {
    1: '普通商家',
    2: '铜牌商家',
    3: '银牌商家',
    4: '金牌商家',
    5: '钻石商家'
  }
  return levels[level] || '普通商家'
}

function goProduct() {
  router.push('/merchant/product')
}

function goSku() {
  router.push('/merchant/sku')
}

function goOrder() {
  router.push('/merchant/order')
}

function goRefund() {
  router.push('/merchant/refund')
}

function goSeckill() {
  router.push('/merchant/marketing/seckill')
}

function goGroup() {
  router.push('/merchant/marketing/group')
}

async function loadDashboard() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId) return
  try {
    const res = await request.get('/order/merchant/dashboard', {
      params: { merchantId }
    })
    if (res.data) {
      dashboardData.todayOrders = res.data.todayOrders || 0
      dashboardData.todaySales = res.data.todaySales || 0
      dashboardData.pendingShip = res.data.pendingShip || 0
      dashboardData.pendingRefund = res.data.pendingRefund || 0
    }
  } catch (e) {
    console.error('加载看板数据失败', e)
  }
}

async function loadSalesTrend() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId || !salesChart) return
  try {
    const res = await request.get('/order/merchant/sales-trend', {
      params: { merchantId, days: salesDays.value }
    })
    if (res.data) {
      const { dates, orderData, amountData } = res.data
      salesChart.setOption({
        xAxis: { data: dates || [] },
        series: [
          { data: orderData || [] },
          { data: amountData || [] }
        ]
      })
    }
  } catch (e) {
    console.error('加载销售趋势失败', e)
  }
}

async function loadOrderDistribution() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId || !orderPieChart) return
  try {
    const res = await request.get('/order/merchant/order-distribution', {
      params: { merchantId }
    })
    if (res.data && res.data.list) {
      const list = res.data.list
      orderPieChart.setOption({
        series: [{
          data: list.map((item: any) => ({
            name: item.name,
            value: item.value,
            itemStyle: { color: item.color }
          }))
        }]
      })
    }
  } catch (e) {
    console.error('加载订单分布失败', e)
  }
}

async function loadTopProducts() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId || !topProductsChart) return
  try {
    const res = await request.get('/order/merchant/top-products', {
      params: { merchantId, limit: 10 }
    })
    if (res.data) {
      const list = res.data.list || res.data || []
      const names = list.map((p: any) => p.name || p.productName || '未知').reverse()
      const values = list.map((p: any) => p.sales || p.quantity || 0).reverse()
      topProductsChart.setOption({
        yAxis: { data: names },
        series: [{ data: values }]
      })
    }
  } catch (e) {
    console.error('加载热销商品失败', e)
  }
}

function initSalesChart() {
  if (!salesChartRef.value) return
  salesChart = echarts.init(salesChartRef.value)
  salesChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['订单数', '销售额'] },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: [] },
    yAxis: [
      { type: 'value', name: '订单数', position: 'left' },
      { type: 'value', name: '销售额(元)', position: 'right' }
    ],
    series: [
      {
        name: '订单数',
        type: 'line',
        smooth: true,
        data: [],
        itemStyle: { color: '#409eff' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(64, 158, 255, 0.3)' },
            { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
          ])
        }
      },
      {
        name: '销售额',
        type: 'line',
        smooth: true,
        yAxisIndex: 1,
        data: [],
        itemStyle: { color: '#67c23a' },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.3)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0.05)' }
          ])
        }
      }
    ]
  })
}

function initOrderPieChart() {
  if (!orderPieRef.value) return
  orderPieChart = echarts.init(orderPieRef.value)
  orderPieChart.setOption({
    tooltip: { trigger: 'item' },
    legend: { orient: 'vertical', right: 10, top: 'center' },
    series: [{
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
      label: { show: false, position: 'center' },
      emphasis: {
        label: { show: true, fontSize: 16, fontWeight: 'bold' }
      },
      labelLine: { show: false },
      data: []
    }]
  })
}

function initTopProductsChart() {
  if (!topProductsChartRef.value) return
  topProductsChart = echarts.init(topProductsChartRef.value)
  topProductsChart.setOption({
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value', name: '销量' },
    yAxis: {
      type: 'category',
      data: []
    },
    series: [{
      type: 'bar',
      data: [],
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#83bff6' },
          { offset: 1, color: '#188df0' }
        ]),
        borderRadius: [0, 4, 4, 0]
      },
      barWidth: 20
    }]
  })
}

function handleResize() {
  salesChart?.resize()
  orderPieChart?.resize()
  topProductsChart?.resize()
}

onMounted(async () => {
  await nextTick()
  initSalesChart()
  initOrderPieChart()
  initTopProductsChart()
  loadDashboard()
  loadSalesTrend()
  loadOrderDistribution()
  loadTopProducts()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  salesChart?.dispose()
  orderPieChart?.dispose()
  topProductsChart?.dispose()
})
</script>

<style lang="scss" scoped>
.merchant-dashboard {
  padding: 20px;
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s, box-shadow 0.2s;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  }

  .stat-icon {
    width: 56px;
    height: 56px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
  }

  &.orders .stat-icon { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
  &.revenue .stat-icon { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
  &.pending-ship .stat-icon { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
  &.pending-refund .stat-icon { background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); }

  .stat-content {
    flex: 1;
  }

  .stat-value {
    font-size: 24px;
    font-weight: bold;
    color: #333;
  }

  .stat-label {
    font-size: 14px;
    color: #999;
    margin-top: 4px;
  }
}

.chart-row {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
  margin-bottom: 20px;

  &:last-child { margin-bottom: 0; }
}

.chart-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);

  &.large {
    grid-column: span 1;
  }

  &.full {
    grid-column: span 2;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;

  h3 {
    margin: 0;
    font-size: 16px;
    color: #333;
  }
}

.chart-container {
  width: 100%;
  height: 320px;

  &.pie { height: 280px; }
  &.bar { height: 380px; }
}

.section-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 20px;
}

.section-card {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);

  h3 {
    font-size: 16px;
    color: #333;
    margin: 0 0 16px 0;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;
  }
}

.shop-info {
  .shop-item {
    display: flex;
    justify-content: space-between;
    padding: 10px 0;
    border-bottom: 1px dashed #f0f0f0;

    .label { color: #999; }
    .value { color: #333; font-weight: 500; }
  }
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;

  .el-button {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 6px;
    height: 70px;
    padding: 10px;
  }
}
</style>
