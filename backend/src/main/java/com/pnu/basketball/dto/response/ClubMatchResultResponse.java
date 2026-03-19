package com.pnu.basketball.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClubMatchResultResponse {
    private UUID id;
    private UUID requestId;
    private String homeClubName;
    private String awayClubName;
    private Integer homeScore;
    private Integer awayScore;
    private Boolean homeApproved;
    private Boolean awayApproved;
    private Boolean adminApproved;
}
