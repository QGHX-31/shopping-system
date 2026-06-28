package com.shopping.user.controller;

import com.shopping.common.entity.Address;
import com.shopping.common.utils.Result;
import com.shopping.user.service.AddressService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 用户收货地址
 * 注：路径用 /address 而不是 /user/address，方便其他服务（比如 order-service）远程调用
 */
@RestController
@RequestMapping("/address")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class AddressController {

    @Resource
    private AddressService addressService;

    /** 列表 */
    @GetMapping("/list")
    public Result<List<Address>> list(@RequestParam Long userId) {
        return Result.success(addressService.listByUserId(userId));
    }

    /**
     * 给订单服务远程调用：根据 userId + addressId 查一条地址
     * 返回的 JSON key：name / phone / detail（前后端统一）
     */
    @GetMapping("/get")
    public Result<Map<String, Object>> get(@RequestParam Long userId,
                                          @RequestParam Long id) {
        Address a = addressService.getById(userId, id);
        if (a == null) return Result.error("地址不存在");
        Map<String, Object> data = new HashMap<>();
        data.put("id", a.getId());
        data.put("userId", a.getUserId());
        data.put("name", a.getName());
        data.put("phone", a.getPhone());
        data.put("province", a.getProvince());
        data.put("city", a.getCity());
        data.put("district", a.getDistrict());
        data.put("detail", a.getDetail());
        data.put("isDefault", a.getIsDefault());
        return Result.success(data);
    }

    /** 新增 */
    @PostMapping("/create")
    public Result<Long> create(@RequestBody Address address) {
        return Result.success(addressService.create(address));
    }

    /** 更新 */
    @PutMapping("/update")
    public Result<Boolean> update(@RequestBody Address address) {
        return Result.success(addressService.update(address));
    }

    /** 删除（软删） */
    @DeleteMapping("/delete")
    public Result<Boolean> delete(@RequestParam Long userId,
                                  @RequestParam Long id) {
        return Result.success(addressService.delete(userId, id));
    }

    /** 设为默认 */
    @PutMapping("/default")
    public Result<Boolean> setDefault(@RequestParam Long userId,
                                      @RequestParam Long id) {
        return Result.success(addressService.setDefault(userId, id));
    }
}
