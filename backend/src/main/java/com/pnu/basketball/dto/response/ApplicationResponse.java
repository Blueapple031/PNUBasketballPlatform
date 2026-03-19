package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.ApplicationStatus;
import com.pnu.basketball.domain.Position;
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
public class ApplicationResponse {
    private UUID applicationId;
    private Long applicantId;
    private String applicantNickname;
    private Position applicantPosition;
    private Integer applicantExp;
    private Integer applicantNoShowCount;
    private Integer applicantParticipationCount;
    private ApplicationStatus status;
    private String message;
    private LocalDateTime createdAt;
}
