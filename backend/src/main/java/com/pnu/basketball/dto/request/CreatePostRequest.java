package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CreatePostRequest {

    @NotBlank(message = "제목을 입력해주세요.")
    @Size(max = 200)
    private String title;

    @NotBlank(message = "내용을 입력해주세요.")
    private String content;
}
