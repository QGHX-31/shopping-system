<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>角色管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索角色名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增角色</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="roleList" v-loading="loading" border>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="角色名称" prop="name" width="160" />
        <el-table-column label="角色编码" prop="code" width="160" />
        <el-table-column label="角色描述" prop="description" min-width="200" />
        <el-table-column label="管理员数量" prop="adminCount" width="110" align="center" />
        <el-table-column label="权限数量" prop="permissionCount" width="100" align="center" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
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
            <el-button size="small" type="warning" link @click="assignPermission(row)">分配权限</el-button>
            <el-button size="small" type="danger" link :disabled="row.isSuper">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && roleList.length === 0" description="暂无角色" />
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

    <el-dialog v-model="permDialogVisible" title="分配权限" width="600px">
      <el-tree
        :data="permissionTree"
        :props="{ label: 'name', children: 'children' }"
        show-checkbox
        node-key="id"
        :default-checked-keys="checkedPermIds"
        ref="permTreeRef"
      />
      <template #footer>
        <el-button @click="permDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="confirmAssignPerm">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const searchKeyword = ref('')
const roleList = ref<any[]>([])
const loading = ref(false)
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)

const permDialogVisible = ref(false)
const checkedPermIds = ref<number[]>([])
const permissionTree = ref<any[]>([])

function formatTime(s: string) {
  return s ? s.replace('T', ' ').slice(0, 16) : '—'
}

async function loadRoles() {
  loading.value = true
  try {
    roleList.value = [
      { id: 1, name: '超级管理员', code: 'super_admin', description: '拥有系统所有权限', adminCount: 1, permissionCount: 128, status: 1, isSuper: true, createdAt: '2026-01-01 00:00:00' },
      { id: 2, name: '运营管理员', code: 'operate_admin', description: '负责活动配置、订单管理等运营工作', adminCount: 3, permissionCount: 68, status: 1, isSuper: false, createdAt: '2026-02-01 10:00:00' },
      { id: 3, name: '商品管理员', code: 'goods_admin', description: '负责商品上架、分类管理', adminCount: 5, permissionCount: 35, status: 1, isSuper: false, createdAt: '2026-03-01 09:00:00' },
      { id: 4, name: '财务管理员', code: 'finance_admin', description: '负责退款审核、财务报表', adminCount: 2, permissionCount: 22, status: 1, isSuper: false, createdAt: '2026-03-15 14:00:00' },
      { id: 5, name: '客服管理员', code: 'service_admin', description: '负责处理用户投诉、售后问题', adminCount: 4, permissionCount: 18, status: 0, isSuper: false, createdAt: '2026-04-01 11:00:00' }
    ]
    total.value = roleList.value.length
  } finally {
    loading.value = false
  }
}

async function loadPermissionTree() {
  permissionTree.value = [
    {
      id: 1, name: '订单管理', children: [
        { id: 11, name: '订单查看' },
        { id: 12, name: '订单发货' },
        { id: 13, name: '订单取消' }
      ]
    },
    {
      id: 2, name: '商品管理', children: [
        { id: 21, name: '商品查看' },
        { id: 22, name: '商品编辑' },
        { id: 23, name: '商品上下架' }
      ]
    },
    {
      id: 3, name: '用户管理', children: [
        { id: 31, name: '用户查看' },
        { id: 32, name: '用户管理' }
      ]
    },
    {
      id: 4, name: '营销管理', children: [
        { id: 41, name: '优惠券管理' },
        { id: 42, name: '活动配置' }
      ]
    },
    {
      id: 5, name: '系统管理', children: [
        { id: 51, name: '管理员管理' },
        { id: 52, name: '角色管理' },
        { id: 53, name: '权限管理' }
      ]
    }
  ]
}

function handleSearch() {
  page.value = 1
  loadRoles()
}

function handlePageChange(val: number) {
  page.value = val
}

function handleAdd() {
  ElMessage.info('新增角色功能开发中')
}

function assignPermission(row: any) {
  checkedPermIds.value = [11, 12, 21, 22, 23, 31, 41]
  permDialogVisible.value = true
}

function confirmAssignPerm() {
  ElMessage.success('权限分配成功')
  permDialogVisible.value = false
}

onMounted(() => {
  loadRoles()
  loadPermissionTree()
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
