<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>权限管理</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索权限名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增权限</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="permissionList" v-loading="loading" border row-key="id">
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-table :data="row.children || []" border size="small" style="margin-left: 40px">
              <el-table-column label="ID" prop="id" width="80" />
              <el-table-column label="权限名称" prop="name" min-width="180" />
              <el-table-column label="权限编码" prop="code" width="200" />
              <el-table-column label="类型" width="100">
                <template #default="{ row: child }">
                  <el-tag size="small" :type="child.type === 1 ? 'primary' : 'success'">
                    {{ child.type === 1 ? '菜单' : '按钮' }}
                  </el-tag>
                </template>
              </el-table-column>
              <el-table-column label="排序" prop="sort" width="80" align="center" />
              <el-table-column label="操作" width="150">
                <template #default="{ row: child }">
                  <el-button size="small" type="primary" link>编辑</el-button>
                  <el-button size="small" type="danger" link>删除</el-button>
                </template>
              </el-table-column>
            </el-table>
          </template>
        </el-table-column>
        <el-table-column label="ID" prop="id" width="80" />
        <el-table-column label="权限名称" prop="name" min-width="200" />
        <el-table-column label="权限编码" prop="code" width="220" />
        <el-table-column label="类型" width="100">
          <template #default="{ row }">
            <el-tag size="small" type="warning">目录</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="排序" prop="sort" width="80" align="center" />
        <el-table-column label="子权限数量" width="110" align="center">
          <template #default="{ row }">
            {{ row.children?.length || 0 }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>编辑</el-button>
            <el-button size="small" type="success" link>添加子权限</el-button>
            <el-button size="small" type="danger" link>删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && permissionList.length === 0" description="暂无权限" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const searchKeyword = ref('')
const permissionList = ref<any[]>([])
const loading = ref(false)

async function loadPermissions() {
  loading.value = true
  try {
    permissionList.value = [
      {
        id: 1, name: '订单管理', code: 'order', sort: 1, type: 0, children: [
          { id: 11, name: '订单列表', code: 'order:list', sort: 1, type: 1 },
          { id: 12, name: '订单详情', code: 'order:detail', sort: 2, type: 1 },
          { id: 13, name: '订单发货', code: 'order:ship', sort: 3, type: 2 },
          { id: 14, name: '订单取消', code: 'order:cancel', sort: 4, type: 2 }
        ]
      },
      {
        id: 2, name: '商品管理', code: 'product', sort: 2, type: 0, children: [
          { id: 21, name: '商品列表', code: 'product:list', sort: 1, type: 1 },
          { id: 22, name: '商品新增', code: 'product:add', sort: 2, type: 2 },
          { id: 23, name: '商品编辑', code: 'product:edit', sort: 3, type: 2 },
          { id: 24, name: '商品上下架', code: 'product:status', sort: 4, type: 2 }
        ]
      },
      {
        id: 3, name: '用户管理', code: 'user', sort: 3, type: 0, children: [
          { id: 31, name: '用户列表', code: 'user:list', sort: 1, type: 1 },
          { id: 32, name: '用户禁用', code: 'user:disable', sort: 2, type: 2 }
        ]
      },
      {
        id: 4, name: '营销管理', code: 'marketing', sort: 4, type: 0, children: [
          { id: 41, name: '优惠券管理', code: 'coupon:list', sort: 1, type: 1 },
          { id: 42, name: '活动配置', code: 'activity:list', sort: 2, type: 1 }
        ]
      },
      {
        id: 5, name: '系统管理', code: 'system', sort: 5, type: 0, children: [
          { id: 51, name: '管理员管理', code: 'admin:list', sort: 1, type: 1 },
          { id: 52, name: '角色管理', code: 'role:list', sort: 2, type: 1 },
          { id: 53, name: '权限管理', code: 'permission:list', sort: 3, type: 1 }
        ]
      }
    ]
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  loadPermissions()
}

function handleAdd() {
  ElMessage.info('新增权限功能开发中')
}

onMounted(() => {
  loadPermissions()
})
</script>

<style lang="scss" scoped">
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
</style>
