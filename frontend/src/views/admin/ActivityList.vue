<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>活动配置</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索活动名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-select v-model="typeFilter" placeholder="活动类型" clearable style="width: 120px">
          <el-option label="秒杀活动" value="seckill" />
          <el-option label="拼团活动" value="group" />
          <el-option label="满减活动" value="discount" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增活动</el-button>
      </div>
    </div>

    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <el-tab-pane label="秒杀活动" name="seckill">
        <el-table :data="seckillList" v-loading="loading" border>
          <el-table-column label="ID" prop="id" width="80" />
          <el-table-column label="活动名称" prop="name" min-width="200" />
          <el-table-column label="活动时间" width="280">
            <template #default="{ row }">
              <span>{{ formatDate(row.startTime) }} ~ {{ formatDate(row.endTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="商品数" width="90" align="center">
            <template #default="{ row }">
              <span>-</span>
            </template>
          </el-table-column>
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getActivityStatus(row).type" size="small">
                {{ getActivityStatus(row).text }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-button size="small" type="primary" link>查看</el-button>
              <el-button size="small" type="warning" link>编辑</el-button>
              <el-button size="small" type="danger" link>删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="拼团活动" name="group">
        <el-table :data="groupList" v-loading="loading" border>
          <el-table-column label="ID" prop="id" width="80" />
          <el-table-column label="活动名称" prop="name" min-width="200" />
          <el-table-column label="拼团人数" prop="requiredNum" width="100" align="center" />
          <el-table-column label="活动时间" width="280">
            <template #default="{ row }">
              <span>{{ formatDate(row.startTime) }} ~ {{ formatDate(row.endTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="库存" prop="availableStock" width="90" align="center" />
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getActivityStatus(row).type" size="small">
                {{ getActivityStatus(row).text }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-button size="small" type="primary" link>查看</el-button>
              <el-button size="small" type="warning" link>编辑</el-button>
              <el-button size="small" type="danger" link>删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>

      <el-tab-pane label="平台活动" name="platform">
        <el-table :data="activityList" v-loading="loading" border>
          <el-table-column label="ID" prop="id" width="80" />
          <el-table-column label="活动名称" prop="name" min-width="200" />
          <el-table-column label="活动类型" width="120">
            <template #default="{ row }">
              <el-tag size="small">{{ row.typeName }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="活动时间" width="280">
            <template #default="{ row }">
              <span>{{ formatDate(row.startTime) }} ~ {{ formatDate(row.endTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column label="商家ID" prop="merchantId" width="100" align="center" />
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getActivityStatus(row).type" size="small">
                {{ getActivityStatus(row).text }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button size="small" type="primary" link>查看详情</el-button>
              <el-button size="small" type="warning" link>编辑</el-button>
              <el-button size="small" type="danger" link>删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-empty v-if="!loading && currentList.length === 0" description="暂无活动" />

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
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const searchKeyword = ref('')
const typeFilter = ref('')
const activeTab = ref('seckill')
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const seckillList = ref<any[]>([])
const groupList = ref<any[]>([])
const activityList = ref<any[]>([])

const currentList = computed(() => {
  if (activeTab.value === 'seckill') return seckillList.value
  if (activeTab.value === 'group') return groupList.value
  return activityList.value
})

function formatDate(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

function getActivityStatus(row: any) {
  const now = new Date().getTime()
  const start = row.startTime ? new Date(row.startTime.replace(' ', 'T')).getTime() : 0
  const end = row.endTime ? new Date(row.endTime.replace(' ', 'T')).getTime() : Infinity
  if (row.status === 0) return { text: '未启用', type: 'info' }
  if (now < start) return { text: '未开始', type: 'warning' }
  if (now > end) return { text: '已结束', type: 'info' }
  return { text: '进行中', type: 'success' }
}

async function loadActivities() {
  loading.value = true
  try {
    const [seckillRes, groupRes] = await Promise.all([
      request.get('/seckill/activity/list').catch(() => ({ data: { list: [] } })),
      request.get('/group/activity/list').catch(() => ({ data: { list: [] } }))
    ])

    seckillList.value = (seckillRes.data?.list || []) as any[]
    groupList.value = (groupRes.data?.list || []) as any[]

    // 平台活动tab暂时合并显示（无单独后端接口）
    activityList.value = [
      ...seckillList.value.map((item: any) => ({ ...item, typeName: '秒杀活动' })),
      ...groupList.value.map((item: any) => ({ ...item, typeName: '拼团活动' }))
    ]

    total.value = currentList.value.length
  } catch (e) {
    console.error('加载活动失败', e)
    seckillList.value = []
    groupList.value = []
    activityList.value = []
  } finally {
    loading.value = false
  }
}

function handleTabChange() {
  total.value = currentList.value.length
  page.value = 1
}

function handleSearch() {
  page.value = 1
}

function handlePageChange(val: number) {
  page.value = val
}

function handleAdd() {
  ElMessage.info('新增活动功能开发中')
}

onMounted(() => {
  loadActivities()
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

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}
</style>
