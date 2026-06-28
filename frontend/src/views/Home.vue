<template>
  <div class="home-page">
    <Header />

    <!-- 顶部活动快捷入口 (淘宝风格) -->
    <section class="quick-entry">
      <div class="container">
        <ul class="entry-list">
          <li v-for="entry in quickEntries" :key="entry.label" @click="goEntry(entry)">
            <div class="entry-icon" :style="{ background: entry.color }">
              <component :is="entry.icon" :size="24" color="#fff" />
            </div>
            <span>{{ entry.label }}</span>
          </li>
        </ul>
      </div>
    </section>

    <!-- 主区域：分类侧栏 + 轮播 + 右侧卡片 -->
    <section class="main-section">
      <div class="container main-grid">
        <!-- 左侧分类 -->
        <aside class="category-sidebar">
          <h3 class="sidebar-title">商品分类</h3>
          <ul class="sidebar-list">
            <li
              v-for="cat in topCategories"
              :key="cat.id"
              class="sidebar-item"
              @mouseenter="hoverCategory = cat.id"
              @mouseleave="hoverCategory = null"
              @click="goCategory(cat.id)"
            >
              <span class="cat-name">{{ cat.name }}</span>
              <el-icon><ArrowRight /></el-icon>
              <div v-if="hoverCategory === cat.id && getChildren(cat.id).length" class="sub-panel">
                <a
                  v-for="sub in getChildren(cat.id)"
                  :key="sub.id"
                  @click.stop="goCategory(sub.id)"
                >{{ sub.name }}</a>
              </div>
            </li>
          </ul>
        </aside>

        <!-- 中间轮播 -->
        <div class="banner-area">
          <el-carousel height="460px" indicator-position="outside" arrow="always" :interval="4000">
            <el-carousel-item v-for="(b, i) in banners" :key="i">
              <div class="banner-slide" :style="{ background: b.gradient }">
                <div class="banner-content">
                  <h2 class="banner-title">{{ b.title }}</h2>
                  <p class="banner-subtitle">{{ b.subtitle }}</p>
                  <el-button type="warning" round size="large" @click="goEntry({ path: b.path })">
                    立即查看
                  </el-button>
                </div>
                <div class="banner-deco">
                  <img :src="b.image" :alt="b.title" />
                </div>
              </div>
            </el-carousel-item>
          </el-carousel>
        </div>

        <!-- 右侧登录 + 公告 + 推广 -->
        <aside class="side-area">
          <div v-if="!userStore.isLogin" class="user-card">
            <div class="avatar-circle">
              <el-icon :size="36"><UserFilled /></el-icon>
            </div>
            <p class="hi-text">Hi! 你好</p>
            <div class="card-btns">
              <el-button type="danger" size="small" @click="goLogin">登录</el-button>
              <el-button size="small" @click="goRegister">注册</el-button>
            </div>
            <div class="card-links">
              <a @click="goMember"><el-icon><Coin /></el-icon> 领积分</a>
              <a @click="goCoupon"><el-icon><Ticket /></el-icon> 领优惠</a>
            </div>
          </div>
          <div v-else class="user-card logged">
            <div class="avatar-circle">
              <el-avatar :size="56" :src="userStore.userInfo?.avatar" />
            </div>
            <p class="hi-text">{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</p>
            <div class="card-links">
              <a @click="goMember"><el-icon><Coin /></el-icon> 会员中心</a>
              <a @click="handleLogout">退出</a>
            </div>
          </div>

          <div class="promo-card">
            <div class="promo-title">
              <span><el-icon><Bell /></el-icon> 活动公告</span>
              <a>更多</a>
            </div>
            <ul class="promo-list">
              <li v-for="(n, i) in notices" :key="i" @click="n.path && router.push(n.path)">
                <el-tag v-if="n.tag" :type="n.tagType || 'danger'" size="small">{{ n.tag }}</el-tag>
                <span>{{ n.text }}</span>
              </li>
            </ul>
          </div>
        </aside>
      </div>
    </section>

    <!-- 限时秒杀 -->
    <section class="seckill-section">
      <div class="container">
        <div class="section-header">
          <div class="title-area">
            <el-icon :size="28" color="#fff"><AlarmClock /></el-icon>
            <h2>限时秒杀</h2>
            <span class="sub-title">SECKILL · 抢到就是赚到</span>
          </div>
          <div class="countdown">
            <span class="cd-label">{{ seckillEnd ? '距离结束' : '加载中...' }}</span>
            <span class="cd-time">{{ cd.h }}</span>:
            <span class="cd-time">{{ cd.m }}</span>:
            <span class="cd-time">{{ cd.s }}</span>
          </div>
          <router-link to="/seckill" class="more-link">更多秒杀 ›</router-link>
        </div>

        <div v-loading="loadingSeckill" class="seckill-grid">
          <el-empty v-if="!loadingSeckill && seckillList.length === 0" description="暂无秒杀商品" />
          <div
            v-for="p in seckillList"
            :key="p.id"
            class="seckill-card"
            @click="goProduct(p.productId)"
          >
            <div class="seckill-image">
              <img :src="p.imageUrl || defaultImg" :alt="p.productName" />
              <span class="discount-tag">{{ calcDiscount(p) }}折</span>
            </div>
            <div class="seckill-info">
              <h4 class="seckill-name">{{ p.productName }}</h4>
              <div class="seckill-price">
                <span class="now">¥{{ Number(p.seckillPrice).toFixed(2) }}</span>
                <span class="old">¥{{ Number(p.originalPrice).toFixed(2) }}</span>
              </div>
              <div class="seckill-progress">
                <div class="bar" :style="{ width: progress(p) + '%' }"></div>
                <span class="bar-text">已抢 {{ p.salesCount || 0 }} 件</span>
              </div>
              <el-button type="danger" size="small" class="seckill-btn">立即抢</el-button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 优惠券 + 拼团双列 -->
    <section class="promo-row">
      <div class="container promo-grid">
        <!-- 优惠券 -->
        <div class="block coupons-block">
          <div class="block-header">
            <div class="title-area">
              <el-icon :size="24" color="#ff5b5b"><Ticket /></el-icon>
              <h2>领券中心</h2>
              <span class="sub-title">省更多</span>
            </div>
            <router-link to="/coupon" class="more-link">更多 ›</router-link>
          </div>
          <div v-loading="loadingCoupon" class="coupon-list">
            <el-empty v-if="!loadingCoupon && couponList.length === 0" description="暂无可领优惠券" />
            <div v-for="c in couponList" :key="c.id" class="coupon-item" @click="receiveCoupon(c)">
              <div class="c-left">
                <div class="c-amount">
                  <template v-if="c.type === 2">{{ (c.discountAmount * 10).toFixed(1) }}折</template>
                  <template v-else>
                    <span class="cur">¥</span><span class="num">{{ c.discountAmount }}</span>
                  </template>
                </div>
                <div class="c-condition">{{ c.minAmount ? `满${c.minAmount}元可用` : '无门槛' }}</div>
              </div>
              <div class="c-right">
                <div class="c-name">{{ c.name }}</div>
                <div class="c-time">至 {{ formatTime(c.endTime) }} 失效</div>
                <el-button 
                  type="danger" 
                  size="small" 
                  round 
                  :disabled="isCouponReceived(c)"
                  :plain="isCouponReceived(c)"
                >
                  {{ isCouponReceived(c) ? '已领取' : '立即领取' }}
                </el-button>
              </div>
            </div>
          </div>
        </div>

        <!-- 拼团 -->
        <div class="block group-block">
          <div class="block-header">
            <div class="title-area">
              <el-icon :size="24" color="#67c23a"><UserFilled /></el-icon>
              <h2>拼团活动</h2>
              <span class="sub-title">低价开团</span>
            </div>
            <router-link to="/group" class="more-link">更多拼团 ›</router-link>
          </div>
          <div v-loading="loadingGroup" class="group-list">
            <el-empty v-if="!loadingGroup && groupList.length === 0" description="暂无拼团活动" />
            <div v-for="g in groupList" :key="g.id" class="group-item" @click="goProduct(g.productId)">
              <div class="g-image">
                <img :src="g.imageUrl || defaultImg" :alt="g.productName" />
                <span class="g-tag">{{ g.requiredNum }}人成团</span>
              </div>
              <div class="g-info">
                <h4 class="g-name">{{ g.productName }}</h4>
                <div class="g-price">
                  <span class="now">¥{{ Number(g.groupPrice).toFixed(2) }}</span>
                  <span class="old">¥{{ Number(g.originalPrice).toFixed(2) }}</span>
                </div>
                <el-button type="success" size="small" round @click.stop="openGroup(g)">去拼团</el-button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 热卖商品 -->
    <section class="hot-section">
      <div class="container">
        <div class="section-header light">
          <h2>热卖商品 <small>HOT · 大家都在买</small></h2>
          <router-link to="/search?sort=hot" class="more-link">查看更多 ›</router-link>
        </div>
        <div class="product-grid">
          <div
            v-for="product in productStore.hotProducts"
            :key="product.id"
            class="product-card"
            @click="goProduct(product.id)"
          >
            <div class="product-image">
              <img :src="product.imageUrl || defaultImg" :alt="product.name" />
              <span class="tag tag-hot">热卖</span>
            </div>
            <div class="product-body">
              <h4 class="product-name">{{ product.name }}</h4>
              <p class="product-price">
                <span class="now">¥{{ product.price.toFixed(2) }}</span>
                <span v-if="product.originalPrice" class="old">¥{{ product.originalPrice.toFixed(2) }}</span>
              </p>
              <p class="product-meta">销量 {{ product.salesCount }} 件</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 猜你喜欢 -->
    <section class="guess-section">
      <div class="container">
        <div class="section-header light">
          <h2>
            <el-icon color="#ff4400"><Star /></el-icon>
            猜你喜欢
            <small>根据浏览推荐</small>
          </h2>
        </div>
        <div class="product-grid">
          <div
            v-for="p in productStore.newProducts"
            :key="p.id"
            class="product-card"
            @click="goProduct(p.id)"
          >
            <div class="product-image">
              <img :src="p.imageUrl || defaultImg" :alt="p.name" />
              <span class="tag tag-new">新品</span>
            </div>
            <div class="product-body">
              <h4 class="product-name">{{ p.name }}</h4>
              <p class="product-price">
                <span class="now">¥{{ p.price.toFixed(2) }}</span>
                <span v-if="p.originalPrice" class="old">¥{{ p.originalPrice.toFixed(2) }}</span>
              </p>
              <p class="product-meta">销量 {{ p.salesCount }} 件</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <Footer />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, markRaw } from 'vue'
