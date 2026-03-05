package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.MatchState;
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
public class AdminMatchListResponse {
    private UUID matchId;
    private String homeClubName;
    private String awayClubName;
    private LocalDateTime scheduledAt;
    private MatchState state;
    private Integer homeScore;
    private Integer awayScore;
}
