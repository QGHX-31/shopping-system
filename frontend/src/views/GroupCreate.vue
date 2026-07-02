<template>
  <div class="group-create-page">
    <Header />
    <div class="container">
      <h2 class="page-title">发起拼团</h2>

      <div v-if="loading" class="loading-wrap">
        <el-icon :size="48" class="loading-icon"><Loading /></el-icon>
        <p>加载中...</p>
      </div>

      <div v-else class="checkout-content">
        <div class="section-card">
          <div class="section-header">
            <h3>拼团商品</h3>
          </div>
          <div v-if="activity" class="group-product-info">
            <img :src="activity.imageUrl || defaultImg" :alt="activity.productName" class="product-img" />
            <div class="product-detail">
              <h4 class="product-name">{{ activity.productName }}</h4>
              <div class="price-row">
                <span class="group-price">¥{{ Number(activity.groupPrice).toFixed(2) }}</span>
                <span class="original-price">¥{{ Number(activity.originalPrice).toFixed(2) }}</span>
                <el-tag type="success" size="small">{{ activity.requiredNum }}人成团</el-tag>
              </div>
              <div class="group-tip">
                <el-icon><InfoFilled /></el-icon>
                <span>拼团成功后发货，失败自动退款</span>
              </div>
            </div>
          </div>
        </div>

        <div class="section-card">
          <div class="section-header">
            <h3>收货地址</h3>
          </div>
          <div v-if="selectedAddress" class="selected-address-card" @click="showAddressPicker = true">
            <div class="addr-icon">
              <el-icon :size="22"><Location /></el-icon>
            </div>
            <div class="addr-info">
              <div class="addr-top">
                <span class="addr-name">{{ selectedAddress.name }}</span>
                <span class="addr-phone">{{ selectedAddress.phone }}</span>
                <el-tag v-if="selectedAddress.isDefault === 1 || selectedAddress.isDefault === true" type="danger" size="small">默认</el-tag>
              </div>
              <div class="addr-detail-text">
                {{ selectedAddress.province }} {{ selectedAddress.city }} {{ selectedAddress.district }} {{ selectedAddress.detail }}
              </div>
            </div>
            <div class="addr-arrow">
              <el-icon :size="18"><ArrowRight /></el-icon>
            </div>
          </div>
          <div v-else class="no-address-tip" @click="showAddressPicker = true">
            <el-icon :size="20" color="#999"><Location /></el-icon>
            <span>请添加收货地址</span>
            <el-icon :size="18" color="#ccc"><ArrowRight /></el-icon>
          </div>
        </div>

        <div class="section-card">
          <div class="section-header"><h3>订单备注</h3></div>
          <el-input
            v-model="remark"
            type="textarea"
            :rows="2"
            placeholder="选填，建议留言前先与商家协商一致"
            maxlength="200"
            show-word-limit
          />
        </div>

        <div class="checkout-bar">
          <div class="bar-info">
            <div class="info-row">
              <span>商品金额：</span>
              <span class="value">¥{{ Number(activity?.groupPrice || 0).toFixed(2) }}</span>
            </div>
            <div class="info-row">
              <span>运费：</span>
              <span class="value">{{ shippingFee === 0 ? '免邮' : '¥' + shippingFee.toFixed(2) }}</span>
            </div>
            <div class="info-row total">
              <span>实付：</span>
              <span class="value price">¥{{ finalAmount.toFixed(2) }}</span>
            </div>
          </div>
          <el-button
            type="success"
            size="large"
            class="submit-btn"
            :disabled="!selectedAddress || !activity || submitting"
            :loading="submitting"
            @click="handleSubmit"
          >
            提交拼团
          </el-button>
        </div>
      </div>
    </div>
    <Footer />

    <el-dialog v-model="showAddressPicker" title="选择收货地址" width="620px" @close="showAddressForm = false">
      <div v-if="!showAddressForm" class="address-picker-list">
        <div v-if="addresses.length === 0" class="empty-tip">
          <el-empty description="暂无收货地址" :image-size="80" />
        </div>
        <div v-else class="addr-picker-items">
          <div
            v-for="addr in addresses"
            :key="addr.id"
            class="addr-picker-item"
            :class="{ active: selectedAddressId === addr.id }"
            @click="pickAddress(addr.id)"
          >
            <div class="picker-radio">
              <el-radio :model-value="selectedAddressId" :label="addr.id" />
            </div>
            <div class="picker-info">
              <div class="picker-top">
                <span class="picker-name">{{ addr.name }}</span>
                <span class="picker-phone">{{ addr.phone }}</span>
                <el-tag v-if="addr.isDefault === 1 || addr.isDefault === true" type="danger" size="small" effect="dark">默认</el-tag>
              </div>
              <div class="picker-addr">
                {{ addr.province }} {{ addr.city }} {{ addr.district }} {{ addr.detail }}
              </div>
            </div>
            <div class="picker-actions">
              <el-button type="primary" link size="small" @click.stop="editAddress(addr)">
                <el-icon><Edit /></el-icon>编辑
              </el-button>
              <el-button type="danger" link size="small" @click.stop="deleteAddress(addr.id)">
                <el-icon><Delete /></el-icon>删除
              </el-button>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="address-form">
        <el-form :model="addressForm" label-width="80px">
          <el-form-item label="收货人">
            <el-input v-model="addressForm.name" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="addressForm.phone" placeholder="请输入手机号" maxlength="11" />
          </el-form-item>
          <el-form-item label="省份">
            <el-select v-model="addressForm.province" placeholder="请选择省份" filterable style="width: 100%" @change="onProvinceChange">
              <el-option v-for="p in provinces" :key="p" :label="p" :value="p" />
            </el-select>
          </el-form-item>
          <el-form-item label="城市">
            <el-select v-model="addressForm.city" placeholder="请选择城市" filterable :disabled="!addressForm.province" style="width: 100%" @change="onCityChange">
              <el-option v-for="c in availableCities" :key="c" :label="c" :value="c" />
            </el-select>
          </el-form-item>
          <el-form-item label="区/县">
            <el-select v-model="addressForm.district" placeholder="请选择区/县" filterable :disabled="!addressForm.city" clearable style="width: 100%">
              <el-option v-for="d in availableDistricts" :key="d" :label="d" :value="d" />
            </el-select>
          </el-form-item>
          <el-form-item label="详细地址">
            <el-input v-model="addressForm.detail" placeholder="街道、楼牌号等" />
          </el-form-item>
          <el-form-item label="设为默认">
            <el-switch v-model="addressForm.isDefault" />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <template v-if="showAddressForm">
          <el-button @click="backToList">返回</el-button>
          <el-button type="primary" @click="saveAddress">保存</el-button>
        </template>
        <template v-else>
          <el-button @click="showAddressPicker = false">关闭</el-button>
          <el-button type="primary" @click="addNewAddress">
            <el-icon><Plus /></el-icon>新增收货地址
          </el-button>
        </template>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Loading, Plus, InfoFilled, Edit, Delete, Location, ArrowRight } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import request from '@/utils/request'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { CHINA_REGIONS, PROVINCES } from '@/utils/regions'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const loading = ref(true)