import { useRouter } from 'vue-router'
import { useProductStore } from '@/stores/product'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import {
  AlarmClock, Ticket, UserFilled, ArrowRight, Star, Bell, Coin, ChatLineRound, ShoppingCart, User
} from '@element-plus/icons-vue'

const router = useRouter()
const productStore = useProductStore()
const userStore = useUserStore()

const defaultImg = 'https://via.placeholder.com/240x240/f5f5f5/ccc?text=商品'
const hoverCategory = ref<number | null>(null)

const topCategories = computed(() => productStore.categories.filter(c => c.parentId === 0))

function getChildren(parentId: number) {
  return productStore.categories.filter(c => c.parentId === parentId)
}

// ========== 顶部快捷入口 ==========
const quickEntries = [
  { label: '限时秒杀', icon: 'AlarmClock', color: 'linear-gradient(135deg, #ff7676, #f54e4e)', path: '/seckill' },
  { label: '优惠券', icon: 'Ticket', color: 'linear-gradient(135deg, #ffb86c, #ff7e2d)', path: '/coupon' },
  { label: '拼团活动', icon: 'UserFilled', color: 'linear-gradient(135deg, #67c23a, #85ce61)', path: '/group' },
  { label: '新品上市', icon: 'Star', color: 'linear-gradient(135deg, #ffd76e, #ffaa1d)', path: '/search?sort=new' },
  { label: '热卖爆款', icon: 'Bell', color: 'linear-gradient(135deg, #ff8d8d, #ff5050)', path: '/search?sort=hot' },
  { label: '积分商城', icon: 'Coin', color: 'linear-gradient(135deg, #f7a35c, #f56c2c)', path: '/member' },
  { label: '会员中心', icon: 'User', color: 'linear-gradient(135deg, #6f9ef0, #4f80e0)', path: '/member' },
]

