<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>用户管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索用户名/手机号" clearable style="width: 220px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="userList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="头像" width="70">
          <template #default="{ row }">
            <el-avatar :src="row.avatar || defaultAvatar" :size="36" />
          </template>
        </el-table-column>
        <el-table-column label="用户名" prop="username" width="120" />
        <el-table-column label="昵称" prop="nickname" width="120" />
        <el-table-column label="手机号" prop="phone" width="130" />
        <el-table-column label="邮箱" prop="email" width="180" show-overflow-tooltip />
        <el-table-column label="积分" prop="points" width="90" align="center" />
        <el-table-column label="等级" width="100" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="getLevelType(row.level)">
              {{ getLevelText(row.level) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="注册时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>详情</el-button>
            <el-button size="small" type="info" link @click="resetPassword(row)">重置密码</el-button>
            <el-button size="small" :type="row.status === 1 ? 'warning' : 'success'" link @click="toggleStatus(row)">
              {{ row.status === 1 ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && userList.length === 0" description="暂无用户" />
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import request from '@/utils/request'

const router = useRouter()
const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

const searchKeyword = ref('')
const userList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

function getLevelText(level: number) {
  const levels: Record<number, string> = {
    1: '普通会员', 2: '铜牌会员', 3: '银牌会员', 4: '金牌会员', 5: '钻石会员'
  }
  return levels[level] || '普通会员'
}

function getLevelType(level: number) {
  const types: Record<number, string> = {
    1: 'info', 2: '', 3: 'success', 4: 'warning', 5: 'danger'
  }
  return types[level] || 'info'
}

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadUsers() {
  loading.value = true
  try {
    const res = await request.get('/user/list', {
      params: {
        keyword: searchKeyword.value || undefined,
        page: page.value,
        size: pageSize.value
      }
    })
    const list = (res.data?.list || res.data?.records || []) as any[]
    userList.value = list
    total.value = res.data?.total || list.length
  } catch (e) {
    console.error('加载用户失败', e)
    userList.value = []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  page.value = 1
  loadUsers()
}

function handlePageChange(val: number) {
  page.value = val
  loadUsers()
}

async function toggleStatus(row: any) {
  const action = row.status === 1 ? '禁用' : '启用'
  const newStatus = row.status === 1 ? 0 : 1
  try {
    await ElMessageBox.confirm(`确定要${action}该用户吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.put(`/user/${row.id}/status`, null, {
      params: { status: newStatus }
    })
    ElMessage.success(`已${action}`)
    loadUsers()
  } catch { /* canceled */ }
}

async function resetPassword(row: any) {
  try {
    await ElMessageBox.confirm(`确定要重置 ${row.username} 的密码为 123456 吗？`, '重置密码', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await request.put(`/user/${row.id}/reset-password`)
    ElMessage.success('密码已重置为 123456')
  } catch { /* canceled */ }
}

onMounted(() => {
  loadUsers()
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
