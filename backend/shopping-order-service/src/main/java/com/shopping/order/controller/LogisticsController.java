package com.shopping.order.controller;

import com.shopping.common.utils.Result;
import com.shopping.order.entity.OrderLogisticsTrack;
import com.shopping.order.service.OrderLogisticsTrackService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/order/logistics")
public class LogisticsController {

    @Autowired
    private OrderLogisticsTrackService orderLogisticsTrackService;

    @GetMapping("/list")
    public Result<List<OrderLogisticsTrack>> list(@RequestParam Long orderId) {
        try {
            List<OrderLogisticsTrack> list = orderLogisticsTrackService.getByOrderId(orderId);
            return Result.success(list);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/add")
    public Result<Void> add(@RequestBody Map<String, Object> body) {
        try {
            Long orderId = Long.valueOf(String.valueOf(body.get("orderId")));
            String expressCompany = (String) body.get("expressCompany");
            String trackingNo = (String) body.get("trackingNo");
            String status = body.get("status") != null ? String.valueOf(body.get("status")) : null;
            String location = (String) body.get("location");
            String description = (String) body.get("description");
            orderLogisticsTrackService.addLogisticsTrack(orderId, expressCompany, trackingNo, status, location, description);
            return Result.success(null);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}
