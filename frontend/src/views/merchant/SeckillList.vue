<template>
  <div class="seckill-list">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="平台活动" name="templates">
        <div class="toolbar">
          <el-input v-model="searchKeyword" placeholder="搜索活动名称" style="width: 240px;" clearable />
          <el-button type="primary" @click="loadTemplates">查询</el-button>
        </div>
        <el-table :data="templateList" border>
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="name" label="活动名称" min-width="180" />
          <el-table-column prop="startTime" label="开始时间" width="180" />
          <el-table-column prop="endTime" label="结束时间" width="180" />
          <el-table-column prop="limitPerUser" label="每人限购" width="100" />
          <el-table-column label="操作" width="120">
            <template #default="scope">
              <el-button size="small" type="primary" @click="openJoinDialog(scope.row)">报名参加</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="我的报名" name="mine">
        <div class="toolbar">
          <el-select v-model="statusFilter" placeholder="报名状态" style="width: 160px;" clearable>
            <el-option label="待审核" :value="1" />
            <el-option label="已通过" :value="2" />
            <el-option label="已拒绝" :value="0" />
          </el-select>
          <el-button type="primary" @click="loadMine">查询</el-button>
        </div>
        <el-table :data="mineList" border>
          <el-table-column prop="id" label="ID" width="80" />
          <el-table-column prop="templateId" label="活动ID" width="100" />
          <el-table-column prop="productId" label="商品ID" width="100" />
          <el-table-column prop="seckillPrice" label="秒杀价" width="120" />
          <el-table-column prop="originalPrice" label="原价" width="120" />
          <el-table-column prop="availableStock" label="可用库存" width="100" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag :type="getStatusType(scope.row.status)">
                {{ getStatusText(scope.row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createdAt" label="报名时间" width="180" />
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="showJoinDialog" title="报名秒杀活动" width="600px">
      <el-form :model="joinForm" label-width="100px">
        <el-form-item label="活动名称">
          <span>{{ currentTemplate?.name }}</span>
        </el-form-item>
        <el-form-item label="选择商品">
          <el-select v-model="joinForm.productId" filterable placeholder="请选择商品" style="width: 100%;">
            <el-option
              v-for="p in productList"
              :key="p.id"
              :label="p.name"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="秒杀价">
          <el-input v-model="joinForm.seckillPrice" type="number" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input v-model="joinForm.originalPrice" type="number" />
        </el-form-item>
        <el-form-item label="总库存">
          <el-input v-model="joinForm.totalStock" type="number" />
        </el-form-item>
        <el-form-item label="每人限购">
          <el-input v-model="joinForm.limitPerUser" type="number" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showJoinDialog = false">取消</el-button>
        <el-button type="primary" @click="submitJoin">提交报名</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'
import { useMerchantStore } from '@/stores/merchant'

const merchantStore = useMerchantStore()
const merchantId = ref(Number(localStorage.getItem('merchant_id') || 0))

const activeTab = ref('templates')
const searchKeyword = ref('')
const statusFilter = ref<number | ''>('')
const templateList = ref<any[]>([])
const mineList = ref<any[]>([])
const productList = ref<any[]>([])
const showJoinDialog = ref(false)
const currentTemplate = ref<any>(null)

const joinForm = reactive({
  templateId: 0,
  merchantId: 0,
  productId: 0,
  skuId: null as number | null,
  seckillPrice: 0,
  originalPrice: 0,
  totalStock: 0,
  availableStock: 0,
  limitPerUser: 1
})

function getStatusType(status: number) {
  const types: Record<number, string> = { 0: 'danger', 1: 'warning', 2: 'success' }
  return types[status] || 'info'
}

function getStatusText(status: number) {
  const texts: Record<number, string> = { 0: '已拒绝', 1: '待审核', 2: '已通过' }
  return texts[status] || '未知'
}

async function loadTemplates() {
  try {
    const res = await request.get('/activity/merchant/seckill/templates')
    let list = res.data || []
    if (searchKeyword.value) {
      list = list.filter((t: any) => t.name.includes(searchKeyword.value))
    }
    templateList.value = list
  } catch (e) {
    console.error('加载平台活动失败', e)
  }
}

async function loadMine() {
  try {
    const res = await request.get(`/activity/merchant/seckill/list/${merchantId.value}`)
    let list = res.data || []
    if (statusFilter.value !== '') {
      list = list.filter((t: any) => t.status === statusFilter.value)
    }
    mineList.value = list
  } catch (e) {
    console.error('加载我的报名失败', e)
  }
}

async function loadProducts() {
  try {
    const res = await request.get('/merchant/product/list', {
      params: { merchantId: merchantId.value, page: 1, size: 100 }
    })
    productList.value = res.data.list || res.data || []
  } catch (e) {
    console.error('加载商品列表失败', e)
  }
}

function handleTabChange() {
  if (activeTab.value === 'templates') {
    loadTemplates()
  } else {
    loadMine()
  }
}

function openJoinDialog(template: any) {
  currentTemplate.value = template
  joinForm.templateId = template.id
  joinForm.merchantId = merchantId.value
  joinForm.productId = 0
  joinForm.seckillPrice = 0
  joinForm.originalPrice = 0
  joinForm.totalStock = 0
  joinForm.availableStock = 0
  joinForm.limitPerUser = template.limitPerUser || 1
  loadProducts()
  showJoinDialog.value = true
}

async function submitJoin() {
  if (!joinForm.productId) {
    ElMessage.warning('请选择商品')
    return
  }
  joinForm.availableStock = joinForm.totalStock
  try {
    await request.post('/activity/merchant/seckill/join', joinForm)
    ElMessage.success('报名成功，等待审核')
    showJoinDialog.value = false
    loadMine()
  } catch (e) {
    ElMessage.error('报名失败')
  }
}

onMounted(() => {
  loadTemplates()
})
</script>

<style lang="scss" scoped>
.seckill-list {
  padding: 20px;
}

.toolbar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}
</style>
