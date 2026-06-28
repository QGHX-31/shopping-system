package com.shopping.marketing.service;

import com.shopping.common.entity.GroupBuyActivity;
import com.shopping.common.entity.GroupBuyMember;
import com.shopping.common.entity.GroupBuyTeam;

import java.util.Map;

public interface GroupBuyService {
    
    Map<String, Object> getActiveActivities();
    
    Map<String, Object> getActivityDetail(Long id);
    
    GroupBuyActivity createActivity(GroupBuyActivity activity);
    
    Map<String, Object> createTeam(Long activityId, Long userId);

    Map<String, Object> createTeamByParticipation(Long participationId, Long userId);

    Map<String, Object> joinTeam(String teamNo, Long userId);
    
    Map<String, Object> getTeamDetail(String teamNo);
    
    Map<String, Object> getActiveTeamsByProduct(Long productId, Integer page, Integer size);
    
    void checkAndCloseExpiredTeams();
    
    void checkAndCompleteTeams();
}
