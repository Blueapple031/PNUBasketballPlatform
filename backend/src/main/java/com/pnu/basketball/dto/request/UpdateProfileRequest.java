package com.pnu.basketball.dto.request;

import com.pnu.basketball.domain.Position;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class UpdateProfileRequest {

    @Size(min = 2, max = 50, message = "본명은 2-50자 사이여야 합니다.")
    private String realName;

    @Pattern(regexp = "^(010\\d{8}|010-\\d{4}-\\d{4})$", message = "전화번호 형식이 올바르지 않습니다. (01012345678 또는 010-1234-5678)")
    private String phoneNumber;

    @Size(max = 500, message = "프로필 이미지 URL은 500자를 초과할 수 없습니다.")
    private String profileImageUrl;

    @Size(min = 2, max = 30, message = "닉네임은 2-30자 사이여야 합니다.")
    private String nickname;

    private Position position;
}
