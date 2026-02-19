package com.pnu.basketball.dto.request.club;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class TransferCaptainRequest {
    
    @NotNull(message = "위임받을 사용자 ID는 필수입니다.")
    private Long userId;
}

