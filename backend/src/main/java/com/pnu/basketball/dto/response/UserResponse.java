package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
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
    public static UserResponse fromEntity(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .nickname(user.getNickname())
                .phoneNumber(user.getPhoneNumber())
                .profileImageUrl(user.getProfileImageUrl())
                .loginType(user.getLoginType())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
 
