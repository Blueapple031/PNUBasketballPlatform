package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.MatchSourceType;
import com.pnu.basketball.domain.RecruitmentGameFormat;
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
public class MatchResponse {
    private UUID id;
    private MatchSourceType sourceType;
    private UUID recruitmentId;
    private String locationName;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private RecruitmentGameFormat gameFormat;
    private LocalDateTime createdAt;
}
