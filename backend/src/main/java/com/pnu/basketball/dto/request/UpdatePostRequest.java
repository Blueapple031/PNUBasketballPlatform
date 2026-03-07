package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class UpdatePostRequest {

    @Size(max = 200)
    private String title;

    private String content;
}
