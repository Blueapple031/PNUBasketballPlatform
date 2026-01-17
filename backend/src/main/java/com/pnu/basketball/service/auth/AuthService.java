package com.pnu.basketball.service.auth;

import com.pnu.basketball.dto.request.LoginRequest;
import com.pnu.basketball.dto.request.SignupRequest;
import com.pnu.basketball.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse signup(SignupRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refreshToken(String refreshToken);
    void logout(Long userId, String refreshToken);
}

