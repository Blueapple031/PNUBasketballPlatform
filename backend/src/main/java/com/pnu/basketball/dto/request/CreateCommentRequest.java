package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CreateCommentRequest {

    @NotBlank(message = "답글 내용은 필수입니다.")
    @Size(min = 1, max = 1000, message = "답글 내용은 1~1000자 사이여야 합니다.")
    private String content;
}
