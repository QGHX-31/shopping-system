<template>
  <div class="product-edit-page">
    <div class="page-header">
      <el-button @click="goBack">
        <el-icon><ArrowLeft /></el-icon>
        <span>返回</span>
      </el-button>
      <h2>{{ isEdit ? '编辑商品' : '新增商品' }}</h2>
    </div>

    <div class="form-card">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="商品名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入商品名称" maxlength="100" />
        </el-form-item>

        <el-form-item label="商品分类" prop="categoryId">
          <el-cascader
            v-model="categoryPath"
            :options="categoryOptions"
            :props="{ value: 'id', label: 'name', children: 'children' }"
            placeholder="请选择商品分类"
            clearable
            style="width: 100%"
            @change="handleCategoryChange"
          />
        </el-form-item>

        <el-form-item label="品牌">
          <el-input v-model="form.brand" placeholder="请输入品牌" maxlength="50" />
        </el-form-item>

        <el-form-item label="商品图片" prop="imageUrl">
          <div class="image-preview-wrap">
            <img v-if="form.imageUrl" :src="form.imageUrl" class="image-preview" />
            <div v-else class="image-placeholder">暂无图片</div>
          </div>
          <el-input v-model="form.imageUrl" placeholder="请输入商品图片URL" class="url-input" />
          <div class="img-tip">请填写图片的完整URL地址</div>
        </el-form-item>

        <el-form-item label="商品详情图">
          <el-input
            v-model="form.detailImages"
            type="textarea"
            :rows="2"
            placeholder="多张图片用英文逗号分隔"
          />
        </el-form-item>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="售价" prop="price">
              <el-input-number v-model="form.price" :min="0" :precision="2" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="原价">
              <el-input-number v-model="form.originalPrice" :min="0" :precision="2" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="库存" prop="stock">
              <el-input-number v-model="form.stock" :min="0" :step="1" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="8">
            <el-form-item label="是否热门">
              <el-switch v-model="form.isHot" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="是否新品">
              <el-switch v-model="form.isNew" :active-value="1" :inactive-value="0" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="商品状态">
              <el-switch v-model="form.status" :active-value="1" :inactive-value="0" active-text="上架" inactive-text="下架" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="商品描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="5"
            placeholder="请输入商品描述"
            maxlength="2000"
            show-word-limit
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">提交</el-button>
          <el-button @click="goBack">取消</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft } from '@element-plus/icons-vue'
import { useMerchantStore } from '@/stores/merchant'
import request from '@/utils/request'

const router = useRouter()
const route = useRoute()
const merchantStore = useMerchantStore()

const formRef = ref()
const submitting = ref(false)
const categoryOptions = ref<any[]>([])
const categoryPath = ref<number[]>([])

const isEdit = computed(() => !!route.query.id)
const productId = computed(() => Number(route.query.id) || 0)

const form = reactive({
  id: 0,
  name: '',
  categoryId: null as number | null,
  brand: '',
  price: 0,
  originalPrice: 0,
  stock: 0,
  salesCount: 0,
  description: '',
  imageUrl: '',
  detailImages: '',
  isHot: 0,
  isNew: 0,
  status: 1,
  merchantId: 0
})

const rules = {
  name: [{ required: true, message: '请输入商品名称', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择商品分类', trigger: 'change' }],
  price: [{ required: true, message: '请输入售价', trigger: 'blur' }],
  stock: [{ required: true, message: '请输入库存', trigger: 'blur' }],
  imageUrl: [{ required: true, message: '请输入商品图片URL', trigger: 'blur' }]
}

function buildCategoryTree(list: any[]) {
  const map: Record<number, any> = {}
  list.forEach(item => {
    map[item.id] = { ...item, children: [] }
  })
  const tree: any[] = []
  list.forEach(item => {
    if (item.parentId === 0 || item.parentId === null) {
      tree.push(map[item.id])
    } else if (map[item.parentId]) {
      map[item.parentId].children.push(map[item.id])
    }
  })
  return tree
}

function findCategoryPath(categories: any[], targetId: number, path: number[] = []): number[] {
  for (const cat of categories) {
    const newPath = [...path, cat.id]
    if (cat.id === targetId) return newPath
    if (cat.children && cat.children.length) {
      const result = findCategoryPath(cat.children, targetId, newPath)
      if (result.length) return result
    }
  }
  return []
}

async function loadCategories() {
  try {
    const res = await request.get('/category/list')
    const list = res.data?.list || res.data || []
    categoryOptions.value = buildCategoryTree(list)
  } catch (e) {
    console.error('加载分类失败', e)
  }
}

async function loadProduct() {
  if (!productId.value) return
  try {
    const res = await request.get(`/product/${productId.value}`)
    const data = res.data
    if (data) {
      Object.assign(form, data)
      if (data.categoryId) {
        categoryPath.value = findCategoryPath(categoryOptions.value, data.categoryId)
      }
    }
  } catch (e) {
    ElMessage.error('加载商品信息失败')
  }
}

function handleCategoryChange(val: number[]) {
  form.categoryId = val && val.length > 0 ? val[val.length - 1] : null
}

function goBack() {
  router.push('/merchant/product')
}

async function handleSubmit() {
  if (!formRef.value) return
  if (!form.categoryId && categoryPath.value.length > 0) {
    form.categoryId = categoryPath.value[categoryPath.value.length - 1]
  }
  if (!form.categoryId) {
    ElMessage.warning('请选择商品分类')
    return
  }
  await formRef.value.validate()
  form.merchantId = merchantStore.merchantInfo?.id || Number(localStorage.getItem('merchant_id') || 0)
  if (!form.merchantId) {
    ElMessage.error('商家信息获取失败，请重新登录')
    return
  }
  submitting.value = true
  try {
    if (isEdit.value) {
      await request.put('/merchant/product/' + productId.value, form)
      ElMessage.success('修改成功')
    } else {
      await request.post('/merchant/product/add', form)
      ElMessage.success('添加成功')
    }
    setTimeout(() => goBack(), 500)
  } catch (e: any) {
    ElMessage.error(e?.message || '保存失败')
  } finally {
    submitting.value = false
  }
}

onMounted(() => {
  loadCategories().then(() => {
    if (isEdit.value) {
      loadProduct()
    }
  })
})
</script>

<style lang="scss" scoped>
.product-edit-page {
  padding: 20px;
}

.page-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 20px;
    color: #333;
  }
}

.form-card {
  background: #fff;
  border-radius: 8px;
  padding: 24px;
  max-width: 900px;
}

.image-preview-wrap {
  margin-bottom: 8px;
}

.image-preview {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #dcdfe6;
}

.image-placeholder {
  width: 120px;
  height: 120px;
  border: 1px dashed #dcdfe6;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: #999;
  background: #fafafa;
}

.img-tip {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

.url-input {
  width: 400px;
}
</style>
