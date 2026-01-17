package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class GoogleLoginRequest {
    
    @NotBlank(message = "ID Token은 필수입니다.")
    private String idToken;
}

