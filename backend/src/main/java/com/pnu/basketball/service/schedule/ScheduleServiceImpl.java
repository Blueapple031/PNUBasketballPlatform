package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.Match;
import com.pnu.basketball.domain.MatchState;
import com.pnu.basketball.dto.response.ScheduleCourtSlotResponse;
import com.pnu.basketball.dto.response.ScheduleMatchResponse;
import com.pnu.basketball.repository.ClubCourtSlotRepository;
import com.pnu.basketball.repository.MatchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.WeekFields;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleServiceImpl implements ScheduleService {

    private final ClubCourtSlotRepository clubCourtSlotRepository;
    private final MatchRepository matchRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleCourtSlotResponse> getCourtSlotsForWeek(int year, int week) {
        List<ScheduleCourtSlotResponse> result = new ArrayList<>();
        WeekFields weekFields = WeekFields.ISO;

        for (int day = 0; day < 7; day++) {
            int dayOfWeek = day;
            clubCourtSlotRepository.findByDayOfWeekOrderByStartTimeAsc(dayOfWeek).stream()
                    .map(slot -> ScheduleCourtSlotResponse.builder()
                            .id(slot.getId())
                            .clubId(slot.getClub().getId())
                            .clubName(slot.getClub().getName())
                            .venueId(slot.getVenue().getId())
                            .venueName(slot.getVenue().getName())
                            .dayOfWeek(slot.getDayOfWeek())
                            .startTime(slot.getStartTime())
                            .endTime(slot.getEndTime())
                            .build())
                    .forEach(result::add);
        }
        return result;
    }

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleMatchResponse> getConfirmedMatches(LocalDate startDate, LocalDate endDate, UUID clubId) {
        LocalDateTime start = startDate.atStartOfDay();
        LocalDateTime end = endDate.plusDays(1).atStartOfDay();

        List<Match> matches = matchRepository.findByStateAndScheduledAtBetweenOrderByScheduledAtAsc(
                MatchState.CONFIRMED, start, end);

        if (clubId != null) {
            matches = matches.stream()
                    .filter(m -> (m.getHomeClub() != null && m.getHomeClub().getId().equals(clubId))
                            || (m.getAwayClub() != null && m.getAwayClub().getId().equals(clubId)))
                    .collect(Collectors.toList());
        }

        return matches.stream()
                .map(this::toScheduleMatchResponse)
                .collect(Collectors.toList());
    }

    private ScheduleMatchResponse toScheduleMatchResponse(Match match) {
        String homeName = match.getHomeClub() != null ? match.getHomeClub().getName() : "픽업";
        String awayName = match.getAwayClub() != null ? match.getAwayClub().getName() : "픽업";
        String venueName = match.getVenue() != null ? match.getVenue().getName() : "-";

        return ScheduleMatchResponse.builder()
                .id(match.getId())
                .homeClubName(homeName)
                .awayClubName(awayName)
                .venueName(venueName)
                .scheduledAt(match.getScheduledAt())
                .endAt(match.getEndAt())
                .gameFormat(match.getGameFormat())
                .matchPurpose(match.getMatchPurpose())
                .build();
    }
}
