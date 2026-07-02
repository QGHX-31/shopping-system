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
        <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width: 120px">
          <el-option label="未启用" :value="0" />
          <el-option label="已启用" :value="1" />
        </el-select>
        <el-select v-model="levelFilter" placeholder="层级筛选" clearable style="width: 120px">
          <el-option label="平台券" :value="1" />
          <el-option label="店铺券" :value="2" />
          <el-option label="单品券" :value="3" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="openAddDialog">新增模板</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="couponList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="优惠券名称" prop="name" min-width="180" />
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag size="small" :type="getTypeTagType(row.type)">
              {{ getTypeText(row.type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="面值" width="120" align="center">
          <template #default="{ row }">
            <span class="coupon-value">
              <template v-if="row.type === 1">¥{{ row.discountAmount }}</template>
              <template v-else-if="row.type === 2">{{ formatDiscountRate(row.discountAmount) }}折</template>
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
            {{ getScopeText(row.scopeType) }}
          </template>
        </el-table-column>
        <el-table-column label="层级" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="getLevelTagType(row.couponLevel)">
              {{ getLevelText(row.couponLevel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="发放总量" prop="totalCount" width="90" align="center" />
        <el-table-column label="已领取" width="90" align="center">
          <template #default="{ row }">{{ getUsedCount(row) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row)" size="small">
              {{ getStatusText(row) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link @click="openEditDialog(row)">编辑</el-button>
            <el-button size="small" :type="row.status === 1 ? 'warning' : 'success'" link @click="toggleStatus(row)">
              {{ row.status === 1 ? '停用' : '启用' }}
            </el-button>
            <el-button size="small" type="danger" link @click="handleDelete(row)">删除</el-button>
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

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑优惠券' : '新增优惠券'" width="650px">
      <el-form :model="form" label-width="120px" ref="formRef">
        <el-form-item label="优惠券名称" required>
          <el-input v-model="form.name" placeholder="请输入优惠券名称" />
        </el-form-item>
        <el-form-item label="优惠券类型" required>
          <el-radio-group v-model="form.type">
            <el-radio :value="1">满减券</el-radio>
            <el-radio :value="2">折扣券</el-radio>
            <el-radio :value="3">免邮券</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item :label="form.type === 2 ? '折扣比例' : '优惠金额'" required>
          <template v-if="form.type === 1">
            <el-input-number v-model="form.discountAmount" :min="1" :step="10" />
            <span style="margin-left: 8px; color: #999;">元</span>
          </template>
          <template v-else-if="form.type === 2">
            <el-input-number v-model="discountRateInput" :min="1" :max="9.9" :step="0.1" :precision="1" />
            <span style="margin-left: 8px; color: #999;">折（如 8 表示8折）</span>
          </template>
          <template v-else>
            <el-input-number v-model="form.discountAmount" :min="0" :step="1" />
            <span style="margin-left: 8px; color: #999;">元（免邮券填写运费金额）</span>
          </template>
        </el-form-item>
        <el-form-item label="使用门槛" required>
          <el-input-number v-model="form.minAmount" :min="0" :step="50" />
          <span style="margin-left: 8px; color: #999;">元，0表示无门槛</span>
        </el-form-item>
        <el-form-item label="发放总量" required>
          <el-input-number v-model="form.totalCount" :min="1" :step="100" />
          <span style="margin-left: 8px; color: #999;">张</span>
        </el-form-item>
        <el-form-item label="每人限领">
          <el-input-number v-model="form.perUserLimit" :min="1" :max="10" />
          <span style="margin-left: 8px; color: #999;">张</span>
        </el-form-item>
        <el-form-item label="优惠券层级" required>
          <el-radio-group v-model="form.couponLevel">
            <el-radio :value="1">平台券</el-radio>
            <el-radio :value="2">店铺券</el-radio>
            <el-radio :value="3">单品券</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="适用范围类型" required>
          <el-radio-group v-model="form.scopeType">
            <el-radio :value="1">全场通用</el-radio>
            <el-radio :value="2">指定店铺</el-radio>
            <el-radio :value="4">指定分类</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="有效期" required>
          <el-date-picker
            v-model="dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="使用说明">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入使用说明" />
        </el-form-item>
        <el-form-item label="用户类型">
          <el-radio-group v-model="form.userType">
            <el-radio :value="0">全部用户</el-radio>
            <el-radio :value="1">新用户专享</el-radio>
            <el-radio :value="2">会员专享</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="叠加规则">
          <el-radio-group v-model="form.mutuallyExclusive">
            <el-radio :value="0">可叠加</el-radio>
            <el-radio :value="1">同层互斥</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="0">未启用</el-radio>
            <el-radio :value="1">已启用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitForm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance } from 'element-plus'
import request from '@/utils/request'

const searchKeyword = ref('')
const typeFilter = ref<number | null>(null)
const statusFilter = ref<number | null>(null)
const levelFilter = ref<number | null>(null)
const couponList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const isEdit = ref(false)
const editId = ref<number | null>(null)
const formRef = ref<FormInstance>()
const dateRange = ref<any[]>([])
const discountRateInput = ref(8)

const form = ref<any>({
  name: '',
  type: 1,
  discountAmount: 10,
  minAmount: 100,
  totalCount: 1000,
  perUserLimit: 1,
  couponLevel: 1,
  scopeType: 1,
  description: '',
  userType: 0,
  mutuallyExclusive: 1,
  status: 0
})

function getTypeText(type: number) {
  const types: Record<number, string> = { 1: '满减券', 2: '折扣券', 3: '免邮券' }
  return types[type] || '优惠券'
}

function getTypeTagType(type: number) {
  const types: Record<number, string> = { 1: 'warning', 2: 'success', 3: 'info' }
  return types[type] || 'info'
}

function formatDiscountRate(rate: number) {
  if (!rate) return 0
  return Math.round(rate * 10) / 10
}

function getScopeText(scope: number) {
  const scopes: Record<number, string> = { 1: '全场通用', 2: '指定店铺', 3: '指定商品', 4: '指定分类' }
  return scopes[scope] || '全场通用'
}

function getLevelText(level: number) {
  const levels: Record<number, string> = { 1: '平台券', 2: '店铺券', 3: '单品券' }
  return levels[level] || '平台券'
}

function getLevelTagType(level: number) {
  const types: Record<number, string> = { 1: '', 2: 'warning', 3: 'danger' }
  return types[level] || ''
}

function formatDate(s: string) {
  if (!s) return '—'
  return s.replace('T', ' ').slice(0, 16)
}

function getStatusType(row: any) {
  if (row.status === 0) return 'info'
  const now = new Date()
  const start = new Date(row.startTime)
  const end = new Date(row.endTime)
  if (now < start) return 'warning'
  if (now > end) return 'info'
  return 'success'
}

function getStatusText(row: any) {
  if (row.status === 0) return '未启用'
  const now = new Date()
  const start = new Date(row.startTime)
  const end = new Date(row.endTime)
  if (now < start) return '未开始'
  if (now > end) return '已结束'
  return '进行中'
}

function getUsedCount(row: any) {
  if (row.totalCount != null && row.remainingCount != null) {
    return row.totalCount - row.remainingCount
  }
  return row.usedCount || 0
}

async function loadCoupons() {
  loading.value = true
  try {
    const params: any = {
      page: page.value,
      size: pageSize.value
    }
    if (searchKeyword.value) params.name = searchKeyword.value
    if (typeFilter.value != null) params.type = typeFilter.value
    if (statusFilter.value != null) params.status = statusFilter.value
    if (levelFilter.value != null) params.couponLevel = levelFilter.value

    const res = await request.get('/admin/coupon/list', { params })
    couponList.value = res.data?.list || []
    total.value = res.data?.total || 0
  } catch (e: any) {
    console.error('加载优惠券失败', e)
    ElMessage.error(e?.message || '加载失败')
    couponList.value = []
    total.value = 0
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
  loadCoupons()
}

function openAddDialog() {
  isEdit.value = false
  editId.value = null
  form.value = {
    name: '',
    type: 1,
    discountAmount: 10,
    minAmount: 100,
    totalCount: 1000,
    perUserLimit: 1,
    couponLevel: 1,
    scopeType: 1,
    description: '',
    userType: 0,
    mutuallyExclusive: 1,
    status: 0
  }
  dateRange.value = []
  discountRateInput.value = 8
  dialogVisible.value = true
}

function openEditDialog(row: any) {
  isEdit.value = true
  editId.value = row.id
  form.value = {
    ...row
  }
  if (row.type === 2 && row.discountAmount) {
    discountRateInput.value = Math.round(row.discountAmount * 10) / 10
  } else {
    discountRateInput.value = 8
  }
  if (row.startTime && row.endTime) {
    dateRange.value = [new Date(row.startTime), new Date(row.endTime)]
  } else {
    dateRange.value = []
  }
  dialogVisible.value = true
}

async function toggleStatus(row: any) {
  const newStatus = row.status === 1 ? 0 : 1
  const actionText = newStatus === 1 ? '启用' : '停用'
  try {
    await ElMessageBox.confirm(`确定要${actionText}该优惠券吗？`, '提示', {
      type: 'warning'
    })
  } catch {
    return
  }
  try {
    await request.put(`/admin/coupon/status/${row.id}`, null, { params: { status: newStatus } })
    ElMessage.success(`${actionText}成功`)
    loadCoupons()
  } catch (e: any) {
    ElMessage.error(e?.message || `${actionText}失败`)
  }
}

async function handleDelete(row: any) {
  try {
    await ElMessageBox.confirm('确定要删除该优惠券吗？删除后不可恢复！', '警告', {
      type: 'warning',
      confirmButtonText: '删除',
      cancelButtonText: '取消'
    })
  } catch {
    return
  }
  try {
    await request.delete(`/admin/coupon/delete/${row.id}`)
    ElMessage.success('删除成功')
    loadCoupons()
  } catch (e: any) {
    ElMessage.error(e?.message || '删除失败')
  }
}

async function submitForm() {
  if (!form.value.name) {
    ElMessage.warning('请输入优惠券名称')
    return
  }
  if (!dateRange.value || dateRange.value.length !== 2) {
    ElMessage.warning('请选择有效期')
    return
  }
  if (form.value.type === 2) {
    form.value.discountAmount = discountRateInput.value / 10
  }
  if (form.value.type === 3 && form.value.discountAmount == null) {
    form.value.discountAmount = 0
  }

  const data = {
    ...form.value,
    startTime: dateRange.value[0],
    endTime: dateRange.value[1]
  }

  try {
    if (isEdit.value && editId.value) {
      await request.put(`/admin/coupon/update/${editId.value}`, data)
      ElMessage.success('更新成功')
    } else {
      await request.post('/admin/coupon/create', data)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadCoupons()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
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
