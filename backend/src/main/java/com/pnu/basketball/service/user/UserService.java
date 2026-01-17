package com.pnu.basketball.service.user;

import com.pnu.basketball.dto.response.UserResponse;

public interface UserService {
    UserResponse getCurrentUser(Long userId);
    boolean checkEmailAvailability(String email);
    boolean checkNicknameAvailability(String nickname);
}

