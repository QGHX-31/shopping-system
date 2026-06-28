<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <h2>商家管理后台</h2>
        <p>欢迎登录商家管理系统</p>
      </div>
      <el-form :model="loginForm" :rules="rules" ref="formRef" class="login-form">
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="请输入商家账号"
            prefix-icon="User"
            size="large"
          />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="login-btn" @click="handleLogin" :loading="loading">
            登录
          </el-button>
        </el-form-item>
      </el-form>
      <div class="login-tip">
        <p>测试账号: merchant01 / 123456</p>
        <p>管理员账号: admin / 123456（平台运营）</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { useMerchantStore } from '@/stores/merchant'

const router = useRouter()
const merchantStore = useMerchantStore()
const loading = ref(false)
const formRef = ref<FormInstance>()

const loginForm = reactive({ username: '', password: '' })
const rules: FormRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

async function handleLogin() {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await merchantStore.login(loginForm)
      ElMessage.success('登录成功')
      router.push('/merchant/dashboard')
    } catch (e: any) {
      ElMessage.error(e?.message || '登录失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1f2d3d 0%, #2c3e50 100%);
}
.login-container {
  width: 420px;
  background: #fff;
  border-radius: 8px;
  padding: 40px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}
.login-header {
  text-align: center;
  margin-bottom: 30px;
  h2 { font-size: 26px; color: #333; margin-bottom: 8px; }
  p { color: #999; font-size: 14px; }
}
.login-btn { width: 100%; }
.login-tip { text-align: center; color: #999; font-size: 12px; margin-top: 16px; }
</style>
