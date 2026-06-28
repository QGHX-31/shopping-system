<template>
  <div class="admin-page">
    <div class="page-header">
      <h2>商品分类</h2>
      <div class="search-bar">
        <el-input v-model="searchKeyword" placeholder="搜索分类名称" clearable style="width: 200px" @keyup.enter="handleSearch" />
        <el-button type="primary" @click="handleSearch">搜索</el-button>
        <el-button type="success" @click="handleAdd">新增分类</el-button>
      </div>
    </div>

    <div class="table-card">
      <el-table :data="categoryList" v-loading="loading" border row-key="id">
        <el-table-column type="expand">
          <template #default="{ row }">
            <el-table :data="row.children || []" border size="small" style="margin-left: 40px">
              <el-table-column label="ID" prop="id" width="80" />
              <el-table-column label="子分类名称" prop="name" min-width="200" />
              <el-table-column label="排序" prop="sort" width="80" align="center" />
              <el-table-column label="状态" width="90">
                <template #default="{ row: child }">
                  <el-tag :type="child.status === 1 ? 'success' : 'info'" size="small">
                    {{ child.status === 1 ? '启用' : '禁用' }}
                  </el-tag>
                </template>
              </el-table-column>
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
        <el-table-column label="分类名称" prop="name" min-width="200" />
        <el-table-column label="图标" width="80">
          <template #default="{ row }">
            <span style="font-size: 20px">{{ row.icon || '📂' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="排序" prop="sort" width="80" align="center" />
        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
              {{ row.status === 1 ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button size="small" type="primary" link>编辑</el-button>
            <el-button size="small" type="success" link>添加子分类</el-button>
            <el-button size="small" type="danger" link>删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!loading && categoryList.length === 0" description="暂无分类" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const searchKeyword = ref('')
const categoryList = ref<any[]>([])
const loading = ref(false)

async function loadCategories() {
  loading.value = true
  try {
    categoryList.value = [
      { id: 1, name: '手机数码', icon: '📱', sort: 1, status: 1, children: [
        { id: 101, name: '手机', sort: 1, status: 1 },
        { id: 102, name: '平板电脑', sort: 2, status: 1 },
        { id: 103, name: '智能手表', sort: 3, status: 1 },
        { id: 104, name: '耳机音响', sort: 4, status: 1 }
      ]},
      { id: 2, name: '家用电器', icon: '🏠', sort: 2, status: 1, children: [
        { id: 201, name: '冰箱', sort: 1, status: 1 },
        { id: 202, name: '洗衣机', sort: 2, status: 1 },
        { id: 203, name: '空调', sort: 3, status: 1 }
      ]},
      { id: 3, name: '服装鞋包', icon: '👔', sort: 3, status: 1, children: [
        { id: 301, name: '男装', sort: 1, status: 1 },
        { id: 302, name: '女装', sort: 2, status: 1 },
        { id: 303, name: '鞋靴', sort: 3, status: 1 }
      ]},
      { id: 4, name: '美妆个护', icon: '💄', sort: 4, status: 1, children: [
        { id: 401, name: '护肤', sort: 1, status: 1 },
        { id: 402, name: '彩妆', sort: 2, status: 1 }
      ]},
      { id: 5, name: '食品生鲜', icon: '🍎', sort: 5, status: 1, children: [
        { id: 501, name: '零食', sort: 1, status: 1 },
        { id: 502, name: '饮料', sort: 2, status: 1 }
      ]},
      { id: 6, name: '图书文具', icon: '📚', sort: 6, status: 1, children: [] }
    ]
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  loadCategories()
}

function handleAdd() {
  ElMessage.info('新增分类功能开发中')
}

onMounted(() => {
  loadCategories()
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
</style>
