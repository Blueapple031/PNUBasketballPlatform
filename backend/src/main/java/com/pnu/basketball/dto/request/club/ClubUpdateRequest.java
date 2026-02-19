package com.pnu.basketball.dto.request.club;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ClubUpdateRequest {
    
    @Size(max = 100, message = "동아리 이름은 100자를 초과할 수 없습니다.")
    private String name;
    
    @Size(max = 500, message = "로고 URL은 500자를 초과할 수 없습니다.")
    private String logoUrl;
    
    private String description;
}

