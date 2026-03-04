package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@NoArgsConstructor
public class CompleteProfileRequest {

    @Size(min = 2, max = 50, message = "본명은 2-50자 사이여야 합니다.")
    private String realName;

    @NotNull(message = "생년월일은 필수입니다.")
    private LocalDate dateOfBirth;

    @NotNull(message = "부산대 학생 여부는 필수입니다.")
    private Boolean isPnuStudent;

    @Size(max = 100, message = "학과는 100자 이내입니다.")
    private String department;

    @Size(max = 20, message = "학번은 20자 이내입니다.")
    private String studentId;
}
