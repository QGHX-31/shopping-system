<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>换货管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索换货单号/订单号" clearable style="width: 220px" @keyup.enter="handleSearch" />
        <el-select v-model="exchangeStatus" placeholder="状态筛选" clearable style="width: 140px">
          <el-option label="待审核" :value="0" />
          <el-option label="待退货" :value="1" />
          <el-option label="已拒绝" :value="2" />
          <el-option label="已完成" :value="3" />
          <el-option label="已取消" :value="4" />
          <el-option label="退货中" :value="5" />
          <el-option label="待发货" :value="6" />
          <el-option label="已发货" :value="7" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="stats-row">
      <div class="stat-mini">
        <span class="num">{{ totalCount }}</span>
        <span class="label">全部换货</span>
      </div>
      <div class="stat-mini warning">
        <span class="num">{{ pendingCount }}</span>
        <span class="label">待审核</span>
      </div>
      <div class="stat-mini primary">
        <span class="num">{{ processingCount }}</span>
        <span class="label">处理中</span>
      </div>
      <div class="stat-mini success">
        <span class="num">{{ completedCount }}</span>
        <span class="label">已完成</span>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="exchangeList" v-loading="loading" border>
        <el-table-column label="换货单号" prop="exchangeNo" width="200" />
        <el-table-column label="订单号" prop="orderId" width="180">
          <template #default="{ row }">
            <span class="link-text">{{ row.orderId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="商家ID" prop="merchantId" width="100" />
        <el-table-column label="原商品" min-width="180">
          <template #default="{ row }">
            <div class="product-cell">
              <span>{{ row.originalProductName }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="新商品" min-width="180">
          <template #default="{ row }">
            <div class="product-cell">
              <span>{{ row.newProductName }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="价格差异" width="110" align="right">
          <template #default="{ row }">
            <span :class="['price-diff', getDiffClass(row)]">
              {{ formatPriceDiff(row) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.applyTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && exchangeList.length === 0" description="暂无换货申请" />
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

    <el-dialog v-model="detailVisible" title="换货详情" width="650px">
      <div v-if="currentExchange" class="exchange-detail">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="换货单号">{{ currentExchange.exchangeNo }}</el-descriptions-item>
          <el-descriptions-item label="订单ID">{{ currentExchange.orderId }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ currentExchange.userId }}</el-descriptions-item>
          <el-descriptions-item label="商家ID">{{ currentExchange.merchantId }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusTagType(currentExchange.status)" size="small">
              {{ getStatusText(currentExchange.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ formatTime(currentExchange.applyTime) }}</el-descriptions-item>
          <el-descriptions-item label="换货原因" :span="2">{{ currentExchange.exchangeReason || '—' }}</el-descriptions-item>
        </el-descriptions>

        <div class="compare-section">
          <h4>商品对比</h4>
          <div class="product-compare">
            <div class="compare-item">
              <div class="compare-title">原商品</div>
              <div class="product-name">{{ currentExchange.originalProductName }}</div>
              <div v-if="currentExchange.originalSpecValues" class="product-spec">{{ currentExchange.originalSpecValues }}</div>
              <div class="product-price">¥{{ Number(currentExchange.originalPrice || 0).toFixed(2) }}</div>
              <div class="product-qty">数量：{{ currentExchange.originalQuantity }}</div>
            </div>
            <div class="compare-arrow">→</div>
            <div class="compare-item">
              <div class="compare-title">新商品</div>
              <div class="product-name">{{ currentExchange.newProductName }}</div>
              <div v-if="currentExchange.newSpecValues" class="product-spec">{{ currentExchange.newSpecValues }}</div>
              <div class="product-price">¥{{ Number(currentExchange.newPrice || 0).toFixed(2) }}</div>
              <div class="product-qty">数量：{{ currentExchange.newQuantity }}</div>
            </div>
          </div>
          <div class="price-diff-row">
            价格差异：
            <span :class="['price-diff', getDiffClass(currentExchange)]">
              {{ formatPriceDiff(currentExchange) }}
            </span>
          </div>
        </div>

        <div v-if="currentExchange.returnLogisticsCompany" class="logistics-section">
          <h4>退货物流</h4>
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="物流公司">{{ currentExchange.returnLogisticsCompany }}</el-descriptions-item>
            <el-descriptions-item label="物流单号">{{ currentExchange.returnTrackingNo }}</el-descriptions-item>
            <el-descriptions-item v-if="currentExchange.returnShipTime" label="发货时间">{{ formatTime(currentExchange.returnShipTime) }}</el-descriptions-item>
            <el-descriptions-item v-if="currentExchange.returnReceiveTime" label="收货时间">{{ formatTime(currentExchange.returnReceiveTime) }}</el-descriptions-item>
          </el-descriptions>
        </div>

        <div v-if="currentExchange.exchangeLogisticsCompany" class="logistics-section">
          <h4>换货物流</h4>
          <el-descriptions :column="2" border size="small">
            <el-descriptions-item label="物流公司">{{ currentExchange.exchangeLogisticsCompany }}</el-descriptions-item>
            <el-descriptions-item label="物流单号">{{ currentExchange.exchangeTrackingNo }}</el-descriptions-item>
            <el-descriptions-item v-if="currentExchange.exchangeShipTime" label="发货时间">{{ formatTime(currentExchange.exchangeShipTime) }}</el-descriptions-item>
          </el-descriptions>
        </div>

        <div v-if="currentExchange.merchantRemark" class="remark-section">
          <h4>商家备注</h4>
          <p>{{ currentExchange.merchantRemark }}</p>
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

const searchKeyword = ref('')
const exchangeStatus = ref<number | null>(null)
const exchangeList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const totalCount = ref(0)
const pendingCount = ref(0)
const processingCount = ref(0)
const completedCount = ref(0)

const detailVisible = ref(false)
const currentExchange = ref<any>(null)

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待审核', 1: '待退货', 2: '已拒绝', 3: '已完成',
    4: '已取消', 5: '退货中', 6: '待发货', 7: '已发货'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning', 1: 'primary', 2: 'danger', 3: 'success',
    4: 'info', 5: 'warning', 6: 'primary', 7: 'success'
  }
  return types[status] || 'info'
}

function formatPriceDiff(row: any) {
  const diff = Number(row.priceDifference || 0)
  if (diff > 0) return `+¥${diff.toFixed(2)}`
  if (diff < 0) return `-¥${Math.abs(diff).toFixed(2)}`
  return '¥0.00'
}

function getDiffClass(row: any) {
  const diff = Number(row.priceDifference || 0)
  if (diff > 0) return 'diff-positive'
  if (diff < 0) return 'diff-negative'
  return 'diff-zero'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadExchanges() {
  loading.value = true
  try {
    const res = await request.get('/admin/order/exchange/list', {
      params: {
        status: exchangeStatus.value ?? undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    total.value = res.data?.total || 0

    if (searchKeyword.value) {
      list = list.filter(item =>
        item.exchangeNo?.includes(searchKeyword.value) ||
        String(item.orderId || '').includes(searchKeyword.value)
      )
      total.value = list.length
    }

    exchangeList.value = list
  } catch (e) {
    console.error('加载换货列表失败', e)
    exchangeList.value = []
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    const allRes = await request.get('/admin/order/exchange/list', { params: { page: 1, size: 10000 } })
    const all = allRes.data?.list || allRes.data?.records || []
    totalCount.value = allRes.data?.total || all.length
    pendingCount.value = all.filter((r: any) => r.status === 0).length
    processingCount.value = all.filter((r: any) => [1, 5, 6, 7].includes(r.status)).length
    completedCount.value = all.filter((r: any) => r.status === 3).length
  } catch (e) {
    console.error('加载换货统计失败', e)
  }
}

function handleSearch() {
  page.value = 1
  loadExchanges()
}

function handlePageChange(val: number) {
  page.value = val
  loadExchanges()
}

async function viewDetail(row: any) {
  try {
    const res = await request.get(`/admin/order/exchange/detail/${row.id}`)
    currentExchange.value = res.data?.exchange || res.data || row
  } catch (e) {
    currentExchange.value = row
  }
  detailVisible.value = true
}

onMounted(() => {
  loadStats()
  loadExchanges()
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

  .num { display: block; font-size: 24px; font-weight: bold; color: #333; }
  .label { font-size: 13px; color: #999; }
  &.warning .num { color: #e6a23c; }
  &.primary .num { color: #409eff; }
  &.success .num { color: #67c23a; }
  &.danger .num { color: #f56c6c; }
}

.link-text {
  color: #409eff;
  cursor: pointer;
  font-family: monospace;
  font-size: 13px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.price-diff {
  font-weight: 600;
  &.diff-positive { color: #f56c6c; }
  &.diff-negative { color: #67c23a; }
  &.diff-zero { color: #909399; }
}

.exchange-detail {
  .compare-section, .logistics-section, .remark-section {
    margin-top: 20px;
    h4 { margin: 0 0 12px 0; font-size: 15px; color: #333; }
  }

  .product-compare {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 16px;
    background: #f8f9fa;
    border-radius: 8px;

    .compare-item {
      flex: 1;
      text-align: center;
    }

    .compare-title {
      font-weight: bold;
      color: #666;
      margin-bottom: 8px;
    }

    .product-name {
      font-size: 14px;
      color: #333;
      margin-bottom: 4px;
    }

    .product-spec {
      font-size: 12px;
      color: #999;
      margin-bottom: 4px;
    }

    .product-price {
      font-size: 16px;
      font-weight: bold;
      color: #f56c6c;
      margin-bottom: 4px;
    }

    .product-qty {
      font-size: 12px;
      color: #999;
    }

    .compare-arrow {
      font-size: 24px;
      color: #409eff;
      font-weight: bold;
    }
  }

  .price-diff-row {
    text-align: center;
    margin-top: 12px;
    font-size: 14px;
    color: #666;
  }

  .remark-section p {
    margin: 0;
    padding: 12px;
    background: #f8f9fa;
    border-radius: 6px;
    color: #333;
  }
}
</style>
