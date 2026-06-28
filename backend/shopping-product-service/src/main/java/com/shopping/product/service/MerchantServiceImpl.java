package com.shopping.product.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.Merchant;
import com.shopping.common.entity.MerchantStats;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.Admin;
import com.shopping.product.mapper.AdminMapper;
import com.shopping.product.mapper.MerchantMapper;
import com.shopping.product.mapper.MerchantStatsMapper;
import com.shopping.product.mapper.ProductMapper;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@Service
public class MerchantServiceImpl implements MerchantService {

    @Resource
    private MerchantMapper merchantMapper;

    @Resource
    private MerchantStatsMapper merchantStatsMapper;

    @Resource
    private ProductMapper productMapper;

    @Resource
    private AdminMapper adminMapper;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public Merchant login(String username, String password) {
        Merchant merchant = merchantMapper.selectOne(new LambdaQueryWrapper<Merchant>()
                .eq(Merchant::getUsername, username)
                .eq(Merchant::getStatus, 1));
        if (merchant != null && passwordEncoder.matches(password, merchant.getPassword())) {
            return merchant;
        }

        // 兼容平台管理员登录
        Admin admin = adminMapper.selectOne(new LambdaQueryWrapper<Admin>()
                .eq(Admin::getUsername, username)
                .eq(Admin::getStatus, 1));
        if (admin != null && passwordEncoder.matches(password, admin.getPassword())) {
            Merchant virtualMerchant = new Merchant();
            virtualMerchant.setId(0L);
            virtualMerchant.setUsername(admin.getUsername());
            virtualMerchant.setShopName("平台运营中心");
            virtualMerchant.setContactName(admin.getRealName());
            virtualMerchant.setContactPhone(admin.getPhone());
            virtualMerchant.setEmail(admin.getEmail());
            virtualMerchant.setStatus(1);
            virtualMerchant.setLevel(4);
            virtualMerchant.setIsAdmin(true);
            return virtualMerchant;
        }

        return null;
    }

    @Override
    public Merchant register(String username, String password, String shopName, String contactName, String contactPhone, String email) {
        // 检查用户名是否已存在
        Merchant exist = merchantMapper.selectOne(new LambdaQueryWrapper<Merchant>()
                .eq(Merchant::getUsername, username));
        if (exist != null) {
            throw new RuntimeException("商家账号已存在");
        }
        // 创建商家
        Merchant merchant = new Merchant();
        merchant.setUsername(username);
        merchant.setPassword(passwordEncoder.encode(password));
        merchant.setShopName(shopName);
        merchant.setContactName(contactName);
        merchant.setContactPhone(contactPhone);
        merchant.setEmail(email);
        merchant.setStatus(1); // 默认启用，简化处理（真实场景可设为 0 待审核）
        merchant.setLevel(1);
        merchantMapper.insert(merchant);
        return merchant;
    }
    
    @Override
    public Map<String, Object> getMerchantList(Integer page, Integer size, String keyword, Integer status) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 10 : size;

        LambdaQueryWrapper<Merchant> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Merchant::getCreatedAt);
        if (status != null) {
            wrapper.eq(Merchant::getStatus, status);
        }
        if (keyword != null && !keyword.isEmpty()) {
            java.util.List<Long> productMerchantIds = new java.util.ArrayList<>();
            LambdaQueryWrapper<Product> productWrapper = new LambdaQueryWrapper<>();
            productWrapper.like(Product::getName, keyword)
                          .eq(Product::getStatus, 1)
                          .select(Product::getMerchantId);
            var productList = productMapper.selectList(productWrapper);
            for (Product p : productList) {
                if (p.getMerchantId() != null && !productMerchantIds.contains(p.getMerchantId())) {
                    productMerchantIds.add(p.getMerchantId());
                }
            }
            wrapper.and(w -> {
                w.like(Merchant::getShopName, keyword);
                w.or().like(Merchant::getContactName, keyword);
                w.or().like(Merchant::getContactPhone, keyword);
                if (!productMerchantIds.isEmpty()) {
                    w.or().in(Merchant::getId, productMerchantIds);
                }
            });
        }

        IPage<Merchant> merchantPage = new Page<>(page, size);
        IPage<Merchant> resultPage = merchantMapper.selectPage(merchantPage, wrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    public boolean updateMerchantStatus(Long id, Integer status) {
        Merchant merchant = new Merchant();
        merchant.setId(id);
        merchant.setStatus(status);
        return merchantMapper.updateById(merchant) > 0;
    }
    
    @Override
    public Merchant getMerchantById(Long id) {
        return merchantMapper.selectById(id);
    }

    @Override
    public MerchantStats getMerchantStats(Long merchantId) {
        LambdaQueryWrapper<MerchantStats> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(MerchantStats::getMerchantId, merchantId)
               .orderByDesc(MerchantStats::getStatDate)
               .last("LIMIT 1");
        MerchantStats stats = merchantStatsMapper.selectOne(wrapper);

        if (stats == null) {
            stats = new MerchantStats();
            stats.setMerchantId(merchantId);
            stats.setStatDate(LocalDate.now());
            stats.setOrderCount(0);
            stats.setOrderAmount(BigDecimal.ZERO);
            stats.setProductViews(0);
            stats.setProductSales(0);
            stats.setNewCustomers(0);
        }
        return stats;
    }

    @Override
    public Map<String, Object> listMerchantProducts(Long merchantId, String keyword, Integer page, Integer size) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 10 : size;

        LambdaQueryWrapper<Product> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Product::getMerchantId, merchantId)
               .orderByDesc(Product::getCreatedAt);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(Product::getName, keyword);
        }

        IPage<Product> productPage = new Page<>(page, size);
        IPage<Product> resultPage = productMapper.selectPage(productPage, wrapper);

        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    public boolean toggleProductStatus(Long productId, Integer status) {
        Product product = new Product();
        product.setId(productId);
        product.setStatus(status);
        return productMapper.updateById(product) > 0;
    }

    @Override
    public boolean deleteProduct(Long productId) {
        return productMapper.deleteById(productId) > 0;
    }
}
