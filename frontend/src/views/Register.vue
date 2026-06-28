<template>
  <div class="register-page">
    <div class="register-container">
      <div class="register-header">
        <h2>{{ registerType === 'user' ? '用户注册' : '商家入驻' }}</h2>
        <p>创建您的购物系统账号</p>
      </div>
      <el-form :model="registerForm" :rules="rules" ref="registerFormRef" class="register-form">
        <el-form-item prop="username">
          <el-input
            v-model="registerForm.username"
            :placeholder="registerType === 'user' ? '请输入用户名' : '请输入商家账号'"
            :prefix-icon="User"
            size="large"
          />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="请输入密码"
            :prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>
        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            placeholder="请确认密码"
            :prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>
        <el-form-item v-if="registerType === 'merchant'" prop="shopName">
          <el-input
            v-model="registerForm.shopName"
            placeholder="请输入店铺名称"
            :prefix-icon="Shop"
            size="large"
          />
        </el-form-item>
        <el-form-item v-if="registerType === 'merchant'" prop="contactName">
          <el-input
            v-model="registerForm.contactName"
            placeholder="请输入联系人姓名"
            :prefix-icon="UserFilled"
            size="large"
          />
        </el-form-item>
        <el-form-item v-if="registerType === 'merchant'" prop="contactPhone">
          <el-input
            v-model="registerForm.contactPhone"
            placeholder="请输入联系电话"
            :prefix-icon="Phone"
            size="large"
          />
        </el-form-item>
        <el-form-item v-if="registerType === 'user'" prop="email">
          <el-input
            v-model="registerForm.email"
            placeholder="请输入邮箱（选填）"
            :prefix-icon="Message"
            size="large"
          />
        </el-form-item>
        <el-form-item v-if="registerType === 'user'" prop="phone">
          <el-input
            v-model="registerForm.phone"
            placeholder="请输入手机号（选填）"
            :prefix-icon="Phone"
            size="large"
          />
        </el-form-item>
        <el-form-item>
          <div class="register-type-selector">
            <el-radio-group v-model="registerType" size="large">
              <el-radio-button value="user">用户注册</el-radio-button>
              <el-radio-button value="merchant">商家入驻</el-radio-button>
            </el-radio-group>
          </div>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" size="large" class="register-btn" @click="handleRegister" :loading="loading">
            注册
          </el-button>
        </el-form-item>
      </el-form>
      <div class="login-link">
        <span>已有账号？</span>
        <router-link to="/login">立即登录</router-link>
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
import { User, Lock, Shop, UserFilled, Phone, Message } from '@element-plus/icons-vue'

const router = useRouter()
const userStore = useUserStore()
const merchantStore = useMerchantStore()
const loading = ref(false)
const registerType = ref<'user' | 'merchant'>('user')

const registerFormRef = ref<FormInstance>()

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  email: '',
  phone: '',
  shopName: '',
  contactName: '',
  contactPhone: ''
})

const rules: FormRules = {
  username: [
    { required: true, message: '请输入账号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 20, message: '密码长度在6到20个字符', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator(_, value, callback) {
        if (value !== registerForm.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
  ],
  phone: [
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ],
  shopName: [
    { required: true, message: '请输入店铺名称', trigger: 'blur' }
  ],
  contactName: [
    { required: true, message: '请输入联系人', trigger: 'blur' }
  ],
  contactPhone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号格式', trigger: 'blur' }
  ]
}

watch(registerType, () => {
  Object.assign(registerForm, {
    username: '',
    password: '',
    confirmPassword: '',
    email: '',
    phone: '',
    shopName: '',
    contactName: '',
    contactPhone: ''
  })
})

async function handleRegister() {
  if (!registerFormRef.value) return
  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      if (registerType.value === 'user') {
        await userStore.register({
          username: registerForm.username,
          password: registerForm.password,
          email: registerForm.email,
          phone: registerForm.phone
        })
        ElMessage.success('注册成功，请登录')
        router.push('/login')
      } else {
        await merchantStore.register({
          username: registerForm.username,
          password: registerForm.password,
          shopName: registerForm.shopName,
          contactName: registerForm.contactName,
          contactPhone: registerForm.contactPhone,
          email: registerForm.email
        })
        ElMessage.success('商家入驻成功，请登录')
        router.push('/merchant/login')
      }
    } catch (error: any) {
      ElMessage.error(error?.message || '注册失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style lang="scss" scoped>
.register-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-container {
  width: 450px;
  background: #fff;
  border-radius: 10px;
  padding: 40px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.register-header {
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

.register-form {
  .register-type-selector {
    display: flex;
    justify-content: center;
    width: 100%;
  }

  .register-btn {
    width: 100%;
  }
}

.login-link {
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
</style>
