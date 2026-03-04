package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminSetCaptainRequest {

    @NotNull(message = "사용자 ID는 필수입니다.")
    private Long userId;
}
