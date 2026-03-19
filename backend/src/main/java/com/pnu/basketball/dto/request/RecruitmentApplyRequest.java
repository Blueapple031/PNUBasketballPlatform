package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class RecruitmentApplyRequest {

    @Size(max = 200, message = "메시지는 200자 이내입니다.")
    private String message;
}
