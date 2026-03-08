package com.pnu.basketball.dto.response;

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
public class ScheduleCourtSlotResponse {
    private UUID id;
    private UUID clubId;
    private String clubName;
    private UUID venueId;
    private String venueName;
    private int dayOfWeek;
    private LocalTime startTime;
    private LocalTime endTime;
}
