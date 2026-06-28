<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>商家管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索店铺名称/联系人" clearable style="width: 220px" @keyup.enter="handleSearch" />
        <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width: 120px">
          <el-option label="正常" :value="1" />
          <el-option label="待审核" :value="2" />
          <el-option label="已禁用" :value="0" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="merchantList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="店铺logo" width="80">
          <template #default="{ row }">
            <el-avatar :src="row.logo || defaultLogo" :size="40" />
          </template>
        </el-table-column>
        <el-table-column label="店铺名称" prop="shopName" min-width="160" show-overflow-tooltip />
        <el-table-column label="联系人" prop="contactName" width="100" />
        <el-table-column label="联系电话" prop="contactPhone" width="130" />
        <el-table-column label="店铺等级" width="100" align="center">
          <template #default="{ row }">
            <el-rate :model-value="row.level || 1" disabled show-text size="small" />
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="入驻时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>查看</el-button>
            <el-button v-if="row.status === 2" size="small" type="success" link @click="audit(row, 1)">通过</el-button>
            <el-button v-if="row.status === 2" size="small" type="danger" link @click="audit(row, 0)">拒绝</el-button>
            <el-button v-if="row.status === 1" size="small" type="warning" link @click="toggleDisable(row)">禁用</el-button>
            <el-button v-if="row.status === 0" size="small" type="success" link @click="toggleDisable(row)">启用</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && merchantList.length === 0" description="暂无商家" />
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
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '@/utils/request'

const defaultLogo = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const searchKeyword = ref('')
const statusFilter = ref<number | null>(null)
const merchantList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '已禁用', 1: '正常', 2: '待审核'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'info', 1: 'success', 2: 'warning'
  }
  return types[status] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadMerchants() {
  loading.value = true
  try {
    const res = await request.get('/merchant/list', {
      params: {
        keyword: searchKeyword.value || undefined,
        status: statusFilter.value ?? undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    const list = (res.data?.list || res.data?.records || []) as any[]
    merchantList.value = list
    total.value = res.data?.total || list.length
  } catch (e) {
    console.error('加载商家失败', e)
    merchantList.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadMerchants()
}

function handlePageChange(val: number) {
  page.value = val
  loadMerchants()
}

async function audit(row: any, status: number) {
  const action = status === 1 ? '通过' : '拒绝'
  try {
    await ElMessageBox.confirm(`确定要${action}该商家入驻申请吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.put(`/merchant/${row.id}/status`, null, {
      params: { status: status }
    })
    ElMessage.success(`审核${action}`)
    loadMerchants()
  } catch { /* canceled */ }
}

async function toggleDisable(row: any) {
  const action = row.status === 1 ? '禁用' : '启用'
  const newStatus = row.status === 1 ? 0 : 1
  try {
    await ElMessageBox.confirm(`确定要${action}该商家吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.put(`/merchant/${row.id}/status`, null, {
      params: { status: newStatus }
    })
    ElMessage.success(`已${action}`)
    loadMerchants()
  } catch { /* canceled */ }
}

onMounted(() => {
  loadMerchants()
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

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
