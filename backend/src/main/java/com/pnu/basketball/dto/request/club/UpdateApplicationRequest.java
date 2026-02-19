package com.pnu.basketball.dto.request.club;

import com.pnu.basketball.domain.ClubMemberStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UpdateApplicationRequest {
    
    @NotNull(message = "상태는 필수입니다.")
    private ClubMemberStatus status;
}

