package com.pnu.basketball.dto.response;

import com.pnu.basketball.domain.LoginType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String tokenType;
    private Long expiresIn;
    private UserInfo user;
    
    @Getter
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long userId;
        private String email;
        private String realName;
        private String profileImageUrl;
        private LoginType loginType;
        private Boolean isNewUser;
        private Boolean needsClubSelection;  // 학생 && 동아리 미가입 시 true
    }
}

