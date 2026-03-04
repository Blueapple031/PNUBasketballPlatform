package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.LoginType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long userId;
    private String email;
    private String realName;
    private String phoneNumber;
    private String profileImageUrl;
    private LoginType loginType;
    private LocalDate dateOfBirth;
    private Boolean isPnuStudent;
    private String department;
    private String studentId;
    private LocalDateTime createdAt;
}