// Element Plus icon 组件映射
const iconMap: Record<string, any> = {
  Coin, AlarmClock, Ticket, Star, ShoppingCart, UserFilled, ChatLineRound, User, Bell
}
function resolveIcon(name: string) {
  return markRaw(iconMap[name] || Star)
}
quickEntries.forEach(e => { e.icon = resolveIcon(e.icon) })

// 轮播图
const banners = ref([
  {
    title: '夏季上新 解锁潮流穿搭',
    subtitle: '当季爆款 一键焕新',
    path: '/search?keyword=夏季',
    image: 'https://via.placeholder.com/520x380/9bcb8a/fff?text=Summer+Fashion',
    gradient: 'linear-gradient(135deg, #8ec77d 0%, #5da349 100%)'
  },
  {
    title: '秒杀爆款 1元起抢',
    subtitle: '每日10点 限时开抢',
    path: '/seckill',
    image: 'https://via.placeholder.com/520x380/f56c6c/fff?text=Seckill',
    gradient: 'linear-gradient(135deg, #ff7676 0%, #f54e4e 100%)'
  },
  {
    title: '百亿补贴 全网底价',
    subtitle: '官方直补 立省50%',
    path: '/coupon',
    image: 'https://via.placeholder.com/520x380/ff9a44/fff?text=Big+Subsidy',
    gradient: 'linear-gradient(135deg, #ffb86c 0%, #ff7e2d 100%)'
  },
  {
    title: '拼团更划算',
    subtitle: '邀好友一起省钱',
    path: '/group',
    image: 'https://via.placeholder.com/520x380/67c23a/fff?text=Group+Buy',
    gradient: 'linear-gradient(135deg, #95d475 0%, #5daf34 100%)'
  }
])

