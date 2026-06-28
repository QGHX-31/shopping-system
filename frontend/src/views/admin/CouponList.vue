<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>优惠券模板</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索优惠券名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-select v-model="typeFilter" placeholder="类型筛选" clearable style="width: 120px">
          <el-option label="满减券" :value="1" />
          <el-option label="折扣券" :value="2" />
          <el-option label="免邮券" :value="3" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增模板</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="couponList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="优惠券名称" prop="name" min-width="180" />
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="row.type === 2 ? 'success' : 'warning'">
              {{ getTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="面值" width="120" align="center">
          <template #default="{ row }">
            <span class="coupon-value">
              <template v-if="row.type === 1">¥{{ row.discountAmount }}</template>
              <template v-else-if="row.type === 2">{{ row.discountRate }}折</template>
              <template v-else>免邮</template>
            </span>
          </template>
        </el-table-column>
        <el-table-column label="使用门槛" width="120" align="center">
          <template #default="{ row }">满{{ row.minAmount }}元可用</template>
        </el-table-column>
        <el-table-column label="有效期" width="220">
          <template #default="{ row }">
            <span>{{ formatDate(row.startTime) }} ~ {{ formatDate(row.endTime) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="适用范围" width="100">
          <template #default="{ row }">
            {{ row.scope === 0 ? '全场通用' : row.scope === 1 ? '指定分类' : '指定商品' }}
          </template>
        </el-table-column>
        <el-table-column label="发放总量" prop="totalCount" width="100" align="center" />
        <el-table-column label="已领取" prop="usedCount" width="90" align="center" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row)" size="small">
              {{ getStatusText(row) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>编辑</el-button>
            <el-button size="small" type="danger" link>删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && couponList.length === 0" description="暂无优惠券" />
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const searchKeyword = ref('')
const typeFilter = ref<number | null>(null)
const couponList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

function getTypeText(type: number) {
  const types: Record<number, string> = {
    1: '满减券', 2: '折扣券', 3: '免邮券'
  }
  return types[type] || '优惠券'
}

function formatDate(s: string) {
  return s ? s.replace('T', ' ').slice(0, 10) : '—'
}

function getStatusType(row: any) {
  const now = new Date()
  const start = new Date(row.startTime)
  const end = new Date(row.endTime)
  if (now < start) return 'info'
  if (now > end) return 'info'
  return 'success'
}

function getStatusText(row: any) {
  const now = new Date()
  const start = new Date(row.startTime)
  const end = new Date(row.endTime)
  if (now < start) return '未开始'
  if (now > end) return '已结束'
  return '进行中'
}

async function loadCoupons() {
  loading.value = true
  try {
    const list = [
      { id: 1, name: '新人专享满减券', type: 1, discountAmount: 20, discountRate: 0, minAmount: 100, startTime: '2026-06-01', endTime: '2026-07-31', scope: 0, totalCount: 10000, usedCount: 3520 },
      { id: 2, name: '618全场8折券', type: 2, discountAmount: 0, discountRate: 8, minAmount: 200, startTime: '2026-06-18', endTime: '2026-06-20', scope: 0, totalCount: 50000, usedCount: 42310 },
      { id: 3, name: '手机品类券', type: 1, discountAmount: 100, discountRate: 0, minAmount: 2000, startTime: '2026-06-01', endTime: '2026-06-30', scope: 1, totalCount: 2000, usedCount: 856 },
      { id: 4, name: '免邮福利券', type: 3, discountAmount: 0, discountRate: 0, minAmount: 50, startTime: '2026-06-01', endTime: '2026-12-31', scope: 0, totalCount: 100000, usedCount: 28900 },
      { id: 5, name: '会员专享9折', type: 2, discountAmount: 0, discountRate: 9, minAmount: 100, startTime: '2026-01-01', endTime: '2026-12-31', scope: 0, totalCount: 8000, usedCount: 5230 }
    ]
    couponList.value = list
    total.value = list.length
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadCoupons()
}

function handlePageChange(val: number) {
  page.value = val
}

function handleAdd() {
  ElMessage.info('新增优惠券功能开发中')
}

onMounted(() => {
  loadCoupons()
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

.coupon-value {
  color: #f56c6c;
  font-weight: bold;
  font-size: 16px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
