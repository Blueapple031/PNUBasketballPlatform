package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class RefreshTokenRequest {
    
    @NotBlank(message = "Refresh Token은 필수입니다.")
    private String refreshToken;
}

