package com.shopping.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.common.entity.Member;
import com.shopping.common.entity.PointsRecord;

import java.util.List;

public interface MemberService extends IService<Member> {
    Member getMemberInfo(Long userId);
    void addPoints(Long userId, Integer points, String source);
    void consumePoints(Long userId, Integer points, String orderNo);
    List<PointsRecord> getPointsRecords(Long userId);
}
