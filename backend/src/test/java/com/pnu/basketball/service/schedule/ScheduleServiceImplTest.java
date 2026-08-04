package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.Schedule;
import com.pnu.basketball.domain.ScheduleLocationEntity;
import com.pnu.basketball.domain.ScheduleStatus;
import com.pnu.basketball.dto.request.ScheduleCreateRequest;
import com.pnu.basketball.dto.response.ScheduleCreateResult;
import com.pnu.basketball.dto.response.ScheduleResponse;
import com.pnu.basketball.repository.ScheduleLocationRepository;
import com.pnu.basketball.repository.ScheduleRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ScheduleServiceImplTest {

    @Mock
    private ScheduleRepository scheduleRepository;

    @Mock
    private ScheduleLocationRepository locationRepository;

    @InjectMocks
    private ScheduleServiceImpl scheduleService;

    @Test
    void trainingIsStoredAsOneIndefiniteRecurringRule() {
        UUID locationId = UUID.randomUUID();
        ScheduleLocationEntity location = location(locationId);
        ScheduleCreateRequest request = ScheduleCreateRequest.builder()
                .locationId(locationId)
                .scheduleDate(LocalDate.of(2026, 8, 3))
                .startTime(LocalTime.of(18, 0))
                .endTime(LocalTime.of(20, 0))
                .status("SCHEDULED")
                .scheduleType("TRAINING")
                .title("정기 훈련")
                .build();

        when(locationRepository.findById(locationId)).thenReturn(Optional.of(location));
        when(scheduleRepository.existsOverlappingForWeeklyRecurrence(
                locationId, request.getScheduleDate(), request.getStartTime(), request.getEndTime(), null))
                .thenReturn(false);
        when(scheduleRepository.save(any(Schedule.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ScheduleCreateResult result = scheduleService.createSchedule(request);

        ArgumentCaptor<Schedule> scheduleCaptor = ArgumentCaptor.forClass(Schedule.class);
        verify(scheduleRepository).save(scheduleCaptor.capture());
        verify(scheduleRepository, never()).existsOverlappingForCreate(any(), any(), any(), any());
        assertThat(scheduleCaptor.getValue().isRecurring()).isTrue();
        assertThat(scheduleCaptor.getValue().getScheduleType()).isEqualTo("TRAINING");
        assertThat(result.getCreatedCount()).isEqualTo(1);
        assertThat(result.getSchedule().isRecurring()).isTrue();
    }

    @Test
    void recurringRuleIsExpandedBeyondTwelveWeeks() {
        UUID locationId = UUID.randomUUID();
        Schedule recurring = Schedule.builder()
                .id(UUID.randomUUID())
                .location(location(locationId))
                .scheduleDate(LocalDate.of(2026, 1, 5))
                .startTime(LocalTime.of(18, 0))
                .endTime(LocalTime.of(20, 0))
                .status(ScheduleStatus.SCHEDULED)
                .scheduleType("TRAINING")
                .recurring(true)
                .title("정기 훈련")
                .build();

        LocalDate startDate = LocalDate.of(2026, 4, 1);
        LocalDate endDate = LocalDate.of(2026, 4, 14);
        when(scheduleRepository.findByScheduleDateBetweenOrderByScheduleDateAscLocation_NameAscStartTimeAsc(
                startDate, endDate)).thenReturn(List.of());
        when(scheduleRepository.findByRecurringTrueAndScheduleDateLessThanEqual(endDate))
                .thenReturn(List.of(recurring));

        List<ScheduleResponse> result = scheduleService.getSchedules(startDate, endDate, null);

        assertThat(result).extracting(ScheduleResponse::getScheduleDate)
                .containsExactly(LocalDate.of(2026, 4, 6), LocalDate.of(2026, 4, 13));
        assertThat(result).allMatch(ScheduleResponse::isRecurring);
    }

    private ScheduleLocationEntity location(UUID id) {
        return ScheduleLocationEntity.builder()
                .id(id)
                .name("체육관")
                .sortOrder(1)
                .build();
    }
}
