package com.pnu.basketball.controller.schedule;

import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ScheduleCourtSlotResponse;
import com.pnu.basketball.dto.response.ScheduleMatchResponse;
import com.pnu.basketball.service.schedule.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/schedule")
@RequiredArgsConstructor
public class ScheduleController {

    private final ScheduleService scheduleService;

    @GetMapping("/court-slots")
    public ResponseEntity<ApiResponse<List<ScheduleCourtSlotResponse>>> getCourtSlots(
            @RequestParam int year,
            @RequestParam int week) {
        List<ScheduleCourtSlotResponse> slots = scheduleService.getCourtSlotsForWeek(year, week);
        return ResponseEntity.ok(ApiResponse.success(slots, "주간 코트 사용시간 조회 성공"));
    }

    @GetMapping("/confirmed-matches")
    public ResponseEntity<ApiResponse<List<ScheduleMatchResponse>>> getConfirmedMatches(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @RequestParam(required = false) UUID clubId) {
        List<ScheduleMatchResponse> matches = scheduleService.getConfirmedMatches(startDate, endDate, clubId);
        return ResponseEntity.ok(ApiResponse.success(matches, "확정 매칭 조회 성공"));
    }
}
