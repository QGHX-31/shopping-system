<template>
  <div class="checkout-page">
    <Header />
    <div class="container">
      <h2 class="page-title">订单结算</h2>

      <div v-if="loading" class="loading-wrap">
        <el-icon :size="48" class="loading-icon"><Loading /></el-icon>
        <p>加载中...</p>
      </div>

      <div v-else class="checkout-content">
        <!-- 收货地址 -->
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

        <!-- 商品清单 -->
        <div class="section-card">
          <div class="section-header">
            <h3>商品清单</h3>
            <span class="goods-count">共 {{ orderItems.length }} 件商品</span>
          </div>
          <div class="goods-list">
            <div v-for="item in orderItems" :key="item.productId" class="goods-item">
              <img :src="item.imageUrl || defaultImage" :alt="item.name" class="goods-img" />
              <div class="goods-info">
                <p class="goods-name">{{ item.name }}</p>
                <p class="goods-price">¥{{ formatPrice(item.price) }}</p>
              </div>
              <div class="goods-qty">×{{ item.quantity }}</div>
              <div class="goods-subtotal">¥{{ formatPrice(item.price * item.quantity) }}</div>
            </div>
          </div>
        </div>

        <!-- 优惠信息 -->
        <div class="section-card">
          <div class="section-header">
            <h3>优惠信息</h3>
          </div>
          <div class="coupon-section">
            <div class="coupon-header">
              <span>优惠券</span>
              <span class="coupon-count">
                可用 {{ availableCoupons.length }} 张
              </span>
            </div>
            <div class="coupon-selector-card">
              <div class="coupon-tabs">
                <div class="coupon-tab" :class="{ active: activeCouponTab === 'platform' }" @click="activeCouponTab = 'platform'">
                  平台券 <span class="tab-count">({{ platformCoupons.length }})</span>
                </div>
                <div class="coupon-tab" :class="{ active: activeCouponTab === 'merchant' }" @click="activeCouponTab = 'merchant'">
                  店铺券 <span class="tab-count">({{ merchantCoupons.length }})</span>
                </div>
                <div class="coupon-tab" :class="{ active: activeCouponTab === 'single' }" @click="activeCouponTab = 'single'">
                  单品券 <span class="tab-count">({{ singleCoupons.length }})</span>
                </div>
              </div>
              
              <div class="coupon-list">
                <div v-if="currentTabCoupons.length === 0" class="empty-coupons">
                  <el-empty description="暂无可用优惠券" :image-size="60" />
                </div>
                <div 
                  v-for="c in currentTabCoupons" 
                  :key="c.id" 
                  class="coupon-card"
                  :class="{ selected: isCouponSelected(c) }"
                  @click="toggleCoupon(c)"
                >
                  <div class="coupon-left" :class="getCouponLevelClass(c)">
                    <div class="coupon-amount">
                      <span v-if="c.type === 2">{{ (c.discountAmount * 10).toFixed(1) }}折</span>
                      <template v-else>
                        <span class="currency">¥</span>
                        <span class="num">{{ c.discountAmount }}</span>
                      </template>
                    </div>
                    <div class="coupon-condition">{{ c.minAmount && c.minAmount > 0 ? `满${c.minAmount}元可用` : '无门槛' }}</div>
                  </div>
                  <div class="coupon-right">
                    <div class="coupon-name">{{ c.name }}</div>
                    <div class="coupon-scope">
                      <el-tag size="small" type="info">{{ getScopeText(c.scopeType) }}</el-tag>
                    </div>
                    <div class="coupon-expire">至 {{ formatCouponTime(c.expireTime) }} 失效</div>
                    <div class="coupon-select-icon" v-if="isCouponSelected(c)">
                      <el-icon><Check /></el-icon>
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="coupon-tip">
                <el-icon><InfoFilled /></el-icon>
                <span v-if="activeCouponTab === 'merchant'">同店铺只可使用一张，不同店铺可叠加使用</span>
                <span v-else>同层级只可使用一张，不同层级可叠加使用</span>
              </div>
            </div>
            <div v-if="selectedCouponIds.length > 0" class="selected-coupon-info">
              <el-tag type="success" size="small">已选 {{ selectedCouponIds.length }} 张</el-tag>
              <span class="selected-names">{{ selectedCouponsNames }}</span>
              <span class="discount">-¥{{ couponDiscount.toFixed(2) }}</span>
            </div>
            
            <div v-if="receivableCoupons.length > 0" class="receivable-coupons">
              <div class="receivable-header">
                <el-icon><Present /></el-icon>
                <span>有 {{ receivableCoupons.length }} 张优惠券可领取</span>
                <el-button 
                  type="danger" 
                  size="small" 
                  round
                  :loading="receivingAll"
                  @click="handleReceiveAll"
                >
                  一键领取
                </el-button>
              </div>
              <div class="receivable-list">
                <div 
                  v-for="c in receivableCoupons.slice(0, 3)" 
                  :key="c.id" 
                  class="receivable-item"
                >
                  <div class="coupon-info">
                    <span class="coupon-name">{{ c.name }}</span>
                    <span class="coupon-desc">
                      {{ c.type === 1 ? `满${c.minAmount}减${c.discountAmount}` : `${Math.round((1-c.discountAmount)*10)}折` }}
                    </span>
                  </div>
                </div>
                <div v-if="receivableCoupons.length > 3" class="more-coupons">
                  还有 {{ receivableCoupons.length - 3 }} 张可领
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 备注 -->
        <div class="section-card">
          <div class="section-header"><h3>订单备注</h3></div>
          <el-input
            v-model="remark"
            type="textarea"
            :rows="3"
            placeholder="选填，建议留言前先与商家协商一致"
            maxlength="200"
            show-word-limit
          />
        </div>

        <!-- 结算栏 -->
        <div class="checkout-bar">
          <div class="bar-info">
            <div class="info-row">
              <span>商品总额：</span>
              <span class="value">¥{{ formatPrice(totalAmount) }}</span>
            </div>
            <div class="info-row" v-if="couponDiscount > 0">
              <span>优惠券：</span>
              <span class="value discount">-¥{{ formatPrice(couponDiscount) }}</span>
            </div>
            <div class="info-row">
              <span>运费：</span>
              <span class="value">{{ shippingFee === 0 ? '免邮' : '¥' + formatPrice(shippingFee) }}</span>
            </div>
            <div class="info-row total">
              <span>实付：</span>
              <span class="value price">¥{{ formatPrice(finalAmount) }}</span>
            </div>
          </div>
          <el-button
            type="danger"
            size="large"
            class="submit-btn"
            :disabled="!selectedAddress || orderItems.length === 0 || submitting"
            :loading="submitting"
            @click="handleSubmit"
          >
            提交订单
          </el-button>
        </div>
      </div>
    </div>
    <Footer />

    <!-- 地址选择弹窗 -->
    <el-dialog v-model="showAddressPicker" title="选择收货地址" width="620px" @close="showAddressForm = false">
      <!-- 地址列表视图 -->
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

      <!-- 新增/编辑地址表单 -->
      <div v-else class="address-form">
        <el-alert type="info" :closable="false" style="margin-bottom: 16px;">
          <template #title>
            <span style="font-size: 13px;">
              💡 粘贴整段地址（包含收件人、手机号、地址），系统会自动识别填充
            </span>
          </template>
        </el-alert>
        <el-form-item label="智能粘贴">
          <el-input
            v-model="addressPasteText"
            placeholder="例：小明 17625738296 湖北省荆州市荆州区韩可轩镇"
            clearable
            @blur="parseAddressFromPaste"
            @paste="handlePaste"
          />
        </el-form-item>
        <el-divider style="margin: 12px 0">或手动填写</el-divider>

        <el-form :model="addressForm" label-width="80px">
          <el-form-item label="收货人">
            <el-input v-model="addressForm.name" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="addressForm.phone" placeholder="请输入手机号" maxlength="11" />
          </el-form-item>
          <el-form-item label="省份">
            <el-select
              v-model="addressForm.province"
              placeholder="请选择省份"
              filterable
              style="width: 100%"
              @change="onProvinceChange"
            >
              <el-option
                v-for="p in provinces"
                :key="p"
                :label="p"
                :value="p"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="城市">
            <el-select
              v-model="addressForm.city"
              placeholder="请选择城市"
              filterable
              :disabled="!addressForm.province"
              style="width: 100%"
              @change="onCityChange"
            >
              <el-option
                v-for="c in availableCities"
                :key="c"
                :label="c"
                :value="c"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="区/县">
            <el-select
              v-model="addressForm.district"
              placeholder="请选择区/县"
              filterable
              :disabled="!addressForm.city"
              clearable
              style="width: 100%"
            >
              <el-option
                v-for="d in availableDistricts"
                :key="d"
                :label="d"
                :value="d"
              />
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Loading, Plus, Present, InfoFilled, Edit, Delete, Star, Check, Location, ArrowRight } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'
import { useProductStore } from '@/stores/product'
import request from '@/utils/request'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { CHINA_REGIONS, PROVINCES } from '@/utils/regions'
import { parseAddress } from '@/utils/addressParser'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()
const productStore = useProductStore()

