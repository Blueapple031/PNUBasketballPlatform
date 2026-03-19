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
import java.util.ArrayList;
import java.util.List;
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
        List<Schedule> schedules;
        boolean hasLocationFilter = locationIds != null && !locationIds.isEmpty();

        if (startDate != null && endDate != null) {
            if (hasLocationFilter) {
                schedules = scheduleRepository.findByLocationIdInAndScheduleDateBetweenOrderByScheduleDateAscStartTimeAsc(
                        locationIds, startDate, endDate);
            } else {
                schedules = scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocation_NameAscStartTimeAsc(
                        startDate, endDate);
            }
        } else if (startDate != null) {
            schedules = scheduleRepository.findByScheduleDateOrderByLocation_NameAscStartTimeAsc(startDate);
            if (hasLocationFilter) {
                schedules = schedules.stream()
                        .filter(s -> locationIds.contains(s.getLocation().getId()))
                        .collect(Collectors.toList());
            }
        } else {
            LocalDate defaultStart = LocalDate.now();
            LocalDate defaultEnd = defaultStart.plusDays(13);
            if (hasLocationFilter) {
                schedules = scheduleRepository.findByLocationIdInAndScheduleDateBetweenOrderByScheduleDateAscStartTimeAsc(
                        locationIds, defaultStart, defaultEnd);
            } else {
                schedules = scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocation_NameAscStartTimeAsc(
                        defaultStart, defaultEnd);
            }
        }

        return schedules.stream().map(ScheduleResponse::from).collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ScheduleResponse getSchedule(UUID id) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));
        return ScheduleResponse.from(schedule);
    }

    private static final int TRAINING_WEEKS = 12;

    @Override
    @Transactional
    public ScheduleCreateResult createSchedule(ScheduleCreateRequest request) {
        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        if (request.getStartTime().isAfter(request.getEndTime()) || request.getStartTime().equals(request.getEndTime())) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 시간은 종료 시간보다 이전이어야 합니다.");
        }

        boolean isTraining = "TRAINING".equalsIgnoreCase(request.getScheduleType());

        if (isTraining) {
            return createTrainingSchedules(request, location);
        }

        if (scheduleRepository.existsOverlappingForCreate(
                request.getLocationId(), request.getScheduleDate(), request.getStartTime(), request.getEndTime())) {
            throw new CustomException(ErrorCode.SCHEDULE_OVERLAP);
        }

        ScheduleStatus status = parseStatus(request.getStatus(), ScheduleStatus.SCHEDULED);
        String scheduleType = parseScheduleType(request.getScheduleType());

        Schedule schedule = Schedule.builder()
                .location(location)
                .scheduleDate(request.getScheduleDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .status(status)
                .scheduleType(scheduleType)
                .title(request.getTitle())
                .description(request.getDescription())
                .build();

        schedule = scheduleRepository.save(schedule);
        return ScheduleCreateResult.single(ScheduleResponse.from(schedule));
    }

    private ScheduleCreateResult createTrainingSchedules(ScheduleCreateRequest request, ScheduleLocationEntity location) {
        ScheduleStatus status = parseStatus(request.getStatus(), ScheduleStatus.SCHEDULED);
        LocalDate baseDate = request.getScheduleDate();

        List<Schedule> created = new ArrayList<>();
        for (int week = 0; week < TRAINING_WEEKS; week++) {
            LocalDate scheduleDate = baseDate.plusWeeks(week);
            if (scheduleRepository.existsOverlappingForCreate(
                    request.getLocationId(), scheduleDate, request.getStartTime(), request.getEndTime())) {
                throw new CustomException(ErrorCode.SCHEDULE_OVERLAP,
                        scheduleDate + " 해당 날짜·시간대에 이미 일정이 있습니다. 다른 날짜를 선택하거나 기존 일정을 확인해 주세요.");
            }
            Schedule schedule = Schedule.builder()
                    .location(location)
                    .scheduleDate(scheduleDate)
                    .startTime(request.getStartTime())
                    .endTime(request.getEndTime())
                    .status(status)
                    .scheduleType("TRAINING")
                    .title(request.getTitle())
                    .description(request.getDescription())
                    .build();
            created.add(scheduleRepository.save(schedule));
        }
        return ScheduleCreateResult.multiple(ScheduleResponse.from(created.get(0)), created.size());
    }

    private String parseScheduleType(String type) {
        if (type == null || type.isBlank()) return "REGULAR";
        return "TRAINING".equalsIgnoreCase(type) ? "TRAINING" : "REGULAR";
    }

    @Override
    @Transactional
    public ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request) {
        Schedule schedule = scheduleRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_NOT_FOUND));

        ScheduleLocationEntity location = locationRepository.findById(request.getLocationId())
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        if (request.getStartTime().isAfter(request.getEndTime()) || request.getStartTime().equals(request.getEndTime())) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "시작 시간은 종료 시간보다 이전이어야 합니다.");
        }

        if (scheduleRepository.existsOverlappingForUpdate(
                request.getLocationId(), request.getScheduleDate(), request.getStartTime(), request.getEndTime(), id)) {
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

    private ScheduleStatus parseStatus(String statusStr, ScheduleStatus defaultStatus) {
        if (statusStr == null || statusStr.isBlank()) return defaultStatus;
        try {
            return ScheduleStatus.valueOf(statusStr.toUpperCase());
        } catch (IllegalArgumentException e) {
            return defaultStatus;
        }
    }
}
