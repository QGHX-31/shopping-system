<template>
  <div class="admin-login">
    <div class="login-box">
      <div class="login-header">
        <h1>🛒 平台运营后台</h1>
        <p>Shopping System Admin</p>
      </div>
      <el-form :model="loginForm" label-width="0" @submit.prevent="handleLogin">
        <el-form-item>
          <el-input v-model="loginForm.username" placeholder="用户名" size="large" prefix-icon="User" />
        </el-form-item>
        <el-form-item>
          <el-input v-model="loginForm.password" type="password" placeholder="密码" size="large" prefix-icon="Lock" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" style="width: 100%" :loading="loading" @click="handleLogin">
            登 录
          </el-button>
        </el-form-item>
      </el-form>
      <div class="login-tip">
        <p>默认账号：admin / 123456</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useAdminStore } from '@/stores/admin'

const router = useRouter()
const adminStore = useAdminStore()

const loginForm = reactive({
  username: 'admin',
  password: '123456'
})

const loading = ref(false)

async function handleLogin() {
  if (!loginForm.username || !loginForm.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  loading.value = true
  try {
    await adminStore.login(loginForm.username, loginForm.password)
    ElMessage.success('登录成功')
    router.push('/admin/dashboard')
  } catch (e: any) {
    console.error('登录失败', e)
    ElMessage.error(e?.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style lang="scss" scoped>
.admin-login {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-box {
  width: 400px;
  background: #fff;
  border-radius: 12px;
  padding: 40px 30px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;

  h1 {
    margin: 0 0 8px 0;
    font-size: 24px;
    color: #333;
  }

  p {
    margin: 0;
    font-size: 14px;
    color: #999;
  }
}

.login-tip {
  text-align: center;
  margin-top: 20px;
  font-size: 12px;
  color: #999;

  p { margin: 4px 0; }
}
</style>
