package com.shopping.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.common.entity.Member;
import com.shopping.common.entity.PointsRecord;
import com.shopping.common.utils.RedisUtil;
import com.shopping.user.mapper.MemberMapper;
import com.shopping.user.mapper.PointsRecordMapper;
import com.shopping.user.service.MemberService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
public class MemberServiceImpl extends ServiceImpl<MemberMapper, Member> implements MemberService {
    @Resource
    private MemberMapper memberMapper;
    @Resource
    private PointsRecordMapper pointsRecordMapper;
    @Resource
    private RedisUtil redisUtil;

    @Override
    public Member getMemberInfo(Long userId) {
        String key = "member:info:" + userId;
        Member member = redisUtil.get(key, Member.class);
        if (member != null) {
            return member;
        }
        member = memberMapper.selectOne(new LambdaQueryWrapper<Member>().eq(Member::getUserId, userId));
        if (member != null) {
            redisUtil.set(key, member, 30, TimeUnit.MINUTES);
        }
        return member;
    }

    @Override
    @Transactional
    public void addPoints(Long userId, Integer points, String source) {
        Member member = memberMapper.selectOne(new LambdaQueryWrapper<Member>().eq(Member::getUserId, userId));
        if (member != null) {
            member.setTotalPoints(member.getTotalPoints() + points);
            member.setAvailablePoints(member.getAvailablePoints() + points);
            memberMapper.updateById(member);

            PointsRecord record = new PointsRecord();
            record.setUserId(userId);
            record.setPoints(points);
            record.setType(1);
            record.setSource(source);
            pointsRecordMapper.insert(record);

            String key = "member:info:" + userId;
            redisUtil.delete(key);
        }
    }

    @Override
    @Transactional
    public void consumePoints(Long userId, Integer points, String orderNo) {
        Member member = memberMapper.selectOne(new LambdaQueryWrapper<Member>().eq(Member::getUserId, userId));
        if (member != null && member.getAvailablePoints() >= points) {
            member.setAvailablePoints(member.getAvailablePoints() - points);
            memberMapper.updateById(member);

            PointsRecord record = new PointsRecord();
            record.setUserId(userId);
            record.setPoints(-points);
            record.setType(2);
            record.setOrderNo(orderNo);
            pointsRecordMapper.insert(record);

            String key = "member:info:" + userId;
            redisUtil.delete(key);
        }
    }

    @Override
    public List<PointsRecord> getPointsRecords(Long userId) {
        return pointsRecordMapper.selectList(new LambdaQueryWrapper<PointsRecord>()
                .eq(PointsRecord::getUserId, userId)
                .orderByDesc(PointsRecord::getCreatedAt));
    }
}
