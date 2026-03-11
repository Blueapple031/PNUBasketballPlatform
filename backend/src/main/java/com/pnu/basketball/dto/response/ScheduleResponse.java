package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.Schedule;
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
    private UUID locationId;
    private String locationName;
    private LocalDate scheduleDate;
    private LocalTime startTime;
    private LocalTime endTime;
    private String status;
    private String scheduleType;
    private String title;
    private String description;
    private UUID matchId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public static ScheduleResponse from(Schedule schedule) {
        return ScheduleResponse.builder()
                .id(schedule.getId())
                .locationId(schedule.getLocation().getId())
                .locationName(schedule.getLocation().getName())
                .scheduleDate(schedule.getScheduleDate())
                .startTime(schedule.getStartTime())
                .endTime(schedule.getEndTime())
                .status(schedule.getStatus().name())
                .scheduleType(schedule.getScheduleType())
                .title(schedule.getTitle())
                .description(schedule.getDescription())
                .matchId(schedule.getMatchId())
                .createdAt(schedule.getCreatedAt())
                .updatedAt(schedule.getUpdatedAt())
                .build();
    }
}
