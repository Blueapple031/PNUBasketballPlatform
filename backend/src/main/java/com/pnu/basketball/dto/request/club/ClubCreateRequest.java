package com.pnu.basketball.dto.request.club;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ClubCreateRequest {
    @NotBlank(message = "동아리 이름은 필수입니다.")
    private String name;
    
    private String logoUrl;
}