// 公告
const notices = ref([
  { tag: '热', tagType: 'danger', text: '618大促即将开启，全场满300减50', path: '/coupon' },
  { tag: '新', tagType: 'success', text: '新人首单立减20元优惠券已发放', path: '/coupon' },
  { tag: '秒', tagType: 'warning', text: '限时秒杀 iPhone 16 抢到就是赚到', path: '/seckill' },
  { tag: '团', tagType: 'success', text: '拼团活动火热进行中 最低3人成团', path: '/group' },
])

// ========== 秒杀 ==========
const seckillList = ref<any[]>([])
const loadingSeckill = ref(false)
const seckillEnd = ref<number>(0)
const cd = ref({ h: '--', m: '--', s: '--' })
let cdTimer: any = null

function pad(n: number) { return n < 10 ? '0' + n : '' + n }

function startCountdown(endTime: number) {
  seckillEnd.value = endTime
  if (cdTimer) clearInterval(cdTimer)
  cdTimer = setInterval(() => {
    const diff = Math.max(0, endTime - Date.now())
    if (diff <= 0) {
      cd.value = { h: '00', m: '00', s: '00' }
      clearInterval(cdTimer)
      return
    }
    const h = Math.floor(diff / 3_600_000)
    const m = Math.floor((diff % 3_600_000) / 60_000)
    const s = Math.floor((diff % 60_000) / 1000)
    cd.value = { h: pad(h), m: pad(m), s: pad(s) }
  }, 1000)
}

