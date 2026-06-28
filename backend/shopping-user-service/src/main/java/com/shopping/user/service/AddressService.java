package com.shopping.user.service;

import com.shopping.common.entity.Address;

import java.util.List;

public interface AddressService {
    List<Address> listByUserId(Long userId);
    Address getById(Long userId, Long id);
    Long create(Address address);
    boolean update(Address address);
    boolean delete(Long userId, Long id);
    boolean setDefault(Long userId, Long id);
}