const loading = ref(true)
const submitting = ref(false)
const orderItems = ref<any[]>([])
const addresses = ref<any[]>([])
const selectedAddressId = ref<number | null>(null)
const allCoupons = ref<any[]>([])
const availableCoupons = ref<any[]>([])
const receivableCoupons = ref<any[]>([])
const receivingAll = ref(false)
const couponUnusableReasons = ref<Record<number, string>>({})

// 地址粘贴识别
const addressPasteText = ref('')

// 省市区级联数据
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

/** 粘贴/失焦时自动解析 */
function handlePaste(e: ClipboardEvent) {
  const text = e.clipboardData?.getData('text') || addressPasteText.value
  setTimeout(() => applyParsedAddress(text), 50)
}
function parseAddressFromPaste() {
  if (addressPasteText.value) applyParsedAddress(addressPasteText.value)
}
function applyParsedAddress(text: string) {
  const parsed = parseAddress(text)
  if (parsed.name) addressForm.value.name = parsed.name
  if (parsed.phone) addressForm.value.phone = parsed.phone
  if (parsed.province) {
    const matched = provinces.value.find(p => p === parsed.province || p.replace(/[省市]$/, '') === parsed.province)
    if (matched) {
      addressForm.value.province = matched
      if (parsed.city) {
        const cityKey = Object.keys(CHINA_REGIONS[matched] || {}).find(c => c === parsed.city || c.replace(/市$/, '') === parsed.city)
        if (cityKey) addressForm.value.city = cityKey
      }
      if (parsed.district) {
        const distList = CHINA_REGIONS[matched]?.[addressForm.value.city] || []
        const districtKey = distList.find(d => d === parsed.district || d.replace(/(?:区|县|自治县)$/, '') === parsed.district?.replace(/(?:区|县)$/, ''))
        if (districtKey) addressForm.value.district = districtKey
      }
    } else {
      addressForm.value.province = parsed.province + (parsed.province.endsWith('省') ? '' : '省')
    }
  }
  if (parsed.detail) addressForm.value.detail = parsed.detail
  if (parsed.name || parsed.phone) {
    ElMessage.success('已自动识别地址信息，请检查是否正确')
  }
}
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

