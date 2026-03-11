package com.pnu.basketball.service.schedule;

import com.pnu.basketball.dto.request.ScheduleLocationCreateRequest;
import com.pnu.basketball.dto.request.ScheduleLocationUpdateRequest;
import com.pnu.basketball.dto.response.ScheduleLocationResponse;

import java.util.List;
import java.util.UUID;

public interface ScheduleLocationService {

    List<ScheduleLocationResponse> getAllLocations();

    ScheduleLocationResponse getLocation(UUID id);

    ScheduleLocationResponse createLocation(ScheduleLocationCreateRequest request);

    ScheduleLocationResponse updateLocation(UUID id, ScheduleLocationUpdateRequest request);

    void deleteLocation(UUID id);
}
