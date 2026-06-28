package com.shopping.order.vo;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class OrderItemRequest {
    @NotNull(message = "商品ID不能为空")
    private Long productId;

    private Long skuId;

    @NotNull(message = "商品数量不能为空")
    @Min(value = 1, message = "商品数量至少为1")
    private Integer quantity;
}