const defaultImage = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iNDAwIiBoZWlnaHQ9IjQwMCIgZmlsbD0iI2Y1ZjVmNSIvPjx0ZXh0IHg9IjUwJSIgeT0iNTAlIiBkb21pbmFudC1iYXNlbGluZT0ibWlkZGxlIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTgiIGZpbGw9IiM5OTkiPuaaguaXoOWbvueJhzwvdGV4dD48L3N2Zz4='

const selectedAddress = computed(() => {
  return addresses.value.find(a => a.id === selectedAddressId.value)
    || addresses.value.find(a => a.isDefault)
    || addresses.value[0]
})

const totalAmount = computed(() => {
  return orderItems.value.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0)
})

const selectedCouponIds = ref<number[]>([])
const activeCouponTab = ref('platform')

const selectedCoupons = computed(() => {
  return allCoupons.value.filter(c => selectedCouponIds.value.includes(c.id))
})

const usableCoupons = computed(() => {
  return allCoupons.value.filter(c => isCouponUsable(c))
})

function dedupByTemplate(coupons: any[]) {
  const map = new Map<number, any>()
  for (const c of coupons) {
    const tplId = c.templateId || c.id
    if (!map.has(tplId)) {
      map.set(tplId, c)
    } else {
      const existing = map.get(tplId)
      if (c.expireTime && existing.expireTime && c.expireTime > existing.expireTime) {
        map.set(tplId, c)
      }
    }
  }
  return Array.from(map.values())
}

const platformCoupons = computed(() => {
  return dedupByTemplate(usableCoupons.value.filter(c => (c.couponLevel || 1) === 1))
})

const merchantCoupons = computed(() => {
  return dedupByTemplate(usableCoupons.value.filter(c => (c.couponLevel || 1) === 2))
})

const singleCoupons = computed(() => {
  return dedupByTemplate(usableCoupons.value.filter(c => (c.couponLevel || 1) === 3))
})

const currentTabCoupons = computed(() => {
  if (activeCouponTab.value === 'platform') return platformCoupons.value
  if (activeCouponTab.value === 'merchant') return merchantCoupons.value
  if (activeCouponTab.value === 'single') return singleCoupons.value
  return []
})

