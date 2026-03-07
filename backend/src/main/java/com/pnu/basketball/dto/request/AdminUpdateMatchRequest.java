package com.pnu.basketball.dto.request;

import com.pnu.basketball.domain.MatchState;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminUpdateMatchRequest {

    private MatchState state;
    private Integer homeScore;
    private Integer awayScore;
}