const submitting = ref(false)
const activity = ref<any>(null)
const addresses = ref<any[]>([])
const selectedAddressId = ref<number | null>(null)
const remark = ref('')
const showAddressPicker = ref(false)
const showAddressForm = ref(false)
const editingAddressId = ref<number | null>(null)
const addressForm = ref({
  name: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: true
})

const defaultImg = 'https://via.placeholder.com/240x240/f5f5f5/ccc?text=商品'

const provinces = ref<string[]>(PROVINCES)
const availableCities = computed(() => {
  if (!addressForm.value.province) return []
  return Object.keys(CHINA_REGIONS[addressForm.value.province] || {})
})
const availableDistricts = computed(() => {
  if (!addressForm.value.province || !addressForm.value.city) return []
  return CHINA_REGIONS[addressForm.value.province]?.[addressForm.value.city] || []
})

function onProvinceChange() {
  addressForm.value.city = ''
  addressForm.value.district = ''
}
function onCityChange() {
  addressForm.value.district = ''
}

const selectedAddress = computed(() => {
  return addresses.value.find(a => a.id === selectedAddressId.value)
    || addresses.value.find(a => a.isDefault)
    || addresses.value[0]
})

const shippingFee = computed(() => {
  const price = Number(activity.value?.groupPrice || 0)
  return price >= 99 ? 0 : 10
})

const finalAmount = computed(() => {
  const price = Number(activity.value?.groupPrice || 0)
  return Math.max(0, price + shippingFee.value)
})

function pickAddress(addrId: number) {
  selectedAddressId.value = addrId
  showAddressPicker.value = false
}

