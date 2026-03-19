package com.pnu.basketball.dto.request;

import com.pnu.basketball.domain.RecruitmentGameFormat;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@NoArgsConstructor
public class RecruitmentCreateRequest {

    @NotNull(message = "경기 시작 시각은 필수입니다.")
    private LocalDateTime startAt;

    @NotNull(message = "경기 종료 시각은 필수입니다.")
    private LocalDateTime endAt;

    @NotNull(message = "장소는 필수입니다.")
    private UUID locationId;

    @NotNull(message = "기본 인원 수는 필수입니다.")
    @Min(value = 1, message = "기본 인원은 1명 이상이어야 합니다.")
    private Integer baseMembersCount;

    @NotNull(message = "모집 인원은 필수입니다.")
    @Min(value = 1, message = "모집 인원은 1명 이상이어야 합니다.")
    private Integer neededMembers;

    @NotNull(message = "경기 형태는 필수입니다.")
    private RecruitmentGameFormat gameFormat;

    private LocalDateTime deadlineAt;
}
