<template>
  <div class="cart-page">
    <Header />
    <div class="container">
      <h2 class="page-title">购物车</h2>
      <div v-if="cartStore.cartItems.length === 0" class="empty-cart">
        <el-icon :size="64" color="#ccc"><ShoppingCart /></el-icon>
        <p>购物车是空的</p>
        <el-button type="primary" @click="goShopping">去购物</el-button>
      </div>
      <div v-else class="cart-content">
        <div class="merchant-group" v-for="group in merchantGroups" :key="group.merchantId">
          <div class="merchant-header">
            <div class="merchant-left">
              <el-checkbox
                :model-value="isMerchantAllSelected(group.merchantId)"
                :indeterminate="isMerchantIndeterminate(group.merchantId)"
                @change="(val: boolean) => handleMerchantSelectAll(group.merchantId, val)"
              >
                <span class="merchant-name">{{ getMerchantName(group.merchantId) }}</span>
              </el-checkbox>
            </div>
            <div class="merchant-right">
              <span class="merchant-subtotal-label">店铺小计：</span>
              <span class="merchant-subtotal">¥{{ getMerchantSubtotal(group.merchantId).toFixed(2) }}</span>
            </div>
          </div>
          <el-table :data="group.items" border @selection-change="(selection: any[]) => handleSelectionChange(group.merchantId, selection)" :ref="(el: any) => setTableRef(group.merchantId, el)">
            <el-table-column type="selection" width="55" />
            <el-table-column label="商品图片" width="120">
              <template #default="{ row }">
                <img :src="row.productImage || 'https://via.placeholder.com/100'" alt="" class="cart-image clickable" @click="goProduct(row.productId)" />
              </template>
            </el-table-column>
            <el-table-column label="商品名称">
              <template #default="{ row }">
                <span class="product-name-link" @click="goProduct(row.productId)">{{ row.productName }}</span>
              </template>
            </el-table-column>
            <el-table-column label="单价" width="100">
              <template #default="{ row }">
                <span class="price">¥{{ row.price.toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="数量" width="150">
              <template #default="{ row }">
                <el-input-number
                  v-model="row.quantity"
                  :min="1"
                  @change="(val: number) => handleUpdateQuantity(row.id, val)"
                />
              </template>
            </el-table-column>
            <el-table-column label="小计" width="120">
              <template #default="{ row }">
                <span class="subtotal">¥{{ (row.price * row.quantity).toFixed(2) }}</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button type="danger" size="small" @click="handleDelete(row.id)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
        <div class="cart-footer">
          <div class="select-all">
            <el-checkbox v-model="selectAll" @change="handleSelectAll">全选</el-checkbox>
            <span>已选 {{ cartStore.selectedCount }} 件商品</span>
          </div>
          <div class="cart-total">
            <span>合计：</span>
            <span class="total-price">¥{{ cartStore.totalPrice.toFixed(2) }}</span>
            <el-button type="danger" size="large" :disabled="cartStore.selectedCount === 0" @click="goCheckout">结算</el-button>
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { useUserStore } from '@/stores/user'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { ShoppingCart } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

const selectAll = ref(false)
const tableRefs = ref<Record<number, any>>({})

interface MerchantGroup {
  merchantId: number
  items: any[]
}

const merchantGroups = computed<MerchantGroup[]>(() => {
  const groupsMap = new Map<number, any[]>()
  for (const item of cartStore.cartItems) {
    const merchantId = item.merchantId || 0
    if (!groupsMap.has(merchantId)) {
      groupsMap.set(merchantId, [])
    }
    groupsMap.get(merchantId)!.push(item)
  }
  const groups: MerchantGroup[] = []
  groupsMap.forEach((items, merchantId) => {
    groups.push({ merchantId, items })
  })
  return groups.sort((a, b) => a.merchantId - b.merchantId)
})

const allSelected = computed(() => {
  return cartStore.cartItems.length > 0 && cartStore.cartItems.every(item => item.selected)
})

watch(() => cartStore.cartItems, () => {
  selectAll.value = allSelected.value
}, { deep: true })

function setTableRef(merchantId: number, el: any) {
  if (el) {
    tableRefs.value[merchantId] = el
  }
}

function getMerchantName(merchantId: number): string {
  const item = cartStore.cartItems.find(i => i.merchantId === merchantId)
  return (item as any)?.merchantName || `店铺${merchantId}`
}

function isMerchantAllSelected(merchantId: number): boolean {
  const items = cartStore.cartItems.filter(i => i.merchantId === merchantId)
  return items.length > 0 && items.every(item => item.selected)
}

function isMerchantIndeterminate(merchantId: number): boolean {
  const items = cartStore.cartItems.filter(i => i.merchantId === merchantId)
  const selectedCount = items.filter(item => item.selected).length
  return selectedCount > 0 && selectedCount < items.length
}

function getMerchantSubtotal(merchantId: number): number {
  return cartStore.cartItems
    .filter(i => i.merchantId === merchantId && i.selected)
    .reduce((sum, item) => sum + item.price * item.quantity, 0)
}

function goShopping() {
  router.push('/')
}

function goProduct(productId: number) {
  router.push(`/product/${productId}`)
}

function goCheckout() {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    router.push('/login')
    return
  }
  const selectedItems = cartStore.cartItems.filter(item => item.selected)
  if (selectedItems.length === 0) {
    ElMessage.warning('请选择要结算的商品')
    return
  }
  const cartIds = selectedItems.map(item => item.id).join(',')
  router.push({
    path: '/checkout',
    query: { cartIds }
  })
}

async function handleUpdateQuantity(cartId: number, quantity: number) {
  await cartStore.updateCartItem(cartId, quantity)
  await syncAllTableSelections()
}

async function handleDelete(cartId: number) {
  await cartStore.deleteCartItem(cartId)
  ElMessage.success('删除成功')
  await syncAllTableSelections()
}

async function handleSelectAll(selected: boolean) {
  await cartStore.toggleSelectAll(selected)
  await syncAllTableSelections()
}

async function handleMerchantSelectAll(merchantId: number, selected: boolean) {
  const merchantItems = cartStore.cartItems.filter(i => i.merchantId === merchantId)
  for (const item of merchantItems) {
    if (item.selected !== selected) {
      await cartStore.toggleSelect(item.id)
    }
  }
  await syncAllTableSelections()
}

function handleSelectionChange(merchantId: number, selection: any[]) {
  const selectedIds = new Set(selection.map((item: any) => item.id))
  const merchantItems = cartStore.cartItems.filter(i => i.merchantId === merchantId)
  
  const updatePromises: Promise<any>[] = []
  for (const item of merchantItems) {
    const shouldSelect = selectedIds.has(item.id)
    if (item.selected !== shouldSelect) {
      updatePromises.push(cartStore.toggleSelect(item.id))
    }
  }
  
  Promise.all(updatePromises).then(() => {
    selectAll.value = allSelected.value
  })
}

async function syncAllTableSelections() {
  await nextTick()
  for (const merchantId in tableRefs.value) {
    const tableRef = tableRefs.value[merchantId]
    if (!tableRef) continue
    const mid = Number(merchantId)
    const selectedRows = cartStore.cartItems.filter(item => item.merchantId === mid && item.selected)
    tableRef.clearSelection()
    for (const row of selectedRows) {
      tableRef.toggleRowSelection(row, true)
    }
  }
  selectAll.value = allSelected.value
}

onMounted(async () => {
  if (userStore.isLogin) {
    await cartStore.getCartList()
    await syncAllTableSelections()
  }
})
</script>

<style lang="scss" scoped>
.cart-page {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.page-title {
  font-size: 24px;
  margin-bottom: 30px;
}

.empty-cart {
  text-align: center;
  padding: 80px 0;

  p {
    margin: 20px 0;
    color: #999;
    font-size: 18px;
  }
}

.cart-content {
  .cart-image {
    width: 100px;
    height: 100px;
    object-fit: cover;
    border-radius: 5px;
    &.clickable {
      cursor: pointer;
      transition: opacity 0.2s;
      &:hover { opacity: 0.8; }
    }
  }
  
  .product-name-link {
    cursor: pointer;
    color: #333;
    transition: color 0.2s;
    &:hover { color: #ff4400; }
  }

  .price,
  .subtotal {
    color: #f56c6c;
    font-weight: bold;
  }
}

.merchant-group {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
}

.merchant-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 20px;
  background: linear-gradient(90deg, #f5f7fa 0%, #e8ecf1 100%);
  border: 1px solid #ebeef5;
  border-bottom: none;
  border-radius: 8px 8px 0 0;

  .merchant-left {
    display: flex;
    align-items: center;
  }

  .merchant-name {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
    margin-left: 8px;
  }

  .merchant-right {
    display: flex;
    align-items: center;
    gap: 5px;
  }

  .merchant-subtotal-label {
    font-size: 14px;
    color: #606266;
  }

  .merchant-subtotal {
    font-size: 18px;
    font-weight: bold;
    color: #f56c6c;
  }
}

.merchant-group :deep(.el-table) {
  border-radius: 0 0 8px 8px;
}

.cart-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 5px;

  .select-all {
    display: flex;
    align-items: center;
    gap: 10px;
    color: #666;
  }

  .cart-total {
    display: flex;
    align-items: center;
    gap: 10px;

    .total-price {
      font-size: 24px;
      font-weight: bold;
      color: #f56c6c;
    }
  }
}
</style>