function isCouponSelected(coupon: any) {
  return selectedCouponIds.value.includes(coupon.id)
}

function toggleCoupon(coupon: any) {
  if (!isCouponUsable(coupon)) return

  if (isCouponSelected(coupon)) {
    selectedCouponIds.value = selectedCouponIds.value.filter(id => id !== coupon.id)
  } else {
    const level = coupon.couponLevel || 1
    if (level === 2) {
      // 店铺券：同商家只能选1张
      const merchantId = coupon.merchantId
      selectedCouponIds.value = selectedCouponIds.value.filter(id => {
        const c = allCoupons.value.find(x => x.id === id)
        return !c || (c.couponLevel || 1) !== 2 || c.merchantId !== merchantId
      })
    } else {
      // 平台券/单品券：同层级只能选1张
      selectedCouponIds.value = selectedCouponIds.value.filter(id => {
        const c = allCoupons.value.find(x => x.id === id)
        return !c || (c.couponLevel || 1) !== level
      })
    }
    selectedCouponIds.value.push(coupon.id)
  }
}

function getCouponLevelClass(coupon: any) {
  const level = coupon.couponLevel || 1
  if (level === 1) return 'platform'
  if (level === 2) return 'merchant'
  return 'single'
}

function getScopeText(scope: number) {
  const scopes: Record<number, string> = {
    1: '全平台通用',
    2: '指定店铺',
    3: '指定商品',
    4: '指定类目'
  }
  return scopes[scope] || '通用'
}

function formatCouponTime(s: string) { 
  return s ? s.replace('T', ' ').slice(0, 16) : '' 
}

const selectedCouponsNames = computed(() => {
  return selectedCoupons.value.map(c => c.name).join('、')
})

function calcSingleCouponDiscount(coupon: any, amount: number): number {
  if (!coupon || !isCouponUsable(coupon)) return 0
  const discountAmount = Number(coupon.discountAmount || coupon.amount)
  const type = coupon.type
  if (type === 2) {
    const rate = discountAmount
    return Number((amount * (1 - rate)).toFixed(2))
  }
  return Math.min(discountAmount, amount)
}

// 各商家商品金额（用于店铺券计算）
const merchantAmountMap = computed(() => {
  const map: Record<number, number> = {}
  for (const item of orderItems.value) {
    const mid = item.merchantId || 0
    map[mid] = (map[mid] || 0) + Number(item.price) * item.quantity
  }
  return map
})

const couponDiscount = computed(() => {
  if (selectedCoupons.value.length === 0) return 0

  let totalDiscount = 0
  for (const c of selectedCoupons.value) {
    const level = c.couponLevel || 1
    let baseAmount = totalAmount.value
    if (level === 2 && c.merchantId != null) {
      baseAmount = merchantAmountMap.value[c.merchantId] || 0
    }
    totalDiscount += calcSingleCouponDiscount(c, baseAmount)
  }

  return Number(Math.min(totalDiscount, totalAmount.value).toFixed(2))
})

const merchantId = computed(() => {
  if (orderItems.value.length === 0) return null
  const firstItem = orderItems.value[0]
  return firstItem.merchantId || null
})

const singleMerchantId = computed(() => {
  const uniqueMerchants = [...new Set(orderItems.value.map((i: any) => i.merchantId).filter(Boolean))]
  return uniqueMerchants.length === 1 ? uniqueMerchants[0] : null
})

const productIds = computed(() => {
  return orderItems.value.map((item: any) => item.productId).filter(Boolean)
})

const categoryIds = computed(() => {
  return [...new Set(orderItems.value.map((item: any) => item.categoryId).filter(Boolean))]
})

function isCouponUsable(coupon: any): boolean {
  if (!coupon) return false
  if (coupon.status !== 0) return false
  if (coupon.expireTime && new Date(coupon.expireTime).getTime() < Date.now()) return false

  const minAmount = Number(coupon.minAmount || 0)
  if (minAmount > 0) {
    let baseAmount = totalAmount.value
    if ((coupon.couponLevel || 1) === 2 && coupon.merchantId != null) {
      baseAmount = merchantAmountMap.value[coupon.merchantId] || 0
    }
    if (baseAmount < minAmount) return false
  }

  const reason = couponUnusableReasons.value[coupon.id]
  if (reason) return false

  return true
}

