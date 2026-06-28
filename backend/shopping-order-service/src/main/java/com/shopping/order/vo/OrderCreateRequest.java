package com.shopping.order.vo;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class OrderCreateRequest {
    @NotNull(message = "用户ID不能为空")
    private Long userId;

    @NotEmpty(message = "商品列表不能为空")
    @Valid
    private List<OrderItemRequest> items;

    @NotNull(message = "收货地址不能为空")
    private Long addressId;

    private Long couponId;

    private List<Long> couponIds;

    @Size(max = 500, message = "备注长度不能超过500个字符")
    private String remark;

    private String groupTeamNo;

    private Long groupActivityId;
}
