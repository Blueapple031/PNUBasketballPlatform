package com.pnu.basketball.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
public class PollCreateRequest {

    @NotBlank(message = "투표 질문을 입력해주세요.")
    @Size(max = 500)
    private String question;

    @Size(min = 2, max = 10, message = "선택지는 2~10개여야 합니다.")
    private List<String> options;

    private LocalDateTime expiresAt;
}
