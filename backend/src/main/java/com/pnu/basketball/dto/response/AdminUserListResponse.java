package com.pnu.basketball.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminUserListResponse {
    private Long userId;
    private String email;
    private String realName;
    private Boolean isPnuStudent;
    private String department;
    private String studentId;
    private String clubName;
    private LocalDateTime createdAt;
}