function getCouponUnusableReason(coupon: any): string {
  if (!coupon) return ''
  if (coupon.status === 1) return '已使用'
  if (coupon.status === 2) return '已过期'
  if (coupon.expireTime && new Date(coupon.expireTime).getTime() < Date.now()) return '已过期'

  const minAmount = Number(coupon.minAmount || 0)
  if (minAmount > 0) {
    let baseAmount = totalAmount.value
    if ((coupon.couponLevel || 1) === 2 && coupon.merchantId != null) {
      baseAmount = merchantAmountMap.value[coupon.merchantId] || 0
    }
    if (baseAmount < minAmount) {
      return `满${minAmount}可用`
    }
  }

  return couponUnusableReasons.value[coupon.id] || '不可用'
}

function formatCouponValue(coupon: any): string {
  if (!coupon) return ''
  const type = coupon.type
  const discountAmount = Number(coupon.discountAmount || coupon.amount)
  if (type === 2) {
    const discountTenths = discountAmount * 10
    if (discountTenths === Math.floor(discountTenths)) {
      return `${Math.floor(discountTenths)}折`
    }
    return `${discountTenths.toFixed(1)}折`
  }
  return `减¥${discountAmount}`
}

function canSelectCoupon(coupon: any): boolean {
  if (!isCouponUsable(coupon)) return false

  const level = coupon.couponLevel || 1

  if (level === 2) {
    // 店铺券：同商家只能选1张
    const selectedSameMerchant = selectedCoupons.value.filter(c =>
      (c.couponLevel || 1) === 2 && c.merchantId === coupon.merchantId
    )
    if (selectedSameMerchant.length === 0) return true
    return selectedSameMerchant.some(c => c.id === coupon.id)
  }

  // 平台券/单品券：同层级只能选1张
  const selectedSameLevel = selectedCoupons.value.filter(c => (c.couponLevel || 1) === level)
  if (selectedSameLevel.length === 0) return true
  return selectedSameLevel.some(c => c.id === coupon.id)
}

function onCouponChange() {
  const validIds: number[] = []
  const levelBestCoupon: Record<number, any> = {}
  const merchantBestCoupon: Record<number, any> = {}

  for (const id of selectedCouponIds.value) {
    const c = allCoupons.value.find(x => x.id === id)
    if (!c || !isCouponUsable(c)) continue

    const level = c.couponLevel || 1

    if (level === 2) {
      // 店铺券：同商家保留最划算的一张
      const mid = c.merchantId || 0
      if (!merchantBestCoupon[mid]) {
        merchantBestCoupon[mid] = c
        validIds.push(id)
      } else {
        const current = merchantBestCoupon[mid]
        if (calcCouponDiscount(c) > calcCouponDiscount(current)) {
          const idx = validIds.indexOf(current.id)
          if (idx !== -1) validIds[idx] = id
          merchantBestCoupon[mid] = c
        }
      }
    } else {
      // 平台券/单品券：同层级保留最划算的一张
      if (!levelBestCoupon[level]) {
        levelBestCoupon[level] = c
        validIds.push(id)
      } else {
        const current = levelBestCoupon[level]
        if (calcCouponDiscount(c) > calcCouponDiscount(current)) {
          const idx = validIds.indexOf(current.id)
          if (idx !== -1) validIds[idx] = id
          levelBestCoupon[level] = c
        }
      }
    }
  }

  if (validIds.length !== selectedCouponIds.value.length) {
    selectedCouponIds.value = validIds
  }
}

function calcCouponDiscount(coupon: any): number {
  if (!coupon) return 0
  const level = coupon.couponLevel || 1
  let baseAmount = totalAmount.value || 0
  if (level === 2 && coupon.merchantId != null) {
    baseAmount = merchantAmountMap.value[coupon.merchantId] || 0
  }
  const type = coupon.type
  const discountAmount = Number(coupon.discountAmount || coupon.amount || 0)
  if (type === 2) {
    return (1 - discountAmount) * baseAmount
  }
  return Math.min(discountAmount, baseAmount)
}

const shippingFee = computed(() => {
  return totalAmount.value >= 99 ? 0 : 10
})

const finalAmount = computed(() => {
  return Math.max(0, totalAmount.value - couponDiscount.value + shippingFee.value)
})

function formatPrice(price: any): string {
  if (price == null) return '0.00'
  return Number(price).toFixed(2)
}

