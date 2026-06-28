<template>
  <div class="refund-list-page">
    <div class="page-header">
      <h2>退款管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索退款单号" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-select v-model="refundStatus" placeholder="状态筛选" clearable style="width: 140px">
          <el-option label="待审核" :value="0" />
          <el-option label="待退货" :value="1" />
          <el-option label="退货中" :value="5" />
          <el-option label="已完成" :value="3" />
          <el-option label="已拒绝" :value="2" />
          <el-option label="已取消" :value="4" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="refund-status-tabs">
      <div
        v-for="tab in statusTabs"
        :key="tab.value"
        :class="['status-tab', { active: currentStatus === tab.value }]"
        @click="currentStatus = tab.value; page = 1; loadRefunds()"
      >
        {{ tab.label }}
      </div>
    </div>

    <div class="refund-table">
      <el-table :data="refundList" v-loading="loading" border>
        <el-table-column label="退款单号" prop="refundNo" width="200" />
        <el-table-column label="订单号" width="200">
          <template #default="{ row }">
            <span class="order-no">{{ row.orderId }}</span>
          </template>
        </el-table-column>
        <el-table-column label="用户ID" prop="userId" width="100" />
        <el-table-column label="退款金额" width="120">
          <template #default="{ row }">
            <span class="refund-amount">¥{{ Number(row.refundAmount).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="退款原因" min-width="150">
          <template #default="{ row }">
            <span>{{ row.refundReason }}</span>
          </template>
        </el-table-column>
        <el-table-column label="退款类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.refundType === 1 ? 'info' : 'warning'" size="small">
              {{ row.refundType === 1 ? '仅退款' : '退货退款' }}
            </el-tag>
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
        <el-table-column label="商家备注" min-width="120">
          <template #default="{ row }">
            <span>{{ row.merchantRemark || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button v-if="row.status === 0" type="success" size="small" @click="showApproveDialog(row)">同意退款</el-button>
              <el-button v-if="row.status === 0" type="danger" size="small" @click="showRejectDialog(row)">拒绝</el-button>
              <el-button v-if="row.status === 5" type="success" size="small" @click="showConfirmReceiveDialog(row)">确认收货</el-button>
              <el-button size="small" @click="viewDetail(row)">详情</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && refundList.length === 0" description="暂无退款申请" />
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

    <!-- 同意退款对话框 -->
    <el-dialog v-model="approveDialogVisible" title="同意退款" width="420px">
      <p class="dialog-tip">确定要同意该退款申请吗？</p>
      <el-form label-width="80px">
        <el-form-item label="退款金额">
          <span class="refund-amount">¥{{ Number(currentRefund?.refundAmount || 0).toFixed(2) }}</span>
        </el-form-item>
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
        <el-button type="success" @click="confirmApprove">确认退款</el-button>
      </template>
    </el-dialog>

    <!-- 拒绝退款对话框 -->
    <el-dialog v-model="rejectDialogVisible" title="拒绝退款" width="420px">
      <p class="dialog-tip">请填写拒绝退款的原因：</p>
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
    <el-dialog v-model="confirmReceiveDialogVisible" title="确认收货" width="420px">
      <p class="dialog-tip">确认已收到退货商品吗？确认后将完成退款。</p>
      <el-form label-width="80px" v-if="currentRefund">
        <el-form-item label="物流公司">
          <span>{{ currentRefund.returnLogisticsCompany }}</span>
        </el-form-item>
        <el-form-item label="物流单号">
          <span>{{ currentRefund.returnTrackingNo }}</span>
        </el-form-item>
        <el-form-item label="退款金额">
          <span class="refund-amount">¥{{ Number(currentRefund.refundAmount || 0).toFixed(2) }}</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="confirmReceiveDialogVisible = false">取消</el-button>
        <el-button type="success" @click="confirmReceive">确认收货并退款</el-button>
      </template>
    </el-dialog>

    <!-- 退款详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="退款详情" width="600px">
      <div v-if="currentRefund" class="refund-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-row"><span class="label">退款单号：</span><span>{{ currentRefund.refundNo }}</span></div>
          <div class="detail-row"><span class="label">订单号：</span><span class="order-no">{{ currentRefund.orderNo || currentRefund.orderId }}</span></div>
          <div class="detail-row"><span class="label">用户ID：</span><span>{{ currentRefund.userId }}</span></div>
          <div class="detail-row"><span class="label">退款类型：</span>
            <el-tag :type="currentRefund.refundType === 1 ? 'info' : 'warning'" size="small">
              {{ currentRefund.refundType === 1 ? '仅退款' : '退货退款' }}
            </el-tag>
          </div>
          <div class="detail-row"><span class="label">退款金额：</span>
            <span class="refund-amount">¥{{ Number(currentRefund.refundAmount).toFixed(2) }}</span>
          </div>
          <div class="detail-row"><span class="label">退款状态：</span>
            <el-tag :type="getStatusTagType(currentRefund.status)" size="small">
              {{ getStatusText(currentRefund.status) }}
            </el-tag>
          </div>
        </div>

        <div v-if="detailItems.length > 0" class="detail-section">
          <h4>退款商品</h4>
          <div v-for="(item, idx) in detailItems" :key="idx" class="refund-product">
            <img :src="item.productImage || defaultImg" class="product-img" />
            <div class="product-info">
              <div class="product-name">{{ item.productName }}</div>
              <div v-if="item.specValues" class="product-spec">{{ item.specValues }}</div>
              <div class="product-price">
                <span>¥{{ Number(item.price).toFixed(2) }}</span>
                <span> × {{ item.quantity }}</span>
                <span class="subtotal">小计：¥{{ (Number(item.price) * Number(item.quantity)).toFixed(2) }}</span>
              </div>
            </div>
          </div>
        </div>

        <div class="detail-section">
          <h4>退款原因</h4>
          <p>{{ currentRefund.refundReason }}</p>
        </div>

        <div v-if="voucherImages.length > 0" class="detail-section">
          <h4>退款凭证</h4>
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

        <div class="detail-section">
          <h4>时间信息</h4>
          <div class="detail-row"><span class="label">申请时间：</span><span>{{ formatTime(currentRefund.applyTime) }}</span></div>
          <div v-if="currentRefund.auditTime" class="detail-row"><span class="label">审核时间：</span><span>{{ formatTime(currentRefund.auditTime) }}</span></div>
          <div v-if="currentRefund.refundTime" class="detail-row"><span class="label">退款时间：</span><span>{{ formatTime(currentRefund.refundTime) }}</span></div>
        </div>

        <div v-if="currentRefund.merchantRemark" class="detail-section">
          <h4>商家备注</h4>
          <p>{{ currentRefund.merchantRemark }}</p>
        </div>

        <div v-if="currentRefund.refundType === 2 && currentRefund.returnLogisticsCompany" class="detail-section">
          <h4>退货物流信息</h4>
          <div class="detail-row"><span class="label">物流公司：</span><span>{{ currentRefund.returnLogisticsCompany }}</span></div>
          <div class="detail-row"><span class="label">物流单号：</span><span class="mono">{{ currentRefund.returnTrackingNo }}</span></div>
          <div v-if="currentRefund.returnShipTime" class="detail-row"><span class="label">发货时间：</span><span>{{ formatTime(currentRefund.returnShipTime) }}</span></div>
          <div v-if="currentRefund.returnReceiveTime" class="detail-row"><span class="label">收货时间：</span><span>{{ formatTime(currentRefund.returnReceiveTime) }}</span></div>
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
import { ZoomIn } from '@element-plus/icons-vue'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const merchantStore = useMerchantStore()

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const statusTabs = [
  { label: '全部', value: null },
  { label: '待审核', value: 0 },
  { label: '待退货', value: 1 },
  { label: '退货中', value: 5 },
  { label: '已完成', value: 3 },
  { label: '已拒绝', value: 2 },
  { label: '已取消', value: 4 },
]

const currentStatus = ref<number | null>(null)
const searchKeyword = ref('')
const refundStatus = ref<number | null>(null)
const refundList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const approveDialogVisible = ref(false)
const rejectDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const currentRefund = ref<any>(null)
const approveRemark = ref('')
const rejectRemark = ref('')
const confirmReceiveDialogVisible = ref(false)
const detailItems = ref<any[]>([])
const voucherImages = ref<string[]>([])
const viewerVisible = ref(false)
const viewerIndex = ref(0)

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
    5: '退货中'
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
    5: 'warning'
  }
  return types[status] || 'info'
}

async function loadRefunds() {
  if (merchantStore.merchantInfo?.id === undefined || merchantStore.merchantInfo?.id === null) return
  loading.value = true
  try {
    const status = currentStatus.value !== null ? currentStatus.value : refundStatus.value
    const res = await request.get('/refund/merchant', {
      params: {
        merchantId: merchantStore.merchantInfo.id,
        status: status !== null && status !== '' ? status : undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    const totalCount = res.data?.total || 0

    if (searchKeyword.value) {
      list = list.filter(item => item.refundNo?.includes(searchKeyword.value))
      total.value = list.length
    } else {
      total.value = totalCount
    }
    refundList.value = list
  } catch (e) {
    console.error('加载退款列表失败', e)
    refundList.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadRefunds()
}

function handlePageChange(val: number) {
  page.value = val
  loadRefunds()
}

function showApproveDialog(row: any) {
  currentRefund.value = row
  approveRemark.value = ''
  approveDialogVisible.value = true
}

function showRejectDialog(row: any) {
  currentRefund.value = row
  rejectRemark.value = ''
  rejectDialogVisible.value = true
}

function showConfirmReceiveDialog(row: any) {
  currentRefund.value = row
  confirmReceiveDialogVisible.value = true
}

async function viewDetail(row: any) {
  currentRefund.value = row
  detailItems.value = []
  voucherImages.value = []
  try {
    const res = await request.get('/refund/detail', {
      params: { refundId: row.id }
    })
    if (res.data) {
      currentRefund.value = res.data.refund || row
      detailItems.value = res.data.items || res.data.orderItems || []
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
    console.error('加载退款详情失败', e)
    detailItems.value = row.items || []
    if (row.voucherImages) {
      voucherImages.value = Array.isArray(row.voucherImages) ? row.voucherImages : [row.voucherImages]
    }
  }
  detailDialogVisible.value = true
}

async function confirmApprove() {
  if (!currentRefund.value) return
  try {
    await request.post('/refund/audit', null, {
      params: {
        refundId: currentRefund.value.id,
        approve: true,
        remark: approveRemark.value || undefined
      }
    })
    ElMessage.success('退款成功')
    approveDialogVisible.value = false
    loadRefunds()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

async function confirmReject() {
  if (!currentRefund.value || !rejectRemark.value.trim()) return
  try {
    await request.post('/refund/audit', null, {
      params: {
        refundId: currentRefund.value.id,
        approve: false,
        remark: rejectRemark.value
      }
    })
    ElMessage.success('已拒绝退款申请')
    rejectDialogVisible.value = false
    loadRefunds()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

async function confirmReceive() {
  if (!currentRefund.value) return
  try {
    await request.post('/refund/return-receive', null, {
      params: {
        refundId: currentRefund.value.id,
        merchantId: merchantStore.merchantInfo?.id
      }
    })
    ElMessage.success('已确认收货，退款完成')
    confirmReceiveDialogVisible.value = false
    loadRefunds()
  } catch (e: any) {
    ElMessage.error(e?.message || '操作失败')
  }
}

onMounted(() => {
  loadRefunds()
})

watch(() => merchantStore.merchantInfo, (val) => {
  if (val?.id !== undefined && val?.id !== null && refundList.value.length === 0) {
    loadRefunds()
  }
}, { deep: true })
</script>

<style lang="scss" scoped>
.refund-list-page {
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

.refund-status-tabs {
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

.refund-table {
  .order-no {
    color: #666;
    font-family: monospace;
  }

  .refund-amount {
    color: #f56c6c;
    font-weight: 500;
    font-size: 15px;
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

.refund-detail {
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

  .refund-amount {
    color: #f56c6c;
    font-weight: bold;
    font-size: 16px;
  }

  .order-no {
    color: #666;
    font-family: monospace;
  }

  .mono {
    font-family: monospace;
    color: #666;
  }

  .refund-product {
    display: flex;
    gap: 12px;
    padding: 10px 0;
    border-bottom: 1px dashed #f0f0f0;

    &:last-child {
      border-bottom: none;
    }

    .product-img {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 4px;
      flex-shrink: 0;
    }

    .product-info {
      flex: 1;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .product-name {
      font-size: 13px;
      color: #333;
    }

    .product-spec {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }

    .product-price {
      font-size: 13px;
      color: #666;

      .subtotal {
        color: #e6a23c;
        font-weight: 500;
        margin-left: 12px;
      }
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
