<template>
  <div class="member-page">
    <Header />
    <div class="container">
      <div class="member-header">
        <div class="member-info">
          <el-avatar :size="80" :src="userStore.userInfo?.avatar" />
          <div class="member-detail">
            <h2>{{ userStore.userInfo?.nickname || userStore.userInfo?.username }}</h2>
            <p>{{ memberLevelText }}</p>
          </div>
        </div>
        <div class="member-stats">
          <div class="stat-item">
            <span class="stat-value">{{ memberInfo?.totalPoints || 0 }}</span>
            <span class="stat-label">总积分</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ memberInfo?.availablePoints || 0 }}</span>
            <span class="stat-label">可用积分</span>
          </div>
          <div class="stat-item">
            <span class="stat-value">{{ orderCount }}</span>
            <span class="stat-label">订单数</span>
          </div>
        </div>
      </div>
      <div class="member-content">
        <el-tabs v-model="activeTab">
          <el-tab-pane label="我的订单" name="orders">
            <div class="order-status-tabs">
              <div
                v-for="tab in orderStatusTabs"
                :key="tab.value"
                :class="['status-tab', { active: orderStatus === tab.value }]"
                @click="orderStatus = tab.value; loadOrders()"
              >
                {{ tab.label }}
              </div>
            </div>
            <div class="orders-list">
              <div class="order-toolbar">
                <el-button
                  type="danger"
                  size="small"
                  :disabled="selectedOrderNos.length === 0"
                  @click="handleBatchDelete"
                >
                  批量删除 ({{ selectedOrderNos.length }})
                </el-button>
                <span style="color: #909399; font-size: 12px; margin-left: 8px;">
                  仅已完成/已取消/已退款的订单可删除
                </span>
              </div>
              <el-table
                v-if="ordersLoaded || loadingOrders"
                :data="orderList"
                :key="'order-table-' + orderList.length + '-' + orderStatus"
                v-loading="loadingOrders"
                border
                @selection-change="handleSelectionChange"
              >
                <el-table-column type="selection" width="50">
                  <template #default="{ row }">
                    <el-checkbox
                      :model-value="selectedOrderNos.includes(row.orderNo)"
                      :disabled="!canDeleteOrder(row)"
                      @change="(val: boolean) => toggleSelectRow(row, val)"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="订单号" prop="orderNo" width="180" />
                <el-table-column label="商品" width="100">
                  <template #default="{ row }">
                    <img 
                      :src="row.productImage || defaultImg" 
                      :alt="row.productName" 
                      class="order-product-img product-link"
                      @click="goToProductDetail(row)"
                    />
                  </template>
                </el-table-column>
                <el-table-column label="商品名称">
                  <template #default="{ row }">
                    <span class="product-link" @click="goToProductDetail(row)">{{ row.productName || '商品' }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="单价" width="100">
                  <template #default="{ row }">
                    <span class="price">¥{{ Number(row.items?.[0]?.price || 0).toFixed(2) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="数量" width="80">
                  <template #default="{ row }">
                    <span>{{ row.items?.[0]?.quantity || 1 }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="实付金额" width="110">
                  <template #default="{ row }">
                    <span class="price total">¥{{ Number(row.payAmount || row.totalAmount || 0).toFixed(2) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="状态" width="140">
                  <template #default="{ row }">
                    <div class="order-status-col">
                      <div class="status-tags">
                        <el-tag :type="getOrderStatusTagType(row.status)" size="small">
                          {{ getOrderStatusText(row.status) }}
                        </el-tag>
                        <el-tag v-if="row.groupBuyTeamId" type="success" size="small" effect="plain">拼团</el-tag>
                        <el-tag v-if="row.refundStatus === 2" type="danger" size="small">退款被拒</el-tag>
                      </div>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="下单时间" width="160">
                  <template #default="{ row }">
                    <span>{{ formatTime(row.createdAt) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="320">
                  <template #default="{ row }">
                    <div class="order-actions">
                      <el-button v-if="row.status === 0" type="primary" size="small" @click="payOrder(row)">去支付</el-button>
                      <el-button v-if="row.status === 0" type="info" size="small" @click="cancelOrder(row)">取消订单</el-button>
                      <el-tag v-if="row.status === 1 && row.refundStatus !== 2" type="warning" size="small" class="wait-ship-tag">等待发货</el-tag>
                      <el-button v-if="row.status === 1 && row.refundStatus !== 2" type="warning" size="small" @click="applyRefund(row)">申请退款</el-button>
                      <el-button v-if="row.refundStatus === 2" type="warning" size="small" @click="applyRefund(row)">再次申请退款</el-button>
                      <el-button v-if="row.status === 2" type="success" size="small" @click="confirmReceive(row)">确认收货</el-button>
                      <el-button v-if="row.status === 2 && row.refundStatus !== 2" type="warning" size="small" @click="applyRefund(row)">申请退款</el-button>
                      <el-button v-if="row.refundStatus === 2 && row.rejectReason" type="info" size="small" @click="showRejectReason(row)">拒绝原因</el-button>
                      <el-button v-if="row.status === 3 && !row.hasReview" type="warning" size="small" @click="openReviewDialog(row)">评价</el-button>
                      <el-button v-if="row.status === 3 && row.hasReview" type="info" size="small" @click="viewReview(row)">查看评价</el-button>
                      <el-button v-if="row.status === 3" type="success" size="small" @click="applyExchange(row)">申请换货</el-button>
                      <el-button v-if="row.status === 3 || row.status === 4 || row.status === 6" type="danger" size="small" @click="deleteOrder(row)">删除</el-button>
                      <el-button size="small" @click="viewOrderDetail(row)">详情</el-button>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="!loadingOrders && orderList.length === 0" description="暂无订单" />
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的拼团" name="groups">
            <div class="groups-list">
              <el-table :data="groupOrders" border v-loading="loadingGroupOrders">
                <el-table-column label="团号" prop="teamNo" width="160">
                  <template #default="{ row }">
                    <span class="team-no">{{ row.teamNo }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="商品" width="80">
                  <template #default="{ row }">
                    <div class="group-product-img-wrap">
                      <img :src="row.productImage || defaultImg" class="group-product-img" />
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="商品名称" prop="productName" />
                <el-table-column label="拼团价" width="100">
                  <template #default="{ row }">
                    <span class="price">¥{{ Number(row.payAmount || 0).toFixed(2) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="成团进度" width="140">
                  <template #default="{ row }">
                    <el-tag :type="row.groupStatus === 1 ? 'success' : row.groupStatus === 0 ? 'warning' : 'info'" size="small">
                      {{ row.groupStatusText }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="操作" width="200">
                  <template #default="{ row }">
                    <el-button v-if="row.groupStatus === 0 && row.status === 0" size="small" type="info" @click="cancelGroup(row)">取消拼团</el-button>
                    <el-button v-if="row.groupStatus === 0 && row.status === 1" size="small" type="warning" @click="applyRefundGroup(row)">申请退款</el-button>
                    <el-button v-if="row.groupStatus === 0" size="small" type="success" @click="shareGroup(row)">邀请好友</el-button>
                    <el-button size="small" @click="viewOrderDetail(row)">详情</el-button>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="!loadingGroupOrders && groupOrders.length === 0" description="暂无拼团记录" />
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的退款" name="refunds">
            <div class="refund-status-tabs">
              <div
                v-for="tab in refundStatusTabs"
                :key="tab.value"
                :class="['status-tab', { active: refundStatus === tab.value }]"
                @click="refundStatus = tab.value; loadRefunds()"
              >
                {{ tab.label }}
              </div>
            </div>
            <div class="refunds-list">
              <el-table :data="refundList" v-loading="loadingRefunds" border>
                <el-table-column label="退款单号" prop="refundNo" width="200" />
                <el-table-column label="订单ID" prop="orderId" width="100" />
                <el-table-column label="退款类型" width="100">
                  <template #default="{ row }">
                    <el-tag :type="row.refundType === 1 ? 'info' : 'warning'" size="small">
                      {{ row.refundType === 1 ? '仅退款' : '退货退款' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="退款金额" width="120">
                  <template #default="{ row }">
                    <span class="refund-amount">¥{{ Number(row.refundAmount).toFixed(2) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="状态" width="100">
                  <template #default="{ row }">
                    <el-tag :type="getRefundStatusTagType(row.status)" size="small">
                      {{ getRefundStatusText(row.status) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="申请时间" prop="applyTime" width="160" />
                <el-table-column label="操作" width="180" fixed="right">
                  <template #default="{ row }">
                    <div class="action-buttons">
                      <el-button v-if="row.status === 1" type="primary" size="small" @click="showReturnShipDialog(row)">填写退货物流</el-button>
                      <el-button size="small" @click="viewRefundDetail(row)">详情</el-button>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="!loadingRefunds && refundList.length === 0" description="暂无退款记录" />
            </div>
            <div v-if="refundTotal > 0" class="pagination">
              <el-pagination
                v-model:current-page="refundPage"
                :page-size="refundPageSize"
                :total="refundTotal"
                layout="total, prev, pager, next, jumper"
                @current-change="loadRefunds"
              />
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的换货" name="exchanges">
            <div class="exchange-status-tabs">
              <div
                v-for="tab in exchangeStatusTabs"
                :key="tab.value"
                :class="['status-tab', { active: exchangeStatus === tab.value }]"
                @click="exchangeStatus = tab.value; loadExchanges()"
              >
                {{ tab.label }}
              </div>
            </div>
            <div class="exchanges-list">
              <el-table :data="exchangeList" v-loading="loadingExchanges" border>
                <el-table-column label="换货单号" prop="exchangeNo" width="200" />
                <el-table-column label="原商品" width="180">
                  <template #default="{ row }">
                    <div class="exchange-product-col">
                      <img :src="row.originalProductImage || defaultImg" class="exchange-product-img" />
                      <span>{{ row.originalProductName }}</span>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="新商品" width="180">
                  <template #default="{ row }">
                    <div class="exchange-product-col">
                      <img :src="row.newProductImage || defaultImg" class="exchange-product-img" />
                      <span>{{ row.newProductName }}</span>
                    </div>
                  </template>
                </el-table-column>
                <el-table-column label="状态" width="120">
                  <template #default="{ row }">
                    <el-tag :type="getExchangeStatusTagType(row.status)" size="small">
                      {{ getExchangeStatusText(row.status) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column label="申请时间" prop="applyTime" width="160" />
                <el-table-column label="操作" width="240" fixed="right">
                  <template #default="{ row }">
                    <div class="action-buttons">
                      <el-button v-if="row.status === 1" type="primary" size="small" @click="showExchangeReturnShipDialog(row)">填写退货物流</el-button>
                      <el-button v-if="row.status === 5" type="success" size="small" @click="confirmExchangeReceive(row)">确认收货</el-button>
                      <el-button v-if="row.status === 0" type="danger" size="small" @click="cancelExchange(row)">取消</el-button>
                      <el-button size="small" @click="viewExchangeDetail(row)">详情</el-button>
                    </div>
                  </template>
                </el-table-column>
              </el-table>
              <el-empty v-if="!loadingExchanges && exchangeList.length === 0" description="暂无换货记录" />
            </div>
            <div v-if="exchangeTotal > 0" class="pagination">
              <el-pagination
                v-model:current-page="exchangePage"
                :page-size="exchangePageSize"
                :total="exchangeTotal"
                layout="total, prev, pager, next, jumper"
                @current-change="loadExchanges"
              />
            </div>
          </el-tab-pane>
          <el-tab-pane label="积分记录" name="points">
            <div class="points-list">
              <el-table :data="pointsRecords" border>
                <el-table-column label="积分变动" width="100">
                  <template #default="{ row }">
                    <span :class="row.points > 0 ? 'positive' : 'negative'">
                      {{ row.points > 0 ? '+' : '' }}{{ row.points }}
                    </span>
                  </template>
                </el-table-column>
                <el-table-column label="类型" width="100">
                  <template #default="{ row }">
                    <span>{{ getPointTypeText(row.type) }}</span>
                  </template>
                </el-table-column>
                <el-table-column label="来源" prop="source" />
                <el-table-column label="时间" prop="createdAt" />
              </el-table>
            </div>
          </el-tab-pane>
          <el-tab-pane label="我的消息" name="messages">
            <div class="message-page">
              <div class="message-type-tabs">
                <div
                  v-for="tab in messageTypeTabs"
                  :key="tab.value"
                  :class="['message-type-tab', { active: messageType === tab.value }]"
                  @click="messageType = tab.value; loadMessages()"
                >
                  {{ tab.label }}
                  <el-badge v-if="tab.value !== '' && getUnreadCount(tab.value) > 0" :value="getUnreadCount(tab.value)" class="tab-badge" />
                </div>
              </div>
              <div class="message-list">
                <el-table :data="filteredMessages" border v-loading="loadingMessages" @row-click="handleMessageClick">
                  <el-table-column label="状态" width="60">
                    <template #default="{ row }">
                      <span class="message-status-dot" :class="{ unread: !row.isRead }"></span>
                    </template>
                  </el-table-column>
                  <el-table-column label="标题" prop="title">
                    <template #default="{ row }">
                      <span :class="{ 'message-title-unread': !row.isRead }">{{ row.title }}</span>
                    </template>
                  </el-table-column>
                  <el-table-column label="类型" width="100">
                    <template #default="{ row }">
                      <el-tag :type="getMessageTypeTagType(row.type)" size="small">
                        {{ getMessageTypeText(row.type) }}
                      </el-tag>
                    </template>
                  </el-table-column>
                  <el-table-column label="时间" prop="createdAt" width="160" />
                </el-table>
                <el-empty v-if="!loadingMessages && filteredMessages.length === 0" description="暂无消息" />
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="收货地址" name="address">
            <div class="address-manager">
              <div class="addr-toolbar">
                <el-button type="primary" @click="openAddAddress">
                  <el-icon><Plus /></el-icon>新增收货地址
                </el-button>
                <span style="color: #909399; font-size: 12px; margin-left: 12px;">
                  共 {{ addressList.length }} 个收货地址
                </span>
              </div>
              <div v-if="addressList.length === 0" class="addr-empty">
                <el-empty description="暂无收货地址，点击上方按钮添加" :image-size="80" />
              </div>
              <div v-else class="addr-cards">
                <div
                  v-for="addr in addressList"
                  :key="addr.id"
                  class="addr-card"
                  :class="{ 'is-default': addr.isDefault === 1 || addr.isDefault === true }"
                >
                  <div class="addr-card-header">
                    <span class="addr-name">{{ addr.name }}</span>
                    <span class="addr-phone">{{ addr.phone }}</span>
                    <el-tag v-if="addr.isDefault === 1 || addr.isDefault === true" type="danger" size="small" effect="dark">默认</el-tag>
                  </div>
                  <div class="addr-card-detail">
                    {{ addr.province }} {{ addr.city }} {{ addr.district }} {{ addr.detail }}
                  </div>
                  <div class="addr-card-actions">
                    <el-button
                      v-if="addr.isDefault !== 1 && addr.isDefault !== true"
                      type="primary"
                      link
                      size="small"
                      @click="handleSetDefault(addr.id)"
                    >
                      <el-icon><Star /></el-icon>设为默认
                    </el-button>
                    <el-button
                      v-else
                      type="info"
                      link
                      size="small"
                      disabled
                    >
                      <el-icon><Check /></el-icon>默认地址
                    </el-button>
                    <el-button type="primary" link size="small" @click="openEditAddress(addr)">
                      <el-icon><Edit /></el-icon>编辑
                    </el-button>
                    <el-button type="danger" link size="small" @click="handleDeleteAddress(addr.id)">
                      <el-icon><Delete /></el-icon>删除
                    </el-button>
                  </div>
                </div>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane label="个人设置" name="settings">
            <el-form :model="profileForm" class="profile-form" ref="profileFormRef">
              <el-form-item label="昵称">
                <el-input v-model="profileForm.nickname" maxlength="20" />
              </el-form-item>
              <el-form-item label="邮箱">
                <el-input v-model="profileForm.email" placeholder="请输入邮箱" />
              </el-form-item>
              <el-form-item label="手机号">
                <el-input v-model="profileForm.phone" maxlength="11" placeholder="请输入11位手机号" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="saveProfile">保存修改</el-button>
              </el-form-item>
            </el-form>
          </el-tab-pane>
        </el-tabs>
      </div>
    </div>
    <Footer />

    <!-- 订单详情弹窗 -->
    <el-dialog v-model="orderDetailVisible" title="订单详情" width="640px">
      <div v-if="orderDetail" class="order-detail">
        <div class="detail-section">
          <h4>基本信息</h4>
          <div class="detail-row"><span class="label">订单号：</span><span class="mono">{{ orderDetail.orderNo }}</span></div>
          <div class="detail-row"><span class="label">订单状态：</span>
            <el-tag :type="getOrderStatusTagType(orderDetail.status)" size="small">{{ getOrderStatusText(orderDetail.status) }}</el-tag>
          </div>
          <div class="detail-row"><span class="label">下单时间：</span><span>{{ formatTime(orderDetail.createdAt) }}</span></div>
          <div v-if="orderDetail.payTime" class="detail-row"><span class="label">支付时间：</span><span>{{ formatTime(orderDetail.payTime) }}</span></div>
          <div v-if="orderDetail.groupBuyTime" class="detail-row"><span class="label">拼单时间：</span><span>{{ formatTime(orderDetail.groupBuyTime) }}</span></div>
          <div v-if="orderDetail.deliveryTime" class="detail-row"><span class="label">发货时间：</span><span>{{ formatTime(orderDetail.deliveryTime) }}</span></div>
          <div v-if="orderDetail.expressCompany" class="detail-row"><span class="label">快递公司：</span><span>{{ orderDetail.expressCompany }}</span></div>
          <div v-if="orderDetail.trackingNo" class="detail-row"><span class="label">物流单号：</span><span class="mono">{{ orderDetail.trackingNo }}</span></div>
          <div v-if="orderDetail.receiveTime" class="detail-row"><span class="label">成交时间：</span><span>{{ formatTime(orderDetail.receiveTime) }}</span></div>
          <div v-if="orderDetail.cancelTime" class="detail-row"><span class="label">取消时间：</span><span>{{ formatTime(orderDetail.cancelTime) }}</span></div>
        </div>

        <div v-if="orderDetail.expressCompany || orderDetail.trackingNo" class="detail-section">
          <h4>物流轨迹</h4>
          <div v-if="logisticsTrackList.length > 0" class="logistics-timeline">
            <el-timeline>
              <el-timeline-item
                v-for="(track, idx) in logisticsTrackList"
                :key="idx"
                :timestamp="track.time"
                :type="idx === 0 ? 'primary' : ''"
                :color="idx === 0 ? '#ff4400' : ''"
              >
                <div class="track-status">{{ track.status }}</div>
                <div class="track-desc">{{ track.description }}</div>
              </el-timeline-item>
            </el-timeline>
          </div>
          <el-empty v-else description="暂无物流信息" :image-size="60" />
        </div>
        <div class="detail-section">
          <h4>收货信息</h4>
          <div class="detail-row"><span class="label">收货人：</span><span>{{ orderDetail.receiverName || '-' }}</span></div>
          <div class="detail-row"><span class="label">联系电话：</span><span>{{ orderDetail.receiverPhone || '-' }}</span></div>
          <div class="detail-row"><span class="label">收货地址：</span><span>{{ orderDetail.receiverAddress || '-' }}</span></div>
        </div>
        <div class="detail-section">
          <h4>商品信息</h4>
          <div v-for="(item, idx) in orderDetailItems" :key="idx" class="detail-product">
            <img :src="item.productImage || defaultImg" class="detail-img" />
            <div class="detail-product-info">
              <div class="detail-product-name">{{ item.productName }}</div>
              <div class="detail-product-spec" v-if="item.specValues">{{ item.specValues }}</div>
              <div class="detail-product-price">
                <span>¥{{ Number(item.price).toFixed(2) }}</span>
                <span> × {{ item.quantity }}</span>
              </div>
            </div>
          </div>
        </div>
        <div v-if="orderCoupons && orderCoupons.length > 0" class="detail-section">
          <h4>优惠券</h4>
          <div v-for="(c, idx) in orderCoupons" :key="idx" class="coupon-card">
            <div class="coupon-left">
              <div class="coupon-amount">¥{{ Number(c.discountAmount).toFixed(0) }}</div>
              <div class="coupon-condition">满{{ Number(c.minAmount).toFixed(0) }}可用</div>
            </div>
            <div class="coupon-right">
              <div class="coupon-name">{{ c.name }}</div>
            </div>
          </div>
        </div>
        <div class="detail-section">
          <h4>金额信息</h4>
          <div class="detail-row"><span class="label">商品总额：</span><span>¥{{ Number(orderDetail.totalAmount).toFixed(2) }}</span></div>
          <div v-if="orderDetail.discountAmount > 0" class="detail-row"><span class="label">优惠金额：</span><span class="discount">-¥{{ Number(orderDetail.discountAmount).toFixed(2) }}</span></div>
          <div class="detail-row"><span class="label">运费：</span><span>¥{{ Number(orderDetail.freightAmount || 0).toFixed(2) }}</span></div>
          <div class="detail-row total-row"><span class="label">实付金额：</span><span class="total-price">¥{{ Number(orderDetail.payAmount).toFixed(2) }}</span></div>
        </div>
        <div v-if="orderDetail.remark" class="detail-section">
          <h4>备注</h4>
          <p>{{ orderDetail.remark }}</p>
        </div>
      </div>
      <template #footer>
        <el-button @click="orderDetailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 取消订单对话框 -->
    <el-dialog v-model="cancelDialogVisible" title="取消订单" width="500px">
      <div class="cancel-dialog">
        <p class="dialog-tip">请选择取消订单的原因：</p>
        <div class="reason-options">
          <div
            v-for="reason in cancelReasons"
            :key="reason"
            :class="['reason-item', { selected: selectedCancelReason === reason }]"
            @click="selectedCancelReason = reason"
          >
            {{ reason }}
          </div>
          <div
            :class="['reason-item', { selected: selectedCancelReason === 'other' }]"
            @click="selectedCancelReason = 'other'"
          >
            其他
          </div>
        </div>
        <div v-if="selectedCancelReason === 'other'" class="custom-reason">
          <el-input
            v-model="customCancelReason"
            type="textarea"
            :rows="3"
            placeholder="请输入取消原因..."
            maxlength="200"
            show-word-limit
          />
        </div>
      </div>
      <template #footer>
        <el-button @click="cancelDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canSubmitCancel" @click="confirmCancel">确定取消</el-button>
      </template>
    </el-dialog>

    <!-- 地址编辑弹窗 -->
    <el-dialog v-model="addressDialogVisible" :title="editingAddrId ? '编辑收货地址' : '新增收货地址'" width="560px">
      <el-form :model="addrForm" label-width="80px">
        <el-form-item label="收货人">
          <el-input v-model="addrForm.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号">
          <el-input v-model="addrForm.phone" placeholder="请输入手机号" maxlength="11" />
        </el-form-item>
        <el-form-item label="省份">
          <el-select
            v-model="addrForm.province"
            placeholder="请选择省份"
            filterable
            style="width: 100%"
            @change="onAddrProvinceChange"
          >
            <el-option
              v-for="p in addrProvinces"
              :key="p"
              :label="p"
              :value="p"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="城市">
          <el-select
            v-model="addrForm.city"
            placeholder="请选择城市"
            filterable
            :disabled="!addrForm.province"
            style="width: 100%"
            @change="onAddrCityChange"
          >
            <el-option
              v-for="c in addrAvailableCities"
              :key="c"
              :label="c"
              :value="c"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="区/县">
          <el-select
            v-model="addrForm.district"
            placeholder="请选择区/县"
            filterable
            :disabled="!addrForm.city"
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="d in addrAvailableDistricts"
              :key="d"
              :label="d"
              :value="d"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="详细地址">
          <el-input v-model="addrForm.detail" placeholder="街道、楼牌号等" />
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="addrForm.isDefault" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addressDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveAddr">保存</el-button>
      </template>
    </el-dialog>

    <!-- 退款申请对话框 -->
    <el-dialog v-model="refundDialogVisible" title="申请退款" width="620px">
      <div class="refund-dialog">
        <el-form label-width="90px">
          <el-form-item label="退款类型">
            <el-radio-group v-model="selectedRefundType" @change="onRefundTypeChange">
              <el-radio :value="1">仅退款</el-radio>
              <el-radio v-if="canReturnRefund" :value="2">退货退款</el-radio>
            </el-radio-group>
            <div v-if="!canReturnRefund" class="refund-type-tip">
              <el-icon style="margin-right: 4px; color: #e6a23c;"><Warning /></el-icon>
              商品未发货，仅支持仅退款
            </div>
            <div v-if="selectedRefundType === 2" class="refund-type-tip" style="margin-top: 8px;">
              <el-icon style="margin-right: 4px; color: #e6a23c;"><Warning /></el-icon>
              退货退款需退还全部商品
            </div>
          </el-form-item>
        </el-form>

        <div class="refund-products-section">
          <div class="section-title">
            <span>选择退款商品</span>
            <span v-if="selectedRefundType === 1" class="section-tip">可选择部分商品退款</span>
            <span v-else class="section-tip">退货退款需全部退还</span>
          </div>
          <div class="refund-product-list">
            <div
              v-for="(item, idx) in refundOrderItems"
              :key="idx"
              :class="['refund-product-item', { disabled: selectedRefundType === 2 }]"
            >
              <el-checkbox
                v-model="selectedRefundItems"
                :value="item.id || idx"
                :disabled="selectedRefundType === 2"
              />
              <img :src="item.productImage || defaultImg" class="refund-product-img" />
              <div class="refund-product-info">
                <div class="refund-product-name">{{ item.productName }}</div>
                <div class="refund-product-spec" v-if="item.specValues">{{ item.specValues }}</div>
                <div class="refund-product-price">
                  <span>¥{{ Number(item.price).toFixed(2) }}</span>
                  <span> × {{ item.quantity }}</span>
                </div>
              </div>
              <div class="refund-product-subtotal">
                ¥{{ (Number(item.price) * (item.quantity || 1)).toFixed(2) }}
              </div>
            </div>
          </div>
          <div class="refund-amount-summary">
            <span>已选商品退款金额合计：</span>
            <span class="refund-amount-total">¥{{ selectedRefundAmount.toFixed(2) }}</span>
          </div>
        </div>

        <p class="dialog-tip">请选择退款原因：</p>
        <div class="reason-options">
          <div
            v-for="reason in currentRefundReasons"
            :key="reason"
            :class="['reason-item', { selected: selectedRefundReason === reason }]"
            @click="selectedRefundReason = reason"
          >
            {{ reason }}
          </div>
          <div
            :class="['reason-item', { selected: selectedRefundReason === 'other' }]"
            @click="selectedRefundReason = 'other'"
          >
            其他
          </div>
        </div>
        <div v-if="selectedRefundReason === 'other'" class="custom-reason">
          <el-input
            v-model="customRefundReason"
            type="textarea"
            :rows="3"
            placeholder="请输入退款原因..."
            maxlength="200"
            show-word-limit
          />
        </div>

        <div class="upload-voucher-section">
          <div class="section-title">上传凭证（选填）</div>
          <el-upload
            v-model:file-list="refundVoucherList"
            action="#"
            list-type="picture-card"
            :auto-upload="false"
            :limit="6"
            multiple
            accept="image/*"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
          <div class="upload-tip">最多上传6张图片，支持 jpg、png 格式</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="refundDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canSubmitRefund" @click="confirmRefund">提交申请</el-button>
      </template>
    </el-dialog>

    <!-- 退款详情对话框 -->
    <el-dialog v-model="refundDetailVisible" title="退款详情" width="600px">
      <div class="refund-detail" v-if="currentRefundDetail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="退款单号">{{ currentRefundDetail.refundNo }}</el-descriptions-item>
          <el-descriptions-item label="订单ID">{{ currentRefundDetail.orderId }}</el-descriptions-item>
          <el-descriptions-item label="退款类型">
            <el-tag :type="currentRefundDetail.refundType === 1 ? 'info' : 'warning'" size="small">
              {{ currentRefundDetail.refundType === 1 ? '仅退款' : '退货退款' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="退款状态">
            <el-tag :type="getRefundStatusTagType(currentRefundDetail.status)" size="small">
              {{ getRefundStatusText(currentRefundDetail.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="退款金额" span="2">
            <span class="refund-amount">¥{{ Number(currentRefundDetail.refundAmount).toFixed(2) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="退款原因" span="2">{{ currentRefundDetail.refundReason }}</el-descriptions-item>
          <el-descriptions-item label="申请时间" span="2">{{ currentRefundDetail.applyTime }}</el-descriptions-item>
          <el-descriptions-item v-if="currentRefundDetail.reviewTime" label="审核时间" span="2">
            {{ currentRefundDetail.reviewTime }}
          </el-descriptions-item>
          <el-descriptions-item v-if="currentRefundDetail.reviewRemark" label="审核备注" span="2">
            {{ currentRefundDetail.reviewRemark }}
          </el-descriptions-item>
        </el-descriptions>

        <!-- 退货物流信息 -->
        <div v-if="currentRefundDetail.refundType === 2 && currentRefundDetail.returnLogisticsCompany" class="return-logistics">
          <h4>退货物流信息</h4>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="物流公司">{{ currentRefundDetail.returnLogisticsCompany }}</el-descriptions-item>
            <el-descriptions-item label="物流单号">{{ currentRefundDetail.returnTrackingNo }}</el-descriptions-item>
            <el-descriptions-item v-if="currentRefundDetail.returnShipTime" label="发货时间" span="2">
              {{ currentRefundDetail.returnShipTime }}
            </el-descriptions-item>
            <el-descriptions-item v-if="currentRefundDetail.returnReceiveTime" label="收货时间" span="2">
              {{ currentRefundDetail.returnReceiveTime }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 退款进度 -->
        <div class="refund-progress">
          <h4>退款进度</h4>
          <el-steps :active="getRefundProgress(currentRefundDetail)" finish-status="success" align-center>
            <el-step title="提交申请" :description="currentRefundDetail.applyTime" />
            <el-step
              :title="currentRefundDetail.refundType === 1 ? '商家审核' : '商家审核'"
              :description="currentRefundDetail.reviewTime || ''"
            />
            <el-step v-if="currentRefundDetail.refundType === 2" title="退货发货" :description="currentRefundDetail.returnShipTime || ''" />
            <el-step v-if="currentRefundDetail.refundType === 2" title="商家收货" :description="currentRefundDetail.returnReceiveTime || ''" />
            <el-step title="退款完成" :description="currentRefundDetail.status === 3 ? currentRefundDetail.completeTime || currentRefundDetail.reviewTime : ''" />
          </el-steps>
        </div>
      </div>
      <template #footer>
        <el-button @click="refundDetailVisible = false">关闭</el-button>
        <el-button type="success" @click="openServiceDialog">
          <el-icon><Service /></el-icon>联系客服
        </el-button>
        <el-button v-if="currentRefundDetail?.status === 1" type="primary" @click="showReturnShipDialog(currentRefundDetail)">
          填写退货物流
        </el-button>
      </template>
    </el-dialog>

    <!-- 填写退货物流对话框 -->
    <el-dialog v-model="returnShipDialogVisible" title="填写退货物流" width="450px">
      <div class="return-ship-form">
        <el-form label-width="100px">
          <el-form-item label="物流公司">
            <el-select v-model="returnLogisticsCompany" placeholder="请选择物流公司">
              <el-option
                v-for="exp in logisticsCompanies"
                :key="exp.code"
                :label="exp.name"
                :value="exp.name"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="物流单号">
            <el-input v-model="returnTrackingNo" placeholder="请输入物流单号" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="returnShipDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canSubmitReturnShip" @click="submitReturnShip">确认发货</el-button>
      </template>
    </el-dialog>

    <!-- 换货申请对话框 -->
    <el-dialog v-model="exchangeDialogVisible" title="申请换货" width="700px">
      <div class="exchange-dialog">
        <div class="exchange-products-section">
          <div class="section-title">
            <span>原商品信息</span>
          </div>
          <div class="exchange-product-list">
            <div
              v-for="(item, idx) in exchangeOrderItems"
              :key="idx"
              class="exchange-product-item"
            >
              <img :src="item.productImage || defaultImg" class="exchange-product-img" />
              <div class="exchange-product-info">
                <div class="exchange-product-name">{{ item.productName }}</div>
                <div class="exchange-product-spec" v-if="item.specValues">{{ item.specValues }}</div>
                <div class="exchange-product-price">
                  <span>¥{{ Number(item.price).toFixed(2) }}</span>
                  <span> × {{ item.quantity }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="exchange-new-product-section">
          <div class="section-title">
            <span>选择换货商品</span>
            <el-button type="primary" size="small" @click="goToSelectProduct">去选择商品</el-button>
          </div>
          <div class="new-product-input">
            <el-form label-width="100px">
              <el-form-item label="新商品ID">
                <el-input v-model="newProductId" placeholder="请输入新商品ID" />
              </el-form-item>
              <el-form-item label="新SKU ID">
                <el-input v-model="newSkuId" placeholder="请输入新SKU ID" />
              </el-form-item>
            </el-form>
          </div>
        </div>

        <p class="dialog-tip">请选择换货原因：</p>
        <div class="reason-options">
          <div
            v-for="reason in exchangeReasons"
            :key="reason"
            :class="['reason-item', { selected: selectedExchangeReason === reason }]"
            @click="selectedExchangeReason = reason"
          >
            {{ reason }}
          </div>
          <div
            :class="['reason-item', { selected: selectedExchangeReason === 'other' }]"
            @click="selectedExchangeReason = 'other'"
          >
            其他
          </div>
        </div>
        <div v-if="selectedExchangeReason === 'other'" class="custom-reason">
          <el-input
            v-model="customExchangeReason"
            type="textarea"
            :rows="3"
            placeholder="请输入换货原因..."
            maxlength="200"
            show-word-limit
          />
        </div>
      </div>
      <template #footer>
        <el-button @click="exchangeDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canSubmitExchange" @click="confirmExchange">提交申请</el-button>
      </template>
    </el-dialog>

    <!-- 换货详情对话框 -->
    <el-dialog v-model="exchangeDetailVisible" title="换货详情" width="700px">
      <div class="exchange-detail" v-if="currentExchangeDetail">
        <div class="exchange-products-compare">
          <div class="product-section original">
            <h4>原商品</h4>
            <div class="product-card">
              <img :src="currentExchangeDetail.originalProductImage || defaultImg" class="product-img" />
              <div class="product-info">
                <div class="product-name">{{ currentExchangeDetail.originalProductName }}</div>
                <div class="product-spec" v-if="currentExchangeDetail.originalSpecValues">{{ currentExchangeDetail.originalSpecValues }}</div>
                <div class="product-price">¥{{ Number(currentExchangeDetail.originalPrice || 0).toFixed(2) }}</div>
              </div>
            </div>
          </div>
          <div class="product-section new">
            <h4>新商品</h4>
            <div class="product-card">
              <img :src="currentExchangeDetail.newProductImage || defaultImg" class="product-img" />
              <div class="product-info">
                <div class="product-name">{{ currentExchangeDetail.newProductName }}</div>
                <div class="product-spec" v-if="currentExchangeDetail.newSpecValues">{{ currentExchangeDetail.newSpecValues }}</div>
                <div class="product-price">¥{{ Number(currentExchangeDetail.newPrice || 0).toFixed(2) }}</div>
              </div>
            </div>
          </div>
        </div>

        <el-descriptions :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="换货单号">{{ currentExchangeDetail.exchangeNo }}</el-descriptions-item>
          <el-descriptions-item label="订单ID">{{ currentExchangeDetail.orderId }}</el-descriptions-item>
          <el-descriptions-item label="换货状态">
            <el-tag :type="getExchangeStatusTagType(currentExchangeDetail.status)" size="small">
              {{ getExchangeStatusText(currentExchangeDetail.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="换货原因">{{ currentExchangeDetail.exchangeReason }}</el-descriptions-item>
          <el-descriptions-item label="申请时间">{{ currentExchangeDetail.applyTime }}</el-descriptions-item>
        </el-descriptions>

        <!-- 退货物流信息 -->
        <div v-if="currentExchangeDetail.returnLogisticsCompany" class="return-logistics">
          <h4>退货物流信息</h4>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="物流公司">{{ currentExchangeDetail.returnLogisticsCompany }}</el-descriptions-item>
            <el-descriptions-item label="物流单号">{{ currentExchangeDetail.returnTrackingNo }}</el-descriptions-item>
            <el-descriptions-item v-if="currentExchangeDetail.returnShipTime" label="发货时间" span="2">
              {{ currentExchangeDetail.returnShipTime }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 换货发货物流信息 -->
        <div v-if="currentExchangeDetail.exchangeLogisticsCompany" class="exchange-logistics">
          <h4>换货发货物流信息</h4>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="物流公司">{{ currentExchangeDetail.exchangeLogisticsCompany }}</el-descriptions-item>
            <el-descriptions-item label="物流单号">{{ currentExchangeDetail.exchangeTrackingNo }}</el-descriptions-item>
            <el-descriptions-item v-if="currentExchangeDetail.exchangeShipTime" label="发货时间" span="2">
              {{ currentExchangeDetail.exchangeShipTime }}
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 换货进度 -->
        <div class="exchange-progress">
          <h4>换货进度</h4>
          <el-steps :active="getExchangeProgress(currentExchangeDetail)" finish-status="success" align-center>
            <el-step title="提交申请" :description="currentExchangeDetail.applyTime" />
            <el-step title="商家审核" :description="currentExchangeDetail.reviewTime || ''" />
            <el-step title="退货发货" :description="currentExchangeDetail.returnShipTime || ''" />
            <el-step title="商家收货" :description="currentExchangeDetail.returnReceiveTime || ''" />
            <el-step title="换货发货" :description="currentExchangeDetail.exchangeShipTime || ''" />
            <el-step title="确认收货" :description="currentExchangeDetail.exchangeReceiveTime || ''" />
          </el-steps>
        </div>
      </div>
      <template #footer>
        <el-button @click="exchangeDetailVisible = false">关闭</el-button>
        <el-button v-if="currentExchangeDetail?.status === 1" type="primary" @click="showExchangeReturnShipDialog(currentExchangeDetail)">
          填写退货物流
        </el-button>
        <el-button v-if="currentExchangeDetail?.status === 5" type="success" @click="confirmExchangeReceive(currentExchangeDetail)">
          确认收货
        </el-button>
        <el-button v-if="currentExchangeDetail?.status === 0" type="danger" @click="cancelExchange(currentExchangeDetail)">
          取消申请
        </el-button>
      </template>
    </el-dialog>

    <!-- 换货退货物流对话框 -->
    <el-dialog v-model="exchangeReturnShipDialogVisible" title="填写退货物流" width="450px">
      <div class="return-ship-form">
        <el-form label-width="100px">
          <el-form-item label="物流公司">
            <el-select v-model="exchangeReturnLogisticsCompany" placeholder="请选择物流公司">
              <el-option
                v-for="exp in logisticsCompanies"
                :key="exp.code"
                :label="exp.name"
                :value="exp.name"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="物流单号">
            <el-input v-model="exchangeReturnTrackingNo" placeholder="请输入物流单号" />
          </el-form-item>
        </el-form>
      </div>
      <template #footer>
        <el-button @click="exchangeReturnShipDialogVisible = false">取消</el-button>
        <el-button type="primary" :disabled="!canSubmitExchangeReturnShip" @click="submitExchangeReturnShip">确认发货</el-button>
      </template>
    </el-dialog>

    <!-- 订单评价弹窗 -->
    <el-dialog v-model="reviewDialogVisible" :title="isViewReview ? '查看评价' : '订单评价'" width="640px">
      <div class="review-dialog" v-if="currentReviewOrder">
        <div class="review-order-info">
          <span class="label">订单号：</span>
          <span class="mono">{{ currentReviewOrder.orderNo }}</span>
        </div>
        <div class="review-products-list">
          <div v-for="(item, idx) in reviewItems" :key="idx" class="review-product-item">
            <div class="review-product-header">
              <img :src="item.productImage || defaultImg" class="review-product-img" />
              <div class="review-product-info">
                <div class="review-product-name">{{ item.productName }}</div>
                <div class="review-product-spec" v-if="item.specValues">{{ item.specValues }}</div>
              </div>
            </div>
            <div v-if="!isViewReview" class="review-rating">
              <span class="rating-label">商品评分：</span>
              <el-rate v-model="item.rating" :max="5" />
            </div>
            <div v-else class="review-rating">
              <span class="rating-label">商品评分：</span>
              <el-rate :model-value="item.rating" :max="5" disabled />
            </div>
            <div class="review-content">
              <span class="rating-label">评价内容：</span>
              <el-input
                v-model="item.content"
                type="textarea"
                :rows="3"
                :disabled="isViewReview"
                placeholder="分享您的购物体验..."
                maxlength="500"
                show-word-limit
              />
            </div>
            <div class="review-images">
              <span class="rating-label">评价图片：</span>
              <div v-if="isViewReview" class="review-image-list">
                <el-image
                  v-for="(img, imgIdx) in (item.images || [])"
                  :key="imgIdx"
                  :src="img"
                  :preview-src-list="item.images"
                  fit="cover"
                  class="review-image"
                />
                <span v-if="!item.images || item.images.length === 0" class="no-images">暂无图片</span>
              </div>
              <el-upload
                v-else
                v-model:file-list="item.imageFiles"
                action="#"
                list-type="picture-card"
                :auto-upload="false"
                :limit="6"
                multiple
                accept="image/*"
              >
                <el-icon><Plus /></el-icon>
              </el-upload>
            </div>
          </div>
        </div>
        <div v-if="!isViewReview" class="review-anonymous">
          <el-checkbox v-model="reviewAnonymous">匿名评价</el-checkbox>
        </div>
        <div v-if="isViewReview && currentReviewOrder.reviewTime" class="review-time">
          <span class="label">评价时间：</span>
          <span>{{ formatTime(currentReviewOrder.reviewTime) }}</span>
        </div>
      </div>
      <template #footer>
        <el-button @click="reviewDialogVisible = false">{{ isViewReview ? '关闭' : '取消' }}</el-button>
        <el-button v-if="!isViewReview" type="primary" :disabled="!canSubmitReview" @click="submitReview">提交评价</el-button>
      </template>
    </el-dialog>

    <!-- 客服对话弹窗 -->
    <el-dialog v-model="serviceDialogVisible" title="在线客服" width="520px" class="service-dialog">
      <div class="service-header">
        <el-avatar :size="48" src="https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png" />
        <div class="service-info">
          <div class="service-name">售后客服小助手</div>
          <div class="service-status">
            <span class="status-dot online"></span>
            在线
          </div>
        </div>
      </div>
      <div class="service-messages" ref="serviceMessagesRef">
        <div v-for="(msg, idx) in serviceMessages" :key="idx" :class="['service-msg', msg.isUser ? 'user' : 'service']">
          <div v-if="!msg.isUser" class="service-avatar">
            <el-avatar :size="36" src="https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png" />
          </div>
          <div class="msg-content">
            <div v-if="msg.type === 'text'" class="msg-text">{{ msg.content }}</div>
            <div v-else-if="msg.type === 'image'" class="msg-image">
              <el-image :src="msg.content" fit="cover" :preview-src-list="[msg.content]" />
            </div>
            <div class="msg-time">{{ msg.time }}</div>
          </div>
          <div v-if="msg.isUser" class="user-avatar">
            <el-avatar :size="36" :src="userStore.userInfo?.avatar" />
          </div>
        </div>
        <div v-if="serviceTyping" class="service-msg service">
          <div class="service-avatar">
            <el-avatar :size="36" src="https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png" />
          </div>
          <div class="msg-content">
            <div class="msg-text typing">
              <span></span><span></span><span></span>
            </div>
          </div>
        </div>
      </div>
      <div class="service-input-area">
        <div class="service-tools">
          <el-upload
            action="#"
            :auto-upload="false"
            :show-file-list="false"
            accept="image/*"
            :on-change="handleServiceImageUpload"
          >
            <el-button type="primary" link>
              <el-icon><Picture /></el-icon>图片
            </el-button>
          </el-upload>
        </div>
        <div class="service-input-wrapper">
          <el-input
            v-model="serviceInputText"
            type="textarea"
            :rows="2"
            placeholder="请输入您的问题..."
            @keydown.enter.ctrl="sendServiceMessage"
          />
          <el-button type="primary" :disabled="!serviceInputText.trim()" @click="sendServiceMessage">
            发送
          </el-button>
        </div>
      </div>
    </el-dialog>

    <!-- 消息详情弹窗 -->
    <el-dialog v-model="messageDetailVisible" title="消息详情" width="520px">
      <div v-if="currentMessage" class="message-detail">
        <h3 class="message-detail-title">{{ currentMessage.title }}</h3>
        <div class="message-detail-meta">
          <el-tag :type="getMessageTypeTagType(currentMessage.type)" size="small">
            {{ getMessageTypeText(currentMessage.type) }}
          </el-tag>
          <span class="message-detail-time">{{ formatTime(currentMessage.createdAt) }}</span>
        </div>
        <div class="message-detail-content">
          {{ currentMessage.content || currentMessage.detail || '暂无详细内容' }}
        </div>
      </div>
      <template #footer>
        <el-button type="primary" @click="messageDetailVisible = false">我知道了</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Star, Check, Edit, Delete, Warning, Picture, Service } from '@element-plus/icons-vue'
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import request from '@/utils/request'
import { CHINA_REGIONS, PROVINCES } from '@/utils/regions'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeTab = ref('orders')
const memberInfo = ref<any>(null)
const pointsRecords = ref<any[]>([])
const messages = ref<any[]>([])
const orderCount = ref(0)
const ordersLoaded = ref(false)

const defaultImg = 'https://via.placeholder.com/60x60/f5f5f5/ccc?text=商品'

const orderStatusTabs = [
  { label: '全部', value: '' },
  { label: '待支付', value: '0' },
  { label: '已支付', value: '1' },
  { label: '已发货', value: '2' },
  { label: '已完成', value: '3' },
  { label: '已取消', value: '4' },
  { label: '退款中', value: '5' },
  { label: '已退款', value: '6' },
]
const orderStatus = ref('')
const orderList = ref<any[]>([])
const loadingOrders = ref(false)
const selectedOrderNos = ref<string[]>([])

const groupOrders = ref<any[]>([])
const loadingGroupOrders = ref(false)

function canDeleteOrder(row: any): boolean {
  return row.status === 3 || row.status === 4 || row.status === 6
}

function toggleSelectRow(row: any, val: boolean) {
  if (val) {
    if (!selectedOrderNos.value.includes(row.orderNo)) {
      selectedOrderNos.value.push(row.orderNo)
    }
  } else {
    selectedOrderNos.value = selectedOrderNos.value.filter(n => n !== row.orderNo)
  }
}

function handleSelectionChange(selection: any[]) {
  // 仅保留可删除的
  selectedOrderNos.value = selection
    .filter(canDeleteOrder)
    .map((r: any) => r.orderNo)
}

async function handleBatchDelete() {
  if (selectedOrderNos.value.length === 0) {
    ElMessage.warning('请先选择要删除的订单')
    return
  }
  try {
    await ElMessageBox.confirm(
      `确定要删除选中的 ${selectedOrderNos.value.length} 个订单吗？删除后不可恢复。`,
      '批量删除确认',
      { confirmButtonText: '确定删除', cancelButtonText: '取消', type: 'warning' }
    )
  } catch {
    return
  }
  try {
    await request.post('/order/batch-delete', {
      orderNos: selectedOrderNos.value,
      userId: userStore.userInfo?.id
    })
    ElMessage.success(`已删除 ${selectedOrderNos.value.length} 个订单`)
    selectedOrderNos.value = []
    loadOrders()
  } catch (e: any) {
    ElMessage.error(e.response?.data?.message || e.message || '批量删除失败')
  }
}

// 取消订单相关
const cancelDialogVisible = ref(false)
const currentCancelOrder = ref<any>(null)
const cancelReasons = [
  '商品价格过高',
  '商品降价了',
  '不想要了',
  '商品缺货',
  '收货信息填写错误',
  '重复下单',
  '支付遇到问题'
]
const selectedCancelReason = ref('')
const customCancelReason = ref('')
const canSubmitCancel = computed(() => {
  return selectedCancelReason.value !== ''
})

// 退款申请相关
const refundDialogVisible = ref(false)
const currentRefundOrder = ref<any>(null)
const selectedRefundType = ref(1)
const refundOrderItems = ref<any[]>([])
const selectedRefundItems = ref<any[]>([])
const refundVoucherList = ref<any[]>([])

const refundReasonsOnlyRefund = [
  '商品与描述不符',
  '未收到商品',
  '商品质量问题',
  '买错/不想要了',
  '价格问题',
]

const refundReasonsReturnRefund = [
  '商品与描述不符',
  '商品质量问题',
  '商品损坏/有瑕疵',
  '收到错误商品',
  '买错/不想要了',
]

const currentRefundReasons = computed(() => {
  return selectedRefundType.value === 1 ? refundReasonsOnlyRefund : refundReasonsReturnRefund
})

const selectedRefundAmount = computed(() => {
  if (!refundOrderItems.value.length) return 0
  if (selectedRefundType.value === 2) {
    return refundOrderItems.value.reduce((sum, item) => sum + Number(item.price) * (item.quantity || 1), 0)
  }
  return refundOrderItems.value
    .filter((_: any, idx: number) => selectedRefundItems.value.includes(refundOrderItems.value[idx].id || idx))
    .reduce((sum: number, item: any) => sum + Number(item.price) * (item.quantity || 1), 0)
})

const selectedRefundReason = ref('')
const customRefundReason = ref('')
const canSubmitRefund = computed(() => {
  return selectedRefundReason.value !== '' && selectedRefundItems.value.length > 0
})
const canReturnRefund = computed(() => {
  if (!currentRefundOrder.value) return false
  const status = currentRefundOrder.value.status
  return status === 2 || status === 3
})

function onRefundTypeChange() {
  if (selectedRefundType.value === 2) {
    selectedRefundItems.value = refundOrderItems.value.map((item: any, idx: number) => item.id || idx)
  }
}

// 退款列表相关
const refundStatusTabs = [
  { label: '全部', value: -1 },
  { label: '待审核', value: 0 },
  { label: '待退货', value: 1 },
  { label: '退货中', value: 5 },
  { label: '已完成', value: 3 },
  { label: '已拒绝', value: 2 },
  { label: '已取消', value: 4 },
]
const refundStatus = ref<number>(-1)
const refundList = ref<any[]>([])
const loadingRefunds = ref(false)
const refundPage = ref(1)
const refundPageSize = ref(10)
const refundTotal = ref(0)

// 退款详情
const refundDetailVisible = ref(false)
const currentRefundDetail = ref<any>(null)

// 退货物流
const returnShipDialogVisible = ref(false)
const currentReturnRefund = ref<any>(null)
const returnLogisticsCompany = ref('')
const returnTrackingNo = ref('')
const logisticsCompanies = [
  { code: 'SF', name: '顺丰速运' },
  { code: 'JD', name: '京东物流' },
  { code: 'EMS', name: 'EMS' },
  { code: 'ZTO', name: '中通快递' },
  { code: 'YTO', name: '圆通速递' },
  { code: 'YD', name: '韵达快递' },
  { code: 'JT', name: '极兔速递' },
  { code: 'STO', name: '申通快递' },
  { code: 'YUNDA', name: '韵达速递' },
  { code: 'DB', name: '德邦快递' },
  { code: 'SFTC', name: '顺丰同城' },
]
const canSubmitReturnShip = computed(() => {
  return returnLogisticsCompany.value !== '' && returnTrackingNo.value.trim() !== ''
})

// 换货申请相关
const exchangeDialogVisible = ref(false)
const currentExchangeOrder = ref<any>(null)
const exchangeOrderItems = ref<any[]>([])
const newProductId = ref('')
const newSkuId = ref('')
const exchangeReasons = [
  '商品质量问题',
  '商品与描述不符',
  '商品损坏/有瑕疵',
  '收到错误商品',
  '尺码/规格不合适',
  '颜色/款式不满意',
]
const selectedExchangeReason = ref('')
const customExchangeReason = ref('')
const canSubmitExchange = computed(() => {
  return selectedExchangeReason.value !== '' &&
         newProductId.value.trim() !== '' &&
         newSkuId.value.trim() !== ''
})

// 换货列表相关
const exchangeStatusTabs = [
  { label: '全部', value: -1 },
  { label: '待审核', value: 0 },
  { label: '待退货', value: 1 },
  { label: '退货中', value: 2 },
  { label: '待发货', value: 3 },
  { label: '待收货', value: 5 },
  { label: '已完成', value: 6 },
  { label: '已拒绝', value: 4 },
  { label: '已取消', value: 7 },
]
const exchangeStatus = ref<number>(-1)
const exchangeList = ref<any[]>([])
const loadingExchanges = ref(false)
const exchangePage = ref(1)
const exchangePageSize = ref(10)
const exchangeTotal = ref(0)

// 换货详情
const exchangeDetailVisible = ref(false)
const currentExchangeDetail = ref<any>(null)

// 换货退货物流
const exchangeReturnShipDialogVisible = ref(false)
const currentExchangeReturn = ref<any>(null)
const exchangeReturnLogisticsCompany = ref('')
const exchangeReturnTrackingNo = ref('')
const canSubmitExchangeReturnShip = computed(() => {
  return exchangeReturnLogisticsCompany.value !== '' && exchangeReturnTrackingNo.value.trim() !== ''
})

// 订单详情
const orderDetailVisible = ref(false)
const orderDetail = ref<any>(null)
const orderDetailItems = ref<any[]>([])
const orderCoupons = ref<any[]>([])
const logisticsTrackList = ref<any[]>([])

const mockLogisticsTrack = [
  { time: '2024-01-15 14:30:00', status: '已签收', description: '您的快件已签收，签收人：本人' },
  { time: '2024-01-15 09:20:00', status: '派送中', description: '快递员正在为您派送，请保持电话畅通' },
  { time: '2024-01-14 22:15:00', status: '到达目的地', description: '快件已到达【XX市XX区营业点】' },
  { time: '2024-01-14 08:30:00', status: '运输中', description: '快件已从【XX市转运中心】发出' },
  { time: '2024-01-13 18:45:00', status: '运输中', description: '快件已到达【XX市转运中心】' },
  { time: '2024-01-13 10:00:00', status: '已发货', description: '商家已发货，正在等待快递员揽收' },
]

async function viewOrderDetail(row: any) {
  try {
    const res = await request.get('/order/detail', {
      params: { orderNo: row.orderNo }
    })
    if (res.data) {
      orderDetail.value = res.data.order
      orderDetailItems.value = res.data.items || []
      orderCoupons.value = res.data.coupons || []
      if (orderDetail.value?.status >= 2) {
        logisticsTrackList.value = mockLogisticsTrack
      } else {
        logisticsTrackList.value = []
      }
      orderDetailVisible.value = true
    }
  } catch (e) {
    ElMessage.error('加载订单详情失败')
  }
}

function getRefundStatusText(status: number) {
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

function getRefundStatusTagType(status: number) {
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
  if (!userStore.userInfo?.id) return
  loadingRefunds.value = true
  try {
    const res = await request.get('/refund/user', {
      params: {
        userId: userStore.userInfo.id,
        page: refundPage.value,
        size: refundPageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    const totalCount = res.data?.total || 0
    if (refundStatus.value !== -1) {
      list = list.filter(item => item.status === refundStatus.value)
    }
    refundList.value = list
    refundTotal.value = totalCount
  } catch (e) {
    console.error('加载退款列表失败', e)
    refundList.value = []
  } finally {
    loadingRefunds.value = false
  }
}

async function viewRefundDetail(row: any) {
  try {
    const res = await request.get('/refund/detail', {
      params: { id: row.id }
    })
    if (res.data) {
      currentRefundDetail.value = res.data
      refundDetailVisible.value = true
    }
  } catch (e) {
    ElMessage.error('加载退款详情失败')
  }
}

function getRefundProgress(refund: any) {
  if (!refund) return 0
  const status = refund.status
  const type = refund.refundType
  if (type === 1) {
    if (status === 0) return 0
    if (status === 2 || status === 4) return 1
    if (status === 3) return 2
  } else {
    if (status === 0) return 0
    if (status === 1) return 1
    if (status === 5) return 2
    if (status === 3) return 4
    if (status === 2 || status === 4) return 1
  }
  return 0
}

function showReturnShipDialog(row: any) {
  currentReturnRefund.value = row
  returnLogisticsCompany.value = ''
  returnTrackingNo.value = ''
  returnShipDialogVisible.value = true
  refundDetailVisible.value = false
}

async function submitReturnShip() {
  if (!currentReturnRefund.value || !canSubmitReturnShip.value) return
  try {
    await request.post('/refund/return-ship', null, {
      params: {
        refundId: currentReturnRefund.value.id,
        userId: userStore.userInfo?.id,
        logisticsCompany: returnLogisticsCompany.value,
        trackingNo: returnTrackingNo.value.trim()
      }
    })
    ElMessage.success('退货物流已提交')
    returnShipDialogVisible.value = false
    loadRefunds()
  } catch (e: any) {
    ElMessage.error(e?.message || '提交失败')
  }
}

// ==================== 换货功能 ====================
function applyExchange(row: any) {
  currentExchangeOrder.value = row
  selectedExchangeReason.value = ''
  customExchangeReason.value = ''
  newProductId.value = ''
  newSkuId.value = ''
  const items = row.items || []
  exchangeOrderItems.value = items
  exchangeDialogVisible.value = true
}

function goToSelectProduct() {
  ElMessage.info('请前往商品详情页选择规格后返回，或直接输入新商品ID和SKU ID')
}

async function confirmExchange() {
  if (!currentExchangeOrder.value || !canSubmitExchange.value) return
  try {
    const reason = selectedExchangeReason.value === 'other'
      ? (customExchangeReason.value.trim() || '其他')
      : selectedExchangeReason.value

    const firstItem = exchangeOrderItems.value[0]
    await request.post('/exchange/apply', null, {
      params: {
        userId: userStore.userInfo?.id,
        orderId: currentExchangeOrder.value.id,
        orderItemId: firstItem?.id,
        originalProductId: firstItem?.productId,
        originalSkuId: firstItem?.skuId,
        newProductId: newProductId.value.trim(),
        newSkuId: newSkuId.value.trim(),
        reason
      }
    })
    ElMessage.success('换货申请已提交')
    exchangeDialogVisible.value = false
    loadOrders()
  } catch (e: any) {
    ElMessage.error(e?.message || '申请失败')
  }
}

async function loadExchanges() {
  if (!userStore.userInfo?.id) return
  loadingExchanges.value = true
  try {
    const res = await request.get('/exchange/user', {
      params: {
        userId: userStore.userInfo.id,
        page: exchangePage.value,
        size: exchangePageSize.value
      }
    })
    let list = (res.data?.list || res.data?.records || []) as any[]
    const totalCount = res.data?.total || 0
    if (exchangeStatus.value !== -1) {
      list = list.filter(item => item.status === exchangeStatus.value)
    }
    exchangeList.value = list
    exchangeTotal.value = totalCount
  } catch (e) {
    console.error('加载换货列表失败', e)
    exchangeList.value = []
  } finally {
    loadingExchanges.value = false
  }
}

function getExchangeStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待审核',
    1: '待退货',
    2: '退货中',
    3: '待发货',
    4: '已拒绝',
    5: '待收货',
    6: '已完成',
    7: '已取消'
  }
  return types[status] || '未知'
}

function getExchangeStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning',
    1: 'primary',
    2: 'warning',
    3: 'info',
    4: 'danger',
    5: 'success',
    6: 'success',
    7: 'info'
  }
  return types[status] || 'info'
}

async function viewExchangeDetail(row: any) {
  try {
    const res = await request.get('/exchange/detail', {
      params: { id: row.id }
    })
    if (res.data) {
      currentExchangeDetail.value = res.data
      exchangeDetailVisible.value = true
    }
  } catch (e) {
    ElMessage.error('加载换货详情失败')
  }
}

function showExchangeReturnShipDialog(row: any) {
  currentExchangeReturn.value = row
  exchangeReturnLogisticsCompany.value = ''
  exchangeReturnTrackingNo.value = ''
  exchangeReturnShipDialogVisible.value = true
  exchangeDetailVisible.value = false
}

async function submitExchangeReturnShip() {
  if (!currentExchangeReturn.value || !canSubmitExchangeReturnShip.value) return
  try {
    await request.post('/exchange/return-ship', null, {
      params: {
        exchangeId: currentExchangeReturn.value.id,
        userId: userStore.userInfo?.id,
        logisticsCompany: exchangeReturnLogisticsCompany.value,
        trackingNo: exchangeReturnTrackingNo.value.trim()
      }
    })
    ElMessage.success('退货物流已提交')
    exchangeReturnShipDialogVisible.value = false
    loadExchanges()
  } catch (e: any) {
    ElMessage.error(e?.message || '提交失败')
  }
}

async function confirmExchangeReceive(row: any) {
  try {
    await ElMessageBox.confirm('确认收到换货商品？', '确认收货', {
      type: 'success',
      confirmButtonText: '确认',
      cancelButtonText: '取消'
    })
    await request.post('/exchange/user-confirm', null, {
      params: {
        exchangeId: row.id,
        userId: userStore.userInfo?.id
      }
    })
    ElMessage.success('确认收货成功')
    exchangeDetailVisible.value = false
    loadExchanges()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e?.message || '操作失败')
    }
  }
}

async function cancelExchange(row: any) {
  try {
    await ElMessageBox.confirm('确定要取消换货申请吗？', '取消确认', {
      type: 'warning',
      confirmButtonText: '确定取消',
      cancelButtonText: '保留申请'
    })
    await request.post('/exchange/cancel', null, {
      params: {
        exchangeId: row.id,
        userId: userStore.userInfo?.id
      }
    })
    ElMessage.success('换货申请已取消')
    exchangeDetailVisible.value = false
    loadExchanges()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e?.message || '取消失败')
    }
  }
}

function getExchangeProgress(exchange: any) {
  if (!exchange) return 0
  const status = exchange.status
  if (status === 0) return 0
  if (status === 1 || status === 4) return 1
  if (status === 2) return 2
  if (status === 3) return 3
  if (status === 5) return 4
  if (status === 6) return 5
  return 0
}

watch(() => route.query.tab, (val) => {
  if (val && typeof val === 'string') {
    activeTab.value = val
  }
}, { immediate: true })

const profileForm = reactive({
  nickname: '',
  email: '',
  phone: ''
})

const memberLevelText = computed(() => {
  const level = memberInfo.value?.memberLevel || 1
  const levels: Record<number, string> = {
    1: '普通会员',
    2: '银卡会员',
    3: '金卡会员',
    4: '钻石会员'
  }
  return levels[level] || '普通会员'
})

function getPointTypeText(type: number) {
  const types: Record<number, string> = {
    1: '获取',
    2: '消费',
    3: '过期'
  }
  return types[type] || '未知'
}

function getMessageTypeText(type: number) {
  const types: Record<number, string> = {
    1: '系统消息',
    2: '订单通知',
    3: '退款通知',
    4: '活动通知',
  }
  return types[type] || '系统消息'
}

function getMessageTypeTagType(type: number) {
  const types: Record<number, string> = {
    1: 'info',
    2: 'primary',
    3: 'warning',
    4: 'success',
  }
  return types[type] || 'info'
}

const messageTypeTabs = [
  { label: '全部', value: '' },
  { label: '订单通知', value: '2' },
  { label: '退款通知', value: '3' },
  { label: '活动通知', value: '4' },
]
const messageType = ref('')
const loadingMessages = ref(false)
const messageDetailVisible = ref(false)
const currentMessage = ref<any>(null)

const filteredMessages = computed(() => {
  if (!messageType.value) return messages.value
  return messages.value.filter(m => String(m.type) === messageType.value)
})

function getUnreadCount(type: string) {
  return messages.value.filter(m => String(m.type) === type && !m.isRead).length
}

async function handleMessageClick(row: any) {
  currentMessage.value = row
  messageDetailVisible.value = true
  if (!row.isRead) {
    try {
      await request.put('/message/read', null, {
        params: { id: row.id }
      })
      row.isRead = true
    } catch (e) {
      console.error('标记已读失败', e)
    }
  }
}

function getOrderStatusText(status: number) {
  const types: Record<number, string> = {
    0: '待支付',
    1: '已支付',
    2: '已发货',
    3: '已完成',
    4: '已取消',
    5: '退款中',
    6: '已退款',
    7: '已过期'
  }
  return types[status] || '未知'
}

function getOrderStatusTagType(status: number) {
  const types: Record<number, string> = {
    0: 'warning',
    1: 'success',
    2: 'primary',
    3: 'success',
    4: 'info',
    5: 'warning',
    6: 'danger',
    7: 'info'
  }
  return types[status] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : ''
}

async function loadOrders() {
  if (!userStore.isLogin) return
  if (!userStore.userInfo?.id) {
    await userStore.getUserInfo()
  }
  if (!userStore.userInfo?.id) return
  loadingOrders.value = true
  try {
    const res = await request.get('/order/user', {
      params: {
        userId: userStore.userInfo.id,
        status: orderStatus.value ? parseInt(orderStatus.value) : null,
        page: 1,
        size: 100
      }
    })
    const data = res.data
    let list: any[] = []
    if (data?.list) {
      list = data.list.map((item: any) => {
        if (item.order) {
          return { ...item.order, items: item.items, refundStatus: item.refundStatus, rejectReason: item.rejectReason, productName: item.items?.[0]?.productName, productImage: item.items?.[0]?.productImage }
        }
        return item
      })
    } else if (data?.records) {
      list = data.records
    } else if (Array.isArray(data)) {
      list = data
    }
    orderList.value = list
    orderCount.value = list.length
    ordersLoaded.value = true
    console.log('[订单列表] 加载成功，数量:', list.length, '状态:', orderStatus.value || '全部')
  } catch (e: any) {
    console.error('[订单列表] 加载失败:', e)
    orderList.value = []
  } finally {
    loadingOrders.value = false
  }
}

async function loadGroupOrders() {
  if (!userStore.isLogin) return
  if (!userStore.userInfo?.id) {
    await userStore.getUserInfo()
  }
  if (!userStore.userInfo?.id) return
  loadingGroupOrders.value = true
  try {
    const userId = userStore.userInfo.id
    
    // 先查询所有订单
    const orderRes = await request.get('/order/user', {
      params: { userId, page: 1, size: 50 }
    })
    const orderData = orderRes.data
    let orders: any[] = []
    if (orderData?.list) {
      orders = orderData.list.map((item: any) => {
        if (item.order) {
          return { ...item.order, items: item.items, productName: item.items?.[0]?.productName, productImage: item.items?.[0]?.productImage }
        }
        return item
      })
    } else if (orderData?.records) {
      orders = orderData.records
    } else if (Array.isArray(orderData)) {
      orders = orderData
    }
    
    // 查询用户参与的拼团团队
    let groupTeams: any[] = []
    try {
      const teamRes = await request.get(`/group/team/user/${userId}`)
      groupTeams = teamRes.data?.teams || teamRes.data?.list || []
    } catch {
      groupTeams = []
    }
    
    // 如果没有查到团队，尝试另一种方式
    if (groupTeams.length === 0) {
      try {
        const memberRes = await request.get('/group/member/user', { params: { userId } })
        const members = memberRes.data?.list || memberRes.data || []
        const teamIds = [...new Set(members.map((m: any) => m.teamId).filter(Boolean))]
        for (const tid of teamIds) {
          try {
            const tr = await request.get(`/group/team/id/${tid}`)
            if (tr.data?.team) {
              groupTeams.push(tr.data.team)
            }
          } catch {}
        }
      } catch {}
    }
    
    // 将订单与团队关联，所有有groupBuyTeamId的订单都是拼团订单
    const groupOrdersList: any[] = []
    const teamIdMap = new Map(groupTeams.map((t: any) => [t.id, t]))
    
    for (const order of orders) {
      const teamId = order.groupBuyTeamId
      if (!teamId) continue
      
      const team = teamIdMap.get(teamId)
      const isRefundedOrCanceled = order.status === 4 || order.status === 5 || order.status === 6
      let finalStatus = 0
      let statusText = '拼团中'
      let teamNo = order.orderNo?.slice(-8) || '-'
      
      if (team) {
        teamNo = team.teamNo
        finalStatus = team.status
        if (finalStatus === 1) {
          statusText = '已成团'
        } else if (finalStatus === 2) {
          statusText = '已失败'
        } else {
          statusText = '拼团中'
        }
      }
      
      if (isRefundedOrCanceled) {
        finalStatus = 2
        statusText = '已取消'
      }
      
      groupOrdersList.push({
        ...order,
        teamNo,
        groupStatus: finalStatus,
        groupStatusText: statusText
      })
    }
    
    // 如果还是没有拼团订单，把所有有商品的订单都当作潜在拼团订单展示（兼容旧数据）
    if (groupOrdersList.length === 0 && orders.length > 0) {
      for (const order of orders) {
        if (order.items && order.items.length > 0) {
          const isRefundedOrCanceled = order.status === 4 || order.status === 5 || order.status === 6
          groupOrdersList.push({
            ...order,
            teamNo: order.orderNo?.slice(-8) || '-',
            groupStatus: isRefundedOrCanceled ? 2 : 0,
            groupStatusText: isRefundedOrCanceled ? '已取消' : '拼团中'
          })
        }
      }
    }
    
    groupOrders.value = groupOrdersList
  } catch (e: any) {
    console.error('[拼团订单] 加载失败:', e)
    groupOrders.value = []
  } finally {
    loadingGroupOrders.value = false
  }
}

function shareGroup(row: any) {
  if (row.teamNo) {
    const url = `${window.location.origin}/product/${row.items?.[0]?.productId || ''}?teamNo=${row.teamNo}`
    navigator.clipboard.writeText(url).then(() => {
      ElMessage.success('拼团链接已复制，快去分享给好友吧！')
    }).catch(() => {
      ElMessage.info(`请手动分享链接：${url}`)
    })
  } else {
    ElMessage.warning('暂无团号信息')
  }
}

function payOrder(row: any) {
  router.push({ path: '/order/pay', query: { orderNo: row.orderNo } })
}

function goToProductDetail(row: any) {
  const productId = row.items?.[0]?.productId
  if (productId) {
    router.push(`/product/${productId}`)
  }
}

function cancelOrder(row: any) {
  currentCancelOrder.value = row
  selectedCancelReason.value = ''
  customCancelReason.value = ''
  cancelDialogVisible.value = true
}

function cancelGroup(row: any) {
  currentCancelOrder.value = row
  selectedCancelReason.value = ''
  customCancelReason.value = ''
  cancelDialogVisible.value = true
}

async function confirmCancel() {
  if (!currentCancelOrder.value || !canSubmitCancel.value) return
  try {
    const reason = selectedCancelReason.value === 'other'
      ? (customCancelReason.value.trim() || '其他')
      : selectedCancelReason.value
    await request.post('/order/cancel', null, {
      params: { orderNo: currentCancelOrder.value.orderNo, reason }
    })
    ElMessage.success('订单已取消')
    cancelDialogVisible.value = false
    loadOrders()
    loadGroupOrders()
  } catch (e: any) {
    ElMessage.error(e?.message || '取消失败')
  }
}

function applyRefund(row: any) {
  currentRefundOrder.value = row
  selectedRefundType.value = row.status === 2 || row.status === 3 ? 2 : 1
  selectedRefundReason.value = ''
  customRefundReason.value = ''
  refundVoucherList.value = []
  const items = row.items || []
  refundOrderItems.value = items
  selectedRefundItems.value = items.map((item: any, idx: number) => item.id || idx)
  refundDialogVisible.value = true
}

function applyRefundGroup(row: any) {
  currentRefundOrder.value = row
  selectedRefundType.value = row.status === 2 || row.status === 3 ? 2 : 1
  selectedRefundReason.value = ''
  customRefundReason.value = ''
  refundVoucherList.value = []
  const items = row.items || []
  refundOrderItems.value = items
  selectedRefundItems.value = items.map((item: any, idx: number) => item.id || idx)
  refundDialogVisible.value = true
}

async function confirmRefund() {
  if (!currentRefundOrder.value || !canSubmitRefund.value) return
  try {
    const reason = selectedRefundReason.value === 'other'
      ? (customRefundReason.value.trim() || '其他')
      : selectedRefundReason.value
    await request.post('/refund/apply', null, {
      params: {
        userId: userStore.userInfo?.id,
        orderId: currentRefundOrder.value.id,
        refundAmount: currentRefundOrder.value.payAmount,
        reason,
        type: selectedRefundType.value
      }
    })
    ElMessage.success('退款申请已提交')
    refundDialogVisible.value = false
    loadOrders()
    loadGroupOrders()
  } catch (e: any) {
    ElMessage.error(e?.message || '申请失败')
  }
}

function showRejectReason(row: any) {
  ElMessageBox.alert(
    row.rejectReason || '商家未填写拒绝原因',
    '退款拒绝原因',
    { type: 'warning', confirmButtonText: '知道了' }
  )
}

function deleteOrder(row: any) {
  ElMessageBox.confirm('确定要删除该订单吗？删除后无法恢复。', '删除订单', {
    type: 'warning',
    confirmButtonText: '确定删除',
    cancelButtonText: '取消'
  }).then(async () => {
    try {
      await request.post('/order/delete', null, {
        params: { orderNo: row.orderNo, userId: userStore.userInfo?.id }
      })
      ElMessage.success('订单已删除')
      loadOrders()
    } catch (e: any) {
      ElMessage.error(e?.message || '删除失败')
    }
  }).catch(() => {})
}

function confirmReceive(row: any) {
  ElMessageBox.confirm(`确认收到商品？`, '确认收货', {
    type: 'success',
    confirmButtonText: '确认收货',
    cancelButtonText: '取消'
  }).then(async () => {
    try {
      await request.post('/order/confirmReceive', null, {
        params: { orderNo: row.orderNo }
      })
      ElMessage.success('确认收货成功')
      loadOrders()
    } catch (e: any) {
      ElMessage.error(e?.message || '操作失败')
    }
  }).catch(() => {})
}

async function loadMemberInfo() {
  const res = await fetch('/api/member/info')
  memberInfo.value = (await res.json()).data
}

async function loadPointsRecords() {
  const res = await fetch('/api/points/list')
  pointsRecords.value = (await res.json()).data
}

async function loadMessages() {
  if (!userStore.userInfo?.id) return
  loadingMessages.value = true
  try {
    const res = await request.get('/message/user/list', {
      params: { userId: userStore.userInfo.id }
    })
    messages.value = res.data?.list || res.data?.records || res.data || []
  } catch (e) {
    console.error('加载消息失败', e)
    messages.value = []
  } finally {
    loadingMessages.value = false
  }
}

// 订单评价
const reviewDialogVisible = ref(false)
const currentReviewOrder = ref<any>(null)
const reviewItems = ref<any[]>([])
const reviewAnonymous = ref(false)
const isViewReview = ref(false)

function openReviewDialog(row: any) {
  currentReviewOrder.value = row
  isViewReview.value = false
  reviewAnonymous.value = false
  const items = row.items || []
  reviewItems.value = items.map((item: any) => ({
    ...item,
    rating: 5,
    content: '',
    imageFiles: []
  }))
  reviewDialogVisible.value = true
}

function viewReview(row: any) {
  currentReviewOrder.value = row
  isViewReview.value = true
  const items = row.items || []
  reviewItems.value = items.map((item: any) => ({
    ...item,
    rating: item.reviewRating || 5,
    content: item.reviewContent || '商品质量很好，物流也很快，非常满意！',
    images: item.reviewImages || []
  }))
  reviewDialogVisible.value = true
}

const canSubmitReview = computed(() => {
  return reviewItems.value.every(item => item.rating > 0 && item.content.trim())
})

async function submitReview() {
  if (!canSubmitReview.value) {
    ElMessage.warning('请为所有商品评分并填写评价内容')
    return
  }
  try {
    const reviews = reviewItems.value.map(item => ({
      productId: item.productId,
      rating: item.rating,
      content: item.content,
      anonymous: reviewAnonymous.value
    }))
    await request.post('/review/submit', {
      orderId: currentReviewOrder.value?.id,
      userId: userStore.userInfo?.id,
      reviews
    })
    ElMessage.success('评价提交成功')
    if (currentReviewOrder.value) {
      currentReviewOrder.value.hasReview = true
      currentReviewOrder.value.reviewTime = new Date().toISOString()
    }
    reviewDialogVisible.value = false
    loadOrders()
  } catch (e: any) {
    ElMessage.error(e?.message || '评价提交失败')
  }
}

// 客服对话
const serviceDialogVisible = ref(false)
const serviceMessages = ref<any[]>([])
const serviceInputText = ref('')
const serviceTyping = ref(false)
const serviceMessagesRef = ref<HTMLElement | null>(null)

function openServiceDialog() {
  serviceMessages.value = [
    {
      isUser: false,
      type: 'text',
      content: '您好，我是售后客服小助手，很高兴为您服务！请问有什么可以帮助您的？',
      time: getCurrentTime()
    }
  ]
  serviceInputText.value = ''
  serviceDialogVisible.value = true
  nextTick(() => {
    scrollServiceToBottom()
  })
}

function getCurrentTime() {
  const now = new Date()
  return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`
}

function scrollServiceToBottom() {
  if (serviceMessagesRef.value) {
    serviceMessagesRef.value.scrollTop = serviceMessagesRef.value.scrollHeight
  }
}

const autoReplies = [
  '非常抱歉给您带来了不好的体验，我们会尽快为您处理退款申请。',
  '好的，您的问题我已经记录下来了，我们的客服人员会在24小时内与您联系。',
  '关于您提到的问题，您可以在退款详情中查看最新进度，有任何疑问随时联系我们。',
  '感谢您的反馈，我们会不断改进服务质量，希望能给您带来更好的购物体验。',
  '您好，您可以详细描述一下您遇到的问题吗？我会尽力为您解答。'
]

function sendServiceMessage() {
  const text = serviceInputText.value.trim()
  if (!text) return

  serviceMessages.value.push({
    isUser: true,
    type: 'text',
    content: text,
    time: getCurrentTime()
  })
  serviceInputText.value = ''
  nextTick(() => scrollServiceToBottom())

  serviceTyping.value = true
  setTimeout(() => {
    serviceTyping.value = false
    const reply = autoReplies[Math.floor(Math.random() * autoReplies.length)]
    serviceMessages.value.push({
      isUser: false,
      type: 'text',
      content: reply,
      time: getCurrentTime()
    })
    nextTick(() => scrollServiceToBottom())
  }, 1000 + Math.random() * 1500)
}

function handleServiceImageUpload(file: any) {
  const reader = new FileReader()
  reader.onload = (e) => {
    const imgUrl = e.target?.result as string
    serviceMessages.value.push({
      isUser: true,
      type: 'image',
      content: imgUrl,
      time: getCurrentTime()
    })
    nextTick(() => scrollServiceToBottom())

    serviceTyping.value = true
    setTimeout(() => {
      serviceTyping.value = false
      serviceMessages.value.push({
        isUser: false,
        type: 'text',
        content: '图片已收到，我们会尽快核实处理，请您耐心等待。',
        time: getCurrentTime()
      })
      nextTick(() => scrollServiceToBottom())
    }, 1000)
  }
  reader.readAsDataURL(file.raw)
}

async function saveProfile() {
  if (!profileForm.nickname || !profileForm.nickname.trim()) {
    ElMessage.warning('昵称不能为空')
    return
  }
  if (profileForm.nickname.trim().length > 20) {
    ElMessage.warning('昵称不能超过20个字符')
    return
  }
  if (profileForm.email && profileForm.email.trim()) {
    const emailReg = /^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$/
    if (!emailReg.test(profileForm.email.trim())) {
      ElMessage.warning('邮箱格式不正确')
      return
    }
  }
  if (profileForm.phone && profileForm.phone.trim()) {
    const phoneReg = /^1[3-9]\d{9}$/
    if (!phoneReg.test(profileForm.phone.trim())) {
      ElMessage.warning('手机号格式不正确，请输入11位有效手机号')
      return
    }
  }
  try {
    const res = await request.put('/user/profile', {
      nickname: profileForm.nickname.trim(),
      email: profileForm.email || '',
      phone: profileForm.phone || ''
    })
    if (res.data) {
      userStore.userInfo = res.data
      ElMessage.success('保存成功')
    }
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '保存失败')
  }
}

// ==================== 收货地址管理 ====================
const addressList = ref<any[]>([])
const addressDialogVisible = ref(false)
const editingAddrId = ref<number | null>(null)
const addrForm = ref({
  name: '',
  phone: '',
  province: '',
  city: '',
  district: '',
  detail: '',
  isDefault: false
})
const addrProvinces = PROVINCES
const addrAvailableCities = computed(() => {
  if (!addrForm.value.province) return []
  return Object.keys(CHINA_REGIONS[addrForm.value.province] || {})
})
const addrAvailableDistricts = computed(() => {
  if (!addrForm.value.province || !addrForm.value.city) return []
  return CHINA_REGIONS[addrForm.value.province]?.[addrForm.value.city] || []
})

function onAddrProvinceChange() {
  addrForm.value.city = ''
  addrForm.value.district = ''
}
function onAddrCityChange() {
  addrForm.value.district = ''
}

async function loadAddressList() {
  if (!userStore.userInfo?.id) return
  try {
    const res = await request.get('/address/list', {
      params: { userId: userStore.userInfo.id }
    })
    addressList.value = res.data || []
  } catch (e) {
    addressList.value = []
  }
}

function openAddAddress() {
  editingAddrId.value = null
  addrForm.value = {
    name: '',
    phone: '',
    province: '',
    city: '',
    district: '',
    detail: '',
    isDefault: addressList.value.length === 0
  }
  addressDialogVisible.value = true
}

function openEditAddress(addr: any) {
  editingAddrId.value = addr.id
  addrForm.value = {
    name: addr.name,
    phone: addr.phone,
    province: addr.province,
    city: addr.city,
    district: addr.district,
    detail: addr.detail,
    isDefault: addr.isDefault === 1 || addr.isDefault === true
  }
  addressDialogVisible.value = true
}

async function saveAddr() {
  if (!addrForm.value.name || !addrForm.value.phone) {
    ElMessage.warning('请填写姓名和手机号')
    return
  }
  if (!addrForm.value.province || !addrForm.value.city) {
    ElMessage.warning('请选择省/市')
    return
  }
  try {
    const payload = {
      ...addrForm.value,
      isDefault: addrForm.value.isDefault ? 1 : 0,
      userId: userStore.userInfo?.id
    }
    if (editingAddrId.value) {
      await request.put('/address/update', {
        ...payload,
        id: editingAddrId.value
      })
      ElMessage.success('地址修改成功')
    } else {
      await request.post('/address/create', payload)
      ElMessage.success('地址添加成功')
    }
    addressDialogVisible.value = false
    editingAddrId.value = null
    await loadAddressList()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '保存失败')
  }
}

async function handleSetDefault(id: number) {
  try {
    await request.put('/address/default', null, {
      params: {
        userId: userStore.userInfo?.id,
        id
      }
    })
    ElMessage.success('已设为默认地址')
    await loadAddressList()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || e?.message || '设置失败')
  }
}

async function handleDeleteAddress(id: number) {
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
    await loadAddressList()
  } catch (e: any) {
    if (e !== 'cancel') {
      ElMessage.error(e?.response?.data?.message || e?.message || '删除失败')
    }
  }
}

watch(activeTab, (val) => {
  if (val === 'orders') {
    nextTick(() => loadOrders())
  }
  if (val === 'groups') {
    nextTick(() => loadGroupOrders())
  }
  if (val === 'address') {
    loadAddressList()
  }
  if (val === 'messages') {
    loadMessages()
  }
  if (val === 'refunds') {
    nextTick(() => loadRefunds())
  }
  if (val === 'exchanges') {
    nextTick(() => loadExchanges())
  }
  if (val === 'settings') {
    fillProfileForm()
  }
})

function fillProfileForm() {
  profileForm.nickname = userStore.userInfo?.nickname || ''
  profileForm.email = userStore.userInfo?.email || ''
  profileForm.phone = userStore.userInfo?.phone || ''
}

watch(() => userStore.userInfo, (val) => {
  if (val?.id && activeTab.value === 'orders' && orderList.value.length === 0) {
    nextTick(() => loadOrders())
  }
  if (val?.id) {
    fillProfileForm()
  }
}, { deep: true })

onMounted(async () => {
  if (userStore.isLogin) {
    await userStore.getUserInfo()
    await loadMemberInfo()
    await loadPointsRecords()
    await loadMessages()
    if (activeTab.value === 'orders') {
      loadOrders()
    }
    if (activeTab.value === 'groups') {
      loadGroupOrders()
    }
    fillProfileForm()
  }
})
</script>

<style lang="scss" scoped>
.member-page {
  min-height: 100vh;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
}

.member-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 10px;
  padding: 30px;
  color: #fff;
  margin-bottom: 30px;

  .member-info {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-bottom: 20px;

    .member-detail {
      h2 {
        font-size: 24px;
        margin-bottom: 5px;
      }
      p {
        opacity: 0.9;
      }
    }
  }

  .member-stats {
    display: flex;
    gap: 40px;

    .stat-item {
      text-align: center;

      .stat-value {
        font-size: 28px;
        font-weight: bold;
        display: block;
      }

      .stat-label {
        font-size: 14px;
        opacity: 0.9;
      }
    }
  }
}

.member-content {
  background: #fff;
  border-radius: 10px;
  padding: 20px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.points-list {
  .positive {
    color: #67c23a;
    font-weight: bold;
  }

  .negative {
    color: #f56c6c;
    font-weight: bold;
  }
}

.message-list {
  .read {
    color: #999;
  }

  .unread {
    color: #667eea;
    font-weight: bold;
  }
}

.profile-form {
  max-width: 600px;
}

.order-status-tabs {
  display: flex;
  gap: 20px;
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
      color: #ff4400;
    }
    &.active {
      color: #ff4400;
      font-weight: 600;
      background: #fff5f0;
    }
  }
}

.cancel-dialog,
.refund-dialog {
  .refund-type-tip {
    margin-top: 8px;
    font-size: 12px;
    color: #e6a23c;
    display: flex;
    align-items: center;
  }

  .dialog-tip {
    margin: 0 0 16px 0;
    font-size: 14px;
    color: #666;
  }

  .refund-amount {
    color: #f56c6c;
    font-weight: bold;
    font-size: 18px;
  }

  .reason-options {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 16px;
  }

  .reason-item {
    padding: 10px 16px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
    font-size: 13px;
    color: #606266;

    &:hover {
      border-color: #ff4400;
      color: #ff4400;
    }

    &.selected {
      border-color: #ff4400;
      background: #fff0eb;
      color: #ff4400;
      font-weight: 500;
    }
  }

  .custom-reason {
    margin-top: 16px;
  }
}

.orders-list {
  .order-toolbar {
    margin-bottom: 12px;
    display: flex;
    align-items: center;
  }
  .order-product-img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
  }
}

.groups-list {
  .group-product-img-wrap {
    width: 60px;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #f5f5f5;
    border-radius: 4px;
    overflow: hidden;
  }
  .group-product-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .product-link {
    cursor: pointer;
    transition: color 0.2s;
    &:hover {
      color: #ff4400;
    }
  }
  .price {
    color: #ff4400;
    font-weight: 500;
    &.total {
      font-size: 16px;
      font-weight: bold;
    }
  }
  .order-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    .el-button {
      margin: 0;
    }
  }
  .order-status-col {
    .status-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
    }
  }
  .wait-ship-tag {
    background: #fff7e6;
    border-color: #ffb300;
    color: #fa8c16;
    font-weight: 500;
  }
}

.order-detail {
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

    &.total-row {
      font-size: 15px;
      font-weight: bold;
      padding-top: 8px;
      margin-top: 4px;
      border-top: 1px dashed #eee;
    }
  }

  .mono {
    font-family: monospace;
    color: #666;
  }

  .discount {
    color: #f56c6c;
  }

  .total-price {
    color: #ff4400;
    font-size: 18px;
  }

  .detail-product {
    display: flex;
    gap: 12px;
    padding: 8px 0;
    border-bottom: 1px dashed #f0f0f0;

    &:last-child {
      border-bottom: none;
    }
  }

  .detail-img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
  }

  .detail-product-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .detail-product-name {
    font-size: 13px;
    color: #333;
  }

  .detail-product-spec {
    font-size: 12px;
    color: #999;
    margin-top: 4px;
  }

  .detail-product-price {
    font-size: 13px;
    color: #ff4400;
  }

  .coupon-card {
    display: flex;
    align-items: stretch;
    background: linear-gradient(135deg, #fff0f0, #fff7e6);
    border: 1px dashed #ff6b6b;
    border-radius: 8px;
    overflow: hidden;

    .coupon-left {
      width: 120px;
      padding: 12px;
      text-align: center;
      border-right: 1px dashed #ffb3b3;
    }

    .coupon-amount {
      font-size: 28px;
      font-weight: bold;
      color: #ff4400;
      line-height: 1.2;
    }

    .coupon-condition {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }

    .coupon-right {
      flex: 1;
      padding: 12px 16px;
      display: flex;
      align-items: center;
    }

    .coupon-name {
      font-size: 14px;
      color: #333;
      font-weight: 500;
    }
  }
}

.address-manager {
  .addr-toolbar {
    margin-bottom: 20px;
    display: flex;
    align-items: center;
  }

  .addr-empty {
    padding: 40px 0;
  }

  .addr-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 16px;
  }

  .addr-card {
    border: 2px solid #e4e7ed;
    border-radius: 8px;
    padding: 16px;
    transition: all 0.2s;
    background: #fff;

    &:hover {
      border-color: #ff4400;
      box-shadow: 0 2px 12px rgba(255, 68, 0, 0.15);
    }

    &.is-default {
      border-color: #ff4400;
      background: linear-gradient(135deg, #fff5f0 0%, #fff 100%);
    }

    .addr-card-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 8px;

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

    .addr-card-detail {
      font-size: 14px;
      color: #666;
      line-height: 1.6;
      margin-bottom: 12px;
      min-height: 44px;
    }

    .addr-card-actions {
      display: flex;
      gap: 12px;
      padding-top: 12px;
      border-top: 1px dashed #eee;
    }
  }
}

.refund-status-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 16px;
  border-bottom: 1px solid #eee;
}

.refunds-list {
  .action-buttons {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .refund-amount {
    color: #f56c6c;
    font-weight: bold;
  }
}

.refund-detail {
  .refund-amount {
    color: #f56c6c;
    font-weight: bold;
    font-size: 18px;
  }

  .return-logistics {
    margin-top: 20px;

    h4 {
      margin: 0 0 12px 0;
      font-size: 15px;
      color: #333;
    }
  }

  .refund-progress {
    margin-top: 20px;

    h4 {
      margin: 0 0 16px 0;
      font-size: 15px;
      color: #333;
    }
  }
}

.return-ship-form {
  padding: 10px 0;
}

.exchange-status-tabs {
  display: flex;
  gap: 0;
  margin-bottom: 16px;
  border-bottom: 1px solid #eee;
}

.exchanges-list {
  .action-buttons {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .exchange-product-col {
    display: flex;
    align-items: center;
    gap: 8px;

    .exchange-product-img {
      width: 40px;
      height: 40px;
      object-fit: cover;
      border-radius: 4px;
    }

    span {
      font-size: 13px;
      color: #333;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
}

.exchange-dialog {
  .exchange-products-section {
    margin-bottom: 20px;
    padding: 16px;
    background: #f9f9f9;
    border-radius: 8px;

    .section-title {
      font-size: 14px;
      font-weight: 600;
      color: #333;
      margin-bottom: 12px;
    }
  }

  .exchange-new-product-section {
    margin-bottom: 20px;
    padding: 16px;
    background: #fff7e6;
    border-radius: 8px;
    border: 1px solid #ffd591;

    .section-title {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 14px;
      font-weight: 600;
      color: #333;
      margin-bottom: 12px;
    }

    .new-product-input {
      .el-form-item {
        margin-bottom: 12px;
      }
    }
  }

  .exchange-product-list {
    max-height: 180px;
    overflow-y: auto;
  }

  .exchange-product-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px;
    background: #fff;
    border-radius: 6px;
    margin-bottom: 8px;

    &:last-child {
      margin-bottom: 0;
    }
  }

  .exchange-product-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
  }

  .exchange-product-info {
    flex: 1;
    min-width: 0;

    .exchange-product-name {
      font-size: 13px;
      color: #333;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .exchange-product-spec {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }

    .exchange-product-price {
      font-size: 12px;
      color: #ff4400;
      margin-top: 4px;
    }
  }

  .dialog-tip {
    margin: 0 0 16px 0;
    font-size: 14px;
    color: #666;
  }

  .reason-options {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    margin-bottom: 16px;
  }

  .reason-item {
    padding: 10px 16px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s;
    text-align: center;
    font-size: 13px;
    color: #606266;

    &:hover {
      border-color: #ff4400;
      color: #ff4400;
    }

    &.selected {
      border-color: #ff4400;
      background: #fff0eb;
      color: #ff4400;
      font-weight: 500;
    }
  }

  .custom-reason {
    margin-top: 16px;
  }
}

.exchange-detail {
  .exchange-products-compare {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 20px;

    .product-section {
      h4 {
        margin: 0 0 12px 0;
        font-size: 14px;
        color: #333;
      }

      .product-card {
        display: flex;
        gap: 12px;
        padding: 12px;
        background: #f5f5f5;
        border-radius: 8px;

        .product-img {
          width: 60px;
          height: 60px;
          object-fit: cover;
          border-radius: 4px;
        }

        .product-info {
          flex: 1;

          .product-name {
            font-size: 13px;
            color: #333;
            margin-bottom: 6px;
          }

          .product-spec {
            font-size: 12px;
            color: #999;
            margin-bottom: 6px;
          }

          .product-price {
            font-size: 14px;
            color: #ff4400;
            font-weight: bold;
          }
        }
      }

      &.original .product-card {
        background: #fff0f0;
        border: 1px solid #ffccc7;
      }

      &.new .product-card {
        background: #f0f5ff;
        border: 1px solid #adc6ff;
      }
    }
  }

  .return-logistics,
  .exchange-logistics {
    margin-top: 20px;

    h4 {
      margin: 0 0 12px 0;
      font-size: 15px;
      color: #333;
    }
  }

  .exchange-progress {
    margin-top: 20px;

    h4 {
      margin: 0 0 16px 0;
      font-size: 15px;
      color: #333;
    }
  }
}

.refund-products-section {
  margin-bottom: 20px;
  padding: 16px;
  background: #f9f9f9;
  border-radius: 8px;

  .section-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    font-size: 14px;
    font-weight: 600;
    color: #333;

    .section-tip {
      font-size: 12px;
      font-weight: normal;
      color: #999;
    }
  }

  .refund-product-list {
    max-height: 240px;
    overflow-y: auto;
  }

  .refund-product-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px;
    background: #fff;
    border-radius: 6px;
    margin-bottom: 8px;

    &.disabled {
      opacity: 0.8;
    }

    &:last-child {
      margin-bottom: 0;
    }
  }

  .refund-product-img {
    width: 50px;
    height: 50px;
    object-fit: cover;
    border-radius: 4px;
  }

  .refund-product-info {
    flex: 1;
    min-width: 0;

    .refund-product-name {
      font-size: 13px;
      color: #333;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .refund-product-spec {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }

    .refund-product-price {
      font-size: 12px;
      color: #ff4400;
      margin-top: 4px;
    }
  }

  .refund-product-subtotal {
    font-size: 14px;
    font-weight: bold;
    color: #ff4400;
  }

  .refund-amount-summary {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    margin-top: 12px;
    padding-top: 12px;
    border-top: 1px dashed #ddd;
    font-size: 14px;
    color: #666;

    .refund-amount-total {
      font-size: 18px;
      font-weight: bold;
      color: #f56c6c;
      margin-left: 8px;
    }
  }
}

.upload-voucher-section {
  margin-top: 20px;

  .section-title {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    margin-bottom: 10px;
  }

  .upload-tip {
    font-size: 12px;
    color: #999;
    margin-top: 8px;
  }
}

.logistics-timeline {
  margin-top: 10px;

  .track-status {
    font-size: 14px;
    font-weight: 500;
    color: #333;
  }

  .track-desc {
    font-size: 12px;
    color: #666;
    margin-top: 4px;
  }
}

.message-page {
  .message-type-tabs {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;

    .message-type-tab {
      position: relative;
      padding: 6px 4px;
      font-size: 14px;
      color: #666;
      cursor: pointer;
      transition: all 0.2s;

      &:hover {
        color: #ff4400;
      }

      &.active {
        color: #ff4400;
        font-weight: 600;

        &::after {
          content: '';
          position: absolute;
          bottom: -13px;
          left: 0;
          right: 0;
          height: 2px;
          background: #ff4400;
        }
      }

      .tab-badge {
        margin-left: 6px;
      }
    }
  }

  .message-status-dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #dcdfe6;

    &.unread {
      background: #ff4400;
    }
  }

  .message-title-unread {
    font-weight: 600;
    color: #333;
  }

  .message-list {
    cursor: pointer;
  }
}

.message-detail {
  .message-detail-title {
    margin: 0 0 12px 0;
    font-size: 18px;
    color: #333;
  }

  .message-detail-meta {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;

    .message-detail-time {
      font-size: 13px;
      color: #999;
    }
  }

  .message-detail-content {
    font-size: 14px;
    color: #666;
    line-height: 1.8;
  }
}

.review-dialog {
  .review-order-info {
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #f0f0f0;
    font-size: 14px;

    .label {
      color: #999;
      margin-right: 8px;
    }

    .mono {
      font-family: monospace;
      color: #666;
    }
  }

  .review-products-list {
    max-height: 400px;
    overflow-y: auto;
  }

  .review-product-item {
    padding: 16px 0;
    border-bottom: 1px dashed #eee;

    &:last-child {
      border-bottom: none;
    }
  }

  .review-product-header {
    display: flex;
    gap: 12px;
    margin-bottom: 12px;
  }

  .review-product-img {
    width: 60px;
    height: 60px;
    object-fit: cover;
    border-radius: 4px;
  }

  .review-product-info {
    flex: 1;

    .review-product-name {
      font-size: 14px;
      color: #333;
    }

    .review-product-spec {
      font-size: 12px;
      color: #999;
      margin-top: 4px;
    }
  }

  .review-rating,
  .review-content,
  .review-images {
    display: flex;
    gap: 10px;
    margin-top: 12px;

    .rating-label {
      width: 80px;
      flex-shrink: 0;
      font-size: 13px;
      color: #666;
      line-height: 1.8;
    }

    .el-rate {
      flex: 1;
    }

    .el-input,
    .el-upload,
    .review-image-list {
      flex: 1;
    }
  }

  .review-image-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    .review-image {
      width: 60px;
      height: 60px;
      border-radius: 4px;
      cursor: pointer;
    }

    .no-images {
      font-size: 13px;
      color: #999;
    }
  }

  .review-anonymous {
    margin-top: 20px;
    text-align: right;
  }

  .review-time {
    margin-top: 16px;
    padding-top: 12px;
    border-top: 1px solid #f0f0f0;
    font-size: 13px;

    .label {
      color: #999;
      margin-right: 8px;
    }
  }
}

.service-dialog {
  :deep(.el-dialog__body) {
    padding: 0;
  }

  :deep(.el-dialog__footer) {
    display: none;
  }

  .service-header {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 16px 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;

    .service-info {
      flex: 1;

      .service-name {
        font-size: 16px;
        font-weight: 600;
      }

      .service-status {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 12px;
        opacity: 0.9;
        margin-top: 4px;

        .status-dot {
          width: 8px;
          height: 8px;
          border-radius: 50%;
          background: #67c23a;
          animation: pulse 2s infinite;
        }
      }
    }
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
  }

  .service-messages {
    height: 400px;
    overflow-y: auto;
    padding: 16px;
    background: #f5f5f5;
  }

  .service-msg {
    display: flex;
    gap: 10px;
    margin-bottom: 16px;

    &.user {
      flex-direction: row-reverse;

      .msg-content {
        align-items: flex-end;
      }

      .msg-text {
        background: #667eea;
        color: #fff;
        border-radius: 12px 12px 0 12px;
      }
    }

    .service-avatar,
    .user-avatar {
      flex-shrink: 0;
    }

    .msg-content {
      max-width: 70%;
      display: flex;
      flex-direction: column;
      gap: 4px;

      .msg-text {
        padding: 10px 14px;
        background: #fff;
        color: #333;
        border-radius: 12px 12px 12px 0;
        font-size: 14px;
        line-height: 1.5;
        word-break: break-all;

        &.typing {
          display: flex;
          gap: 4px;
          padding: 14px 16px;

          span {
            width: 6px;
            height: 6px;
            background: #999;
            border-radius: 50%;
            animation: typing 1.4s infinite;

            &:nth-child(2) {
              animation-delay: 0.2s;
            }

            &:nth-child(3) {
              animation-delay: 0.4s;
            }
          }
        }
      }

      .msg-image {
        max-width: 200px;

        :deep(.el-image) {
          border-radius: 8px;
          overflow: hidden;
        }
      }

      .msg-time {
        font-size: 11px;
        color: #999;
      }
    }
  }

  @keyframes typing {
    0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
    30% { transform: translateY(-4px); opacity: 1; }
  }

  .service-input-area {
    border-top: 1px solid #e4e7ed;
    background: #fff;

    .service-tools {
      display: flex;
      padding: 8px 16px;
      border-bottom: 1px solid #f0f0f0;

      .el-upload {
        margin: 0;
      }
    }

    .service-input-wrapper {
      display: flex;
      gap: 10px;
      padding: 12px 16px;
      align-items: flex-end;

      .el-input {
        flex: 1;
      }
    }
  }
}
</style>