package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class AdminCreateClubRequest {

    @NotBlank(message = "동아리명은 필수입니다.")
    private String name;

    private String logoUrl;

    private String introduction;
}
