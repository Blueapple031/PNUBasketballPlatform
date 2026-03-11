package com.pnu.basketball.controller.schedule;

import com.pnu.basketball.domain.ScheduleLocation;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ScheduleResponse;
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
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/schedules")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSchedules(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) String location) {
        List<ScheduleResponse> schedules = scheduleService.getSchedules(startDate, endDate, location);

        Map<String, Object> data = new HashMap<>();
        data.put("schedules", schedules);
        data.put("locations", java.util.Arrays.stream(ScheduleLocation.values())
                .map(loc -> Map.of("id", loc.name(), "displayName", loc.getDisplayName()))
                .collect(Collectors.toList()));

        return ResponseEntity.ok(ApiResponse.success(data, "일정 조회 성공"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ScheduleResponse>> getSchedule(@PathVariable UUID id) {
        ScheduleResponse schedule = scheduleService.getSchedule(id);
        return ResponseEntity.ok(ApiResponse.success(schedule, "일정 조회 성공"));
    }
}
