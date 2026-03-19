package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.NoShowReportStatus;
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
public class NoShowReportResponse {
    private UUID id;
    private UUID matchId;
    private String reporterNickname;
    private Long reportedUserId;
    private String reportedUserNickname;
    private NoShowReportStatus status;
    private LocalDateTime createdAt;
}
