package com.pnu.basketball.service.user;

import com.pnu.basketball.dto.request.UpdatePasswordRequest;
import com.pnu.basketball.dto.request.UpdateProfileRequest;
import com.pnu.basketball.dto.response.UserResponse;

public interface UserService {
    UserResponse getCurrentUser(Long userId);
    UserResponse updateProfile(Long userId, UpdateProfileRequest request);
    boolean checkEmailAvailability(String email);
    boolean checkNicknameAvailability(String nickname);
    void updatePassword(Long userId, UpdatePasswordRequest request);
    void withdraw(Long userId);
}
