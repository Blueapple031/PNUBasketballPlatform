package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.RecruitmentGameFormat;
import com.pnu.basketball.domain.RecruitmentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RecruitmentDetailResponse {
    private UUID id;
    private Long authorId;
    private String authorNickname;
    private LocalDateTime startAt;
    private LocalDateTime endAt;
    private UUID locationId;
    private String locationName;
    private Integer baseMembersCount;
    private Integer neededMembers;
    private Long acceptedCount;
    private RecruitmentGameFormat gameFormat;
    private RecruitmentStatus status;
    private LocalDateTime deadlineAt;
    private LocalDateTime createdAt;
    private boolean isFull;
    private List<ApplicationResponse> applications;
}
