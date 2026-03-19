package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@NoArgsConstructor
public class ClubMatchCreateRequest {

    @NotNull(message = "경기 시작 시각은 필수입니다.")
    private LocalDateTime startAt;

    @NotNull(message = "경기 종료 시각은 필수입니다.")
    private LocalDateTime endAt;

    @NotNull(message = "장소는 필수입니다.")
    private UUID locationId;

    private UUID awayClubId;
}
