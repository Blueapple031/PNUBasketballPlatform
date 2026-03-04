package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Getter
@NoArgsConstructor
public class SignupRequest {

    @NotBlank(message = "이메일은 필수입니다.")
    @Email(message = "유효한 이메일 형식이 아닙니다.")
    private String email;

    @NotBlank(message = "비밀번호는 필수입니다.")
    @Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다.")
    @Pattern(regexp = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$",
            message = "비밀번호는 영문, 숫자, 특수문자를 포함해야 합니다.")
    private String password;

    @NotBlank(message = "본명은 필수입니다.")
    @Size(min = 2, max = 50, message = "본명은 2-50자 사이여야 합니다.")
    private String realName;

    @Pattern(regexp = "^010-\\d{4}-\\d{4}$", message = "전화번호 형식이 올바르지 않습니다.")
    private String phoneNumber;

    @NotNull(message = "생년월일은 필수입니다.")
    private LocalDate dateOfBirth;

    @NotNull(message = "부산대 학생 여부는 필수입니다.")
    private Boolean isPnuStudent;

    @Size(max = 100, message = "학과는 100자 이내입니다.")
    private String department;

    @Size(max = 20, message = "학번은 20자 이내입니다.")
    private String studentId;
}
