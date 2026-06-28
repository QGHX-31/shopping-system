<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>订单管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索订单号/收货人" clearable style="width: 220px" @keyup.enter="handleSearch" />
        <el-select v-model="orderStatus" placeholder="状态筛选" clearable style="width: 140px">
          <el-option label="待支付" :value="0" />
          <el-option label="待发货" :value="1" />
          <el-option label="已发货" :value="2" />
          <el-option label="已完成" :value="3" />
          <el-option label="已取消" :value="4" />
          <el-option label="退款中" :value="5" />
          <el-option label="已退款" :value="6" />
        </el-select>
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 260px"
        />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="stats-row">
      <div class="stat-mini">
        <span class="num">{{ totalCount }}</span>
        <span class="label">全部订单</span>
      </div>
      <div class="stat-mini warning">
        <span class="num">{{ pendingPayCount }}</span>
        <span class="label">待支付</span>
      </div>
      <div class="stat-mini primary">
        <span class="num">{{ pendingShipCount }}</span>
        <span class="label">待发货</span>
      </div>
      <div class="stat-mini success">
        <span class="num">{{ completedCount }}</span>
        <span class="label">已完成</span>
      </div>
      <div class="stat-mini danger">
        <span class="num">{{ refundCount }}</span>
        <span class="label">退款中</span>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="orderList" v-loading="loading" border>
        <el-table-column label="订单号" prop="order.orderNo" width="200" />
        <el-table-column label="店铺" width="140">
          <template #default="{ row }">
            <span>{{ getMerchantName(row.order?.merchantId) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="220">
          <template #default="{ row }">
            <div class="product-item">
              <img :src="getFirstItem(row)?.productImage || defaultImg" class="product-img" />
              <div class="product-info">
                <span class="product-name">{{ getFirstItem(row)?.productName || '—' }}</span>
                <span class="product-more" v-if="getItemCount(row) > 1">等{{ getItemCount(row) }}件商品</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货人" width="100">
          <template #default="{ row }">
            <span>{{ row.order?.receiverName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="实付金额" width="110" align="right">
          <template #default="{ row }">
            <span class="price">¥{{ Number(row.order?.payAmount || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="下单时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.order?.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.order?.status)" size="small">
              {{ getStatusText(row.order?.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link @click="viewDetail(row)">详情</el-button>
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

    <el-dialog v-model="detailVisible" title="订单详情" width="650px">
      <div v-if="currentOrder" class="order-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-grid">
            <div class="detail-row"><span class="label">订单号：</span><span class="mono">{{ currentOrder.order?.orderNo }}</span></div>
            <div class="detail-row"><span class="label">下单时间：</span><span>{{ formatTime(currentOrder.order?.createdAt) }}</span></div>
            <div class="detail-row"><span class="label">店铺：</span><span>{{ getMerchantName(currentOrder.order?.merchantId) }}</span></div>
            <div class="detail-row"><span class="label">订单状态：</span>
              <el-tag :type="getStatusTagType(currentOrder.order?.status)" size="small">{{ getStatusText(currentOrder.order?.status) }}</el-tag>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>收货信息</h4>
          <div class="detail-grid">
            <div class="detail-row"><span class="label">收货人：</span><span>{{ currentOrder.order?.receiverName }}</span></div>
            <div class="detail-row"><span class="label">联系电话：</span><span>{{ currentOrder.order?.receiverPhone }}</span></div>
            <div class="detail-row full"><span class="label">收货地址：</span><span>{{ currentOrder.order?.receiverAddress }}</span></div>
          </div>
        </div>
        <div class="detail-section">
          <h4>商品列表</h4>
          <div v-for="(item, idx) in detailItems" :key="idx" class="detail-product">
            <img :src="item.productImage || defaultImg" class="detail-img" />
            <div class="detail-product-info">
              <div class="detail-product-name">{{ item.productName }}</div>
              <div class="detail-product-price">
                <span>¥{{ Number(item.price).toFixed(2) }}</span>
                <span> × {{ item.quantity }}</span>
                <span class="subtotal">小计：¥{{ Number(item.subtotal || item.price * item.quantity).toFixed(2) }}</span>
              </div>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>金额明细</h4>
          <div class="detail-grid">
            <div class="detail-row"><span class="label">商品总额：</span><span>¥{{ Number(currentOrder.order?.totalAmount).toFixed(2) }}</span></div>
            <div class="detail-row"><span class="label">优惠金额：</span><span class="discount">-¥{{ Number(currentOrder.order?.discountAmount || 0).toFixed(2) }}</span></div>
            <div class="detail-row"><span class="label">运费：</span><span>¥{{ Number(currentOrder.order?.freightAmount || 0).toFixed(2) }}</span></div>
            <div class="detail-row"><span class="label">实付金额：</span><span class="total-price">¥{{ Number(currentOrder.order?.payAmount).toFixed(2) }}</span></div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import request from '@/utils/request'

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const searchKeyword = ref('')
const orderStatus = ref<number | null>(null)
const dateRange = ref<any[]>([])
const orderList = ref<any[]>([])
const detailItems = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const totalCount = ref(0)
const pendingPayCount = ref(0)
const pendingShipCount = ref(0)
const completedCount = ref(0)
const refundCount = ref(0)

const detailVisible = ref(false)
const currentOrder = ref<any>(null)

const merchantNameMap = ref<Record<number, string>>({})

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待支付', 1: '待发货', 2: '已发货', 3: '已完成',
    4: '已取消', 5: '退款中', 6: '已退款', 7: '已过期'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning', 1: 'primary', 2: 'success', 3: 'success',
    4: 'info', 5: 'danger', 6: 'info', 7: 'info'
  }
  return types[status] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

function getMerchantName(id: number) {
  if (!id) return '—'
  return merchantNameMap.value[id] || `店铺${id}`
}

function getFirstItem(row: any) {
  return row.items?.[0] || null
}

function getItemCount(row: any) {
  return row.items?.length || 0
}

async function loadOrders() {
  loading.value = true
  try {
    const res = await request.get('/admin/order/list', {
      params: {
        orderNo: searchKeyword.value || undefined,
        status: orderStatus.value ?? undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    const list = (res.data?.list || []) as any[]
    total.value = res.data?.total || 0
    orderList.value = list

    const merchantIds = list.map((o: any) => o.order?.merchantId).filter(Boolean)
    loadMerchantNames(merchantIds)
  } catch (e) {
    console.error('加载订单失败', e)
    orderList.value = []
  } finally {
    loading.value = false
  }
}

async function loadMerchantNames(ids: number[]) {
  const uniqueIds = [...new Set(ids)].filter(id => id && !merchantNameMap.value[id])
  for (const id of uniqueIds) {
    try {
      const res = await request.get(`/merchant/${id}`)
      if (res.data?.shopName) {
        merchantNameMap.value[id] = res.data.shopName
      }
    } catch { /* ignore */ }
  }
}

async function loadStats() {
  try {
    const allRes = await request.get('/admin/order/list', { params: { page: 1, size: 10000 } })
    const allOrders = allRes.data?.list || []
    totalCount.value = allRes.data?.total || allOrders.length
    pendingPayCount.value = allOrders.filter((o: any) => o.order?.status === 0).length
    pendingShipCount.value = allOrders.filter((o: any) => o.order?.status === 1).length
    completedCount.value = allOrders.filter((o: any) => o.order?.status === 3).length
    refundCount.value = allOrders.filter((o: any) => o.order?.status === 5).length
  } catch (e) {
    console.error('加载订单统计失败', e)
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

async function viewDetail(row: any) {
  currentOrder.value = row
  try {
    const detailRes = await request.get(`/admin/order/detail/${row.order?.id}`)
    const detail = detailRes.data
    detailItems.value = detail?.items || []
    currentOrder.value = detail || row
  } catch {
    detailItems.value = row.items || []
  }
  detailVisible.value = true
}

onMounted(() => {
  loadStats()
  loadOrders()
})
</script>

<style lang="scss" scoped>
.admin-page {
  background: #fff;
  border-radius: 8px;
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 { margin: 0; font-size: 20px; color: #333; }

  .search-bar {
    display: flex;
    gap: 10px;
    align-items: center;
  }
}

.stats-row {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.stat-mini {
  flex: 1;
  text-align: center;

  .num {
    display: block;
    font-size: 24px;
    font-weight: bold;
    color: #333;
  }
  .label {
    font-size: 13px;
    color: #999;
  }
  &.warning .num { color: #e6a23c; }
  &.primary .num { color: #409eff; }
  &.success .num { color: #67c23a; }
  &.danger .num { color: #f56c6c; }
}

.table-card {
  .product-item {
    display: flex;
    gap: 10px;
    align-items: center;
  }
  .product-img {
    width: 44px;
    height: 44px;
    object-fit: cover;
    border-radius: 4px;
  }
  .product-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .product-name {
    font-size: 13px;
    color: #333;
    max-width: 160px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .product-more {
    font-size: 12px;
    color: #999;
  }
  .price {
    color: #f56c6c;
    font-weight: 600;
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
      margin: 0 0 12px 0;
      font-size: 14px;
      color: #333;
      padding-left: 8px;
      border-left: 3px solid #409eff;
    }
  }

  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px 20px;
  }

  .detail-row {
    display: flex;
    font-size: 13px;

    &.full { grid-column: span 2; }

    .label { color: #999; width: 80px; flex-shrink: 0; }
  }

  .mono { font-family: monospace; color: #666; }

  .discount { color: #f56c6c; }
  .total-price { color: #f56c6c; font-size: 16px; font-weight: bold; }

  .detail-product {
    display: flex;
    gap: 12px;
    padding: 10px 0;
    border-bottom: 1px dashed #f0f0f0;

    &:last-child { border-bottom: none; }
  }

  .detail-img {
    width: 56px;
    height: 56px;
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

  .detail-product-price {
    font-size: 13px;
    color: #666;

    .subtotal {
      float: right;
      color: #f56c6c;
    }
  }
}
</style>
