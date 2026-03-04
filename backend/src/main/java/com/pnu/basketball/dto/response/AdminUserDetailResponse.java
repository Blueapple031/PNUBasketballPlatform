package com.pnu.basketball.dto.response;

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
public class AdminUserDetailResponse {
    private Long userId;
    private String email;
    private String realName;
    private String phoneNumber;
    private LocalDate dateOfBirth;
    private Boolean isPnuStudent;
    private String department;
    private String studentId;
    private String clubName;
    private Integer wins;
    private Integer games;
    private Integer totalScore;
    private LocalDateTime createdAt;
}
