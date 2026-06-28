package com.shopping.order.admin.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.order.admin.entity.AdminRole;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface AdminRoleMapper extends BaseMapper<AdminRole> {
    @Select("SELECT role_id FROM admin_role WHERE admin_id = #{adminId}")
    List<Long> selectRoleIdsByAdminId(Long adminId);

    @Delete("DELETE FROM admin_role WHERE admin_id = #{adminId}")
    int deleteByAdminId(Long adminId);
}
