package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UpdatePostRequest {

    @NotBlank(message = "제목은 필수입니다.")
    @Size(min = 1, max = 200, message = "제목은 1~200자 사이여야 합니다.")
    private String title;

    @NotBlank(message = "본문은 필수입니다.")
    @Size(min = 1, message = "본문은 1자 이상이어야 합니다.")
    private String content;
}
