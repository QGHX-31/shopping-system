<template>
  <div class="product-list-page">
    <div class="page-header">
      <h2>商品管理</h2>
      <el-button type="success" @click="goAddProduct">
        <el-icon><Plus /></el-icon>
        <span>新增商品</span>
      </el-button>
    </div>

    <div class="search-bar">
      <el-input v-model="keyword" placeholder="搜索商品名称" clearable style="width: 250px;" @keyup.enter="handleSearch" />
      <el-select v-model="categoryId" placeholder="全部分类" clearable style="width: 160px">
        <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
      </el-select>
      <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width: 120px">
        <el-option label="上架中" :value="1" />
        <el-option label="已下架" :value="0" />
      </el-select>
      <el-button type="primary" @click="handleSearch">搜索</el-button>
    </div>

    <div class="table-card">
      <el-table :data="tableData" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="商品图片" width="80">
          <template #default="{ row }">
            <img :src="row.imageUrl || row.mainImage || defaultImg" class="product-img" />
          </template>
        </el-table-column>
        <el-table-column label="商品名称" prop="name" min-width="220" show-overflow-tooltip />
        <el-table-column label="分类" width="120">
          <template #default="{ row }">
            <span>{{ getCategoryName(row.categoryId) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="价格" width="100" align="right">
          <template #default="{ row }">
            <span class="price">¥{{ Number(row.price || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" prop="stock" width="80" align="center" />
        <el-table-column label="销量" prop="salesCount" width="80" align="center" />
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '上架中' : '已下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link @click="editProduct(row)">编辑</el-button>
            <el-button
              size="small"
              :type="row.status === 1 ? 'warning' : 'success'"
              link
              @click="toggleStatus(row)"
            >
              {{ row.status === 1 ? '下架' : '上架' }}
            </el-button>
            <el-button size="small" type="danger" link @click="deleteProduct(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && tableData.length === 0" description="暂无商品" />
    </div>

    <div v-if="total > 0" class="pagination">
      <el-pagination
        v-model:current-page="page"
        :page-size="size"
        :total="total"
        layout="total, prev, pager, next, jumper"
        @current-change="handlePageChange"
      />
    </div>

    <el-dialog v-model="showEditDialog" title="编辑商品" width="600px">
      <el-form :model="editingProduct" label-width="80px" v-if="editingProduct">
        <el-form-item label="商品名称">
          <el-input v-model="editingProduct.name" />
        </el-form-item>
        <el-form-item label="商品图片">
          <el-input v-model="editingProduct.imageUrl" placeholder="图片URL" />
        </el-form-item>
        <el-form-item label="商品描述">
          <el-input v-model="editingProduct.description" type="textarea" :rows="3" />
        </el-form-item>
        <el-form-item label="价格">
          <el-input v-model.number="editingProduct.price" type="number" />
        </el-form-item>
        <el-form-item label="库存">
          <el-input v-model.number="editingProduct.stock" type="number" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="editingProduct.categoryId" style="width: 100%">
            <el-option v-for="cat in categoryList" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEditDialog = false">取消</el-button>
        <el-button type="primary" @click="updateProduct">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const router = useRouter()
const merchantStore = useMerchantStore()

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const keyword = ref('')
const categoryId = ref<number | null>(null)
const statusFilter = ref<number | null>(null)
const page = ref(1)
const size = ref(10)
const total = ref(0)
const tableData = ref<any[]>([])
const loading = ref(false)
const showEditDialog = ref(false)
const editingProduct = ref<any>(null)

const categoryList = ref<any[]>([])
const categoryNameMap = ref<Record<number, string>>({})

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : ''
}

function getCategoryName(id: number) {
  if (!id) return '—'
  return categoryNameMap.value[id] || `分类${id}`
}

async function loadCategories() {
  try {
    const res = await request.get('/category/list')
    const list = res.data?.list || res.data?.categories || res.data || []
    categoryList.value = list
    list.forEach((cat: any) => {
      categoryNameMap.value[cat.id] = cat.name
    })
  } catch (e) {
    console.error('加载分类失败', e)
    categoryList.value = [
      { id: 1, name: '服装鞋帽' },
      { id: 2, name: '数码电器' },
      { id: 3, name: '食品饮料' },
      { id: 4, name: '家居用品' },
      { id: 5, name: '美妆个护' }
    ]
    categoryList.value.forEach(cat => {
      categoryNameMap.value[cat.id] = cat.name
    })
  }
}

async function loadProducts() {
  const merchantId = merchantStore.merchantInfo?.id
  if (!merchantId) return
  loading.value = true
  try {
    const res = await request.get('/merchant/product/list', {
      params: {
        merchantId,
        keyword: keyword.value || undefined,
        categoryId: categoryId.value ?? undefined,
        status: statusFilter.value ?? undefined,
        page: page.value,
        size: size.value
      }
    })
    const data = res.data?.list || res.data?.records || res.data?.products || []
    tableData.value = data
    total.value = res.data?.total || 0
  } catch (e) {
    console.error('加载商品列表失败', e)
    tableData.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadProducts()
}

function handlePageChange(val: number) {
  page.value = val
  loadProducts()
}

function goAddProduct() {
  router.push('/merchant/product/add')
}

async function toggleStatus(row: any) {
  const action = row.status === 1 ? '下架' : '上架'
  try {
    await ElMessageBox.confirm(`确定要${action}商品「${row.name}」吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
  } catch {
    return
  }
  try {
    const newStatus = row.status === 1 ? 0 : 1
    await request.put(`/merchant/product/${row.id}/status`, { status: newStatus })
    row.status = newStatus
    ElMessage.success(`${action}成功`)
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

function editProduct(row: any) {
  editingProduct.value = { ...row }
  showEditDialog.value = true
}

async function updateProduct() {
  if (!editingProduct.value) return
  try {
    await request.put(`/merchant/product/${editingProduct.value.id}`, editingProduct.value)
    ElMessage.success('更新成功')
    showEditDialog.value = false
    loadProducts()
  } catch (e: any) {
    ElMessage.error(e?.message || '更新失败')
  }
}

async function deleteProduct(row: any) {
  try {
    await ElMessageBox.confirm(`确定删除商品「${row.name}」吗？此操作不可恢复。`, '删除确认', {
      confirmButtonText: '确定删除',
      cancelButtonText: '取消',
      type: 'error'
    })
  } catch {
    return
  }
  try {
    await request.delete(`/merchant/product/${row.id}`)
    ElMessage.success('删除成功')
    loadProducts()
  } catch (e: any) {
    ElMessage.error(e?.message || '删除失败')
  }
}

onMounted(() => {
  loadCategories()
  loadProducts()
})
</script>

<style lang="scss" scoped>
.product-list-page {
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
}

.search-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
}

.table-card {
  background: #fff;
  border-radius: 8px;
  padding: 16px;

  .product-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
  }

  .price {
    color: #e6a23c;
    font-weight: 500;
  }
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
