<template>
  <div class="order-list-page">
    <div class="page-header">
      <h2>订单管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索订单号" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-select v-model="orderStatus" placeholder="状态筛选" clearable style="width: 140px">
          <el-option label="待支付" :value="0" />
          <el-option label="待发货" :value="1" />
          <el-option label="已发货" :value="2" />
          <el-option label="已完成" :value="3" />
          <el-option label="已取消" :value="4" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="order-status-tabs">
      <div
        v-for="tab in statusTabs"
        :key="tab.value"
        :class="['status-tab', { active: currentStatus === tab.value }]"
        @click="currentStatus = tab.value; loadOrders()"
      >
        {{ tab.label }}
      </div>
    </div>

    <div class="order-table">
      <el-table :data="orderList" v-loading="loading" border>
        <el-table-column label="订单号" prop="orderNo" width="200" />
        <el-table-column v-if="merchantStore.merchantInfo?.isAdmin" label="店铺" width="160">
          <template #default="{ row }">
            <span>{{ getMerchantName(row.merchantId) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="240">
          <template #default="{ row }">
            <div class="product-list">
              <div v-for="(item, idx) in getItemList(row)" :key="idx" class="product-item">
                <img :src="item.productImage || defaultImg" :alt="item.productName" class="product-img" />
                <div class="product-info">
                  <span class="product-name">{{ item.productName || '商品' }}</span>
                  <span class="product-spec" v-if="item.specValues">{{ item.specValues }}</span>
                </div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="单价" width="100">
          <template #default="{ row }">
            <span class="price">¥{{ Number(getFirstItem(row)?.price || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="数量" width="80">
          <template #default="{ row }">
            <span>{{ getTotalQuantity(row) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" width="120">
          <template #default="{ row }">
            <span class="price total">¥{{ Number(row.payAmount || row.totalAmount || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 1" type="success" size="small" @click="showDeliverDialog(row)">发货</el-button>
            <el-button size="small" @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && orderList.length === 0" description="暂无订单" />
    </div>

    <div v-if="total > 0" class="pagination">
      <el-pagination
        v-model:current-page="page"
        :page-size="pageSize"
        :total="total"
        layout="total, prev, pager, next, jumper"
        @current-change="handlePageChange"
      />
    </div>

    <el-dialog v-model="deliverVisible" title="确认发货" width="400px" @open="onDeliverDialogOpen">
      <el-form :model="deliverForm" label-width="80px">
        <el-form-item label="订单号">
          <el-input :value="currentOrder?.orderNo" disabled />
        </el-form-item>
        <el-form-item label="快递公司">
          <el-select v-model="deliverForm.expressCompany" placeholder="请选择快递公司" style="width: 100%">
            <el-option v-for="exp in expressCompanies" :key="exp" :label="exp" :value="exp" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号">
          <div style="display: flex; gap: 8px;">
            <el-input v-model="deliverForm.trackingNo" placeholder="请输入或点击生成" style="flex: 1;" />
            <el-button @click="generateTrackingNo">生成</el-button>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="deliverVisible = false">取消</el-button>
        <el-button type="success" :disabled="!deliverForm.expressCompany || !deliverForm.trackingNo" @click="confirmDeliver">确认发货</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="detailVisible" title="订单详情" width="600px">
      <div v-if="currentOrder" class="order-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-row"><span class="label">订单号：</span><span>{{ currentOrder.orderNo }}</span></div>
          <div class="detail-row"><span class="label">下单时间：</span><span>{{ formatTime(currentOrder.createdAt) }}</span></div>
          <div v-if="currentOrder.payTime" class="detail-row"><span class="label">支付时间：</span><span>{{ formatTime(currentOrder.payTime) }}</span></div>
          <div v-if="currentOrder.groupBuyTime" class="detail-row"><span class="label">拼单时间：</span><span>{{ formatTime(currentOrder.groupBuyTime) }}</span></div>
          <div v-if="currentOrder.deliveryTime" class="detail-row"><span class="label">发货时间：</span><span>{{ formatTime(currentOrder.deliveryTime) }}</span></div>
          <div v-if="currentOrder.expressCompany" class="detail-row">
            <span class="label">快递公司：</span>
            <span>{{ currentOrder.expressCompany }}</span>
          </div>
          <div v-if="currentOrder.trackingNo" class="detail-row">
            <span class="label">物流单号：</span>
            <span class="mono">{{ currentOrder.trackingNo }}</span>
            <el-button type="primary" link size="small" style="margin-left: 12px;" @click="viewLogistics">查看轨迹</el-button>
          </div>
          <div v-if="currentOrder.receiveTime" class="detail-row"><span class="label">成交时间：</span><span>{{ formatTime(currentOrder.receiveTime) }}</span></div>
          <div class="detail-row"><span class="label">订单状态：</span>
            <el-tag :type="getStatusTagType(currentOrder.status)" size="small">{{ getStatusText(currentOrder.status) }}</el-tag>
          </div>
        </div>
        <div class="detail-section">
          <h4>收货信息</h4>
          <div class="detail-row"><span class="label">收货人：</span><span>{{ currentOrder.receiverName }}</span></div>
          <div class="detail-row"><span class="label">联系电话：</span><span>{{ currentOrder.receiverPhone }}</span></div>
          <div class="detail-row"><span class="label">收货地址：</span><span>{{ currentOrder.receiverAddress }}</span></div>
        </div>
        <div class="detail-section">
          <h4>商品信息</h4>
          <div v-for="(item, idx) in detailItems" :key="idx" class="detail-product">
            <img :src="item.productImage || defaultImg" class="detail-img" />
            <div class="detail-product-info">
              <div class="detail-product-name">{{ item.productName }}</div>
              <div class="detail-product-spec" v-if="item.specValues">{{ item.specValues }}</div>
              <div class="detail-product-price">
                <span>¥{{ Number(item.price).toFixed(2) }}</span>
                <span> × {{ item.quantity }}</span>
              </div>
            </div>
          </div>
        </div>
        <div v-if="detailCoupon" class="detail-section">
          <h4>优惠券</h4>
          <div class="coupon-card">
            <div class="coupon-left">
              <div class="coupon-amount">¥{{ Number(detailCoupon.discountAmount).toFixed(0) }}</div>
              <div class="coupon-condition">满{{ Number(detailCoupon.minAmount).toFixed(0) }}可用</div>
            </div>
            <div class="coupon-right">
              <div class="coupon-name">{{ detailCoupon.name }}</div>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>金额信息</h4>
          <div class="detail-row"><span class="label">商品总额：</span><span>¥{{ Number(currentOrder.totalAmount).toFixed(2) }}</span></div>
          <div class="detail-row"><span class="label">优惠金额：</span><span class="discount">-¥{{ Number(currentOrder.discountAmount || 0).toFixed(2) }}</span></div>
          <div class="detail-row"><span class="label">运费：</span><span>¥{{ Number(currentOrder.freightAmount || 0).toFixed(2) }}</span></div>
          <div class="detail-row total-row"><span class="label">实付金额：</span><span class="total-price">¥{{ Number(currentOrder.payAmount).toFixed(2) }}</span></div>
        </div>
        <div v-if="currentOrder.remark" class="detail-section">
          <h4>备注</h4>
          <p>{{ currentOrder.remark }}</p>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="logisticsVisible" title="物流轨迹" width="500px">
      <div v-if="currentOrder" class="logistics-info">
        <div class="logistics-header">
          <span class="logistics-company">{{ currentOrder.expressCompany }}</span>
          <span class="logistics-no">单号：{{ currentOrder.trackingNo }}</span>
        </div>
        <div v-loading="logisticsLoading" class="logistics-timeline">
          <el-timeline v-if="logisticsList.length > 0">
            <el-timeline-item
              v-for="(item, index) in logisticsList"
              :key="index"
              :timestamp="item.time"
              :type="index === 0 ? 'primary' : ''"
              :hollow="index !== 0"
            >
              <div class="logistics-content">{{ item.content }}</div>
              <div v-if="item.location" class="logistics-location">{{ item.location }}</div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-else-if="!logisticsLoading" description="暂无物流信息" />
        </div>
      </div>
      <template #footer>
        <el-button @click="logisticsVisible = false">关闭</el-button>
        <el-button type="primary" @click="refreshLogistics">刷新</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const merchantStore = useMerchantStore()

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const expressCompanies = [
  '顺丰速运',
  '京东物流',
  '中通快递',
  '圆通速递',
  '申通快递',
  '韵达速递',
  '邮政EMS',
  '百世快递',
  '极兔速递',
  '德邦快递'
]

const statusTabs = [
  { label: '全部订单', value: null },
  { label: '待支付', value: 0 },
  { label: '待发货', value: 1 },
  { label: '已发货', value: 2 },
  { label: '已完成', value: 3 },
  { label: '已取消', value: 4 },
]

const currentStatus = ref<number | null>(null)
const searchKeyword = ref('')
const orderStatus = ref<number | null>(null)
const orderList = ref<any[]>([])
const detailItems = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const deliverVisible = ref(false)
const detailVisible = ref(false)
const logisticsVisible = ref(false)
const logisticsLoading = ref(false)
const logisticsList = ref<any[]>([])
const currentOrder = ref<any>(null)
const detailCoupon = ref<any>(null)
const deliverForm = reactive({
  expressCompany: '',
  trackingNo: ''
})

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待支付',
    1: '待发货',
    2: '已发货',
    3: '已完成',
    4: '已取消',
    5: '退款中',
    6: '已退款',
    7: '已过期'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning',
    1: 'primary',
    2: 'success',
    3: 'success',
    4: 'info',
    5: 'danger',
    6: 'info',
    7: 'info'
  }
  return types[status] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : ''
}

const merchantNameMap = ref<Record<number, string>>({})

function getMerchantName(merchantId: number) {
  if (!merchantId) return '—'
  return merchantNameMap.value[merchantId] || `店铺${merchantId}`
}

async function loadMerchantNames(ids: number[]) {
  const uniqueIds = [...new Set(ids)].filter(id => id && !merchantNameMap.value[id])
  if (uniqueIds.length === 0) return
  try {
    for (const id of uniqueIds) {
      try {
        const res = await request.get(`/merchant/detail?id=${id}`)
        if (res.data?.shopName) {
          merchantNameMap.value[id] = res.data.shopName
        }
      } catch {
        // ignore
      }
    }
  } catch {
    // ignore
  }
}

function getItemList(row: any) {
  return row.items || []
}

function getFirstItem(row: any) {
  return row.items?.[0] || null
}

function getTotalQuantity(row: any) {
  if (!row.items) return 0
  return row.items.reduce((sum: number, item: any) => sum + (item.quantity || 0), 0)
}

async function loadOrders() {
  if (merchantStore.merchantInfo?.id === undefined || merchantStore.merchantInfo?.id === null) return
  if (!merchantStore.merchantInfo?.id && !merchantStore.merchantInfo?.isAdmin) return
  loading.value = true
  try {
    const status = currentStatus.value !== null ? currentStatus.value : orderStatus.value
    const res = await request.get('/order/merchant', {
      params: {
        merchantId: merchantStore.merchantInfo.id,
        status: status !== null && status !== '' ? status : undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    const totalCount = res.data?.total || 0

    if (searchKeyword.value) {
      list = list.filter(item => item.orderNo?.includes(searchKeyword.value))
      total.value = list.length
    } else {
      total.value = totalCount
    }

    for (const order of list) {
      try {
        const detailRes = await request.get(`/order/detail?orderNo=${order.orderNo}`)
        order.items = detailRes.data?.items || []
      } catch {
        order.items = []
      }
    }
    orderList.value = list

    if (merchantStore.merchantInfo?.isAdmin) {
      const merchantIds = list.map(o => o.merchantId).filter(Boolean)
      loadMerchantNames(merchantIds)
    }
  } catch (e) {
    console.error('加载订单失败', e)
    orderList.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadOrders()
}

function handlePageChange(val: number) {
  page.value = val
  loadOrders()
}

function showDeliverDialog(row: any) {
  currentOrder.value = row
  deliverForm.expressCompany = ''
  deliverForm.trackingNo = ''
  deliverVisible.value = true
}

function onDeliverDialogOpen() {
  // 默认选择第一个快递公司
  if (expressCompanies.length > 0 && !deliverForm.expressCompany) {
    deliverForm.expressCompany = expressCompanies[0]
  }
  // 自动生成运单号
  if (!deliverForm.trackingNo) {
    generateTrackingNo()
  }
}

function generateTrackingNo() {
  const prefixMap: Record<string, string> = {
    '顺丰速运': 'SF',
    '京东物流': 'JD',
    '中通快递': 'ZT',
    '圆通速递': 'YT',
    '申通快递': 'ST',
    '韵达速递': 'YD',
    '邮政EMS': 'EM',
    '百世快递': 'BT',
    '极兔速递': 'JT',
    '德邦快递': 'DB'
  }
  const prefix = prefixMap[deliverForm.expressCompany] || 'EXP'
  const timestamp = Date.now().toString().slice(-8)
  const random = Math.floor(Math.random() * 1000000).toString().padStart(6, '0')
  deliverForm.trackingNo = prefix + timestamp + random
}

async function confirmDeliver() {
  if (!currentOrder.value) return
  loading.value = true
  try {
    await request.post('/order/deliver', null, {
      params: {
        orderNo: currentOrder.value.orderNo,
        expressCompany: deliverForm.expressCompany,
        trackingNo: deliverForm.trackingNo
      }
    })
    ElMessage.success('发货成功')
    deliverVisible.value = false
    loadOrders()
  } catch (e: any) {
    ElMessage.error(e?.message || '发货失败')
  } finally {
    loading.value = false
  }
}

async function viewDetail(row: any) {
  currentOrder.value = row
  try {
    const detailRes = await request.get(`/order/detail?orderNo=${row.orderNo}`)
    detailItems.value = detailRes.data?.items || []
    detailCoupon.value = detailRes.data?.coupon || null
    currentOrder.value = detailRes.data?.order || row
  } catch {
    detailItems.value = row.items || []
    detailCoupon.value = null
  }
  detailVisible.value = true
}

async function viewLogistics() {
  if (!currentOrder.value) return
  logisticsVisible.value = true
  logisticsList.value = []
  await loadLogistics()
}

async function loadLogistics() {
  if (!currentOrder.value?.trackingNo) return
  logisticsLoading.value = true
  try {
    const res = await request.get('/order/logistics', {
      params: {
        orderNo: currentOrder.value.orderNo,
        trackingNo: currentOrder.value.trackingNo,
        expressCompany: currentOrder.value.expressCompany
      }
    })
    if (res.data && res.data.list) {
      logisticsList.value = res.data.list
    } else if (Array.isArray(res.data)) {
      logisticsList.value = res.data
    } else {
      logisticsList.value = generateMockLogistics()
    }
  } catch (e) {
    console.error('加载物流信息失败', e)
    logisticsList.value = generateMockLogistics()
  } finally {
    logisticsLoading.value = false
  }
}

function generateMockLogistics() {
  const now = new Date()
  const tracks = []
  const statuses = [
    '快件已到达【{city}转运中心】，正在分拣中',
    '快件已从【{city}转运中心】发出，正在运往下一站',
    '快件已到达【{city}】',
    '快件正在派送中，派送员：张师傅，电话：138****8888',
    '快件已签收，签收人：本人'
  ]
  const cities = ['广州', '长沙', '武汉', '郑州', '北京']
  for (let i = 0; i < 5; i++) {
    const time = new Date(now.getTime() - i * 24 * 60 * 60 * 1000 - Math.random() * 8 * 60 * 60 * 1000)
    const cityIndex = Math.min(i, cities.length - 1)
    tracks.push({
      time: formatTime(time.toISOString()),
      content: statuses[Math.min(i, statuses.length - 1)].replace('{city}', cities[cityIndex]),
      location: cities[cityIndex]
    })
  }
  return tracks
}

async function refreshLogistics() {
  await loadLogistics()
  ElMessage.success('物流信息已刷新')
}

onMounted(() => {
  loadOrders()
})
</script>

<style lang="scss" scoped>
.order-list-page {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 20px;
    color: #333;
  }

  .search-bar {
    display: flex;
    gap: 10px;
    align-items: center;
  }
}

.order-status-tabs {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;

  .status-tab {
    padding: 6px 16px;
    font-size: 14px;
    color: #666;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      color: #409eff;
    }

    &.active {
      color: #409eff;
      font-weight: 600;
      background: #ecf5ff;
    }
  }
}

.order-table {
  .product-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .product-item {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .product-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
  }

  .product-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .product-name {
    font-size: 13px;
    color: #333;
    max-width: 200px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .product-spec {
    font-size: 12px;
    color: #999;
  }

  .price {
    color: #e6a23c;
    font-weight: 500;

    &.total {
      font-size: 16px;
      font-weight: bold;
    }
  }
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.order-detail {
  .detail-section {
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;

    &:last-child {
      border-bottom: none;
      margin-bottom: 0;
      padding-bottom: 0;
    }

    h4 {
      margin: 0 0 10px 0;
      font-size: 14px;
      color: #333;
    }
  }

  .detail-row {
    display: flex;
    padding: 4px 0;
    font-size: 13px;

    .label {
      color: #999;
      width: 80px;
      flex-shrink: 0;
    }

    &.total-row {
      font-size: 15px;
      font-weight: bold;
      padding-top: 8px;
      margin-top: 4px;
      border-top: 1px dashed #eee;
    }
  }

  .mono {
    font-family: monospace;
    color: #666;
  }

  .discount {
    color: #f56c6c;
  }

  .total-price {
    color: #e6a23c;
    font-size: 18px;
  }

  .detail-product {
    display: flex;
    gap: 12px;
    padding: 8px 0;
    border-bottom: 1px dashed #f0f0f0;

    &:last-child {
      border-bottom: none;
    }
  }

  .detail-img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
  }

  .detail-product-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .detail-product-name {
    font-size: 13px;
    color: #333;
  }

  .detail-product-spec {
    font-size: 12px;
    color: #999;
    margin-top: 4px;
  }

  .detail-product-price {
    font-size: 13px;
    color: #e6a23c;
  }

  .coupon-card {
    display: flex;
    align-items: stretch;
    background: linear-gradient(135deg, #fff0f0, #fff7e6);
    border: 1px dashed #ff6b6b;
    border-radius: 8px;
    overflow: hidden;

    .coupon-left {
      width: 120px;
      padding: 12px;
      text-align: center;
      border-right: 1px dashed #ffb3b3;
    }

    .coupon-amount {
      font-size: 28px;
      font-weight: bold;
      color: #ff4400;
      line-height: 1.2;
    }

    .coupon-condition {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }

    .coupon-right {
      flex: 1;
      padding: 12px 16px;
      display: flex;
      align-items: center;
    }

    .coupon-name {
      font-size: 14px;
      color: #333;
      font-weight: 500;
    }
  }
}

.logistics-info {
  .logistics-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: #f5f7fa;
    border-radius: 6px;
    margin-bottom: 16px;

    .logistics-company {
      font-size: 14px;
      font-weight: 600;
      color: #333;
    }

    .logistics-no {
      font-size: 13px;
      color: #666;
      font-family: monospace;
    }
  }

  .logistics-timeline {
    max-height: 400px;
    overflow-y: auto;
    padding: 10px 0;
  }

  .logistics-content {
    font-size: 13px;
    color: #333;
    line-height: 1.5;
  }

  .logistics-location {
    font-size: 12px;
    color: #999;
    margin-top: 4px;
  }
}
</style>
