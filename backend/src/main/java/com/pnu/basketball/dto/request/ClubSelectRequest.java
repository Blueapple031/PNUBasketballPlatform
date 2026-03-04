package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Getter
@NoArgsConstructor
public class ClubSelectRequest {

    @NotNull(message = "동아리 ID는 필수입니다.")
    private UUID clubId;
}
