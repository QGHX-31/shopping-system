<template>
  <footer class="footer">
    <!-- 服务保障 -->
    <div class="footer-services">
      <div class="container">
        <ul class="services-list">
          <li v-for="s in services" :key="s.title">
            <el-icon :size="28" :color="s.color"><component :is="s.icon" /></el-icon>
            <div>
              <h4>{{ s.title }}</h4>
              <span>{{ s.desc }}</span>
            </div>
          </li>
        </ul>
      </div>
    </div>

    <!-- 帮助/链接 -->
    <div class="footer-content">
      <div class="container footer-grid">
        <div v-for="col in columns" :key="col.title" class="footer-col">
          <h4>{{ col.title }}</h4>
          <ul>
            <li v-for="l in col.links" :key="l">
              <a href="javascript:;">{{ l }}</a>
            </li>
          </ul>
        </div>
        <div class="footer-qr">
          <h4>关注我们</h4>
          <div class="qr-list">
            <div class="qr-item">
              <div class="qr-img">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://example.com/app" alt="APP" />
              </div>
              <span>下载APP</span>
            </div>
            <div class="qr-item">
              <div class="qr-img">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://example.com/wx" alt="微信" />
              </div>
              <span>官方微信</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 备案/版权 -->
    <div class="footer-bottom">
      <div class="container">
        <p>© 2026 购物系统 版权所有 | ICP备案号：京ICP备12345678号 | 公安备案：京公网安备11010100000000号</p>
        <p class="small">
          本站所有商品图片、文字版权归原作者及本站所有，未经许可不得转载。
          <span class="admin-entry" @click="goAdmin">平台运营后台</span>
          <span class="divider"> | </span>
          <span class="admin-entry" @click="goMerchant">商家登录</span>
        </p>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { CircleCheck, Box, RefreshLeft, Service, Headset } from '@element-plus/icons-vue'

const services = [
  { title: '正品保障', desc: '全场正品 假一赔十', icon: CircleCheck, color: '#ff5e5e' },
  { title: '极速发货', desc: '24小时内出库', icon: Box, color: '#ff8a00' },
  { title: '七天无忧', desc: '七天无理由退换', icon: RefreshLeft, color: '#67c23a' },
  { title: '在线客服', desc: '9:00-21:00 在线', icon: Service, color: '#409eff' },
  { title: '售后保障', desc: '专业售后 用心服务', icon: Headset, color: '#9b59b6' }
]

const columns = [
  {
    title: '购物指南',
    links: ['注册流程', '购物流程', '订单查询', '会员介绍', '优惠券规则', '积分规则']
  },
  {
    title: '配送与支付',
    links: ['快递查询', '免运费政策', '上门自提', '支付方式', '货到付款', '发票信息']
  },
  {
    title: '售后保障',
    links: ['退换货流程', '退款说明', '取消订单', '联系客服', '投诉建议', '服务承诺']
  },
  {
    title: '商家服务',
    links: ['商家入驻', '商家中心', '运营服务', '营销中心', '商家工具', '规则中心']
  }
]

function goAdmin() {
  window.location.href = '/admin/login'
}
function goMerchant() {
  window.location.href = '/merchant/login'
}
</script>

<style lang="scss" scoped>
.footer {
  background: #f5f5f5;
  margin-top: 20px;
  color: #555;
  font-size: 14px;
}
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

/* ========== 服务保障 ========== */
.footer-services {
  background: #fff;
  padding: 28px 0;
  border-bottom: 1px solid #f0f0f0;
}
.services-list {
  display: flex;
  list-style: none;
  margin: 0;
  padding: 0;
  justify-content: space-around;
  li {
    display: flex;
    align-items: center;
    gap: 12px;
    h4 { margin: 0 0 4px; font-size: 16px; color: #333; }
    span { font-size: 12px; color: #999; }
  }
}

/* ========== 帮助/链接 ========== */
.footer-content { padding: 30px 0; }
.footer-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr) 220px;
  gap: 30px;
}
.footer-col {
  h4 { font-size: 16px; margin: 0 0 14px; color: #333; }
  ul { list-style: none; padding: 0; margin: 0; }
  li { margin-bottom: 8px; }
  a {
    color: #888;
    font-size: 13px;
    text-decoration: none;
    &:hover { color: #ff4400; }
  }
}
.footer-qr {
  text-align: center;
  h4 { font-size: 16px; margin: 0 0 14px; color: #333; }
}
.qr-list {
  display: flex;
  gap: 12px;
  justify-content: center;
}
.qr-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 12px;
  color: #888;
  .qr-img {
    width: 100px;
    height: 100px;
    padding: 6px;
    background: #fff;
    border: 1px solid #eee;
    border-radius: 6px;
    margin-bottom: 6px;
    img { width: 100%; height: 100%; }
  }
}

/* ========== 备案 ========== */
.footer-bottom {
  background: #2b2b2b;
  color: #aaa;
  text-align: center;
  padding: 18px 0;
  font-size: 12px;
  p { margin: 4px 0; }
  .small { font-size: 12px; color: #888; }
  .admin-entry {
    cursor: pointer;
    color: #409eff;
    &:hover { color: #66b1ff; text-decoration: underline; }
  }
  .divider { color: #555; margin: 0 4px; }
}
</style>