async function loadSeckill() {
  loadingSeckill.value = true
  try {
    const res = await request.get('/activity/seckill/active')
    const list: any[] = res.data || []
    // 直接取已审核通过的秒杀商品
    seckillList.value = list.slice(0, 6)
    // 设置倒计时（如果有结束时间）
    if (list.length > 0 && list[0].endTime) {
      startCountdown(Number(list[0].endTime))
    } else {
      cd.value = { h: '00', m: '00', s: '00' }
    }
  } catch {
    seckillList.value = []
  } finally {
    loadingSeckill.value = false
  }
}

function calcDiscount(p: any) {
  if (!p.originalPrice) return '0'
  return (Number(p.seckillPrice) / Number(p.originalPrice) * 10).toFixed(1)
}
function progress(p: any) {
  if (!p.totalStock) return 0
  return Math.min(100, Math.round((p.salesCount || 0) / p.totalStock * 100))
}

// ========== 优惠券 ==========
const couponList = ref<any[]>([])
const loadingCoupon = ref(false)
const myCouponTemplateIds = ref<Set<number>>(new Set())

async function loadCoupons() {
  loadingCoupon.value = true
  try {
    const res = await request.get('/coupon/template/active')
    const templates = res.data?.list || []
    couponList.value = templates.slice(0, 3)
    
    if (userStore.isLogin) {
      await loadMyCouponIds()
    }
  } catch {
    couponList.value = []
  } finally {
    loadingCoupon.value = false
  }
}

async function loadMyCouponIds() {
  try {
    const res = await request.get('/coupon/mine', { 
      params: { userId: userStore.userInfo?.id, page: 1, size: 100 } 
    })
    const myList = res.data?.list || []
    myCouponTemplateIds.value = new Set(myList.map((c: any) => c.templateId))
  } catch (e) {
    console.error('加载我的优惠券失败', e)
  }
}

function isCouponReceived(coupon: any) {
  return myCouponTemplateIds.value.has(coupon.id)
}

async function receiveCoupon(c: any) {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    return router.push('/login')
  }
  try {
    await request.post('/coupon/receive', null, { params: { userId: userStore.userInfo?.id, templateId: c.id } })
    ElMessage.success('领取成功')
    myCouponTemplateIds.value.add(c.id)
  } catch (e: any) {
    ElMessage.error(e?.message || '领取失败')
  }
}

// ========== 拼团 ==========
const groupList = ref<any[]>([])
const loadingGroup = ref(false)

async function loadGroups() {
  loadingGroup.value = true
  try {
    const res = await request.get('/activity/group/active')
    groupList.value = (res.data || []).slice(0, 3)
  } catch {
    groupList.value = []
  } finally {
    loadingGroup.value = false
  }
}

async function openGroup(g: any) {
  if (!userStore.isLogin) {
    ElMessage.warning('请先登录')
    return router.push('/login')
  }
  try {
    await ElMessageBox.confirm(`确认发起【${g.productName || g.name}】的拼团？`, '发起拼团', { type: 'success' })
    router.push({
      path: '/group/create',
      query: {
        productId: g.productId,
        activityId: g.id
      }
    })
  } catch (e: any) {
    if (e === 'cancel') return
    ElMessage.error(e?.message || '开团失败')
  }
}

// ========== 通用 ==========
function formatTime(s: string) { return s ? s.replace('T', ' ').slice(0, 16) : '' }
function goCategory(id: number) { router.push(`/category/${id}`) }
function goProduct(id: number) { router.push(`/product/${id}`) }
function goLogin() { router.push('/login') }
function goRegister() { router.push('/register') }
function goMember() { router.push('/member') }
function goCoupon() { router.push('/coupon') }
function goEntry(entry: any) { if (entry.path) router.push(entry.path) }
async function handleLogout() { await userStore.logout(); router.push('/') }

