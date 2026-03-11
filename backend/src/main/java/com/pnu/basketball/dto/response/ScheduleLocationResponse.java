package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.ScheduleLocationEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleLocationResponse {

    private UUID id;
    private String name;
    private Integer sortOrder;

    public static ScheduleLocationResponse from(ScheduleLocationEntity entity) {
        return ScheduleLocationResponse.builder()
                .id(entity.getId())
                .name(entity.getName())
                .sortOrder(entity.getSortOrder())
                .build();
    }
}
