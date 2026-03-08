package com.pnu.basketball.service.schedule;

import com.pnu.basketball.dto.response.ScheduleCourtSlotResponse;
import com.pnu.basketball.dto.response.ScheduleMatchResponse;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface ScheduleService {
    /**
     * 주간 동아리 코트 사용시간 조회 (해당 주의 요일별)
     * @param year 연도
     * @param week ISO 주차 (1-53)
     */
    List<ScheduleCourtSlotResponse> getCourtSlotsForWeek(int year, int week);

    /**
     * 기간 내 확정된 매칭 조회
     */
    List<ScheduleMatchResponse> getConfirmedMatches(LocalDate startDate, LocalDate endDate, UUID clubId);
}
