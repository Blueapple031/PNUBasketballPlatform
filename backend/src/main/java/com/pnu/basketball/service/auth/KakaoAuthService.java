package com.pnu.basketball.service.auth;

import com.pnu.basketball.dto.request.KakaoLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;

public interface KakaoAuthService {
    AuthResponse authenticate(KakaoLoginRequest request);
}
