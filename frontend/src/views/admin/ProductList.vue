<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>商品管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索商品名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-select v-model="statusFilter" placeholder="状态筛选" clearable style="width: 120px">
          <el-option label="上架中" :value="1" />
          <el-option label="已下架" :value="0" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增商品</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="productList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="商品图片" width="80">
          <template #default="{ row }">
            <img :src="row.imageUrl || defaultImg" class="product-img" />
          </template>
        </el-table-column>
        <el-table-column label="商品名称" prop="name" min-width="200" show-overflow-tooltip />
        <el-table-column label="店铺" width="140">
          <template #default="{ row }">
            <span>{{ getMerchantName(row.merchantId) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="价格" width="100" align="right">
          <template #default="{ row }">
            <span class="price">¥{{ Number(row.price || 0).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" prop="stock" width="80" align="center" />
        <el-table-column label="销量" prop="sales" width="80" align="center" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '上架中' : '已下架' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>编辑</el-button>
            <el-button size="small" :type="row.status === 1 ? 'warning' : 'success'" link @click="toggleStatus(row)">
              {{ row.status === 1 ? '下架' : '上架' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && productList.length === 0" description="暂无商品" />
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

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const searchKeyword = ref('')
const statusFilter = ref<number | null>(null)
const productList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const merchantNameMap = ref<Record<number, string>>({})

function getMerchantName(id: number) {
  if (!id) return '—'
  return merchantNameMap.value[id] || `店铺${id}`
}

async function loadProducts() {
  loading.value = true
  try {
    const res = await request.get('/product/list', {
      params: {
        keyword: searchKeyword.value || undefined,
        status: statusFilter.value ?? undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    const list = (res.data?.list || res.data?.records || []) as any[]
    productList.value = list
    total.value = res.data?.total || list.length

    const merchantIds = list.map((p: any) => p.merchantId).filter(Boolean)
    loadMerchantNames([...new Set(merchantIds)])
  } catch (e) {
    console.error('加载商品失败', e)
    productList.value = []
  } finally {
    loading.value = false
  }
}

async function loadMerchantNames(ids: number[]) {
  const uniqueIds = ids.filter((id: number) => id && !merchantNameMap.value[id])
  for (const id of uniqueIds) {
    try {
      const res = await request.get(`/merchant/detail?id=${id}`)
      if (res.data?.shopName) {
        merchantNameMap.value[id] = res.data.shopName
      }
    } catch { /* ignore */ }
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

function handleAdd() {
  ElMessage.info('新增商品功能开发中')
}

async function toggleStatus(row: any) {
  const action = row.status === 1 ? '下架' : '上架'
  try {
    await ElMessageBox.confirm(`确定要${action}该商品吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    ElMessage.success(`已${action}`)
    loadProducts()
  } catch { /* canceled */ }
}

onMounted(() => {
  loadProducts()
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

.product-img {
  width: 50px;
  height: 50px;
  object-fit: cover;
  border-radius: 4px;
}

.price {
  color: #f56c6c;
  font-weight: 600;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
