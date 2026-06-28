package com.shopping.marketing.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.GroupBuyActivity;
import com.shopping.common.entity.GroupBuyMember;
import com.shopping.common.entity.GroupBuyTeam;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.common.utils.RedisUtil;
import com.shopping.common.entity.MerchantGroupParticipation;
import com.shopping.common.entity.PlatformGroupTemplate;
import com.shopping.marketing.mapper.*;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class GroupBuyServiceImpl implements GroupBuyService {

    @Resource
    private GroupBuyActivityMapper groupBuyActivityMapper;

    @Resource
    private GroupBuyTeamMapper groupBuyTeamMapper;

    @Resource
    private GroupBuyMemberMapper groupBuyMemberMapper;

    @Resource
    private MerchantGroupParticipationMapper merchantGroupParticipationMapper;

    @Resource
    private PlatformGroupTemplateMapper platformGroupTemplateMapper;

    @Resource
    private RedisUtil redisUtil;

    @Resource
    private MqMessageSender mqMessageSender;

    private static final String GROUP_STOCK_KEY = "group:stock:";

    @Override
    public Map<String, Object> getActiveActivities() {
        LambdaQueryWrapper<GroupBuyActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyActivity::getStatus, 1)
               .le(GroupBuyActivity::getStartTime, LocalDateTime.now())
               .ge(GroupBuyActivity::getEndTime, LocalDateTime.now())
               .orderByDesc(GroupBuyActivity::getCreatedAt);
        List<GroupBuyActivity> activities = groupBuyActivityMapper.selectList(wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", activities);
        result.put("total", activities.size());
        return result;
    }

    @Override
    public Map<String, Object> getActivityDetail(Long id) {
        GroupBuyActivity activity = groupBuyActivityMapper.selectById(id);
        if (activity == null) {
            return null;
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("activity", activity);
        return result;
    }

    @Override
    @Transactional
    public GroupBuyActivity createActivity(GroupBuyActivity activity) {
        activity.setStatus(0);
        activity.setCreatedAt(LocalDateTime.now());
        groupBuyActivityMapper.insert(activity);
        
        String stockKey = GROUP_STOCK_KEY + activity.getId();
        redisUtil.set(stockKey, activity.getAvailableStock());
        
        return activity;
    }

    @Override
    @Transactional
    public Map<String, Object> createTeam(Long activityId, Long userId) {
        Map<String, Object> result = new HashMap<>();
        
        GroupBuyActivity activity = groupBuyActivityMapper.selectById(activityId);
        if (activity == null) {
            result.put("success", false);
            result.put("message", "Activity not found");
            return result;
        }
        
        String stockKey = GROUP_STOCK_KEY + activityId;
        Long stock = redisUtil.get(stockKey, Long.class);
        if (stock == null) {
            stock = (long) activity.getAvailableStock();
        }
        
        if (stock <= 0) {
            result.put("success", false);
            result.put("message", "Insufficient stock");
            return result;
        }
        
        GroupBuyTeam team = new GroupBuyTeam();
        team.setTeamNo("GB" + System.currentTimeMillis() + new Random().nextInt(1000));
        team.setActivityId(activityId);
        team.setLeaderId(userId);
        team.setRequiredNum(activity.getRequiredNum());
        team.setCurrentNum(1);
        team.setStatus(0);
        team.setExpireTime(LocalDateTime.now().plusHours(activity.getGroupDuration()));
        team.setCreatedAt(LocalDateTime.now());
        groupBuyTeamMapper.insert(team);
        
        GroupBuyMember member = new GroupBuyMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setIsLeader(1);
        member.setJoinTime(LocalDateTime.now());
        groupBuyMemberMapper.insert(member);
        
        redisUtil.decrement(stockKey, 1);

        Map<String, Object> mqBody = new HashMap<>();
        mqBody.put("teamNo", team.getTeamNo());
        mqBody.put("activityId", activityId);
        mqBody.put("leaderId", userId);
        mqBody.put("requiredNum", team.getRequiredNum());
        mqBody.put("expireTime", team.getExpireTime().toString());
        mqMessageSender.send(MqTopic.GROUP_CREATED, "group", team.getTeamNo(), mqBody);

        result.put("success", true);
        result.put("team", team);
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> createTeamByParticipation(Long participationId, Long userId) {
        Map<String, Object> result = new HashMap<>();

        // 1. 查询商家拼团报名信息
        MerchantGroupParticipation participation = merchantGroupParticipationMapper.selectById(participationId);
        if (participation == null) {
            result.put("success", false);
            result.put("message", "拼团活动不存在");
            return result;
        }
        if (participation.getStatus() != 2) {
            result.put("success", false);
            result.put("message", "拼团活动未通过审核");
            return result;
        }
        if (participation.getAvailableStock() <= 0) {
            result.put("success", false);
            result.put("message", "拼团库存不足");
            return result;
        }

        // 2. 查询模板获取成团人数和时长
        PlatformGroupTemplate template = platformGroupTemplateMapper.selectById(participation.getTemplateId());
        int requiredNum = template != null && template.getRequiredNum() != null ? template.getRequiredNum() : 3;
        int groupDuration = template != null && template.getGroupDuration() != null ? template.getGroupDuration() : 24;

        // 3. 查找或创建 GroupBuyActivity
        Long activityId = findOrCreateActivity(participation, requiredNum, groupDuration);
        if (activityId == null) {
            result.put("success", false);
            result.put("message", "创建拼团活动失败");
            return result;
        }

        // 4. 调用现有创建团队逻辑
        return createTeam(activityId, userId);
    }

    private Long findOrCreateActivity(MerchantGroupParticipation participation, int requiredNum, int groupDuration) {
        // 先查找该商品已有的活跃拼团活动
        LambdaQueryWrapper<GroupBuyActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyActivity::getProductId, participation.getProductId())
               .eq(GroupBuyActivity::getStatus, 1)
               .ge(GroupBuyActivity::getEndTime, LocalDateTime.now())
               .orderByDesc(GroupBuyActivity::getCreatedAt)
               .last("LIMIT 1");
        List<GroupBuyActivity> existing = groupBuyActivityMapper.selectList(wrapper);
        if (!existing.isEmpty()) {
            return existing.get(0).getId();
        }

        // 没有则创建新的
        GroupBuyActivity activity = new GroupBuyActivity();
        activity.setName("拼团活动");
        activity.setMerchantId(participation.getMerchantId());
        activity.setProductId(participation.getProductId());
        activity.setSkuId(participation.getSkuId());
        activity.setGroupPrice(participation.getGroupPrice());
        activity.setOriginalPrice(participation.getOriginalPrice());
        activity.setRequiredNum(requiredNum);
        activity.setTotalStock(participation.getAvailableStock());
        activity.setAvailableStock(participation.getAvailableStock());
        activity.setStartTime(LocalDateTime.now());
        activity.setEndTime(LocalDateTime.now().plusDays(7));
        activity.setGroupDuration(groupDuration);
        activity.setStatus(1);
        activity.setCreatedAt(LocalDateTime.now());
        activity.setUpdatedAt(LocalDateTime.now());
        groupBuyActivityMapper.insert(activity);

        // 初始化库存缓存
        String stockKey = GROUP_STOCK_KEY + activity.getId();
        redisUtil.set(stockKey, activity.getAvailableStock());

        return activity.getId();
    }

    @Override
    @Transactional
    public Map<String, Object> joinTeam(String teamNo, Long userId) {
        Map<String, Object> result = new HashMap<>();
        
        LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.eq(GroupBuyTeam::getTeamNo, teamNo);
        GroupBuyTeam team = groupBuyTeamMapper.selectOne(teamWrapper);
        
        if (team == null) {
            result.put("success", false);
            result.put("message", "Team not found");
            return result;
        }
        
        if (team.getStatus() != 0) {
            result.put("success", false);
            result.put("message", "Team is not open");
            return result;
        }
        
        if (team.getExpireTime().isBefore(LocalDateTime.now())) {
            result.put("success", false);
            result.put("message", "Team has expired");
            return result;
        }
        
        LambdaQueryWrapper<GroupBuyMember> memberCheckWrapper = new LambdaQueryWrapper<>();
        memberCheckWrapper.eq(GroupBuyMember::getTeamId, team.getId())
                         .eq(GroupBuyMember::getUserId, userId);
        Long existingCount = groupBuyMemberMapper.selectCount(memberCheckWrapper);
        if (existingCount > 0) {
            result.put("success", false);
            result.put("message", "Already joined this team");
            return result;
        }
        
        GroupBuyMember member = new GroupBuyMember();
        member.setTeamId(team.getId());
        member.setUserId(userId);
        member.setIsLeader(0);
        member.setJoinTime(LocalDateTime.now());
        groupBuyMemberMapper.insert(member);
        
        team.setCurrentNum(team.getCurrentNum() + 1);
        groupBuyTeamMapper.updateById(team);
        
        if (team.getCurrentNum() >= team.getRequiredNum()) {
            team.setStatus(1);
            team.setSuccessTime(LocalDateTime.now());
            groupBuyTeamMapper.updateById(team);

            Map<String, Object> mqBody = new HashMap<>();
            mqBody.put("teamNo", team.getTeamNo());
            mqBody.put("activityId", team.getActivityId());
            mqBody.put("successTime", team.getSuccessTime().toString());
            mqBody.put("memberCount", team.getCurrentNum());
            mqMessageSender.send(MqTopic.GROUP_SUCCESS, "group", team.getTeamNo(), mqBody);
        }

        result.put("success", true);
        result.put("team", team);
        return result;
    }

    @Override
    public Map<String, Object> getTeamDetail(String teamNo) {
        LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.eq(GroupBuyTeam::getTeamNo, teamNo);
        GroupBuyTeam team = groupBuyTeamMapper.selectOne(teamWrapper);
        
        if (team == null) {
            return null;
        }
        
        LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(GroupBuyMember::getTeamId, team.getId());
        List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("team", team);
        result.put("members", members);
        return result;
    }
    
    @Override
    public Map<String, Object> getActiveTeamsByProduct(Long productId, Integer page, Integer size) {
        page = page == null || page < 1 ? 1 : page;
        size = size == null || size < 1 ? 10 : size;
        
        LambdaQueryWrapper<GroupBuyActivity> activityWrapper = new LambdaQueryWrapper<>();
        activityWrapper.eq(GroupBuyActivity::getProductId, productId)
                       .eq(GroupBuyActivity::getStatus, 1)
                       .le(GroupBuyActivity::getStartTime, LocalDateTime.now())
                       .ge(GroupBuyActivity::getEndTime, LocalDateTime.now());
        List<GroupBuyActivity> activities = groupBuyActivityMapper.selectList(activityWrapper);
        
        if (activities.isEmpty()) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("list", Collections.emptyList());
            empty.put("total", 0);
            empty.put("page", page);
            empty.put("size", size);
            return empty;
        }
        
        List<Long> activityIds = activities.stream().map(GroupBuyActivity::getId).toList();
        
        LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.in(GroupBuyTeam::getActivityId, activityIds)
                   .eq(GroupBuyTeam::getStatus, 0)
                   .orderByDesc(GroupBuyTeam::getCreatedAt);
        
        Page<GroupBuyTeam> teamPage = new Page<>(page, size);
        Page<GroupBuyTeam> resultPage = groupBuyTeamMapper.selectPage(teamPage, teamWrapper);
        
        List<GroupBuyTeam> teams = resultPage.getRecords();
        List<Map<String, Object>> teamList = new ArrayList<>();
        for (GroupBuyTeam team : teams) {
            GroupBuyActivity activity = activities.stream()
                .filter(a -> a.getId().equals(team.getActivityId()))
                .findFirst()
                .orElse(null);
            
            LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
            memberWrapper.eq(GroupBuyMember::getTeamId, team.getId());
            List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
            
            Map<String, Object> teamMap = new HashMap<>();
            teamMap.put("team", team);
            teamMap.put("members", members);
            teamMap.put("activity", activity);
            teamList.add(teamMap);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", teamList);
        result.put("total", resultPage.getTotal());
        result.put("page", resultPage.getCurrent());
        result.put("size", resultPage.getSize());
        return result;
    }

    @Override
    @Scheduled(fixedRate = 60000)
    @Transactional
    public void checkAndCloseExpiredTeams() {
        LambdaQueryWrapper<GroupBuyTeam> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyTeam::getStatus, 0)
               .lt(GroupBuyTeam::getExpireTime, LocalDateTime.now());
        List<GroupBuyTeam> expiredTeams = groupBuyTeamMapper.selectList(wrapper);
        
        for (GroupBuyTeam team : expiredTeams) {
            team.setStatus(2);
            groupBuyTeamMapper.updateById(team);
            
            LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
            memberWrapper.eq(GroupBuyMember::getTeamId, team.getId());
            List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
            
            for (GroupBuyMember member : members) {
                groupBuyMemberMapper.deleteById(member.getId());
            }
            
            String stockKey = GROUP_STOCK_KEY + team.getActivityId();
            redisUtil.increment(stockKey, 1);
        }
    }

    @Override
    @Scheduled(fixedRate = 60000)
    @Transactional
    public void checkAndCompleteTeams() {
        LambdaQueryWrapper<GroupBuyTeam> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyTeam::getStatus, 0)
               .apply("current_num >= required_num");
        List<GroupBuyTeam> completedTeams = groupBuyTeamMapper.selectList(wrapper);
        
        for (GroupBuyTeam team : completedTeams) {
            team.setStatus(1);
            team.setSuccessTime(LocalDateTime.now());
            groupBuyTeamMapper.updateById(team);
        }
    }
}
