package com.shopping.marketing.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.entity.GroupBuyActivity;
import com.shopping.common.entity.GroupBuyMember;
import com.shopping.common.entity.GroupBuyTeam;
import com.shopping.common.entity.Product;
import com.shopping.common.entity.User;
import com.shopping.common.mq.MqMessageSender;
import com.shopping.common.mq.MqTopic;
import com.shopping.common.utils.RedisUtil;
import com.shopping.common.utils.Result;
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

    @Resource
    private ProductMapper productMapper;

    @Resource
    private UserMapper userMapper;

    private static final String GROUP_STOCK_KEY = "group:stock:";

    @Override
    public Map<String, Object> getActiveActivities() {
        LambdaQueryWrapper<GroupBuyActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(GroupBuyActivity::getStatus, 1)
               .ge(GroupBuyActivity::getEndTime, LocalDateTime.now())
               .orderByAsc(GroupBuyActivity::getStartTime)
               .last("LIMIT 20");
        List<GroupBuyActivity> activities = groupBuyActivityMapper.selectList(wrapper);
        
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (GroupBuyActivity activity : activities) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", activity.getId());
            map.put("name", activity.getName());
            map.put("productId", activity.getProductId());
            map.put("groupPrice", activity.getGroupPrice());
            map.put("originalPrice", activity.getOriginalPrice());
            map.put("requiredNum", activity.getRequiredNum());
            map.put("totalStock", activity.getTotalStock());
            map.put("availableStock", activity.getAvailableStock());
            map.put("startTime", activity.getStartTime());
            map.put("endTime", activity.getEndTime());
            map.put("status", activity.getStatus());
            
            if (activity.getProductId() != null) {
                Product product = productMapper.selectById(activity.getProductId());
                if (product != null) {
                    map.put("productName", product.getName());
                    map.put("imageUrl", product.getImageUrl());
                    map.put("salesCount", product.getSalesCount());
                } else {
                    map.put("productName", "未知商品");
                    map.put("imageUrl", "");
                }
            } else {
                map.put("productName", "未知商品");
                map.put("imageUrl", "");
            }
            
            LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
            teamWrapper.eq(GroupBuyTeam::getActivityId, activity.getId())
                       .eq(GroupBuyTeam::getStatus, 0);
            long activeTeamCount = groupBuyTeamMapper.selectCount(teamWrapper);
            map.put("activeTeamCount", activeTeamCount);
            
            resultList.add(map);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultList);
        result.put("total", resultList.size());
        return result;
    }

    @Override
    public Map<String, Object> getActivityList(Long merchantId, Integer status, Integer page, Integer size) {
        Page<GroupBuyActivity> pageObj = new Page<>(page, size);
        LambdaQueryWrapper<GroupBuyActivity> wrapper = new LambdaQueryWrapper<>();
        if (merchantId != null) {
            wrapper.eq(GroupBuyActivity::getMerchantId, merchantId);
        }
        if (status != null) {
            wrapper.eq(GroupBuyActivity::getStatus, status);
        }
        wrapper.orderByDesc(GroupBuyActivity::getCreatedAt);
        
        Page<GroupBuyActivity> resultPage = groupBuyActivityMapper.selectPage(pageObj, wrapper);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", resultPage.getRecords());
        result.put("total", resultPage.getTotal());
        result.put("page", page);
        result.put("size", size);
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
        activity.setStatus(1);
        activity.setCreatedAt(LocalDateTime.now());
        activity.setUpdatedAt(LocalDateTime.now());
        groupBuyActivityMapper.insert(activity);
        
        String stockKey = GROUP_STOCK_KEY + activity.getId();
        redisUtil.set(stockKey, activity.getAvailableStock());
        
        return activity;
    }

    @Override
    @Transactional
    public GroupBuyActivity updateActivity(Long id, GroupBuyActivity activity) {
        GroupBuyActivity exist = groupBuyActivityMapper.selectById(id);
        if (exist == null) {
            return null;
        }
        if (activity.getName() != null) exist.setName(activity.getName());
        if (activity.getMerchantId() != null) exist.setMerchantId(activity.getMerchantId());
        if (activity.getProductId() != null) exist.setProductId(activity.getProductId());
        if (activity.getSkuId() != null) exist.setSkuId(activity.getSkuId());
        if (activity.getGroupPrice() != null) exist.setGroupPrice(activity.getGroupPrice());
        if (activity.getOriginalPrice() != null) exist.setOriginalPrice(activity.getOriginalPrice());
        if (activity.getRequiredNum() != null) exist.setRequiredNum(activity.getRequiredNum());
        if (activity.getTotalStock() != null) exist.setTotalStock(activity.getTotalStock());
        if (activity.getAvailableStock() != null) exist.setAvailableStock(activity.getAvailableStock());
        if (activity.getStartTime() != null) exist.setStartTime(activity.getStartTime());
        if (activity.getEndTime() != null) exist.setEndTime(activity.getEndTime());
        if (activity.getGroupDuration() != null) exist.setGroupDuration(activity.getGroupDuration());
        if (activity.getDescription() != null) exist.setDescription(activity.getDescription());
        exist.setUpdatedAt(LocalDateTime.now());
        groupBuyActivityMapper.updateById(exist);
        
        String stockKey = GROUP_STOCK_KEY + id;
        redisUtil.set(stockKey, exist.getAvailableStock());
        
        return exist;
    }

    @Override
    @Transactional
    public boolean updateActivityStatus(Long id, Integer status) {
        GroupBuyActivity activity = groupBuyActivityMapper.selectById(id);
        if (activity == null) {
            return false;
        }
        activity.setStatus(status);
        activity.setUpdatedAt(LocalDateTime.now());
        groupBuyActivityMapper.updateById(activity);
        return true;
    }

    @Override
    @Transactional
    public boolean deleteActivity(Long id) {
        GroupBuyActivity activity = groupBuyActivityMapper.selectById(id);
        if (activity == null) {
            return false;
        }
        groupBuyActivityMapper.deleteById(id);
        
        String stockKey = GROUP_STOCK_KEY + id;
        redisUtil.delete(stockKey);
        
        return true;
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
        
        LambdaQueryWrapper<GroupBuyMember> memberCheckWrapper = new LambdaQueryWrapper<>();
        memberCheckWrapper.eq(GroupBuyMember::getUserId, userId);
        List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberCheckWrapper);
        
        for (GroupBuyMember member : members) {
            GroupBuyTeam existingTeam = groupBuyTeamMapper.selectById(member.getTeamId());
            if (existingTeam != null && existingTeam.getStatus() == 0) {
                GroupBuyActivity existingActivity = groupBuyActivityMapper.selectById(existingTeam.getActivityId());
                if (existingActivity != null && existingActivity.getProductId().equals(activity.getProductId())) {
                    result.put("success", false);
                    result.put("message", "您已在该商品上发起/参与了一个未完成的拼团，请先完成或取消");
                    return result;
                }
            }
        }
        
        Product product = productMapper.selectById(activity.getProductId());
        if (product == null || product.getStock() <= 0) {
            result.put("success", false);
            result.put("message", "商品库存不足");
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
    public Map<String, Object> createTeamByProduct(Long productId, Long userId) {
        Map<String, Object> result = new HashMap<>();
        
        Product product = productMapper.selectById(productId);
        if (product == null) {
            result.put("success", false);
            result.put("message", "商品不存在");
            return result;
        }
        
        if (product.getStock() == null || product.getStock() <= 0) {
            result.put("success", false);
            result.put("message", "商品库存不足");
            return result;
        }
        
        LambdaQueryWrapper<GroupBuyMember> memberCheckWrapper = new LambdaQueryWrapper<>();
        memberCheckWrapper.eq(GroupBuyMember::getUserId, userId)
                          .eq(GroupBuyMember::getProductId, productId);
        List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberCheckWrapper);
        
        for (GroupBuyMember member : members) {
            GroupBuyTeam existingTeam = groupBuyTeamMapper.selectById(member.getTeamId());
            if (existingTeam != null && existingTeam.getStatus() == 0) {
                result.put("success", false);
                result.put("message", "您已在该商品上发起/参与了一个未完成的拼团，请先完成或取消");
                return result;
            }
        }
        
        int requiredNum = 2;
        int groupDuration = 24;
        
        GroupBuyTeam team = new GroupBuyTeam();
        team.setTeamNo("GB" + System.currentTimeMillis() + new Random().nextInt(1000));
        team.setActivityId(0L);
        team.setProductId(productId);
        team.setLeaderId(userId);
        team.setRequiredNum(requiredNum);
        team.setCurrentNum(1);
        team.setStatus(0);
        team.setExpireTime(LocalDateTime.now().plusHours(groupDuration));
        team.setCreatedAt(LocalDateTime.now());
        groupBuyTeamMapper.insert(team);
        
        GroupBuyMember member = new GroupBuyMember();
        member.setTeamId(team.getId());
        member.setProductId(productId);
        member.setUserId(userId);
        member.setIsLeader(1);
        member.setJoinTime(LocalDateTime.now());
        groupBuyMemberMapper.insert(member);

        Map<String, Object> mqBody = new HashMap<>();
        mqBody.put("teamNo", team.getTeamNo());
        mqBody.put("productId", productId);
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
    @com.shopping.common.annotation.DistributedLock(key = "'groupbuy:join:' + #teamNo + ':' + #userId", waitTime = 3, leaseTime = 10)
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
        
        Product product = productMapper.selectById(productId);
        if (product == null) {
            Map<String, Object> empty = new HashMap<>();
            empty.put("list", Collections.emptyList());
            empty.put("total", 0);
            empty.put("page", page);
            empty.put("size", size);
            return empty;
        }
        
        LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.eq(GroupBuyTeam::getProductId, productId)
                   .eq(GroupBuyTeam::getStatus, 0)
                   .orderByDesc(GroupBuyTeam::getCreatedAt);
        
        Page<GroupBuyTeam> teamPage = new Page<>(page, size);
        Page<GroupBuyTeam> resultPage = groupBuyTeamMapper.selectPage(teamPage, teamWrapper);
        
        List<GroupBuyTeam> teams = resultPage.getRecords();
        List<Map<String, Object>> teamList = new ArrayList<>();
        for (GroupBuyTeam team : teams) {
            LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
            memberWrapper.eq(GroupBuyMember::getTeamId, team.getId());
            List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
            
            List<Map<String, Object>> memberList = new ArrayList<>();
            for (GroupBuyMember member : members) {
                Map<String, Object> memberMap = new HashMap<>();
                memberMap.put("id", member.getId());
                memberMap.put("teamId", member.getTeamId());
                memberMap.put("userId", member.getUserId());
                memberMap.put("orderNo", member.getOrderNo());
                memberMap.put("isLeader", member.getIsLeader());
                memberMap.put("joinTime", member.getJoinTime());
                
                User user = userMapper.selectById(member.getUserId());
                if (user != null) {
                    memberMap.put("nickname", user.getNickname());
                    memberMap.put("userName", user.getUsername());
                    memberMap.put("avatar", user.getAvatar());
                }
                
                memberList.add(memberMap);
            }
            
            Map<String, Object> teamMap = new HashMap<>();
            teamMap.put("team", team);
            teamMap.put("members", memberList);
            teamMap.put("groupPrice", product.getGroupPrice());
            teamMap.put("groupNum", product.getGroupNum());
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
