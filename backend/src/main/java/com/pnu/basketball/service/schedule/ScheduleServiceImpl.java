package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.Schedule;
import com.pnu.basketball.domain.ScheduleLocation;
import com.pnu.basketball.domain.ScheduleStatus;
import com.pnu.basketball.dto.request.ScheduleCreateRequest;
import com.pnu.basketball.dto.request.ScheduleUpdateRequest;
import com.pnu.basketball.dto.response.ScheduleResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleServiceImpl implements ScheduleService {

    private final ScheduleRepository scheduleRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleResponse> getSchedules(LocalDate startDate, LocalDate endDate, String location) {
        List<Schedule> schedules;
        if (startDate != null && endDate != null) {
            schedules = scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocationAscStartTimeAsc(
                    startDate, endDate);
        } else if (startDate != null) {
            schedules = scheduleRepository.findByScheduleDateOrderByLocationAscStartTimeAsc(startDate);
        } else {
            LocalDate defaultStart = LocalDate.now();
            LocalDate defaultEnd = defaultStart.plusDays(13);  // 2주
            schedules = scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocationAscStartTimeAsc(
                    defaultStart, defaultEnd);
        }

        return schedules.stream()
                .filter(s -> location == null || location.isBlank() || s.getLocation().equals(location)
                        || ScheduleLocation.toDisplayName(location).equals(s.getLocation()))
                .map(ScheduleResponse::from)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ScheduleResponse getSchedule(UUID id) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));
        return ScheduleResponse.from(schedule);
    }

    @Override
    @Transactional
    public ScheduleResponse createSchedule(ScheduleCreateRequest request) {
        String location = resolveLocation(request.getLocation());
        validateLocation(location);

        if (request.getStartTime().isAfter(request.getEndTime()) || request.getStartTime().equals(request.getEndTime())) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 시간은 종료 시간보다 이전이어야 합니다.");
        }

        if (scheduleRepository.existsOverlappingForCreate(
                location, request.getScheduleDate(), request.getStartTime(), request.getEndTime())) {
            throw new CustomException(ErrorCode.SCHEDULE_OVERLAP);
        }

        ScheduleStatus status = parseStatus(request.getStatus(), ScheduleStatus.SCHEDULED);

        Schedule schedule = Schedule.builder()
                .location(location)
                .scheduleDate(request.getScheduleDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .status(status)
                .title(request.getTitle())
                .description(request.getDescription())
                .build();

        schedule = scheduleRepository.save(schedule);
        return ScheduleResponse.from(schedule);
    }

    @Override
    @Transactional
    public ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        String location = resolveLocation(request.getLocation());
        validateLocation(location);

        if (request.getStartTime().isAfter(request.getEndTime()) || request.getStartTime().equals(request.getEndTime())) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 시간은 종료 시간보다 이전이어야 합니다.");
        }

        if (scheduleRepository.existsOverlappingForUpdate(
                location, request.getScheduleDate(), request.getStartTime(), request.getEndTime(), id)) {
            throw new CustomException(ErrorCode.SCHEDULE_OVERLAP);
        }

        ScheduleStatus status = parseStatus(request.getStatus(), schedule.getStatus());

        schedule.update(location, request.getScheduleDate(), request.getStartTime(),
                request.getEndTime(), status, request.getTitle(), request.getDescription());

        return ScheduleResponse.from(schedule);
    }

    @Override
    @Transactional
    public void deleteSchedule(UUID id) {
        if (!scheduleRepository.existsById(id)) {
            throw new CustomException(ErrorCode.SCHEDULE_NOT_FOUND);
        }
        scheduleRepository.deleteById(id);
    }

    private String resolveLocation(String input) {
        if (input == null || input.isBlank()) return input;
        for (ScheduleLocation loc : ScheduleLocation.values()) {
            if (loc.name().equalsIgnoreCase(input)) {
                return loc.getDisplayName();
            }
            if (loc.getDisplayName().equals(input)) {
                return loc.getDisplayName();
            }
        }
        return input;
    }

    private void validateLocation(String location) {
        if (location == null || location.isBlank()) {
            throw new CustomException(ErrorCode.INVALID_SCHEDULE_LOCATION);
        }
        if (!ScheduleLocation.isValid(location)) {
            throw new CustomException(ErrorCode.INVALID_SCHEDULE_LOCATION);
        }
    }

    private ScheduleStatus parseStatus(String statusStr, ScheduleStatus defaultStatus) {
        if (statusStr == null || statusStr.isBlank()) return defaultStatus;
        try {
            return ScheduleStatus.valueOf(statusStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            return defaultStatus;
        }
    }
}
