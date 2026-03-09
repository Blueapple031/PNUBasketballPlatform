package com.pnu.basketball.service.user;

import com.pnu.basketball.dto.request.CompleteProfileRequest;
import com.pnu.basketball.dto.request.UpdatePasswordRequest;
import com.pnu.basketball.dto.request.UpdateProfileRequest;
import com.pnu.basketball.dto.response.UserResponse;

public interface UserService {
    UserResponse getCurrentUser(Long userId);
    UserResponse updateProfile(Long userId, UpdateProfileRequest request);
    UserResponse completeProfile(Long userId, CompleteProfileRequest request);
    boolean checkEmailAvailability(String email);
    boolean checkRealNameAvailability(String realName);
    void updatePassword(Long userId, UpdatePasswordRequest request);
    void withdraw(Long userId);
    void updateFcmToken(Long userId, String fcmToken);
    void clearFcmToken(Long userId);
}