function selectAddress(addrId: number) {
  selectedAddressId.value = addrId
}

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
    await loadAddresses()

    const cartIds = route.query.cartIds as string
    const productId = route.query.productId as string
    
    if (cartIds) {
      const cartIdList = cartIds.split(',').map(id => parseInt(id)).filter(id => !isNaN(id))
      await cartStore.getCartList()
      const selectedCartItems = cartStore.cartItems.filter((i: any) => cartIdList.includes(i.id))
      if (selectedCartItems.length === 0) {
        ElMessage.warning('请先选择要结算的商品')
        router.push('/cart')
        return
      }
      orderItems.value = selectedCartItems.map((item: any) => ({
        productId: item.productId,
        name: item.productName,
        imageUrl: item.productImage,
        price: item.price,
        quantity: item.quantity,
        merchantId: item.merchantId,
        categoryId: item.categoryId,
        cartId: item.id
      }))
    } else if (productId) {
      const pid = parseInt(productId)
      const quantity = parseInt(route.query.quantity as string) || 1
      const res = await productStore.getProductDetail(pid)
      const p = res.data
      orderItems.value = [{
        productId: p.id,
        name: p.name,
        imageUrl: p.imageUrl,
        price: p.price,
        merchantId: p.merchantId,
        categoryId: p.categoryId,
        quantity
      }]
    } else {
      ElMessage.warning('订单信息不完整')
      router.push('/cart')
      return
    }
    
    await loadCoupons()
    await loadReceivableCoupons()
  } catch (e) {
    console.error('加载结算信息失败:', e)
    ElMessage.error('加载结算信息失败')
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

async function loadCoupons() {
  try {
    const res = await request.get('/coupon/mine', { 
      params: { userId: userStore.userInfo?.id, status: 0, page: 1, size: 100 } 
    })
    allCoupons.value = res.data?.list || []
    
    await checkCouponsUsable()
  } catch (e) {
    allCoupons.value = []
    availableCoupons.value = []
  }
}

async function checkCouponsUsable() {
  couponUnusableReasons.value = {}
  availableCoupons.value = []
  
  if (allCoupons.value.length === 0) return
  
  try {
    const params: any = {
      userId: userStore.userInfo?.id,
      orderAmount: totalAmount.value
    }
    if (singleMerchantId.value) params.merchantId = singleMerchantId.value
    if (productIds.value.length > 0) params.productIds = productIds.value.join(',')
    if (categoryIds.value.length > 0) params.categoryIds = categoryIds.value.join(',')

    const res = await request.get('/coupon/user/available', { params })
    const usableList: any[] = res.data || []
    const usableIds = new Set(usableList.map(c => c.id))

    availableCoupons.value = allCoupons.value.filter(c => usableIds.has(c.id))

    for (const coupon of allCoupons.value) {
      if (!usableIds.has(coupon.id)) {
        if (coupon.templateId) {
          try {
            const checkRes = await request.post('/coupon/check-usable', null, {
              params: {
                userCouponId: coupon.id,
                userId: userStore.userInfo?.id,
                orderAmount: totalAmount.value,
                merchantId: singleMerchantId.value,
                productIds: productIds.value.join(','),
                categoryIds: categoryIds.value.join(',')
              }
            })
            if (checkRes.data && !checkRes.data.usable && checkRes.data.reason) {
              couponUnusableReasons.value[coupon.id] = checkRes.data.reason
            }
          } catch (e) {
            // 忽略单个检查错误
          }
        }
      }
    }
  } catch (e) {
    console.error('检查优惠券可用性失败', e)
    availableCoupons.value = allCoupons.value.filter(c => {
      const minAmount = Number(c.minAmount || 0)
      return c.status === 0 && (!c.expireTime || new Date(c.expireTime).getTime() >= Date.now())
        && (minAmount <= 0 || totalAmount.value >= minAmount)
    })
  }
}

async function loadReceivableCoupons() {
  if (!userStore.isLogin) {
    receivableCoupons.value = []
    return
  }
  try {
    const params: any = {
      userId: userStore.userInfo?.id
    }
    if (singleMerchantId.value) params.merchantId = singleMerchantId.value
    if (productIds.value.length > 0) params.productIds = productIds.value.join(',')

    const res: any = await request.get('/coupon/receivable', { params })
    receivableCoupons.value = res.data || []
  } catch (e) {
    console.error('加载可领取优惠券失败', e)
    receivableCoupons.value = []
  }
}

async function handleReceiveAll() {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    return
  }
  receivingAll.value = true
  try {
    const params: any = {
      userId: userStore.userInfo?.id
    }
    if (singleMerchantId.value) params.merchantId = singleMerchantId.value
    if (productIds.value.length > 0) params.productIds = productIds.value.join(',')
    
    const res: any = await request.post('/coupon/receive-all', null, { params })
    const successCount = res.data?.successCount || 0
    const failCount = res.data?.failCount || 0
    if (successCount > 0) {
      ElMessage.success(`成功领取 ${successCount} 张优惠券`)
      await loadCoupons()
      await loadReceivableCoupons()
    } else if (failCount > 0) {
      ElMessage.info('部分优惠券领取失败，请稍后重试')
      await loadReceivableCoupons()
    } else {
      ElMessage.info('没有可领取的优惠券')
    }
  } catch (e: any) {
    const errorMsg = e?.response?.data?.message || e?.message || '领取失败'
    ElMessage.error(errorMsg)
  } finally {
    receivingAll.value = false
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
  addressPasteText.value = ''
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
  addressPasteText.value = ''
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
    addressPasteText.value = ''
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

async function setDefaultAddress(id: number) {
  try {
    await request.put('/address/default', null, {
      params: {
        userId: userStore.userInfo?.id,
        id
      }
    })
    ElMessage.success('已设为默认地址')
    await loadAddresses()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '设置失败')
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
  if (orderItems.value.length === 0) {
    ElMessage.warning('订单为空')
    return
  }
  submitting.value = true
  try {
    const orderData = {
      userId: userStore.userInfo?.id,
      items: orderItems.value.map(i => ({
        productId: i.productId,
        quantity: i.quantity,
        cartId: i.cartId
      })),
      addressId: selectedAddress.value.id,
      couponId: selectedCouponIds.value.length > 0 ? selectedCouponIds.value[0] : null,
      couponIds: selectedCouponIds.value,
      remark: remark.value
    }
    const res = await request.post('/order/create', orderData)
    ElMessage.success('订单提交成功！')
    
    // 下单成功后，清除已结算的购物车商品
    const cartIds = orderItems.value
      .filter((i: any) => i.cartId)
      .map((i: any) => i.cartId)
    if (cartIds.length > 0) {
      try {
        await cartStore.batchDeleteCartItems(cartIds)
      } catch (e) {
        console.warn('清除购物车失败:', e)
      }
    }
    
    router.push({
      path: '/order/pay',
      query: { orderNo: res.data?.orderNo }
    })
  } catch (e: any) {
    ElMessage.error(e?.message || '订单提交失败')
  } finally {
    submitting.value = false
  }
}

watch(totalAmount, () => {
  if (allCoupons.value.length > 0) {
    checkCouponsUsable()
  }
})

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.checkout-page {
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
  color: #ff4400;
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
    .goods-count {
      font-size: 13px;
      color: #999;
    }
  }
}

.selected-address-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  border: 2px solid #f56c6c;
  border-radius: 10px;
  background: linear-gradient(135deg, #fff5f5 0%, #ffffff 100%);
  cursor: pointer;
  transition: all 0.2s;

  &:hover {
    box-shadow: 0 4px 12px rgba(245, 108, 108, 0.15);
  }

  .addr-icon {
    flex-shrink: 0;
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f56c6c;
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
    border-color: #f56c6c;
    color: #f56c6c;
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
      border-color: #ffb4b4;
      background: #fff8f8;
    }

    &.active {
      border-color: #f56c6c;
      background: #fff5f5;
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

.goods-list {
  .goods-item {
    display: flex;
    align-items: center;
    gap: 15px;
    padding: 15px 0;
    border-bottom: 1px dashed #f0f0f0;
    &:last-child { border-bottom: none; }
  }
  .goods-img {
    width: 80px;
    height: 80px;
    object-fit: cover;
    border-radius: 6px;
    background: #f5f5f5;
  }
  .goods-info {
    flex: 1;
    min-width: 0;
    .goods-name {
      font-size: 14px;
      color: #333;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      margin-bottom: 6px;
    }
    .goods-price {
      color: #ff4400;
      font-weight: 500;
    }
  }
  .goods-qty {
    color: #666;
    width: 60px;
    text-align: center;
  }
  .goods-subtotal {
    color: #ff4400;
    font-weight: 600;
    width: 100px;
    text-align: right;
  }
}

.coupon-section {
  .coupon-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    color: #666;
    margin-bottom: 12px;
    
    .coupon-count {
      font-size: 12px;
      color: #999;
    }
  }
  
  .coupon-selector-card {
    margin-bottom: 10px;
    
    .coupon-tabs {
      display: flex;
      gap: 0;
      margin-bottom: 16px;
      border-bottom: 1px solid #ebeef5;
      
      .coupon-tab {
        padding: 10px 20px;
        cursor: pointer;
        font-size: 14px;
        color: #666;
        border-bottom: 2px solid transparent;
        margin-bottom: -1px;
        transition: all 0.3s;
        
        .tab-count {
          font-size: 12px;
          color: #999;
          margin-left: 2px;
        }
        
        &.active {
          color: #f56c6c;
          border-bottom-color: #f56c6c;
          font-weight: 600;
          
          .tab-count {
            color: #f56c6c;
          }
        }
        
        &:hover:not(.active) {
          color: #f56c6c;
        }
      }
    }
    
    .coupon-list {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 12px;
      
      .empty-coupons {
        grid-column: 1 / -1;
        padding: 20px 0;
      }
    }
    
    .coupon-card {
      display: flex;
      border: 1px solid #ebeef5;
      border-radius: 6px;
      overflow: hidden;
      cursor: pointer;
      transition: all 0.3s;
      position: relative;
      
      &:hover:not(.disabled) {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      }
      
      &.selected {
        border-color: #f56c6c;
        box-shadow: 0 0 0 2px rgba(245, 108, 108, 0.1);
      }
      
      &.disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
      
      .coupon-left {
        width: 100px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #fff;
        padding: 12px 8px;
        
        &.platform {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        &.merchant {
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        &.single {
          background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
        }
        
        .coupon-amount {
          font-size: 22px;
          font-weight: bold;
          display: flex;
          align-items: baseline;
          
          .currency {
            font-size: 12px;
          }
          
          .num {
            font-size: 26px;
          }
        }
        
        .coupon-condition {
          font-size: 11px;
          margin-top: 4px;
          opacity: 0.9;
        }
      }
      
      .coupon-right {
        flex: 1;
        padding: 10px 12px;
        display: flex;
        flex-direction: column;
        gap: 4px;
        background: #fff;
        position: relative;
        
        .coupon-name {
          font-size: 13px;
          font-weight: 600;
          color: #333;
          overflow: hidden;
          text-overflow: ellipsis;
          white-space: nowrap;
        }
        
        .coupon-scope {
          :deep(.el-tag) {
            transform: scale(0.85);
            transform-origin: left;
          }
        }
        
        .coupon-expire {
          font-size: 11px;
          color: #999;
        }
        
        .coupon-select-icon {
          position: absolute;
          top: 8px;
          right: 8px;
          width: 20px;
          height: 20px;
          background: #f56c6c;
          color: #fff;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 12px;
        }
      }
    }
    
    .coupon-tip {
      display: flex;
      align-items: center;
      gap: 4px;
      margin-top: 12px;
      font-size: 12px;
      color: #999;
      
      .el-icon {
        color: #f56c6c;
      }
    }
  }
  
  .selected-coupon-info {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    background: #f0f9eb;
    border-radius: 4px;
    font-size: 13px;
    color: #67c23a;
    
    .selected-names {
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    
    .discount {
      margin-left: auto;
      font-weight: 600;
      flex-shrink: 0;
    }
  }
  
  .receivable-coupons {
    margin-top: 16px;
    padding: 12px 16px;
    background: #fff7e6;
    border-radius: 8px;
    border: 1px solid #ffd591;
    
    .receivable-header {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
      
      .el-icon {
        color: #fa8c16;
      }
      
      span {
        flex: 1;
        font-size: 14px;
        color: #d46b08;
        font-weight: 500;
      }
    }
    
    .receivable-list {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      
      .receivable-item {
        flex: 1;
        min-width: 120px;
        background: #fff;
        padding: 8px 10px;
        border-radius: 6px;
        border: 1px dashed #ffd591;
        
        .coupon-info {
          display: flex;
          flex-direction: column;
          gap: 2px;
          
          .coupon-name {
            font-size: 12px;
            color: #333;
            font-weight: 500;
          }
          
          .coupon-desc {
            font-size: 11px;
            color: #fa8c16;
          }
        }
      }
      
      .more-coupons {
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 12px;
        color: #d46b08;
        padding: 0 12px;
      }
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
      .discount { color: #67c23a; }
      &.total .price {
        font-size: 24px;
        color: #ff4400;
        font-weight: bold;
      }
    }
  }

  .submit-btn {
    height: 50px;
    padding: 0 50px;
    font-size: 16px;
    background: linear-gradient(135deg, #ff7676, #f54e4e);
    border: none;
  }
}

.address-form {
  padding: 0 20px;
}
</style>
