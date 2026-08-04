package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.Schedule;
import com.pnu.basketball.domain.ScheduleLocationEntity;
import com.pnu.basketball.domain.ScheduleStatus;
import com.pnu.basketball.dto.request.ScheduleCreateRequest;
import com.pnu.basketball.dto.request.ScheduleUpdateRequest;
import com.pnu.basketball.dto.response.ScheduleCreateResult;
import com.pnu.basketball.dto.response.ScheduleResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ScheduleLocationRepository;
import com.pnu.basketball.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleServiceImpl implements ScheduleService {

    private final ScheduleRepository scheduleRepository;
    private final ScheduleLocationRepository locationRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleResponse> getSchedules(LocalDate startDate, LocalDate endDate, List<UUID> locationIds) {
        LocalDate effectiveStart;
        LocalDate effectiveEnd;
        if (startDate != null && endDate != null) {
            effectiveStart = startDate;
            effectiveEnd = endDate;
        } else if (startDate != null) {
            effectiveStart = startDate;
            effectiveEnd = startDate;
        } else {
            effectiveStart = LocalDate.now();
            effectiveEnd = effectiveStart.plusDays(13);
        }

        if (effectiveStart.isAfter(effectiveEnd)) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 날짜는 종료 날짜보다 늦을 수 없습니다.");
        }

        boolean hasLocationFilter = locationIds != null && !locationIds.isEmpty();
        List<Schedule> datedSchedules = hasLocationFilter
                ? scheduleRepository.findByLocationIdInAndScheduleDateBetweenOrderByScheduleDateAscStartTimeAsc(
                        locationIds, effectiveStart, effectiveEnd)
                : scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocation_NameAscStartTimeAsc(
                        effectiveStart, effectiveEnd);

        List<Schedule> recurringSchedules = hasLocationFilter
                ? scheduleRepository.findByRecurringTrueAndLocationIdInAndScheduleDateLessThanEqual(
                        locationIds, effectiveEnd)
                : scheduleRepository.findByRecurringTrueAndScheduleDateLessThanEqual(effectiveEnd);

        Map<UUID, Schedule> uniqueSchedules = new LinkedHashMap<>();
        datedSchedules.forEach(schedule -> uniqueSchedules.put(schedule.getId(), schedule));
        recurringSchedules.forEach(schedule -> uniqueSchedules.put(schedule.getId(), schedule));

        LocalDate rangeStart = effectiveStart;
        LocalDate rangeEnd = effectiveEnd;
        return uniqueSchedules.values().stream()
                .flatMap(schedule -> expandSchedule(schedule, rangeStart, rangeEnd).stream())
                .sorted(Comparator.comparing(ScheduleResponse::getScheduleDate)
                        .thenComparing(ScheduleResponse::getLocationName)
                        .thenComparing(ScheduleResponse::getStartTime))
                .collect(Collectors.toList());
    }

    private List<ScheduleResponse> expandSchedule(Schedule schedule, LocalDate startDate, LocalDate endDate) {
        if (!schedule.isRecurring()) {
            return List.of(ScheduleResponse.from(schedule));
        }

        LocalDate occurrence = schedule.getScheduleDate();
        if (occurrence.isBefore(startDate)) {
            long daysFromFirst = ChronoUnit.DAYS.between(occurrence, startDate);
            occurrence = occurrence.plusWeeks((daysFromFirst + 6) / 7);
        }

        List<ScheduleResponse> occurrences = new ArrayList<>();
        while (!occurrence.isAfter(endDate)) {
            occurrences.add(ScheduleResponse.occurrence(schedule, occurrence));
            occurrence = occurrence.plusWeeks(1);
        }
        return occurrences;
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
    public ScheduleCreateResult createSchedule(ScheduleCreateRequest request) {
        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        validateTimeRange(request.getStartTime(), request.getEndTime());

        if ("TRAINING".equalsIgnoreCase(request.getScheduleType())) {
            return createRecurringTraining(request, location);
        }

        if (scheduleRepository.existsOverlappingForCreate(
                request.getLocationId(), request.getScheduleDate(), request.getStartTime(), request.getEndTime())) {
            throw new CustomException(ErrorCode.SCHEDULE_OVERLAP);
        }

        Schedule schedule = Schedule.builder()
                .location(location)
                .scheduleDate(request.getScheduleDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .status(parseStatus(request.getStatus(), ScheduleStatus.SCHEDULED))
                .scheduleType(parseScheduleType(request.getScheduleType()))
                .recurring(false)
                .title(request.getTitle())
                .description(request.getDescription())
                .build();

        schedule = scheduleRepository.save(schedule);
        return ScheduleCreateResult.single(ScheduleResponse.from(schedule));
    }

    private ScheduleCreateResult createRecurringTraining(
            ScheduleCreateRequest request, ScheduleLocationEntity location) {
        if (scheduleRepository.existsOverlappingForWeeklyRecurrence(
                request.getLocationId(), request.getScheduleDate(), request.getStartTime(), request.getEndTime(), null)) {
            throw new CustomException(ErrorCode.SCHEDULE_OVERLAP,
                    "같은 요일과 시간대에 겹치는 일정이 있습니다. 기존 일정을 확인해 주세요.");
        }

        Schedule schedule = Schedule.builder()
                .location(location)
                .scheduleDate(request.getScheduleDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .status(parseStatus(request.getStatus(), ScheduleStatus.SCHEDULED))
                .scheduleType("TRAINING")
                .recurring(true)
                .title(request.getTitle())
                .description(request.getDescription())
                .build();

        schedule = scheduleRepository.save(schedule);
        return ScheduleCreateResult.single(ScheduleResponse.from(schedule));
    }

    @Override
    @Transactional
    public ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));
        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        validateTimeRange(request.getStartTime(), request.getEndTime());

        boolean overlaps = schedule.isRecurring()
                ? scheduleRepository.existsOverlappingForWeeklyRecurrence(
                        request.getLocationId(), request.getScheduleDate(),
                        request.getStartTime(), request.getEndTime(), id)
                : scheduleRepository.existsOverlappingForUpdate(
                        request.getLocationId(), request.getScheduleDate(),
                        request.getStartTime(), request.getEndTime(), id);
        if (overlaps) {
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

    private void validateTimeRange(java.time.LocalTime startTime, java.time.LocalTime endTime) {
        if (!startTime.isBefore(endTime)) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 시간은 종료 시간보다 이전이어야 합니다.");
        }
    }

    private String parseScheduleType(String type) {
        if (type == null || type.isBlank()) return "REGULAR";
        return "TRAINING".equalsIgnoreCase(type) ? "TRAINING" : "REGULAR";
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
