package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClubCourtSlotUpdateRequest {

    @Min(0)
    @Max(6)
    private Integer dayOfWeek;

    private LocalTime startTime;

    private LocalTime endTime;
}
