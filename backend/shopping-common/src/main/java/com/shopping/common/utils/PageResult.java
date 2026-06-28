package com.shopping.common.utils;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResult<T> {
    private Long total;
    private Long current;
    private Long size;
    private List<T> records;

    public static <T> PageResult<T> of(Long total, Long current, Long size, List<T> records) {
        return new PageResult<>(total, current, size, records);
    }
}
