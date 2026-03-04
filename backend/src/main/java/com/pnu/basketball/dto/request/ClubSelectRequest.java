package com.pnu.basketball.dto.request;

import com.pnu.basketball.domain.ClubRole;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@NoArgsConstructor
public class ClubSelectRequest {

    @NotNull(message = "동아리 ID는 필수입니다.")
    private UUID clubId;

    /**
     * 동아리 내 역할. 미지정 시 MEMBER.
     * PRESIDENT(동아리장)는 백오피스에서만 지정 가능.
     */
    private ClubRole role;
}
