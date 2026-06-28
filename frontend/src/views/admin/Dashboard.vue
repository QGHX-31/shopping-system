<template>
  <div class="admin-dashboard">
    <div class="stats-row">
      <div class="stat-card orders" @click="goOrderList">
        <div class="stat-icon">📦</div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.orderCount || 0 }}</div>
          <div class="stat-label">订单总数</div>
        </div>
        <div class="stat-trend up">+12.5%</div>
      </div>
      <div class="stat-card revenue" @click="goOrderList">
        <div class="stat-icon">💰</div>
        <div class="stat-content">
          <div class="stat-value">¥{{ formatAmount(stats.totalAmount) }}</div>
          <div class="stat-label">销售总额</div>
        </div>
        <div class="stat-trend up">+8.3%</div>
      </div>
      <div class="stat-card users" @click="goUserList">
        <div class="stat-icon">👥</div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.userCount || 0 }}</div>
          <div class="stat-label">用户总数</div>
        </div>
        <div class="stat-trend up">+5.2%</div>
      </div>
      <div class="stat-card products" @click="goProductList">
        <div class="stat-icon">🛍️</div>
        <div class="stat-content">
          <div class="stat-value">{{ stats.productCount || 0 }}</div>
          <div class="stat-label">商品总数</div>
        </div>
        <div class="stat-trend up">+3.1%</div>
      </div>
    </div>

    <div class="chart-row">
      <div class="chart-card large">
      <div class="card-header">
        <h3>销售趋势</h3>
        <el-radio-group v-model="salesPeriod" size="small" @change="loadSalesTrend">
          <el-radio-button label="7">近7天</el-radio-button>
          <el-radio-button label="30">近30天</el-radio-button>
          <el-radio-button label="90">近90天</el-radio-button>
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
      <div class="chart-card">
        <div class="card-header">
          <h3>商品分类销量</h3>
        </div>
        <div ref="categoryChartRef" class="chart-container bar"></div>
      </div>
      <div class="chart-card">
        <div class="card-header">
          <h3>热销商品TOP10</h3>
        </div>
        <el-table :data="hotProducts" size="small">
          <el-table-column type="index" label="排名" width="60" align="center">
            <template #default="{ $index }">
              <span :class="['rank', { top: $index < 3 }]">{{ $index + 1 }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="name" label="商品名称" min-width="150" show-overflow-tooltip />
          <el-table-column prop="sales" label="销量" width="80" align="right" />
          <el-table-column prop="amount" label="销售额" width="100" align="right">
            <template #default="{ row }">¥{{ Number(row.amount).toFixed(0) }}</template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <div class="chart-row">
      <div class="chart-card">
        <div class="card-header">
          <h3>用户增长趋势</h3>
        </div>
        <div ref="userChartRef" class="chart-container line"></div>
      </div>
      <div class="chart-card">
        <div class="card-header">
          <h3>今日实时数据</h3>
        </div>
        <div class="realtime-list">
          <div class="realtime-item">
            <span class="label">今日订单</span>
            <span class="value">{{ stats.todayOrders || 0 }} 单</span>
          </div>
          <div class="realtime-item">
            <span class="label">今日销售额</span>
            <span class="value highlight">¥{{ formatAmount(stats.todayAmount) }}</span>
          </div>
          <div class="realtime-item">
            <span class="label">今日新增用户</span>
            <span class="value">{{ stats.todayUsers || 0 }} 人</span>
          </div>
          <div class="realtime-item">
            <span class="label">待处理退款</span>
            <span class="value warning">{{ stats.pendingRefund || 0 }} 笔</span>
          </div>
          <div class="realtime-item">
            <span class="label">待发货订单</span>
            <span class="value warning">{{ stats.pendingShip || 0 }} 单</span>
          </div>
          <div class="realtime-item">
            <span class="label">活动进行中</span>
            <span class="value success">{{ stats.activeActivities || 0 }} 个</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import request from '@/utils/request'

const router = useRouter()

const salesChartRef = ref<HTMLElement>()
const orderPieRef = ref<HTMLElement>()
const categoryChartRef = ref<HTMLElement>()
const userChartRef = ref<HTMLElement>()

let salesChart: echarts.ECharts | null = null
let orderPieChart: echarts.ECharts | null = null
let categoryChart: echarts.ECharts | null = null
let userChart: echarts.ECharts | null = null

const salesPeriod = ref('7')

const stats = reactive({
  orderCount: 0,
  totalAmount: 0,
  userCount: 0,
  productCount: 0,
  todayOrders: 0,
  todayAmount: 0,
  todayUsers: 0,
  pendingRefund: 0,
  pendingShip: 0,
  activeActivities: 0
})

const hotProducts = ref<any[]>([])

function goOrderList() { router.push('/admin/order/list') }
function goUserList() { router.push('/admin/user/list') }
function goProductList() { router.push('/admin/product/list') }
function goRefundList() { router.push('/admin/refund/list') }

function formatAmount(val: any) {
  if (!val) return '0'
  const num = Number(val)
  if (num >= 10000) {
    return (num / 10000).toFixed(2) + '万'
  }
  return num.toFixed(0)
}

async function loadOverview() {
  try {
    const res: any = await request.get('/admin/stats/overview')
    if (res.code === 200 && res.data) {
      stats.orderCount = res.data.orderCount || 0
      stats.totalAmount = res.data.totalAmount || 0
      stats.userCount = res.data.userCount || 0
      stats.productCount = res.data.productCount || 0
    }
  } catch (e) {
    console.error('加载概览失败', e)
  }
}

async function loadSalesTrend(days?: number) {
  const d = days || parseInt(salesPeriod.value)
  try {
    const res: any = await request.get('/admin/stats/sales-trend', { params: { days: d } })
    if (res.code === 200 && res.data && salesChart) {
      const { dates, orderData, amountData } = res.data
      salesChart.setOption({
        xAxis: { data: dates },
        series: [
          { data: orderData },
          { data: amountData }
        ]
      })
    }
  } catch (e) {
    console.error('加载销售趋势失败', e)
  }
}

async function loadOrderStatus() {
  try {
    const res: any = await request.get('/admin/stats/order-status')
    if (res.code === 200 && res.data && orderPieChart) {
      const list = res.data.list || []
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
    console.error('加载订单状态失败', e)
  }
}

async function loadHotProducts() {
  try {
    const res: any = await request.get('/admin/stats/hot-products', { params: { limit: 10 } })
    if (res.code === 200 && res.data) {
      hotProducts.value = res.data
      if (categoryChart) {
        const names = res.data.slice(0, 6).map((p: any) => p.name || '未知')
        const values = res.data.slice(0, 6).map((p: any) => p.sales || 0)
        categoryChart.setOption({
          xAxis: { data: names },
          series: [{ data: values }]
        })
      }
    }
  } catch (e) {
    console.error('加载热销商品失败', e)
  }
}

async function loadRealtime() {
  try {
    const res: any = await request.get('/admin/stats/realtime')
    if (res.code === 200 && res.data) {
      stats.todayOrders = res.data.todayOrders || 0
      stats.todayAmount = res.data.todayAmount || 0
      stats.todayUsers = res.data.todayUsers || 0
      stats.pendingRefund = res.data.pendingRefund || 0
      stats.pendingShip = res.data.pendingShip || 0
      stats.activeActivities = res.data.activeActivities || 0
    }
  } catch (e) {
    console.error('加载实时数据失败', e)
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

function initCategoryChart() {
  if (!categoryChartRef.value) return
  categoryChart = echarts.init(categoryChartRef.value)
  categoryChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'value' },
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
      barWidth: 16
    }]
  })
}

