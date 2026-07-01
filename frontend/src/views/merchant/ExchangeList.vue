<template>
  <div class="exchange-list-page">
    <div class="page-header">
      <h2>换货管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索换货单号" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="exchange-status-tabs">
      <div
        v-for="tab in statusTabs"
        :key="tab.value"
        :class="['status-tab', { active: currentStatus === tab.value }]"
        @click="currentStatus = tab.value; page = 1; loadExchanges()"
      >
        {{ tab.label }}
      </div>
    </div>

    <div class="exchange-table">
      <el-table :data="exchangeList" v-loading="loading" border>
        <el-table-column label="换货单号" prop="exchangeNo" width="200" />
        <el-table-column label="订单号" width="180">
          <template #default="{ row }">
            <span class="order-no">{{ row.orderId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="原商品" min-width="200">
          <template #default="{ row }">
            <div class="product-cell">
              <img :src="row.originalProductImage || defaultImg" class="product-img" />
              <div class="product-info">
                <div class="product-name">{{ row.originalProductName }}</div>
                <div v-if="row.originalSpecValues" class="product-spec">{{ row.originalSpecValues }}</div>
                <div class="product-price">¥{{ Number(row.originalPrice || 0).toFixed(2) }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="新商品" min-width="200">
          <template #default="{ row }">
            <div class="product-cell">
              <img :src="row.newProductImage || defaultImg" class="product-img" />
              <div class="product-info">
                <div class="product-name">{{ row.newProductName }}</div>
                <div v-if="row.newSpecValues" class="product-spec">{{ row.newSpecValues }}</div>
                <div class="product-price">¥{{ Number(row.newPrice || 0).toFixed(2) }}</div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="价格差异" width="100">
          <template #default="{ row }">
            <span :class="['price-diff', getDiffClass(row)]">
              {{ formatPriceDiff(row) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="申请时间" prop="applyTime" width="160" />
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button v-if="row.status === 0" type="success" size="small" @click="showApproveDialog(row)">审核通过</el-button>
              <el-button v-if="row.status === 0" type="danger" size="small" @click="showRejectDialog(row)">拒绝</el-button>
              <el-button v-if="row.status === 5" type="success" size="small" @click="showConfirmReceiveDialog(row)">确认收货</el-button>
              <el-button v-if="row.status === 6" type="primary" size="small" @click="showShipDialog(row)">发货</el-button>
              <el-button size="small" @click="viewDetail(row)">详情</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && exchangeList.length === 0" description="暂无换货申请" />
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

    <!-- 审核通过对话框 -->
    <el-dialog v-model="approveDialogVisible" title="审核通过" width="420px">
      <p class="dialog-tip">确定要审核通过该换货申请吗？</p>
      <el-form label-width="80px">
        <el-form-item label="备注">
          <el-input
            v-model="approveRemark"
            type="textarea"
            :rows="2"
            placeholder="可选，填写备注说明"
            maxlength="200"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="approveDialogVisible = false">取消</el-button>
        <el-button type="success" @click="confirmApprove">确认通过</el-button>
      </template>
    </el-dialog>

    <!-- 拒绝对话框 -->
    <el-dialog v-model="rejectDialogVisible" title="拒绝换货" width="420px">
      <p class="dialog-tip">请填写拒绝换货的原因：</p>
      <el-input
        v-model="rejectRemark"
        type="textarea"
        :rows="4"
        placeholder="请输入拒绝原因..."
        maxlength="200"
        show-word-limit
      />
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :disabled="!rejectRemark.trim()" @click="confirmReject">确认拒绝</el-button>
      </template>
    </el-dialog>

    <!-- 确认收货对话框 -->
    <el-dialog v-model="confirmReceiveDialogVisible" title="确认收到退货" width="420px">
      <p class="dialog-tip">确认已收到退货商品吗？确认后将进入待发货状态。</p>
      <el-form label-width="80px" v-if="currentExchange">
        <el-form-item label="物流公司">
          <span>{{ currentExchange.returnLogisticsCompany || '-' }}</span>
        </el-form-item>
        <el-form-item label="物流单号">
          <span class="mono">{{ currentExchange.returnTrackingNo || '-' }}</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="confirmReceiveDialogVisible = false">取消</el-button>
        <el-button type="success" @click="confirmReceive">确认收货</el-button>
      </template>
    </el-dialog>

    <!-- 发货对话框 -->
    <el-dialog v-model="shipDialogVisible" title="换货发货" width="450px">
      <p class="dialog-tip">请填写发货物流信息：</p>
      <el-form label-width="90px" :model="shipForm" :rules="shipRules" ref="shipFormRef">
        <el-form-item label="物流公司" prop="logisticsCompany">
          <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司" style="width: 100%">
            <el-option label="顺丰快递" value="顺丰快递" />
            <el-option label="圆通快递" value="圆通快递" />
            <el-option label="中通快递" value="中通快递" />
            <el-option label="韵达快递" value="韵达快递" />
            <el-option label="申通快递" value="申通快递" />
            <el-option label="百世快递" value="百世快递" />
            <el-option label="极兔快递" value="极兔快递" />
            <el-option label="京东物流" value="京东物流" />
            <el-option label="邮政EMS" value="邮政EMS" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号" prop="trackingNo">
          <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" maxlength="50" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="shipDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmShip">确认发货</el-button>
      </template>
    </el-dialog>

    <!-- 换货详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="换货详情" width="700px">
      <div v-if="currentExchange" class="exchange-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-row"><span class="label">换货单号：</span><span class="mono">{{ currentExchange.exchangeNo }}</span></div>
          <div class="detail-row"><span class="label">订单号：</span><span class="order-no">{{ currentExchange.orderNo || currentExchange.orderId }}</span></div>
          <div class="detail-row"><span class="label">用户ID：</span><span>{{ currentExchange.userId }}</span></div>
          <div class="detail-row"><span class="label">换货状态：</span>
            <el-tag :type="getStatusTagType(currentExchange.status)" size="small">
              {{ getStatusText(currentExchange.status) }}
            </el-tag>
          </div>
          <div class="detail-row"><span class="label">换货原因：</span><span>{{ currentExchange.exchangeReason || '-' }}</span></div>
        </div>

        <div class="detail-section">
          <h4>商品对比</h4>
          <div class="product-compare">
            <div class="compare-item">
              <div class="compare-title">原商品</div>
              <div class="product-card">
                <img :src="currentExchange.originalProductImage || defaultImg" class="card-img" />
                <div class="card-info">
                  <div class="card-name">{{ currentExchange.originalProductName }}</div>
                  <div v-if="currentExchange.originalSpecValues" class="card-spec">{{ currentExchange.originalSpecValues }}</div>
                  <div class="card-price">¥{{ Number(currentExchange.originalPrice || 0).toFixed(2) }}</div>
                  <div v-if="currentExchange.originalQuantity" class="card-qty">数量：{{ currentExchange.originalQuantity }}</div>
                </div>
              </div>
            </div>
            <div class="compare-arrow">
              <el-icon><ArrowRight /></el-icon>
            </div>
            <div class="compare-item">
              <div class="compare-title">新商品</div>
              <div class="product-card">
                <img :src="currentExchange.newProductImage || defaultImg" class="card-img" />
                <div class="card-info">
                  <div class="card-name">{{ currentExchange.newProductName }}</div>
                  <div v-if="currentExchange.newSpecValues" class="card-spec">{{ currentExchange.newSpecValues }}</div>
                  <div class="card-price">¥{{ Number(currentExchange.newPrice || 0).toFixed(2) }}</div>
                  <div v-if="currentExchange.newQuantity" class="card-qty">数量：{{ currentExchange.newQuantity }}</div>
                </div>
              </div>
            </div>
          </div>
          <div class="price-diff-row">
            <span>价格差异：</span>
            <span :class="['price-diff', getDiffClass(currentExchange)]">
              {{ formatPriceDiff(currentExchange) }}
            </span>
            <span v-if="currentExchange.priceDiff && Number(currentExchange.priceDiff) > 0" class="diff-tip">
              （用户需补差价）
            </span>
            <span v-else-if="currentExchange.priceDiff && Number(currentExchange.priceDiff) < 0" class="diff-tip">
              （需退还用户差价）
            </span>
          </div>
        </div>

        <div v-if="currentExchange.returnLogisticsCompany" class="detail-section">
          <h4>退货物流信息</h4>
          <div class="detail-row"><span class="label">物流公司：</span><span>{{ currentExchange.returnLogisticsCompany }}</span></div>
          <div class="detail-row"><span class="label">物流单号：</span><span class="mono">{{ currentExchange.returnTrackingNo }}</span></div>
          <div v-if="currentExchange.returnShipTime" class="detail-row"><span class="label">发货时间：</span><span>{{ formatTime(currentExchange.returnShipTime) }}</span></div>
          <div v-if="currentExchange.returnReceiveTime" class="detail-row"><span class="label">收货时间：</span><span>{{ formatTime(currentExchange.returnReceiveTime) }}</span></div>
        </div>

        <div v-if="currentExchange.exchangeLogisticsCompany" class="detail-section">
          <h4>换货发货物流信息</h4>
          <div class="detail-row"><span class="label">物流公司：</span><span>{{ currentExchange.exchangeLogisticsCompany }}</span></div>
          <div class="detail-row"><span class="label">物流单号：</span><span class="mono">{{ currentExchange.exchangeTrackingNo }}</span></div>
          <div v-if="currentExchange.exchangeShipTime" class="detail-row"><span class="label">发货时间：</span><span>{{ formatTime(currentExchange.exchangeShipTime) }}</span></div>
        </div>

        <div class="detail-section">
          <h4>时间信息</h4>
          <div class="detail-row"><span class="label">申请时间：</span><span>{{ formatTime(currentExchange.applyTime) }}</span></div>
          <div v-if="currentExchange.auditTime" class="detail-row"><span class="label">审核时间：</span><span>{{ formatTime(currentExchange.auditTime) }}</span></div>
          <div v-if="currentExchange.completeTime" class="detail-row"><span class="label">完成时间：</span><span>{{ formatTime(currentExchange.completeTime) }}</span></div>
        </div>

        <div v-if="currentExchange.merchantRemark" class="detail-section">
          <h4>商家备注</h4>
          <p>{{ currentExchange.merchantRemark }}</p>
        </div>

        <div v-if="currentExchange.rejectReason" class="detail-section">
          <h4>拒绝原因</h4>
          <p class="reject-reason">{{ currentExchange.rejectReason }}</p>
        </div>

        <div v-if="voucherImages.length > 0" class="detail-section">
          <h4>换货凭证</h4>
          <div class="voucher-list">
            <div
              v-for="(img, idx) in voucherImages"
              :key="idx"
              class="voucher-item"
              @click="previewImage(img)"
            >
              <img :src="img" class="voucher-img" />
              <div class="voucher-mask">
                <el-icon><ZoomIn /></el-icon>
              </div>
            </div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-image-viewer
      v-if="viewerVisible"
      :url-list="voucherImages"
      :initial-index="viewerIndex"
      @close="viewerVisible = false"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { ZoomIn, ArrowRight } from '@element-plus/icons-vue'
import type { FormInstance, FormRules } from 'element-plus'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const merchantStore = useMerchantStore()

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const statusTabs = [
  { label: '全部', value: null },
  { label: '待审核', value: 0 },
  { label: '待退货', value: 1 },
  { label: '退货中', value: 5 },
  { label: '待发货', value: 6 },
  { label: '已发货', value: 7 },
  { label: '已完成', value: 3 },
  { label: '已拒绝', value: 2 },
]

const currentStatus = ref<number | null>(null)
const searchKeyword = ref('')
const exchangeList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const approveDialogVisible = ref(false)
const rejectDialogVisible = ref(false)
const confirmReceiveDialogVisible = ref(false)
const shipDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const currentExchange = ref<any>(null)
const approveRemark = ref('')
const rejectRemark = ref('')
const voucherImages = ref<string[]>([])
const viewerVisible = ref(false)
const viewerIndex = ref(0)

const shipFormRef = ref<FormInstance>()
const shipForm = ref({
  logisticsCompany: '',
  trackingNo: ''
})
const shipRules: FormRules = {
  logisticsCompany: [{ required: true, message: '请选择物流公司', trigger: 'change' }],
  trackingNo: [{ required: true, message: '请输入物流单号', trigger: 'blur' }]
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : ''
}

function previewImage(img: string) {
  const index = voucherImages.value.indexOf(img)
  viewerIndex.value = index >= 0 ? index : 0
  viewerVisible.value = true
}

function getStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待审核',
    1: '待退货',
    2: '已拒绝',
    3: '已完成',
    4: '已取消',
    5: '退货中',
    6: '待发货',
    7: '已发货'
  }
  return types[status] || '未知'
}

function getStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning',
    1: 'primary',
    2: 'danger',
    3: 'success',
    4: 'info',
    5: 'warning',
    6: 'primary',
    7: 'info'
  }
  return types[status] || 'info'
}

function formatPriceDiff(row: any) {
  const diff = Number(row.priceDiff || 0)
  if (diff > 0) {
    return `+¥${diff.toFixed(2)}`
  } else if (diff < 0) {
    return `-¥${Math.abs(diff).toFixed(2)}`
  }
  return '¥0.00'
}

function getDiffClass(row: any) {
  const diff = Number(row.priceDiff || 0)
  if (diff > 0) return 'diff-positive'
  if (diff < 0) return 'diff-negative'
  return 'diff-zero'
}

async function loadExchanges() {
  if (merchantStore.merchantInfo?.id === undefined || merchantStore.merchantInfo?.id === null) return
  loading.value = true
  try {
    const res = await request.get('/exchange/merchant', {
      params: {
        merchantId: merchantStore.merchantInfo.id,
        status: currentStatus.value !== null ? currentStatus.value : undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    const totalCount = res.data?.total || 0

    if (searchKeyword.value) {
      list = list.filter(item => item.exchangeNo?.includes(searchKeyword.value))
      total.value = list.length
    } else {
      total.value = totalCount
    }
    exchangeList.value = list
  } catch (e) {
    console.error('加载换货列表失败', e)
    exchangeList.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadExchanges()
}

function handlePageChange(val: number) {
  page.value = val
  loadExchanges()
}

function showApproveDialog(row: any) {
  currentExchange.value = row
  approveRemark.value = ''
  approveDialogVisible.value = true
}

function showRejectDialog(row: any) {
  currentExchange.value = row
  rejectRemark.value = ''
  rejectDialogVisible.value = true
}

function showConfirmReceiveDialog(row: any) {
  currentExchange.value = row
  confirmReceiveDialogVisible.value = true
}

function showShipDialog(row: any) {
  currentExchange.value = row
  shipForm.value = {
    logisticsCompany: '',
    trackingNo: ''
  }
  shipDialogVisible.value = true
}

async function viewDetail(row: any) {
  currentExchange.value = row
  voucherImages.value = []
  try {
    const res = await request.get('/exchange/detail', {
      params: { id: row.id }
    })
    if (res.data) {
      currentExchange.value = res.data.exchange || res.data || row
      if (res.data.voucherImages) {
        voucherImages.value = Array.isArray(res.data.voucherImages)
          ? res.data.voucherImages
          : [res.data.voucherImages]
      } else if (res.data.images) {
        voucherImages.value = Array.isArray(res.data.images)
          ? res.data.images
          : [res.data.images]
      }
    }
  } catch (e) {
    console.error('加载换货详情失败', e)
    if (row.voucherImages) {
      voucherImages.value = Array.isArray(row.voucherImages) ? row.voucherImages : [row.voucherImages]
    }
  }
  detailDialogVisible.value = true
}

async function confirmApprove() {
  if (!currentExchange.value) return
  try {
    await request.post('/exchange/audit', null, {
      params: {
        exchangeId: currentExchange.value.id,
        approve: true,
        remark: approveRemark.value || undefined
      }
    })
    ElMessage.success('审核通过')
    approveDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

async function confirmReject() {
  if (!currentExchange.value || !rejectRemark.value.trim()) return
  try {
    await request.post('/exchange/audit', null, {
      params: {
        exchangeId: currentExchange.value.id,
        approve: false,
        remark: rejectRemark.value
      }
    })
    ElMessage.success('已拒绝换货申请')
    rejectDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

async function confirmReceive() {
  if (!currentExchange.value) return
  try {
    await request.post('/exchange/confirm-receive', null, {
      params: {
        exchangeId: currentExchange.value.id,
        merchantId: merchantStore.merchantInfo?.id
      }
    })
    ElMessage.success('已确认收货')
    confirmReceiveDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

async function confirmShip() {
  if (!currentExchange.value) return
  if (!shipFormRef.value) return

  try {
    await shipFormRef.value.validate()
    await request.post('/exchange/ship', null, {
      params: {
        exchangeId: currentExchange.value.id,
        merchantId: merchantStore.merchantInfo?.id,
        logisticsCompany: shipForm.value.logisticsCompany,
        trackingNo: shipForm.value.trackingNo
      }
    })
    ElMessage.success('发货成功')
    shipDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    if (e?.message) {
      ElMessage.error(e.message)
    }
  }
}

onMounted(() => {
  loadExchanges()
})

watch(() => merchantStore.merchantInfo, (val) => {
  if (val?.id !== undefined && val?.id !== null && exchangeList.value.length === 0) {
    loadExchanges()
  }
}, { deep: true })
</script>

<style lang="scss" scoped>
.exchange-list-page {
  background: #fff;
  border-radius: 8px;
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

  .search-bar {
    display: flex;
    gap: 10px;
    align-items: center;
  }
}

.exchange-status-tabs {
  display: flex;
  gap: 16px;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f0f0;

  .status-tab {
    padding: 6px 16px;
    font-size: 14px;
    color: #666;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.2s;

    &:hover {
      color: #409eff;
    }

    &.active {
      color: #409eff;
      font-weight: 600;
      background: #ecf5ff;
    }
  }
}

.exchange-table {
  .order-no {
    color: #666;
    font-family: monospace;
  }

  .product-cell {
    display: flex;
    align-items: center;
    gap: 10px;

    .product-img {
      width: 50px;
      height: 50px;
      object-fit: cover;
      border-radius: 4px;
      flex-shrink: 0;
    }

    .product-info {
      flex: 1;
      min-width: 0;

      .product-name {
        font-size: 13px;
        color: #333;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .product-spec {
        font-size: 12px;
        color: #999;
        margin-top: 2px;
      }

      .product-price {
        font-size: 13px;
        color: #f56c6c;
        margin-top: 4px;
      }
    }
  }

  .price-diff {
    font-weight: 500;
    font-size: 14px;

    &.diff-positive {
      color: #f56c6c;
    }

    &.diff-negative {
      color: #67c23a;
    }

    &.diff-zero {
      color: #909399;
    }
  }

  .action-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.dialog-tip {
  margin: 0 0 16px 0;
  color: #666;
  font-size: 14px;
}

.exchange-detail {
  .detail-section {
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;

    &:last-child {
      border-bottom: none;
      margin-bottom: 0;
      padding-bottom: 0;
    }

    h4 {
      margin: 0 0 10px 0;
      font-size: 14px;
      color: #333;
    }

    p {
      margin: 0;
      color: #666;
      line-height: 1.6;
    }

    .reject-reason {
      color: #f56c6c;
    }
  }

  .detail-row {
    display: flex;
    padding: 4px 0;
    font-size: 13px;

    .label {
      color: #999;
      width: 80px;
      flex-shrink: 0;
    }
  }

  .mono {
    font-family: monospace;
    color: #666;
  }

  .order-no {
    color: #666;
    font-family: monospace;
  }

  .product-compare {
    display: flex;
    align-items: center;
    gap: 16px;

    .compare-item {
      flex: 1;

      .compare-title {
        font-size: 13px;
        color: #666;
        margin-bottom: 8px;
        text-align: center;
      }
    }

    .compare-arrow {
      font-size: 24px;
      color: #c0c4cc;
    }

    .product-card {
      display: flex;
      gap: 12px;
      padding: 12px;
      background: #f9f9f9;
      border-radius: 8px;

      .card-img {
        width: 70px;
        height: 70px;
        object-fit: cover;
        border-radius: 4px;
        flex-shrink: 0;
      }

      .card-info {
        flex: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;

        .card-name {
          font-size: 14px;
          color: #333;
          font-weight: 500;
        }

        .card-spec {
          font-size: 12px;
          color: #999;
          margin-top: 4px;
        }

        .card-price {
          font-size: 15px;
          color: #f56c6c;
          font-weight: 500;
        }

        .card-qty {
          font-size: 12px;
          color: #666;
        }
      }
    }
  }

  .price-diff-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 12px;
    padding: 10px;
    background: #fdf6ec;
    border-radius: 4px;
    font-size: 14px;

    .price-diff {
      font-weight: bold;
      font-size: 16px;

      &.diff-positive {
        color: #f56c6c;
      }

      &.diff-negative {
        color: #67c23a;
      }
    }

    .diff-tip {
      color: #e6a23c;
      font-size: 13px;
    }
  }

  .voucher-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }

  .voucher-item {
    position: relative;
    width: 80px;
    height: 80px;
    border-radius: 4px;
    overflow: hidden;
    cursor: pointer;
    border: 1px solid #eee;

    &:hover .voucher-mask {
      opacity: 1;
    }

    .voucher-img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .voucher-mask {
      position: absolute;
      inset: 0;
      background: rgba(0, 0, 0, 0.5);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      opacity: 0;
      transition: opacity 0.2s;

      .el-icon {
        font-size: 20px;
      }
    }
  }
}
</style>