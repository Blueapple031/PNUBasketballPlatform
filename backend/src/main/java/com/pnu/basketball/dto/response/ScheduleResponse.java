package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.Schedule;
import com.pnu.basketball.domain.ScheduleStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ScheduleResponse {

    private UUID id;
    private String location;
    private LocalDate scheduleDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;
    private String title;
    private String description;
    private UUID matchId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ScheduleResponse from(Schedule schedule) {
        return ScheduleResponse.builder()
                .id(schedule.getId())
                .location(schedule.getLocation())
                .scheduleDate(schedule.getScheduleDate())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .status(schedule.getStatus().name())
                .title(schedule.getTitle())
                .description(schedule.getDescription())
                .matchId(schedule.getMatchId())
                .createdAt(schedule.getCreatedAt())
                .updatedAt(schedule.getUpdatedAt())
                .build();
    }
}
