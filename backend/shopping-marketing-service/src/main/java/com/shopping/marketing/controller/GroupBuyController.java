package com.shopping.marketing.controller;

import com.shopping.common.entity.GroupBuyActivity;
import com.shopping.common.entity.GroupBuyMember;
import com.shopping.common.entity.GroupBuyTeam;
import com.shopping.common.utils.Result;
import com.shopping.marketing.mapper.GroupBuyMemberMapper;
import com.shopping.marketing.mapper.GroupBuyTeamMapper;
import com.shopping.marketing.service.GroupBuyService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/group")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class GroupBuyController {

    @Resource
    private GroupBuyService groupBuyService;

    @Resource
    private GroupBuyTeamMapper groupBuyTeamMapper;

    @Resource
    private GroupBuyMemberMapper groupBuyMemberMapper;

    @GetMapping("/activity/list")
    public Result<Map<String, Object>> getActiveActivities() {
        Map<String, Object> data = groupBuyService.getActiveActivities();
        return Result.success(data);
    }

    @GetMapping("/activity/{id}")
    public Result<Map<String, Object>> getActivityDetail(@PathVariable Long id) {
        Map<String, Object> data = groupBuyService.getActivityDetail(id);
        if (data == null) {
            return Result.error("Activity not found");
        }
        return Result.success(data);
    }

    @PostMapping("/activity/create")
    public Result<GroupBuyActivity> createActivity(@RequestBody GroupBuyActivity activity) {
        GroupBuyActivity result = groupBuyService.createActivity(activity);
        return Result.success(result);
    }

    @PostMapping("/team")
    public Result<Map<String, Object>> createTeam(@RequestParam Long activityId,
                                                    @RequestParam Long userId) {
        Map<String, Object> result = groupBuyService.createTeam(activityId, userId);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @PostMapping("/team/open")
    public Result<Map<String, Object>> createTeamByParticipation(@RequestParam Long participationId,
                                                                   @RequestParam Long userId) {
        Map<String, Object> result = groupBuyService.createTeamByParticipation(participationId, userId);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @PostMapping("/join/{teamNo}")
    public Result<Map<String, Object>> joinTeam(@PathVariable String teamNo,
                                                  @RequestParam Long userId) {
        Map<String, Object> result = groupBuyService.joinTeam(teamNo, userId);
        Boolean success = (Boolean) result.get("success");
        if (success != null && !success) {
            return Result.error((String) result.get("message"));
        }
        return Result.success(result);
    }

    @GetMapping("/team/{teamNo}")
    public Result<Map<String, Object>> getTeamDetail(@PathVariable String teamNo) {
        Map<String, Object> data = groupBuyService.getTeamDetail(teamNo);
        if (data == null) {
            return Result.error("Team not found");
        }
        return Result.success(data);
    }
    
    @GetMapping("/teams/product/{productId}")
    public Result<Map<String, Object>> getActiveTeamsByProduct(
            @PathVariable Long productId,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size) {
        Map<String, Object> data = groupBuyService.getActiveTeamsByProduct(productId, page, size);
        return Result.success(data);
    }

    @GetMapping("/team/id/{teamId}")
    public Result<Map<String, Object>> getTeamById(@PathVariable Long teamId) {
        GroupBuyTeam team = groupBuyTeamMapper.selectById(teamId);
        if (team == null) {
            return Result.error("团队不存在");
        }
        LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(GroupBuyMember::getTeamId, teamId);
        List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
        Map<String, Object> result = new HashMap<>();
        result.put("team", team);
        result.put("members", members);
        return Result.success(result);
    }

    @GetMapping("/team/user/{userId}")
    public Result<Map<String, Object>> getTeamsByUser(@PathVariable Long userId) {
        LambdaQueryWrapper<GroupBuyMember> memberWrapper = new LambdaQueryWrapper<>();
        memberWrapper.eq(GroupBuyMember::getUserId, userId);
        List<GroupBuyMember> members = groupBuyMemberMapper.selectList(memberWrapper);
        
        Map<String, Object> result = new HashMap<>();
        if (members.isEmpty()) {
            result.put("teams", Collections.emptyList());
            return Result.success(result);
        }
        
        List<Long> teamIds = members.stream().map(GroupBuyMember::getTeamId).distinct().toList();
        LambdaQueryWrapper<GroupBuyTeam> teamWrapper = new LambdaQueryWrapper<>();
        teamWrapper.in(GroupBuyTeam::getId, teamIds);
        List<GroupBuyTeam> teams = groupBuyTeamMapper.selectList(teamWrapper);
        
        result.put("teams", teams);
        return Result.success(result);
    }

    @PostMapping("/team/cancel")
    public Result<Void> cancelTeam(@RequestParam Long teamId) {
        GroupBuyTeam team = groupBuyTeamMapper.selectById(teamId);
        if (team == null) {
            return Result.error("团队不存在");
        }
        if (team.getStatus() != 0) {
            return Result.error("只有拼团中的团队可以取消");
        }
        
        team.setStatus(2);
        groupBuyTeamMapper.updateById(team);
        
        return Result.success();
    }
}
