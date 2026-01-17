package com.pnu.basketball.service.auth;

import com.pnu.basketball.dto.request.GoogleLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;

public interface GoogleAuthService {
    AuthResponse authenticate(GoogleLoginRequest request);
}

