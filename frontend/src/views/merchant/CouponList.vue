<template>
  <div class="coupon-list">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="平台优惠券" name="platform">
        <div class="toolbar">
          <el-input v-model="searchKeyword" placeholder="搜索优惠券名称" style="width: 240px;" clearable />
          <el-select v-model="scopeFilter" placeholder="适用范围" style="width: 140px;" clearable>
            <el-option label="全平台通用" :value="1" />
            <el-option label="指定类目" :value="4" />
          </el-select>
          <el-button type="primary" @click="loadPlatformCoupons">查询</el-button>
        </div>
        <div class="coupon-grid">
          <div class="coupon-card platform" v-for="coupon in platformCoupons" :key="coupon.id">
            <div class="coupon-tag">平台券</div>
            <div class="coupon-left">
              <div class="coupon-value">
                <span class="currency" v-if="coupon.type === 1">¥</span>
                <span class="amount">{{ coupon.type === 1 ? coupon.discountAmount : (coupon.discountAmount * 10).toFixed(1) }}</span>
                <span class="unit" v-if="coupon.type === 2">折</span>
              </div>
              <div class="coupon-condition">满{{ coupon.minAmount }}可用</div>
            </div>
            <div class="coupon-right">
              <div class="coupon-name">{{ coupon.name }}</div>
              <div class="coupon-info">
                <span>{{ formatTime(coupon.startTime) }} 至 {{ formatTime(coupon.endTime) }}</span>
              </div>
              <div class="coupon-stats">
                <span>剩余 {{ coupon.remainingCount }} 张</span>
                <span>每人限领 {{ coupon.perUserLimit }} 张</span>
              </div>
              <div class="coupon-rules">
                <el-tag size="small" type="info">适用范围：{{ getScopeText(coupon.scopeType) }}</el-tag>
                <el-tag size="small" type="success" v-if="coupon.mutuallyExclusive === 0">可叠加</el-tag>
                <el-tag size="small" type="warning" v-else>同层互斥</el-tag>
                <el-tag size="small" type="danger" v-if="coupon.userType === 1">新用户专享</el-tag>
                <el-tag size="small" type="warning" v-if="coupon.userType === 2">会员专享</el-tag>
              </div>
              <div class="coupon-desc">{{ coupon.description }}</div>
              <el-button size="small" type="primary" @click="openJoinDialog(coupon)">报名参与</el-button>
            </div>
          </div>
        </div>
        <el-empty v-if="platformCoupons.length === 0" description="暂无平台优惠券" />
      </el-tab-pane>

      <el-tab-pane label="店铺优惠券" name="merchant">
        <div class="toolbar">
          <el-input v-model="searchKeyword" placeholder="搜索优惠券名称" style="width: 240px;" clearable />
          <el-select v-model="levelFilter" placeholder="优惠券类型" style="width: 140px;" clearable>
            <el-option label="店铺券" :value="2" />
            <el-option label="单品券" :value="3" />
          </el-select>
          <el-button type="primary" @click="loadMerchantCoupons">查询</el-button>
          <el-button type="success" @click="openCreateDialog">+ 创建优惠券</el-button>
        </div>
        <div class="coupon-grid">
          <div class="coupon-card merchant" v-for="coupon in merchantCoupons" :key="coupon.id">
            <div class="coupon-tag merchant-tag">店铺券</div>
            <div class="coupon-left">
              <div class="coupon-value">
                <span class="currency" v-if="coupon.type === 1">¥</span>
                <span class="amount">{{ coupon.type === 1 ? coupon.discountAmount : (coupon.discountAmount * 10).toFixed(1) }}</span>
                <span class="unit" v-if="coupon.type === 2">折</span>
              </div>
              <div class="coupon-condition">满{{ coupon.minAmount }}可用</div>
            </div>
            <div class="coupon-right">
              <div class="coupon-name">{{ coupon.name }}</div>
              <div class="coupon-info">
                <span>{{ formatTime(coupon.startTime) }} 至 {{ formatTime(coupon.endTime) }}</span>
              </div>
              <div class="coupon-stats">
                <span>已发 {{ coupon.totalCount - coupon.remainingCount }}/{{ coupon.totalCount }}</span>
                <span>每人限领 {{ coupon.perUserLimit }} 张</span>
              </div>
              <div class="coupon-rules">
                <el-tag size="small" type="info">{{ getLevelText(coupon.couponLevel) }}</el-tag>
                <el-tag size="small" :type="coupon.status === 1 ? 'success' : 'info'">
                  {{ coupon.status === 1 ? '已启用' : '未启用' }}
                </el-tag>
              </div>
              <div class="coupon-desc">{{ coupon.description }}</div>
              <div class="coupon-actions">
                <el-button size="small" :type="coupon.status === 1 ? 'warning' : 'success'" @click="toggleStatus(coupon)">
                  {{ coupon.status === 1 ? '停用' : '启用' }}
                </el-button>
                <el-button size="small" type="info" @click="viewCouponDetail(coupon)">详情</el-button>
              </div>
            </div>
          </div>
        </div>
        <el-empty v-if="merchantCoupons.length === 0" description="暂无店铺优惠券" />
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="joinDialogVisible" title="报名平台优惠券活动" width="500px">
      <el-form :model="joinForm" label-width="100px">
        <el-form-item label="优惠券名称">
          <span>{{ currentCoupon?.name }}</span>
        </el-form-item>
        <el-form-item label="优惠类型">
          <span>{{ getTypeText(currentCoupon?.type) }}</span>
        </el-form-item>
        <el-form-item label="使用门槛">
          <span>满{{ currentCoupon?.minAmount }}元可用</span>
        </el-form-item>
        <el-form-item label="适用范围">
          <span>{{ getScopeText(currentCoupon?.scopeType) }}</span>
        </el-form-item>
        <el-form-item label="参与方式">
          <el-radio-group v-model="joinType">
            <el-radio :value="0">全店参与</el-radio>
            <el-radio :value="1">指定商品</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="选择商品" v-if="joinType === 1">
          <el-select v-model="joinForm.productId" filterable placeholder="请选择商品" style="width: 100%;">
            <el-option
              v-for="p in productList"
              :key="p.id"
              :label="p.name"
              :value="p.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="joinDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitJoin">确认报名</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="createDialogVisible" title="创建店铺优惠券" width="600px">
      <el-form :model="createForm" label-width="120px" ref="createFormRef">
        <el-form-item label="优惠券名称" required>
          <el-input v-model="createForm.name" placeholder="请输入优惠券名称" />
        </el-form-item>
        <el-form-item label="优惠券类型" required>
          <el-radio-group v-model="createForm.type">
            <el-radio :value="1">满减券</el-radio>
            <el-radio :value="2">折扣券</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item :label="createForm.type === 1 ? '优惠金额' : '折扣比例'" required>
          <el-input-number v-if="createForm.type === 1" v-model="createForm.discountAmount" :min="1" :step="10" />
          <el-input-number v-else v-model="createForm.discountAmount" :min="0.1" :max="0.99" :step="0.05" />
          <span style="margin-left: 8px; color: #999;" v-if="createForm.type === 2">例如：0.9 表示9折</span>
        </el-form-item>
        <el-form-item label="使用门槛" required>
          <el-input-number v-model="createForm.minAmount" :min="0" :step="50" />
          <span style="margin-left: 8px; color: #999;">元</span>
        </el-form-item>
        <el-form-item label="发行总量" required>
          <el-input-number v-model="createForm.totalCount" :min="1" :step="100" />
          <span style="margin-left: 8px; color: #999;">张</span>
        </el-form-item>
        <el-form-item label="每人限领">
          <el-input-number v-model="createForm.perUserLimit" :min="1" :max="10" />
          <span style="margin-left: 8px; color: #999;">张</span>
        </el-form-item>
        <el-form-item label="优惠券层级" required>
          <el-radio-group v-model="createForm.couponLevel">
            <el-radio :value="2">店铺券（全店通用）</el-radio>
            <el-radio :value="3">单品券（指定商品）</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="适用商品" v-if="createForm.couponLevel === 3">
          <el-select v-model="createForm.productId" filterable placeholder="请选择商品" style="width: 100%;">
            <el-option
              v-for="p in productList"
              :key="p.id"
              :label="p.name"
              :value="p.id"
            />
          </el-select>
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
          <el-input v-model="createForm.description" type="textarea" :rows="2" placeholder="请输入使用说明" />
        </el-form-item>
        <el-form-item label="新用户专享">
          <el-switch v-model="newUserOnly" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitCreate">创建</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="detailDialogVisible" title="优惠券详情" width="500px">
      <div v-if="currentCoupon" class="coupon-detail">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="优惠券名称">{{ currentCoupon.name }}</el-descriptions-item>
          <el-descriptions-item label="类型">{{ getTypeText(currentCoupon.type) }}</el-descriptions-item>
          <el-descriptions-item label="优惠力度">
            <span v-if="currentCoupon.type === 1">满{{ currentCoupon.minAmount }}减{{ currentCoupon.discountAmount }}</span>
            <span v-else>{{ (currentCoupon.discountAmount * 10).toFixed(1) }}折</span>
          </el-descriptions-item>
          <el-descriptions-item label="发行总量">{{ currentCoupon.totalCount }} 张</el-descriptions-item>
          <el-descriptions-item label="剩余数量">{{ currentCoupon.remainingCount }} 张</el-descriptions-item>
          <el-descriptions-item label="每人限领">{{ currentCoupon.perUserLimit }} 张</el-descriptions-item>
          <el-descriptions-item label="有效期">
            {{ formatTime(currentCoupon.startTime) }} 至 {{ formatTime(currentCoupon.endTime) }}
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentCoupon.status === 1 ? 'success' : 'info'">
              {{ currentCoupon.status === 1 ? '已启用' : '未启用' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="使用说明">{{ currentCoupon.description || '-' }}</el-descriptions-item>
        </el-descriptions>
        <div class="rule-section">
          <h4>使用规则说明</h4>
          <ul>
            <li>本优惠券仅限本店铺商品使用</li>
            <li>订单金额需满足最低消费门槛</li>
            <li v-if="currentCoupon.couponLevel === 3">本券为单品券，仅限指定商品使用</li>
            <li>店铺券与单品券互斥，系统自动选择最优</li>
            <li>平台券可与店铺券叠加使用</li>
            <li>优惠券不可兑换现金，不找零</li>
            <li>订单取消后优惠券自动退回</li>
          </ul>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const merchantStore = useMerchantStore()
const merchantId = computed(() => merchantStore.merchantInfo?.id || 0)

const activeTab = ref('platform')
const searchKeyword = ref('')
const scopeFilter = ref<number | null>(null)
const levelFilter = ref<number | null>(null)
const platformCoupons = ref<any[]>([])
const merchantCoupons = ref<any[]>([])
const productList = ref<any[]>([])

const joinDialogVisible = ref(false)
const createDialogVisible = ref(false)
const detailDialogVisible = ref(false)
const currentCoupon = ref<any>(null)
const joinType = ref(0)
const dateRange = ref<any[]>([])
const newUserOnly = ref(false)

const joinForm = reactive({
  templateId: 0,
  merchantId: 0,
  productId: null as number | null
})

const createForm = reactive({
  name: '',
  type: 1,
  discountAmount: 10,
  minAmount: 100,
  totalCount: 1000,
  perUserLimit: 1,
  couponLevel: 2,
  productId: null as number | null,
  description: '',
  merchantId: 0
})

function formatTime(t: string) {
  return t ? t.replace('T', ' ').slice(0, 16) : ''
}

function getTypeText(type: number) {
  const types: Record<number, string> = {
    1: '满减券',
    2: '折扣券',
    3: '固定金额券'
  }
  return types[type] || '未知'
}

function getScopeText(scope: number) {
  const scopes: Record<number, string> = {
    1: '全平台通用',
    2: '指定店铺',
    3: '指定商品',
    4: '指定类目'
  }
  return scopes[scope] || '全平台通用'
}

function getLevelText(level: number) {
  const levels: Record<number, string> = {
    1: '平台券',
    2: '店铺券',
    3: '单品券'
  }
  return levels[level] || '店铺券'
}

async function loadPlatformCoupons() {
  try {
    const res = await request.get('/coupon/template/active')
    let list = (res.data?.list || []) as any[]
    list = list.filter((c: any) => c.merchantId == null || c.merchantId === undefined || c.merchantId === 0)
    if (searchKeyword.value) {
      list = list.filter((t: any) => t.name.includes(searchKeyword.value))
    }
    if (scopeFilter.value !== null) {
      list = list.filter((t: any) => t.scopeType === scopeFilter.value)
    }
    platformCoupons.value = list
  } catch (e) {
    console.error('加载平台优惠券失败', e)
  }
}

async function loadMerchantCoupons() {
  if (!merchantId.value) return
  try {
    const res = await request.get('/coupon/template/merchant', {
      params: {
        merchantId: merchantId.value,
        page: 1,
        size: 100
      }
    })
    let list = (res.data?.list || []) as any[]
    if (searchKeyword.value) {
      list = list.filter((t: any) => t.name.includes(searchKeyword.value))
    }
    if (levelFilter.value !== null) {
      list = list.filter((t: any) => t.couponLevel === levelFilter.value)
    }
    merchantCoupons.value = list
  } catch (e) {
    console.error('加载店铺优惠券失败', e)
  }
}

async function loadProducts() {
  if (!merchantId.value) return
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
  if (activeTab.value === 'platform') {
    loadPlatformCoupons()
  } else {
    loadMerchantCoupons()
  }
}

function openJoinDialog(coupon: any) {
  currentCoupon.value = coupon
  joinForm.templateId = coupon.id
  joinForm.merchantId = merchantId.value
  joinForm.productId = null
  joinType.value = 0
  loadProducts()
  joinDialogVisible.value = true
}

async function submitJoin() {
  if (joinType.value === 1 && !joinForm.productId) {
    ElMessage.warning('请选择商品')
    return
  }
  joinForm.productId = joinType.value === 0 ? null : joinForm.productId
  try {
    await request.post('/activity/merchant/coupon/join', joinForm)
    ElMessage.success('报名成功，等待审核')
    joinDialogVisible.value = false
  } catch (e) {
    ElMessage.error('报名失败')
  }
}

function openCreateDialog() {
  createForm.name = ''
  createForm.type = 1
  createForm.discountAmount = 10
  createForm.minAmount = 100
  createForm.totalCount = 1000
  createForm.perUserLimit = 1
  createForm.couponLevel = 2
  createForm.productId = null
  createForm.description = ''
  createForm.merchantId = merchantId.value
  dateRange.value = []
  newUserOnly.value = false
  loadProducts()
  createDialogVisible.value = true
}

async function submitCreate() {
  if (!createForm.name) {
    ElMessage.warning('请输入优惠券名称')
    return
  }
  if (!dateRange.value || dateRange.value.length !== 2) {
    ElMessage.warning('请选择有效期')
    return
  }
  if (createForm.couponLevel === 3 && !createForm.productId) {
    ElMessage.warning('请选择适用商品')
    return
  }
  try {
    const data = {
      ...createForm,
      merchantId: merchantId.value,
      remainingCount: createForm.totalCount,
      startTime: dateRange.value[0],
      endTime: dateRange.value[1],
      status: 1,
      scopeType: createForm.couponLevel === 3 ? 3 : 2,
      scopeIds: createForm.couponLevel === 3 ? JSON.stringify([createForm.productId]) : null,
      mutuallyExclusive: 1,
      userType: newUserOnly.value ? 1 : 0,
      memberLevel: 0
    }
    await request.post('/coupon/template/create', data)
    ElMessage.success('创建成功')
    createDialogVisible.value = false
    loadMerchantCoupons()
  } catch (e: any) {
    ElMessage.error(e?.message || '创建失败')
  }
}

async function toggleStatus(coupon: any) {
  try {
    const newStatus = coupon.status === 1 ? 0 : 1
    await request.put(`/coupon/template/${coupon.id}/status`, { status: newStatus })
    ElMessage.success('操作成功')
    coupon.status = newStatus
  } catch (e) {
    ElMessage.error('操作失败')
  }
}

function viewCouponDetail(coupon: any) {
  currentCoupon.value = coupon
  detailDialogVisible.value = true
}

onMounted(() => {
  loadPlatformCoupons()
})
</script>

<style lang="scss" scoped>
.coupon-list {
  padding: 20px;
}

.toolbar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.coupon-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.coupon-card {
  background: #fff;
  border-radius: 8px;
  display: flex;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  position: relative;

  .coupon-tag {
    position: absolute;
    top: 0;
    right: 0;
    padding: 4px 12px;
    font-size: 12px;
    color: #fff;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 0 8px 0 8px;
    z-index: 1;

    &.merchant-tag {
      background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
  }

  .coupon-left {
    width: 140px;
    background: linear-gradient(135deg, #ff6b6b 0%, #ee5a5a 100%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 20px 12px;
    color: #fff;

    .coupon-value {
      display: flex;
      align-items: baseline;

      .currency { font-size: 16px; }
      .amount { font-size: 36px; font-weight: bold; }
      .unit { font-size: 16px; }
    }
    .coupon-condition {
      font-size: 12px;
      margin-top: 8px;
      opacity: 0.9;
    }
  }

  &.platform .coupon-left {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  &.merchant .coupon-left {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }

  .coupon-right {
    flex: 1;
    padding: 20px 16px 16px;
    display: flex;
    flex-direction: column;
    gap: 6px;

    .coupon-name {
      font-size: 15px;
      font-weight: bold;
      color: #333;
      margin-top: 4px;
    }
    .coupon-info {
      font-size: 12px;
      color: #999;
    }
    .coupon-stats {
      font-size: 12px;
      color: #666;
      display: flex;
      gap: 16px;
    }
    .coupon-rules {
      display: flex;
      gap: 6px;
      flex-wrap: wrap;
      margin: 4px 0;
    }
    .coupon-desc {
      font-size: 12px;
      color: #999;
      line-height: 1.4;
    }
    .coupon-actions {
      display: flex;
      gap: 8px;
      margin-top: auto;
      padding-top: 8px;
    }
  }
}

.coupon-detail {
  .rule-section {
    margin-top: 16px;
    padding: 12px;
    background: #f9f9f9;
    border-radius: 4px;

    h4 {
      margin: 0 0 8px 0;
      font-size: 14px;
      color: #333;
    }

    ul {
      margin: 0;
      padding-left: 20px;
      font-size: 13px;
      color: #666;
      line-height: 2;
    }
  }
}
</style>