async function loadData() {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    return router.push({ path: '/login', query: { redirect: route.fullPath } })
  }

  if (!userStore.userInfo?.id) {
    await userStore.getUserInfo()
  }

  loading.value = true
  try {
    const productId = route.query.productId
    if (!productId) {
      ElMessage.warning('参数错误')
      router.back()
      return
    }

    const groupRes = await request.get(`/group/product/${productId}`)
    const groupInfo = groupRes.data
    if (!groupInfo || !groupInfo.hasGroupBuy) {
      ElMessage.warning('该商品未开启拼团')
      router.back()
      return
    }

    const productRes = await request.get(`/product/${productId}`)
    const product = productRes.data

    activity.value = {
      id: 0,
      productId: productId,
      productName: product?.name || '拼团商品',
      imageUrl: product?.imageUrl || '',
      groupPrice: groupInfo.groupPrice,
      originalPrice: product?.originalPrice || product?.price || 0,
      requiredNum: groupInfo.groupNum || 2
    }

    await loadAddresses()
  } catch (e) {
    console.error('加载拼团信息失败:', e)
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

async function loadAddresses() {
  try {
    const res = await request.get('/address/list', { params: { userId: userStore.userInfo?.id } })
    addresses.value = res.data || []
    const def = addresses.value.find((a: any) => a.isDefault)
    if (def) selectedAddressId.value = def.id
  } catch (e) {
    addresses.value = []
  }
}

function addNewAddress() {
  editingAddressId.value = null
  addressForm.value = {
    name: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detail: '',
    isDefault: addresses.value.length === 0
  }
  showAddressForm.value = true
}

function editAddress(addr: any) {
  editingAddressId.value = addr.id
  addressForm.value = {
    name: addr.name,
    phone: addr.phone,
    province: addr.province,
    city: addr.city,
    district: addr.district,
    detail: addr.detail,
    isDefault: addr.isDefault === 1 || addr.isDefault === true
  }
  showAddressForm.value = true
}

function backToList() {
  showAddressForm.value = false
  editingAddressId.value = null
}

async function saveAddress() {
  if (!addressForm.value.name || !addressForm.value.phone) {
    ElMessage.warning('请填写姓名和手机号')
    return
  }
  if (!addressForm.value.province || !addressForm.value.city) {
    ElMessage.warning('请选择省/市')
    return
  }
  try {
    const payload = {
      ...addressForm.value,
      isDefault: addressForm.value.isDefault ? 1 : 0,
      userId: userStore.userInfo?.id
    }
    if (editingAddressId.value) {
      await request.put('/address/update', {
        ...payload,
        id: editingAddressId.value
      })
      ElMessage.success('地址修改成功')
    } else {
      await request.post('/address/create', payload)
      ElMessage.success('地址添加成功')
    }
    const isNew = !editingAddressId.value
    showAddressForm.value = false
    editingAddressId.value = null
    await loadAddresses()
    if (isNew) {
      const newest = addresses.value[addresses.value.length - 1]
      if (newest) {
        selectedAddressId.value = newest.id
      }
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '保存地址失败')
  }
}

async function deleteAddress(id: number) {
  try {
    await ElMessageBox.confirm('确定要删除该地址吗？', '删除确认', {
      type: 'warning',
      confirmButtonText: '删除',
      cancelButtonText: '取消'
    })
    await request.delete('/address/delete', {
      params: {
        userId: userStore.userInfo?.id,
        id
      }
    })
    ElMessage.success('删除成功')
    await loadAddresses()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e?.response?.data?.message || e?.message || '删除失败')
    }
  }
}

