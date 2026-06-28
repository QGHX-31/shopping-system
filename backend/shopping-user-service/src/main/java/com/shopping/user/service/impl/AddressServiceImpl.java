package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.entity.Address;
import com.shopping.common.exception.BusinessException;
import com.shopping.user.mapper.AddressMapper;
import com.shopping.user.service.AddressService;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

@Service
public class AddressServiceImpl implements AddressService {

    @Resource
    private AddressMapper addressMapper;

    @Override
    public List<Address> listByUserId(Long userId) {
        return addressMapper.selectList(
                new LambdaQueryWrapper<Address>()
                        .eq(Address::getUserId, userId)
                        .eq(Address::getStatus, 1)
                        .orderByDesc(Address::getIsDefault)
                        .orderByDesc(Address::getId));
    }

    @Override
    public Address getById(Long userId, Long id) {
        Address a = addressMapper.selectById(id);
        if (a == null || !a.getUserId().equals(userId)) {
            return null;
        }
        return a;
    }

    @Override
    public Long create(Address address) {
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            clearDefault(address.getUserId());
        }
        address.setStatus(1);
        addressMapper.insert(address);
        return address.getId();
    }

    @Override
    public boolean update(Address address) {
        Address exist = addressMapper.selectById(address.getId());
        if (exist == null || !exist.getUserId().equals(address.getUserId())) {
            throw new BusinessException("地址不存在");
        }
        if (address.getIsDefault() != null && address.getIsDefault() == 1) {
            clearDefault(address.getUserId());
        }
        return addressMapper.updateById(address) > 0;
    }

    @Override
    public boolean delete(Long userId, Long id) {
        Address exist = addressMapper.selectById(id);
        if (exist == null || !exist.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }
        // 软删除
        Address a = new Address();
        a.setId(id);
        a.setStatus(0);
        return addressMapper.updateById(a) > 0;
    }

    @Override
    public boolean setDefault(Long userId, Long id) {
        clearDefault(userId);
        Address a = new Address();
        a.setId(id);
        a.setIsDefault(1);
        return addressMapper.updateById(a) > 0;
    }

    private void clearDefault(Long userId) {
        List<Address> olds = addressMapper.selectList(
                new LambdaQueryWrapper<Address>()
                        .eq(Address::getUserId, userId)
                        .eq(Address::getIsDefault, 1));
        for (Address o : olds) {
            Address u = new Address();
            u.setId(o.getId());
            u.setIsDefault(0);
            addressMapper.updateById(u);
        }
    }
}