onMounted(async () => {
  try {
    await productStore.getCategories()
  } catch (e) {
    console.error('加载分类失败:', e)
  }
  try {
    await Promise.allSettled([
      productStore.getHotProducts(),
      productStore.getNewProducts(),
      loadSeckill(),
      loadCoupons(),
      loadGroups()
    ])
  } catch (e) {
    console.error('加载数据失败:', e)
  }
})

onUnmounted(() => { if (cdTimer) clearInterval(cdTimer) })
</script>

<style lang="scss" scoped>
.home-page {
  background: #f5f5f5;
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* ========== 顶部快捷入口 ========== */
.quick-entry {
  background: linear-gradient(180deg, #ffe0d0 0%, #fff5ee 100%);
  padding: 18px 0;
}
.quick-entry > .container {
  background: #fff;
  border-radius: 12px;
  padding: 16px 0;
  box-shadow: 0 2px 12px rgba(255, 100, 50, 0.08);
}
.entry-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  justify-content: space-around;
}
.entry-list li {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  width: 80px;
  font-size: 13px;
  color: #333;
  transition: transform 0.2s;
  &:hover { transform: translateY(-2px); }
  .entry-icon {
    width: 46px;
    height: 46px;
    border-radius: 50%;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
  }
}

/* ========== 主区域 ========== */
.main-section { background: #f5f5f5; padding: 16px 0; }
.main-grid {
  display: grid;
  grid-template-columns: 200px 1fr 240px;
  gap: 12px;
  align-items: stretch;
}
.category-sidebar {
  background: #fff;
  border-radius: 8px;
  padding: 12px 0;
  height: 500px;
  .sidebar-title {
    font-size: 16px;
    padding: 0 16px 10px;
    border-bottom: 1px solid #f0f0f0;
    margin: 0 0 6px;
  }
}
.sidebar-list {
  list-style: none;
  margin: 0;
  padding: 0;
  position: relative;
}
.sidebar-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  height: 36px;
  font-size: 13px;
  color: #444;
  cursor: pointer;
  position: relative;
  &:hover {
    background: #fff5f0;
    color: #ff4400;
  }
  .sub-panel {
    position: absolute;
    left: 200px;
    top: 0;
    width: 240px;
    background: #fff;
    border-radius: 0 8px 8px 0;
    box-shadow: 4px 0 12px rgba(0, 0, 0, 0.08);
    padding: 12px;
    z-index: 9;
    display: flex;
    flex-wrap: wrap;
    gap: 6px 14px;
    align-content: flex-start;
    a {
      font-size: 13px;
      color: #555;
      padding: 4px 6px;
      cursor: pointer;
      &:hover { color: #ff4400; }
    }
  }
}

.banner-area {
  border-radius: 8px;
  overflow: hidden;
  :deep(.el-carousel__container) { height: 460px; }
  :deep(.el-carousel__indicators--outside) { margin-top: 6px; }
}
.banner-slide {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 40px;
  color: #fff;
  .banner-content { max-width: 60%; }
  .banner-title { font-size: 38px; font-weight: bold; margin: 0 0 12px; }
  .banner-subtitle { font-size: 18px; margin: 0 0 24px; opacity: 0.9; }
  .banner-deco img {
    max-width: 260px;
    max-height: 240px;
    object-fit: contain;
    filter: drop-shadow(0 4px 12px rgba(0, 0, 0, 0.2));
  }
}

.side-area { display: flex; flex-direction: column; gap: 10px; }
.user-card {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
  text-align: center;
  .avatar-circle {
    width: 64px;
    height: 64px;
    background: #ffece0;
    color: #ff4400;
    border-radius: 50%;
    margin: 0 auto 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .hi-text { font-size: 13px; color: #555; margin: 0 0 10px; }
  .card-btns { display: flex; gap: 8px; justify-content: center; }
  .card-links {
    display: flex;
    gap: 8px;
    justify-content: center;
    margin-top: 10px;
    a {
      font-size: 12px;
      color: #666;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 3px;
      padding: 4px 8px;
      background: #fff5f0;
      border-radius: 12px;
      &:hover { color: #ff4400; }
    }
  }
}
.promo-card {
  background: #fff;
  border-radius: 8px;
  padding: 12px 14px;
  .promo-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 8px;
    span { display: inline-flex; align-items: center; gap: 4px; color: #ff4400; }
    a { font-size: 12px; color: #999; cursor: pointer; }
  }
  .promo-list {
    list-style: none;
    margin: 0;
    padding: 0;
    li {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: #444;
      padding: 4px 0;
      cursor: pointer;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      &:hover { color: #ff4400; }
    }
  }
}
/* ========== section header 通用 ========== */
.section-header {
  display: flex;
  align-items: center;
  padding: 14px 20px;
  background: linear-gradient(90deg, #ff5e5e 0%, #ff8a00 100%);
  color: #fff;
  border-radius: 12px 12px 0 0;
  .title-area {
    display: flex;
    align-items: center;
    gap: 10px;
    h2 { margin: 0; font-size: 24px; font-weight: bold; }
    .sub-title { font-size: 12px; opacity: 0.8; letter-spacing: 1px; }
  }
  .countdown {
    margin-left: 30px;
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    .cd-label { opacity: 0.9; }
    .cd-time {
      display: inline-block;
      padding: 2px 8px;
      background: #2b2b2b;
      border-radius: 4px;
      color: #fff;
      font-weight: 600;
      min-width: 30px;
      text-align: center;
    }
  }
  .more-link {
    margin-left: auto;
    color: #fff;
    text-decoration: none;
    font-size: 14px;
    opacity: 0.9;
    &:hover { opacity: 1; }
  }
  &.light {
    background: #fff;
    color: #333;
    border-radius: 0;
    border-bottom: 2px solid #ff4400;
    margin-bottom: 20px;
    padding: 14px 0;
    h2 {
      font-size: 22px;
      display: flex;
      align-items: center;
      gap: 8px;
      small {
        font-size: 13px;
        color: #999;
        font-weight: 400;
        margin-left: 6px;
      }
    }
    .more-link { color: #666; }
  }
}

/* ========== 秒杀 ========== */
.seckill-section { padding: 20px 0 0; }
.seckill-section > .container {
  background: linear-gradient(180deg, #fff5e8 0%, #fff 100%);
  border-radius: 12px;
  padding-bottom: 20px;
  overflow: hidden;
}
.seckill-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
  padding: 0 16px;
}
.seckill-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid transparent;
  &:hover {
    transform: translateY(-3px);
    border-color: #ff5b5b;
    box-shadow: 0 4px 16px rgba(255, 91, 91, 0.15);
  }
  .seckill-image {
    position: relative;
    height: 150px;
    background: #f5f5f5;
    img { width: 100%; height: 100%; object-fit: cover; }
    .discount-tag {
      position: absolute;
      top: 6px;
      left: 6px;
      background: #ff5b5b;
      color: #fff;
      padding: 2px 8px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
    }
  }
  .seckill-info {
    padding: 10px;
    .seckill-name {
      font-size: 13px;
      margin: 0 0 6px;
      height: 36px;
      overflow: hidden;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      line-height: 1.4;
    }
    .seckill-price {
      display: flex;
      align-items: baseline;
      gap: 6px;
      margin-bottom: 6px;
      .now { color: #ff5b5b; font-size: 18px; font-weight: bold; }
      .old { color: #999; font-size: 12px; text-decoration: line-through; }
    }
    .seckill-progress {
      position: relative;
      background: #ffe5e0;
      height: 16px;
      border-radius: 8px;
      margin-bottom: 8px;
      overflow: hidden;
      .bar {
        position: absolute;
        top: 0; left: 0;
        height: 100%;
        background: linear-gradient(90deg, #ff8a8a, #ff5b5b);
        border-radius: 8px;
      }
      .bar-text {
        position: absolute;
        width: 100%;
        text-align: center;
        line-height: 16px;
        font-size: 11px;
        color: #fff;
        text-shadow: 0 0 2px rgba(0, 0, 0, 0.4);
      }
    }
    .seckill-btn {
      width: 100%;
    }
  }
}

/* ========== 优惠券+拼团 ========== */
.promo-row { padding: 20px 0; }
.promo-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}
.block {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
}
.block-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 20px;
  border-bottom: 1px solid #f5f5f5;
  .title-area {
    display: flex;
    align-items: center;
    gap: 8px;
    h2 { margin: 0; font-size: 20px; font-weight: bold; color: #333; }
    .sub-title { font-size: 12px; color: #999; }
  }
  .more-link { font-size: 13px; color: #666; text-decoration: none; &:hover { color: #ff4400; } }
}

.coupons-block .block-header .title-area h2 { color: #ff5b5b; }
.group-block .block-header .title-area h2 { color: #67c23a; }

.coupon-list, .group-list {
  padding: 14px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}
.coupon-item {
  display: flex;
  align-items: stretch;
  background: linear-gradient(90deg, #fff5f5 0%, #fff 60%);
  border: 1px solid #ffe0e0;
  border-radius: 8px;
  cursor: pointer;
  overflow: hidden;
  transition: all 0.2s;
  &:hover { transform: translateX(2px); border-color: #ff5b5b; }
  .c-left {
    background: linear-gradient(135deg, #ff5b5b, #ff8a8a);
    color: #fff;
    width: 110px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 10px 0;
    .c-amount {
      display: flex;
      align-items: baseline;
      .cur { font-size: 14px; }
      .num { font-size: 28px; font-weight: bold; line-height: 1; }
    }
    .c-condition { font-size: 12px; margin-top: 4px; opacity: 0.9; }
  }
  .c-right {
    flex: 1;
    padding: 10px 14px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    .c-name { font-size: 14px; font-weight: 500; }
    .c-time { font-size: 12px; color: #999; margin: 4px 0; }
  }
}
.group-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px;
  background: #f8fcf5;
  border: 1px solid #e3f2d7;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  &:hover { border-color: #67c23a; }
  .g-image {
    position: relative;
    width: 90px;
    height: 90px;
    background: #f5f5f5;
    border-radius: 6px;
    overflow: hidden;
    flex-shrink: 0;
    img { width: 100%; height: 100%; object-fit: cover; }
    .g-tag {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      background: rgba(103, 194, 58, 0.9);
      color: #fff;
      text-align: center;
      font-size: 11px;
      padding: 2px 0;
    }
  }
  .g-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
    .g-name {
      font-size: 14px;
      margin: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    .g-price {
      .now { color: #67c23a; font-size: 18px; font-weight: bold; margin-right: 6px; }
      .old { color: #999; font-size: 12px; text-decoration: line-through; }
    }
  }
}

/* ========== 商品列表 ========== */
.hot-section, .guess-section { padding: 20px 0; }
.product-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 14px;
}
.product-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  transition: all 0.2s;
  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
  }
  .product-image {
    position: relative;
    height: 200px;
    background: #f5f5f5;
    overflow: hidden;
    img { width: 100%; height: 100%; object-fit: cover; }
    .tag {
      position: absolute;
      top: 8px;
      left: 8px;
      padding: 2px 10px;
      border-radius: 4px;
      font-size: 12px;
      color: #fff;
    }
    .tag-hot { background: #ff5b5b; }
    .tag-new { background: #67c23a; }
  }
  .product-body { padding: 12px; }
  .product-name {
    font-size: 14px;
    margin: 0 0 8px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    line-height: 1.4;
    height: 40px;
  }
  .product-price {
    margin: 0 0 6px;
    .now { color: #ff4400; font-size: 20px; font-weight: bold; margin-right: 6px; }
    .old { color: #999; font-size: 12px; text-decoration: line-through; }
  }
  .product-meta { font-size: 12px; color: #999; margin: 0; }
}
</style>
