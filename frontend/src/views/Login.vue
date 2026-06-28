<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <h2>{{ loginType === 'user' ? '用户登录' : '商家登录' }}</h2>
        <p>欢迎来到购物系统</p>
      </div>
      <el-form :model="loginForm" :rules="rules" ref="loginFormRef" class="login-form">
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            :placeholder="loginType === 'user' ? '请输入用户名' : '请输入商家账号'"
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
          <div class="login-type-selector">
            <el-radio-group v-model="loginType" size="large">
              <el-radio-button value="user">用户登录</el-radio-button>
              <el-radio-button value="merchant">商家登录</el-radio-button>
            </el-radio-group>
          </div>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="login-btn" @click="handleLogin" :loading="loading">
            登录
          </el-button>
        </el-form-item>
      </el-form>
      <div class="register-link" v-if="loginType === 'user'">
        <span>还没有账号？</span>
        <router-link to="/register">立即注册</router-link>
      </div>
      <div class="merchant-tip" v-else>
        <p>测试账号: merchant01 / 123456</p>
        <p>或 merchant02 / 123456</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useMerchantStore } from '@/stores/merchant'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()
const merchantStore = useMerchantStore()
const loading = ref(false)
const loginType = ref<'user' | 'merchant'>('user')

const loginFormRef = ref<FormInstance>()

const loginForm = reactive({
  username: '',
  password: ''
})

const rules: FormRules = {
  username: [
    { required: true, message: '请输入账号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

watch(loginType, () => {
  loginForm.username = ''
  loginForm.password = ''
})

async function handleLogin() {
  if (!loginFormRef.value) return
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      if (loginType.value === 'user') {
        await userStore.login(loginForm)
        ElMessage.success('登录成功')
        router.push('/')
      } else {
        await merchantStore.login(loginForm)
        ElMessage.success('登录成功')
        router.push('/merchant/dashboard')
      }
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
  background: linear-gradient(135deg, #ffd4b8 0%, #ffe5d4 100%);
}

.login-container {
  width: 420px;
  background: #fff;
  border-radius: 10px;
  padding: 40px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;

  h2 {
    font-size: 28px;
    margin-bottom: 10px;
    color: #333;
  }

  p {
    color: #999;
    font-size: 14px;
  }
}

.login-form {
  .login-type-selector {
    display: flex;
    justify-content: center;
    width: 100%;
  }

  .login-btn {
    width: 100%;
  }
}

.register-link {
  text-align: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;

  span {
    color: #999;
    font-size: 14px;
  }

  a {
    color: #667eea;
    text-decoration: none;
    margin-left: 5px;
  }
}

.merchant-tip {
  text-align: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #eee;
  color: #999;
  font-size: 12px;

  p {
    margin: 4px 0;
  }
}
</style>
