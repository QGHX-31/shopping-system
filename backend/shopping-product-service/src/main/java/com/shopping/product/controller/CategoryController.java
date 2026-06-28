package com.shopping.product.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.common.entity.Category;
import com.shopping.common.utils.Result;
import com.shopping.product.mapper.CategoryMapper;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/category")
@CrossOrigin(originPatterns = "*", allowCredentials = "true")
public class CategoryController {

    @Resource
    private CategoryMapper categoryMapper;

    @GetMapping("/list")
    public Result<List<Category>> getCategoryList() {
        List<Category> list = categoryMapper.selectList(null);
        return Result.success(list);
    }

    @GetMapping("/tree")
    public Result<List<Map<String, Object>>> getCategoryTree() {
        List<Category> allCategories = categoryMapper.selectList(null);

        Map<Long, List<Category>> childrenMap = new HashMap<>();
        List<Category> rootCategories = new ArrayList<>();

        for (Category category : allCategories) {
            if (category.getParentId() == null || category.getParentId() == 0) {
                rootCategories.add(category);
            } else {
                childrenMap.computeIfAbsent(category.getParentId(), k -> new ArrayList<>()).add(category);
            }
        }

        List<Map<String, Object>> tree = buildTree(rootCategories, childrenMap);
        return Result.success(tree);
    }

    private List<Map<String, Object>> buildTree(List<Category> categories, Map<Long, List<Category>> childrenMap) {
        return categories.stream().map(category -> {
            Map<String, Object> node = new HashMap<>();
            node.put("id", category.getId());
            node.put("name", category.getName());
            node.put("parentId", category.getParentId());
            node.put("sortOrder", category.getSortOrder());

            List<Category> children = childrenMap.get(category.getId());
            if (children != null && !children.isEmpty()) {
                node.put("children", buildTree(children, childrenMap));
            }
            return node;
        }).collect(Collectors.toList());
    }

    @GetMapping("/{id}")
    public Result<Category> getCategory(@PathVariable Long id) {
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            return Result.error("Category not found");
        }
        return Result.success(category);
    }

    @PostMapping("/create")
    public Result<Category> createCategory(@RequestBody Category category) {
        categoryMapper.insert(category);
        return Result.success(category);
    }

    @PutMapping("/update")
    public Result<Category> updateCategory(@RequestBody Category category) {
        categoryMapper.updateById(category);
        Category updated = categoryMapper.selectById(category.getId());
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    public Result<Boolean> deleteCategory(@PathVariable Long id) {
        int rows = categoryMapper.deleteById(id);
        return Result.success(rows > 0);
    }
}
