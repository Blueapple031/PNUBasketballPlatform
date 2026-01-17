package com.pnu.basketball.controller.auth;

import com.pnu.basketball.dto.request.*;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.dto.response.UserResponse;
import com.pnu.basketball.service.auth.AuthService;
import com.pnu.basketball.service.auth.GoogleAuthService;
import com.pnu.basketball.service.user.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final AuthService authService;
    private final GoogleAuthService googleAuthService;
    private final UserService userService;
    
    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<AuthResponse>> signup(@Valid @RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "회원가입이 완료되었습니다."));
    }
    
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success(response, "로그인 성공"));
    }
    
    @PostMapping("/google")
    public ResponseEntity<ApiResponse<AuthResponse>> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        AuthResponse response = googleAuthService.authenticate(request);
        return ResponseEntity.ok(ApiResponse.success(response, "구글 로그인 성공"));
    }
    
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(response, "토큰 갱신 성공"));
    }
    
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(userId, request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(null, "로그아웃되었습니다."));
    }
    
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(@AuthenticationPrincipal Long userId) {
        UserResponse response = userService.getCurrentUser(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "사용자 정보 조회 성공"));
    }
    
    @GetMapping("/check-email")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkEmail(@RequestParam String email) {
        boolean available = userService.checkEmailAvailability(email);
        Map<String, Object> data = new HashMap<>();
        data.put("available", available);
        data.put("email", email);
        
        String message = available ? "사용 가능한 이메일입니다." : "이미 사용 중인 이메일입니다.";
        return ResponseEntity.ok(ApiResponse.success(data, message));
    }
    
    @GetMapping("/check-nickname")
    public ResponseEntity<ApiResponse<Map<String, Object>>> checkNickname(@RequestParam String nickname) {
        boolean available = userService.checkNicknameAvailability(nickname);
        Map<String, Object> data = new HashMap<>();
        data.put("available", available);
        data.put("nickname", nickname);
        
        String message = available ? "사용 가능한 닉네임입니다." : "이미 사용 중인 닉네임입니다.";
        return ResponseEntity.ok(ApiResponse.success(data, message));
    }
}