async function handleSubmit() {
  if (!selectedAddress.value) {
    ElMessage.warning('请选择收货地址')
    return
  }
  if (!activity.value) {
    ElMessage.warning('拼团信息加载失败')
    return
  }

  submitting.value = true
  try {
    const userId = userStore.userInfo?.id
    const productId = activity.value.productId

    // 1. 创建拼团团队
    const teamRes = await request.post('/group/team/product', null, {
      params: {
        productId: productId,
        userId: userId
      }
    })
    const team = teamRes.data?.team
    if (!team || !team.teamNo) {
      throw new Error(teamRes.data?.message || '创建拼团团队失败')
    }

    // 2. 创建关联订单
    const orderData = {
      userId: userId,
      items: [{
        productId: productId,
        quantity: 1
      }],
      addressId: selectedAddress.value.id,
      remark: remark.value,
      groupTeamNo: team.teamNo,
      groupPrice: activity.value.groupPrice
    }

    const orderRes = await request.post('/order/create', orderData)

    ElMessage.success('拼团发起成功！')
    router.push({
      path: '/order/pay',
      query: { orderNo: orderRes.data?.orderNo, groupTeamNo: team.teamNo }
    })
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.group-create-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 120px;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-title {
  font-size: 24px;
  color: #333;
  margin-bottom: 20px;
}

.loading-wrap {
  text-align: center;
  padding: 80px 0;
  background: #fff;
  border-radius: 8px;
}
.loading-icon {
  animation: spin 1s linear infinite;
  color: #67c23a;
}
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.section-card {
  background: #fff;
  border-radius: 8px;
  padding: 25px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #f0f0f0;

    h3 {
      font-size: 16px;
      color: #333;
      font-weight: 600;
    }
  }
}

.group-product-info {
  display: flex;
  gap: 20px;

  .product-img {
    width: 120px;
    height: 120px;
    object-fit: cover;
    border-radius: 8px;
    background: #f5f5f5;
  }

  .product-detail {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    gap: 10px;

    .product-name {
      font-size: 16px;
      font-weight: 600;
      color: #333;
      margin: 0;
    }

    .price-row {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .group-price {
      color: #67c23a;
      font-size: 26px;
      font-weight: bold;
    }

    .original-price {
      color: #999;
      text-decoration: line-through;
      font-size: 14px;
    }

    .group-tip {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: #e6a23c;
      margin-top: 8px;
    }
  }
}

.selected-address-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  border: 2px solid #67c23a;
  border-radius: 10px;
  background: linear-gradient(135deg, #f0f9eb 0%, #ffffff 100%);
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    box-shadow: 0 4px 12px rgba(103, 194, 58, 0.15);
  }

  .addr-icon {
    flex-shrink: 0;
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #67c23a;
    color: #fff;
    border-radius: 50%;
  }

  .addr-info {
    flex: 1;
    min-width: 0;

    .addr-top {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 6px;

      .addr-name {
        font-size: 16px;
        font-weight: 600;
        color: #333;
      }
      .addr-phone {
        font-size: 14px;
        color: #666;
      }
    }

    .addr-detail-text {
      font-size: 14px;
      color: #666;
      line-height: 1.5;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .addr-arrow {
    flex-shrink: 0;
    color: #999;
  }
}

.no-address-tip {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 20px;
  border: 2px dashed #ddd;
  border-radius: 10px;
  cursor: pointer;
  color: #999;
  font-size: 14px;
  transition: all 0.2s;

  &:hover {
    border-color: #67c23a;
    color: #67c23a;
  }

  &:last-child {
    margin-left: auto;
  }
}

.address-picker-list {
  max-height: 480px;
  overflow-y: auto;
  padding-right: 8px;

  .empty-tip {
    padding: 40px 0;
  }

  .addr-picker-items {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .addr-picker-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 16px;
    border: 2px solid #eee;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;

    &:hover {
      border-color: #b3e19d;
      background: #f0f9eb;
    }

    &.active {
      border-color: #67c23a;
      background: #f0f9eb;
    }

    .picker-radio {
      flex-shrink: 0;
      :deep(.el-radio__label) {
        display: none;
      }
    }

    .picker-info {
      flex: 1;
      min-width: 0;

      .picker-top {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 6px;

        .picker-name {
          font-size: 15px;
          font-weight: 600;
          color: #333;
        }
        .picker-phone {
          font-size: 13px;
          color: #666;
        }
      }

      .picker-addr {
        font-size: 13px;
        color: #666;
        line-height: 1.5;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }

    .picker-actions {
      flex-shrink: 0;
      display: flex;
      gap: 6px;
    }
  }
}

.checkout-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding: 15px 30px;
  box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  z-index: 100;

  .bar-info {
    display: flex;
    gap: 25px;
    align-items: center;

    .info-row {
      display: flex;
      gap: 5px;
      font-size: 14px;
      color: #666;
      .value { color: #333; }
      &.total .price {
        font-size: 24px;
        color: #67c23a;
        font-weight: bold;
      }
    }
  }

  .submit-btn {
    height: 50px;
    padding: 0 50px;
    font-size: 16px;
    background: linear-gradient(135deg, #85ce61, #67c23a);
    border: none;
  }
}

.address-form {
  padding: 0 20px;
}
</style>
