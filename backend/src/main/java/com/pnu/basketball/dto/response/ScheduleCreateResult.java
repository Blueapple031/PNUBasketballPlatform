package com.pnu.basketball.dto.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleCreateResult {
    private ScheduleResponse schedule;
    private int createdCount;

    public static ScheduleCreateResult single(ScheduleResponse schedule) {
        return new ScheduleCreateResult(schedule, 1);
    }

    public static ScheduleCreateResult multiple(ScheduleResponse first, int count) {
        return new ScheduleCreateResult(first, count);
    }
}
