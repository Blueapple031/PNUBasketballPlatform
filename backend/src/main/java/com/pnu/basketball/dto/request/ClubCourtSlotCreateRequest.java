package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClubCourtSlotCreateRequest {

    @NotNull(message = "경기장 ID는 필수입니다.")
    private UUID venueId;

    @NotNull(message = "요일은 필수입니다.")
    @Min(0)
    @Max(6)
    private Integer dayOfWeek;  // 0=일요일, 1=월요일, ..., 6=토요일

    @NotNull(message = "시작 시간은 필수입니다.")
    private LocalTime startTime;

    @NotNull(message = "종료 시간은 필수입니다.")
    private LocalTime endTime;
}