function initUserChart() {
  if (!userChartRef.value) return
  userChart = echarts.init(userChartRef.value)
  const dates = []
  const data = []
  const today = new Date()
  for (let i = 13; i >= 0; i--) {
    const d = new Date(today)
    d.setDate(d.getDate() - i)
    dates.push(`${d.getMonth() + 1}/${d.getDate()}`)
    data.push(0)
  }
  userChart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', containLabel: true },
    xAxis: { type: 'category', boundaryGap: false, data: dates },
    yAxis: { type: 'value', name: '新增用户' },
    series: [{
      type: 'line',
      smooth: true,
      data: data,
      itemStyle: { color: '#f56c6c' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(245, 108, 108, 0.3)' },
          { offset: 1, color: 'rgba(245, 108, 108, 0.05)' }
        ])
      }
    }]
  })
}

function handleResize() {
  salesChart?.resize()
  orderPieChart?.resize()
  categoryChart?.resize()
  userChart?.resize()
}

onMounted(async () => {
  await nextTick()
  initSalesChart()
  initOrderPieChart()
  initCategoryChart()
  initUserChart()
  loadOverview()
  loadSalesTrend()
  loadOrderStatus()
  loadHotProducts()
  loadRealtime()
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  salesChart?.dispose()
  orderPieChart?.dispose()
  categoryChart?.dispose()
  userChart?.dispose()
})
</script>

<style lang="scss" scoped>
.admin-dashboard {
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
    position: relative;
    cursor: pointer;
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
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    &.orders .stat-icon { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    &.revenue .stat-icon { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
    &.users .stat-icon { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); }
    &.products .stat-icon { background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); }

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

    .stat-trend {
      position: absolute;
      top: 16px;
      right: 16px;
      font-size: 12px;
      padding: 2px 8px;
      border-radius: 10px;

      &.up { color: #67c23a; background: #f0f9eb; }
      &.down { color: #f56c6c; background: #fef0f0; }
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
    &.bar { height: 280px; }
    &.line { height: 280px; }
  }

  .rank {
    display: inline-block;
    width: 24px;
    height: 24px;
    line-height: 24px;
    text-align: center;
    border-radius: 50%;
    background: #f0f0f0;
    font-size: 12px;
    color: #999;

    &.top {
      background: linear-gradient(135deg, #ffd700, #ff8c00);
      color: #fff;
      font-weight: bold;
    }
  }

  .realtime-list {
    padding: 10px 0;
  }

  .realtime-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid #f5f5f5;

    &:last-child { border-bottom: none; }

    .label { color: #666; font-size: 14px; }
    .value {
      font-size: 16px;
      font-weight: 600;
      color: #333;

      &.highlight { color: #f56c6c; }
      &.warning { color: #e6a23c; }
      &.success { color: #67c23a; }
    }
  }
}
</style>
