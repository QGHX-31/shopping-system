<template>
  <div class="sku-list">
    <div class="toolbar">
      <el-select v-model="productId" placeholder="选择商品" style="width: 200px;">
        <el-option v-for="p in productList" :key="p.id" :label="p.name" :value="p.id" />
      </el-select>
      <el-button type="primary" @click="loadSkus">查询</el-button>
      <el-button type="success" @click="showAddDialog = true">添加SKU</el-button>
    </div>
    <el-table :data="tableData" border>
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="productId" label="商品ID" width="100" />
      <el-table-column prop="skuCode" label="SKU编码" width="150" />
      <el-table-column prop="specValues" label="规格" width="200" />
      <el-table-column prop="price" label="价格" width="120">
        <template #default="scope">¥{{ scope.row.price }}</template>
      </el-table-column>
      <el-table-column prop="originalPrice" label="原价" width="120">
        <template #default="scope">¥{{ scope.row.originalPrice }}</template>
      </el-table-column>
      <el-table-column prop="stock" label="库存" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.stock < 10 ? 'danger' : 'success'">
            {{ scope.row.stock }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="sales" label="销量" width="100" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.status === 1 ? 'success' : 'danger'">
            {{ scope.row.status === 1 ? '正常' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button size="small" @click="editStock(scope.row)">调整库存</el-button>
          <el-button size="small" type="warning" @click="editSku(scope.row)">编辑</el-button>
          <el-button size="small" type="danger" @click="deleteSku(scope.row)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="pagination">
      <el-pagination
        @current-change="handlePageChange"
        :current-page="page"
        :page-size="size"
        :total="total"
        layout="total, prev, pager, next, jumper"
      />
    </div>
    <el-dialog v-model="showAddDialog" title="添加SKU" width="500px">
      <el-form :model="addForm" label-width="80px">
        <el-form-item label="选择商品">
          <el-select v-model="addForm.productId" placeholder="请选择商品" style="width: 100%;">
            <el-option
              v-for="p in productList"
              :key="p.id"
              :label="p.name"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="SKU编码">
          <el-input v-model="addForm.skuCode" />
        </el-form-item>
        <el-form-item label="规格">
          <el-input v-model="addForm.specValues" placeholder="如：颜色:红色;尺寸:XL" />
        </el-form-item>
        <el-form-item label="价格">
          <el-input v-model="addForm.price" type="number" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input v-model="addForm.originalPrice" type="number" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input v-model="addForm.stock" type="number" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAddDialog = false">取消</el-button>
        <el-button type="primary" @click="addSku">确定</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="showStockDialog" title="调整库存" width="400px">
      <el-form :model="stockForm" label-width="80px">
        <el-form-item label="当前库存">
          <el-input :model-value="editingSku?.stock" disabled />
        </el-form-item>
        <el-form-item label="调整数量">
          <el-input v-model="stockForm.changeAmount" type="number" placeholder="正数增加，负数减少" />
        </el-form-item>
        <el-form-item label="调整后">
          <el-input :model-value="(editingSku?.stock || 0) + (stockForm.changeAmount || 0)" disabled />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showStockDialog = false">取消</el-button>
        <el-button type="primary" @click="saveStock">确定</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="showEditDialog" title="编辑SKU" width="500px">
      <el-form :model="editingSku" label-width="80px">
        <el-form-item label="SKU编码">
          <el-input v-model="editingSku.skuCode" />
        </el-form-item>
        <el-form-item label="规格">
          <el-input v-model="editingSku.specValues" />
        </el-form-item>
        <el-form-item label="价格">
          <el-input v-model="editingSku.price" type="number" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input v-model="editingSku.originalPrice" type="number" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input v-model="editingSku.stock" type="number" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" @click="updateSku">确定</el-button>
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

const productId = ref('')
const page = ref(1)
const size = ref(10)
const total = ref(0)
const tableData = ref<any[]>([])
const productList = ref<any[]>([])
const showAddDialog = ref(false)
const showStockDialog = ref(false)
const showEditDialog = ref(false)
const editingSku = ref<any>(null)

const addForm = reactive({
  productId: null,
  skuCode: '',
  specValues: '',
  price: 0,
  originalPrice: 0,
  stock: 0
})

const stockForm = reactive({
  changeAmount: 0
})

async function loadProducts() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId) return
  try {
    const res = await request.get('/product/merchant/list', { params: { merchantId, page: 1, size: 100 } })
    productList.value = res.data.list || []
  } catch (e) {
    console.error('加载商品列表失败', e)
  }
}

async function loadSkus() {
  try {
    const params: any = { page: page.value, size: size.value }
    const merchantId = merchantStore.merchantInfo?.id
    if (merchantId) params.merchantId = merchantId
    if (productId.value) params.productId = productId.value
    const res = await request.get('/sku/list/all', { params })
    tableData.value = res.data.list
    total.value = res.data.total
  } catch (e) {
    console.error('加载SKU列表失败', e)
  }
}

function handlePageChange(val: number) {
  page.value = val
  loadSkus()
}

async function addSku() {
  if (!addForm.productId) {
    ElMessage.warning('请选择商品')
    return
  }
  try {
    const merchantId = merchantStore.merchantInfo?.id
    await request.post('/sku/add', { ...addForm, merchantId })
    ElMessage.success('添加成功')
    showAddDialog.value = false
    Object.assign(addForm, { productId: null, skuCode: '', specValues: '', price: 0, originalPrice: 0, stock: 0 })
    loadSkus()
  } catch (e) {
    ElMessage.error('添加失败')
  }
}

function editStock(row: any) {
  editingSku.value = row
  stockForm.changeAmount = 0
  showStockDialog.value = true
}

async function saveStock() {
  try {
    await request.put(`/sku/${editingSku.value.id}/stock`, { amount: stockForm.changeAmount })
    editingSku.value.stock += stockForm.changeAmount
    ElMessage.success('库存已更新')
    showStockDialog.value = false
  } catch (e) {
    ElMessage.error('更新失败')
  }
}

function editSku(row: any) {
  editingSku.value = { ...row }
  showEditDialog.value = true
}

async function updateSku() {
  try {
    await request.put(`/sku/${editingSku.value.id}`, editingSku.value)
    ElMessage.success('更新成功')
    showEditDialog.value = false
    loadSkus()
  } catch (e) {
    ElMessage.error('更新失败')
  }
}

async function deleteSku(row: any) {
  if (!confirm(`确定删除SKU「${row.skuCode}」？`)) return
  try {
    await request.delete(`/sku/${row.id}`)
    ElMessage.success('删除成功')
    loadSkus()
  } catch (e) {
    ElMessage.error('删除失败')
  }
}

onMounted(() => {
  loadProducts()
  loadSkus()
})
</script>

<style lang="scss" scoped>
.sku-list {
  padding: 20px;
}

.toolbar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}
</style>