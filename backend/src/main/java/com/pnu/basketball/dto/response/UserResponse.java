package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.LoginType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private Long userId;
    private String email;
    private String nickname;
    private String phoneNumber;
    private String profileImageUrl;
    private LoginType loginType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

