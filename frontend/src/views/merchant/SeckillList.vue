<template>
  <div class="seckill-page">
    <div class="page-header">
      <h2>秒杀活动管理</h2>
      <el-button type="success" @click="openCreateDialog">创建秒杀活动</el-button>
    </div>

    <el-table :data="tableData" border style="width: 100%;">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="活动名称" />
      <el-table-column prop="productName" label="商品" />
      <el-table-column prop="seckillPrice" label="秒杀价" width="100" />
      <el-table-column prop="originalPrice" label="原价" width="100" />
      <el-table-column prop="totalStock" label="总库存" width="100" />
      <el-table-column prop="availableStock" label="剩余库存" width="100" />
      <el-table-column prop="startTime" label="开始时间" width="180" />
      <el-table-column prop="endTime" label="结束时间" width="180" />
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="getStatusType(scope.row.status)">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="200">
        <template #default="scope">
          <el-button size="small" @click="editActivity(scope.row)">编辑</el-button>
          <el-button size="small" :type="scope.row.status === 1 ? 'warning' : 'primary'" @click="toggleStatus(scope.row)">
            {{ scope.row.status === 1 ? '暂停' : '开启' }}
          </el-button>
          <el-button size="small" type="danger" @click="deleteActivity(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pagination.page"
      v-model:page-size="pagination.size"
      :total="pagination.total"
      style="margin-top: 20px; text-align: right;"
      @current-change="loadList"
      @size-change="loadList"
    />

    <el-dialog :title="editForm.id ? '编辑秒杀活动' : '创建秒杀活动'" v-model="dialogVisible" width="600px">
      <el-form :model="editForm" label-width="100px">
        <el-form-item label="选择商品">
          <el-select v-model="editForm.productId" filterable placeholder="请选择商品" style="width: 100%;" @change="handleProductChange">
            <el-option v-for="p in productList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="秒杀价">
          <el-input-number v-model="editForm.seckillPrice" :min="0" :precision="2" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input-number v-model="editForm.originalPrice" :min="0" :precision="2" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="总库存">
          <el-input-number v-model="editForm.totalStock" :min="1" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="活动时间">
          <el-date-picker
            v-model="editForm.dateRange"
            type="datetimerange"
            range-separator="至"
            start-placeholder="开始时间"
            end-placeholder="结束时间"
            style="width: 100%;"
          />
        </el-form-item>
        <el-form-item label="活动描述">
          <el-input type="textarea" v-model="editForm.description" placeholder="请输入活动描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveActivity">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { merchantRequest, getMerchantId } from '@/utils/merchantRequest'

const merchantId = getMerchantId()

const tableData = ref<any[]>([])
const productList = ref<any[]>([])
const dialogVisible = ref(false)
const pagination = reactive({
  page: 1,
  size: 10,
  total: 0
})

const editForm = reactive({
  id: null as number | null,
  productId: null as number | null,
  skuId: null as number | null,
  seckillPrice: 0,
  originalPrice: 0,
  totalStock: 0,
  availableStock: 0,
  dateRange: [] as Date[],
  description: ''
})

const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    0: '未开始',
    1: '进行中',
    2: '已结束'
  }
  return map[status] || '未知'
}

const getStatusType = (status: number) => {
  const map: Record<number, string> = {
    0: 'info',
    1: 'success',
    2: 'danger'
  }
  return map[status] || 'info'
}

const loadList = async () => {
  try {
    const res = await merchantRequest.get('/seckill/activity/list', {
      params: {
        merchantId,
        page: pagination.page,
        size: pagination.size
      }
    })
    tableData.value = res.data.list || []
    pagination.total = res.data.total || 0
  } catch (error) {
    console.error('加载秒杀活动列表失败', error)
  }
}

const loadProducts = async () => {
  try {
    const res = await merchantRequest.get('/merchant/product/list', {
      params: {
        merchantId,
        page: 1,
        size: 100
      }
    })
    productList.value = res.data.list || []
  } catch (error) {
    console.error('加载商品列表失败', error)
  }
}

const handleProductChange = async (productId: number) => {
  if (!productId) return
  try {
    const res = await merchantRequest.get(`/product/${productId}`)
    const product = res.data
    if (product) {
      editForm.originalPrice = product.price || 0
    }
  } catch (error) {
    console.error('获取商品信息失败', error)
  }
}

const openCreateDialog = () => {
  editForm.id = null
  editForm.productId = null
  editForm.skuId = null
  editForm.seckillPrice = 0
  editForm.originalPrice = 0
  editForm.totalStock = 0
  editForm.availableStock = 0
  editForm.dateRange = []
  editForm.description = ''
  dialogVisible.value = true
}

const editActivity = async (row: any) => {
  editForm.id = row.id
  editForm.productId = row.productId
  editForm.skuId = row.skuId
  editForm.seckillPrice = row.seckillPrice || row.price
  editForm.originalPrice = row.originalPrice
  editForm.totalStock = row.totalStock
  editForm.availableStock = row.availableStock
  editForm.dateRange = row.startTime && row.endTime ? [new Date(row.startTime), new Date(row.endTime)] : []
  editForm.description = row.description || ''
  dialogVisible.value = true
}

const saveActivity = async () => {
  if (!editForm.productId) {
    ElMessage.warning('请选择商品')
    return
  }
  if (editForm.seckillPrice >= editForm.originalPrice) {
    ElMessage.warning('秒杀价必须低于原价')
    return
  }
  if (!editForm.dateRange || editForm.dateRange.length < 2) {
    ElMessage.warning('请选择活动时间')
    return
  }

  try {
    const productRes = await merchantRequest.get(`/product/${editForm.productId}`)
    const productName = productRes.data?.name || editForm.productId

    const data = {
      name: `${productName} 秒杀活动`,
      merchantId,
      productId: editForm.productId,
      skuId: editForm.skuId,
      seckillPrice: editForm.seckillPrice,
      originalPrice: editForm.originalPrice,
      totalStock: editForm.totalStock,
      availableStock: editForm.totalStock,
      startTime: editForm.dateRange[0]?.toISOString(),
      endTime: editForm.dateRange[1]?.toISOString(),
      description: editForm.description
    }

    if (editForm.id) {
      await merchantRequest.put(`/seckill/activity/update/${editForm.id}`, data)
      ElMessage.success('更新成功')
    } else {
      await merchantRequest.post('/seckill/activity/create', data)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    loadList()
  } catch (error: any) {
    console.error('保存失败', error)
    ElMessage.error('保存失败: ' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

const toggleStatus = async (row: any) => {
  const newStatus = row.status === 1 ? 0 : 1
  try {
    await merchantRequest.put(`/seckill/activity/status/${row.id}`, {}, {
      params: { status: newStatus }
    })
    ElMessage.success('状态更新成功')
    loadList()
  } catch (error) {
    console.error('状态更新失败', error)
    ElMessage.error('状态更新失败')
  }
}

const deleteActivity = async (row: any) => {
  try {
    await ElMessageBox.confirm('确定要删除这个活动吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await merchantRequest.delete(`/seckill/activity/delete/${row.id}`)
    ElMessage.success('删除成功')
    loadList()
  } catch (error) {
    console.error('删除失败', error)
  }
}

onMounted(() => {
  loadList()
  loadProducts()
})
</script>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
</style>