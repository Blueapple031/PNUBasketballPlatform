package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleLocationUpdateRequest {

    @NotBlank(message = "장소명은 필수입니다.")
    private String name;

    private Integer sortOrder;
}
