package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.Schedule;
import com.pnu.basketball.dto.request.ScheduleCreateRequest;
import com.pnu.basketball.dto.request.ScheduleUpdateRequest;
import com.pnu.basketball.dto.response.ScheduleCreateResult;
import com.pnu.basketball.dto.response.ScheduleResponse;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface ScheduleService {

    List<ScheduleResponse> getSchedules(LocalDate startDate, LocalDate endDate, UUID locationId);

    ScheduleResponse getSchedule(UUID id);

    ScheduleCreateResult createSchedule(ScheduleCreateRequest request);

    ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request);

    void deleteSchedule(UUID id);
}
