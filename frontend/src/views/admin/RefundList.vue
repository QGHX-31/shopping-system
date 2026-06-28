<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>退款管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索退款单号/订单号" clearable style="width: 220px" @keyup.enter="handleSearch" />
        <el-select v-model="refundStatus" placeholder="状态筛选" clearable style="width: 140px">
          <el-option label="待审核" :value="0" />
          <el-option label="已同意" :value="1" />
          <el-option label="已拒绝" :value="2" />
          <el-option label="已完成" :value="3" />
          <el-option label="已取消" :value="4" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="stats-row">
      <div class="stat-mini">
        <span class="num">{{ totalCount }}</span>
        <span class="label">全部退款</span>
      </div>
      <div class="stat-mini warning">
        <span class="num">{{ pendingCount }}</span>
        <span class="label">待审核</span>
      </div>
      <div class="stat-mini success">
        <span class="num">{{ approvedCount }}</span>
        <span class="label">已同意</span>
      </div>
      <div class="stat-mini danger">
        <span class="num">{{ rejectedCount }}</span>
        <span class="label">已拒绝</span>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="refundList" v-loading="loading" border>
        <el-table-column label="退款单号" prop="refundNo" width="200" />
        <el-table-column label="订单号" prop="orderId" width="180">
          <template #default="{ row }">
            <span class="link-text">{{ row.orderId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="退款金额" width="120" align="right">
          <template #default="{ row }">
            <span class="price">¥{{ Number(row.refundAmount || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="退款类型" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.refundType === 1 ? 'info' : 'warning'">
              {{ row.refundType === 1 ? '仅退款' : '退货退款' }}
            </el-tag>
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
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" size="small" type="success" @click="approve(row)">同意</el-button>
            <el-button v-if="row.status === 0" size="small" type="danger" @click="reject(row)">拒绝</el-button>
            <el-button size="small" type="primary" link @click="viewDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && refundList.length === 0" description="暂无退款申请" />
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

    <el-dialog v-model="detailVisible" title="退款详情" width="500px">
      <div v-if="currentRefund" class="refund-detail">
        <el-descriptions :column="2" border size="small">
          <el-descriptions-item label="退款单号">{{ currentRefund.refundNo }}</el-descriptions-item>
          <el-descriptions-item label="订单ID">{{ currentRefund.orderId }}</el-descriptions-item>
          <el-descriptions-item label="用户ID">{{ currentRefund.userId }}</el-descriptions-item>
          <el-descriptions-item label="退款金额" class="price">¥{{ Number(currentRefund.refundAmount).toFixed(2) }}</el-descriptions-item>
          <el-descriptions-item label="退款类型">
            {{ currentRefund.refundType === 1 ? '仅退款' : '退货退款' }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusTagType(currentRefund.status)" size="small">
              {{ getStatusText(currentRefund.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="申请时间" :span="2">{{ formatTime(currentRefund.applyTime) }}</el-descriptions-item>
          <el-descriptions-item label="退款原因" :span="2">{{ currentRefund.refundReason || '—' }}</el-descriptions-item>
          <el-descriptions-item v-if="currentRefund.merchantRemark" label="商家备注" :span="2">
            {{ currentRefund.merchantRemark }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="rejectVisible" title="拒绝退款" width="400px">
      <el-input v-model="rejectRemark" type="textarea" :rows="4" placeholder="请输入拒绝原因" />
      <template #footer>
        <el-button @click="rejectVisible = false">取消</el-button>
        <el-button type="danger" @click="confirmReject">确认拒绝</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const searchKeyword = ref('')
const refundStatus = ref<number | null>(null)
const refundList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const totalCount = ref(0)
const pendingCount = ref(0)
const approvedCount = ref(0)
const rejectedCount = ref(0)

const detailVisible = ref(false)
const currentRefund = ref<any>(null)
const rejectVisible = ref(false)
const rejectRemark = ref('')

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待审核', 1: '已同意', 2: '已拒绝', 3: '已完成', 4: '已取消'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning', 1: 'success', 2: 'danger', 3: 'success', 4: 'info'
  }
  return types[status] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadRefunds() {
  loading.value = true
  try {
    const res = await request.get('/admin/order/refund/list', {
      params: {
        status: refundStatus.value ?? undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    total.value = res.data?.total || 0

    if (searchKeyword.value) {
      list = list.filter(item =>
        item.refundNo?.includes(searchKeyword.value) ||
        String(item.orderId || '').includes(searchKeyword.value)
      )
      total.value = list.length
    }

    refundList.value = list
  } catch (e) {
    console.error('加载退款列表失败', e)
    refundList.value = []
  } finally {
    loading.value = false
  }
}

async function loadStats() {
  try {
    const allRes = await request.get('/admin/order/refund/list', { params: { page: 1, size: 10000 } })
    const all = allRes.data?.list || allRes.data?.records || []
    totalCount.value = allRes.data?.total || all.length
    pendingCount.value = all.filter((r: any) => r.status === 0).length
    approvedCount.value = all.filter((r: any) => r.status === 1 || r.status === 3).length
    rejectedCount.value = all.filter((r: any) => r.status === 2).length
  } catch (e) {
    console.error('加载退款统计失败', e)
  }
}

function handleSearch() {
  page.value = 1
  loadRefunds()
}

function handlePageChange(val: number) {
  page.value = val
  loadRefunds()
}

async function approve(row: any) {
  try {
    await ElMessageBox.confirm('确定同意该退款申请吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.post('/admin/order/refund/audit', null, {
      params: { refundId: row.id, approve: true }
    })
    ElMessage.success('审核通过')
    loadRefunds()
    loadStats()
  } catch { /* canceled */ }
}

function reject(row: any) {
  currentRefund.value = row
  rejectRemark.value = ''
  rejectVisible.value = true
}

async function confirmReject() {
  if (!rejectRemark.value.trim()) {
    ElMessage.warning('请输入拒绝原因')
    return
  }
  try {
    await request.post('/admin/order/refund/audit', null, {
      params: { refundId: currentRefund.value.id, approve: false, remark: rejectRemark.value }
    })
    ElMessage.success('已拒绝')
    rejectVisible.value = false
    loadRefunds()
    loadStats()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

function viewDetail(row: any) {
  currentRefund.value = row
  detailVisible.value = true
}

onMounted(() => {
  loadStats()
  loadRefunds()
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
  &.success .num { color: #67c23a; }
  &.danger .num { color: #f56c6c; }
}

.price { color: #f56c6c; font-weight: 600; }

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

.refund-detail {
  .price {
    color: #f56c6c;
    font-weight: 600;
    font-size: 16px;
  }
}
</style>
