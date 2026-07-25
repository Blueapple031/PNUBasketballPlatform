package com.pnu.basketball.controller.schedule;

import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ScheduleLocationResponse;
import com.pnu.basketball.dto.response.ScheduleResponse;
import com.pnu.basketball.service.schedule.ScheduleLocationService;
import com.pnu.basketball.service.schedule.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;
    private final ScheduleLocationService locationService;

    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSchedules(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) List<UUID> locationIds,
            @RequestParam(required = false) UUID locationId) {
        // locationIds(복수) 또는 locationId(단일) 지원
        List<UUID> effectiveIds = (locationIds != null && !locationIds.isEmpty())
                ? locationIds
                : (locationId != null ? List.of(locationId) : null);
        List<ScheduleResponse> schedules = scheduleService.getSchedules(startDate, endDate, effectiveIds);
        List<ScheduleLocationResponse> locations = locationService.getAllLocations();

        Map<String, Object> data = new HashMap<>();
        data.put("schedules", schedules);
        data.put("locations", locations.stream()
                .map(loc -> Map.<String, Object>of(
                        "id", loc.getId().toString(),
                        "name", loc.getName(),
                        "sortOrder", loc.getSortOrder() != null ? loc.getSortOrder() : 0))
                .toList());

        return ResponseEntity.ok(ApiResponse.success(data, "일정 조회 성공"));
    }

    @GetMapping("/locations")
    public ResponseEntity<ApiResponse<List<ScheduleLocationResponse>>> getLocations() {
        List<ScheduleLocationResponse> locations = locationService.getAllLocations();
        return ResponseEntity.ok(ApiResponse.success(locations, "매칭 장소 목록 조회 성공"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ScheduleResponse>> getSchedule(@PathVariable UUID id) {
        ScheduleResponse schedule = scheduleService.getSchedule(id);
        return ResponseEntity.ok(ApiResponse.success(schedule, "일정 조회 성공"));
    }
}
