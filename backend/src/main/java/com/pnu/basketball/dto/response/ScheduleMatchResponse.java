package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.GameFormat;
import com.pnu.basketball.domain.MatchPurpose;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleMatchResponse {
    private UUID id;
    private String homeClubName;
    private String awayClubName;
    private String venueName;
    private LocalDateTime scheduledAt;
    private LocalDateTime endAt;
    private GameFormat gameFormat;
    private MatchPurpose matchPurpose;
}
