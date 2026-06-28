package com.shopping.user.controller;

import com.shopping.common.entity.Member;
import com.shopping.common.entity.PointsRecord;
import com.shopping.common.utils.JwtUtil;
import com.shopping.common.utils.Result;
import com.shopping.user.service.MemberService;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/member")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class MemberController {
    @Resource
    private MemberService memberService;
    @Resource
    private JwtUtil jwtUtil;

    @GetMapping("/info")
    public Result<Member> getMemberInfo(HttpServletRequest request) {
        Long userId = getUserId(request);
        Member member = memberService.getMemberInfo(userId);
        return Result.success(member);
    }

    @PostMapping("/points/add")
    public Result<Void> addPoints(HttpServletRequest request, @RequestBody PointsRecord record) {
        Long userId = getUserId(request);
        memberService.addPoints(userId, record.getPoints(), record.getSource());
        return Result.success();
    }

    @PostMapping("/points/consume")
    public Result<Void> consumePoints(HttpServletRequest request, @RequestBody PointsRecord record) {
        Long userId = getUserId(request);
        memberService.consumePoints(userId, record.getPoints(), record.getOrderNo());
        return Result.success();
    }

    @GetMapping("/points/records")
    public Result<List<PointsRecord>> getPointsRecords(HttpServletRequest request) {
        Long userId = getUserId(request);
        List<PointsRecord> records = memberService.getPointsRecords(userId);
        return Result.success(records);
    }

    private Long getUserId(HttpServletRequest request) {
        String token = request.getHeader("Authorization").substring(7);
        return jwtUtil.getUserIdFromToken(token);
    }
}
