<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>管理员管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索用户名/姓名" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增管理员</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="adminList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="用户名" prop="username" width="120" />
        <el-table-column label="姓名" prop="realName" width="120" />
        <el-table-column label="手机号" prop="phone" width="130" />
        <el-table-column label="邮箱" prop="email" width="180" show-overflow-tooltip />
        <el-table-column label="角色" min-width="180">
          <template #default="{ row }">
            <el-tag v-for="(role, idx) in row.roles" :key="idx" size="small" style="margin-right: 4px">
              {{ role.name }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="超级管理员" width="110" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.isSuper === 1" type="danger" size="small">是</el-tag>
            <span v-else style="color: #999">否</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
              {{ row.status === 1 ? '正常' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="创建时间" width="160">
          <template #default="{ row }">
            <span>{{ formatTime(row.createdAt) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>编辑</el-button>
            <el-button size="small" type="warning" link @click="assignRole(row)">分配角色</el-button>
            <el-button size="small" :type="row.status === 1 ? 'danger' : 'success'" link @click="toggleStatus(row)">
              {{ row.status === 1 ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && adminList.length === 0" description="暂无管理员" />
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

    <el-dialog v-model="roleDialogVisible" title="分配角色" width="400px">
      <el-checkbox-group v-model="selectedRoles">
        <el-checkbox v-for="role in allRoles" :key="role.id" :value="role.id" :label="role.id">
          {{ role.name }}
        </el-checkbox>
      </el-checkbox-group>
      <template #footer>
        <el-button @click="roleDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmAssignRole">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const searchKeyword = ref('')
const adminList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const roleDialogVisible = ref(false)
const selectedRoles = ref<number[]>([])
const currentAdmin = ref<any>(null)
const allRoles = ref<any[]>([])

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadAdmins() {
  loading.value = true
  try {
    adminList.value = [
      { id: 1, username: 'admin', realName: '超级管理员', phone: '13800138000', email: 'admin@example.com', roles: [{ id: 1, name: '超级管理员' }], isSuper: 1, status: 1, createdAt: '2026-01-01 00:00:00' },
      { id: 2, username: 'oper01', realName: '运营小张', phone: '13800138001', email: 'oper01@example.com', roles: [{ id: 2, name: '运营管理员' }], isSuper: 0, status: 1, createdAt: '2026-03-15 10:30:00' },
      { id: 3, username: 'goods01', realName: '商品管理员', phone: '13800138002', email: 'goods01@example.com', roles: [{ id: 3, name: '商品管理员' }], isSuper: 0, status: 1, createdAt: '2026-04-20 14:00:00' },
      { id: 4, username: 'finance01', realName: '财务小王', phone: '13800138003', email: 'finance@example.com', roles: [{ id: 4, name: '财务管理员' }], isSuper: 0, status: 0, createdAt: '2026-05-10 09:00:00' }
    ]
    total.value = adminList.value.length
  } finally {
    loading.value = false
  }
}

async function loadAllRoles() {
  allRoles.value = [
    { id: 1, name: '超级管理员' },
    { id: 2, name: '运营管理员' },
    { id: 3, name: '商品管理员' },
    { id: 4, name: '财务管理员' },
    { id: 5, name: '客服管理员' }
  ]
}

function handleSearch() {
  page.value = 1
  loadAdmins()
}

function handlePageChange(val: number) {
  page.value = val
}

function handleAdd() {
  ElMessage.info('新增管理员功能开发中')
}

function assignRole(row: any) {
  currentAdmin.value = row
  selectedRoles.value = row.roles?.map((r: any) => r.id) || []
  roleDialogVisible.value = true
}

function confirmAssignRole() {
  ElMessage.success('角色分配成功')
  roleDialogVisible.value = false
}

async function toggleStatus(row: any) {
  const action = row.status === 1 ? '禁用' : '启用'
  try {
    await ElMessageBox.confirm(`确定要${action}该管理员吗？`, '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    row.status = row.status === 1 ? 0 : 1
    ElMessage.success(`已${action}`)
  } catch { /* canceled */ }
}

onMounted(() => {
  loadAdmins()
  loadAllRoles()
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
