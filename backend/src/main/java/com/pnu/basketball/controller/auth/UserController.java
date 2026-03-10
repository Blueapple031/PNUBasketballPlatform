package com.pnu.basketball.controller.auth;

import com.pnu.basketball.dto.request.FcmTokenRequest;
import com.pnu.basketball.dto.request.UpdatePasswordRequest;
import com.pnu.basketball.dto.request.UpdateProfileRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.UserResponse;
import com.pnu.basketball.service.user.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;


@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class UserController {

    private final UserService userService;

    @PutMapping("/me")
    @Operation(summary = "유저 프로필 수정", description = "닉네임, 전화번호, 프로필 이미지 URL을 수정합니다.")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody UpdateProfileRequest request
    ) {
        UserResponse response = userService.updateProfile(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "프로필이 성공적으로 수정되었습니다."));
    }

    @PutMapping("/me/password")
    @Operation(summary = "비밀번호 변경", description = "현재 비밀번호를 확인하고 새 비밀번호로 변경합니다. 구글 로그인 사용자는 접근할 수 없습니다.")
    public ResponseEntity<ApiResponse<Void>> updatePassword(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody UpdatePasswordRequest request
    ) {
        userService.updatePassword(userId, request);
        return ResponseEntity.ok(ApiResponse.success(null, "비밀번호가 성공적으로 변경되었습니다."));
    }

    @DeleteMapping("/me")
    @Operation(summary = "회원 탈퇴", description = "현재 로그인한 사용자의 계정을 비활성화(소프트 삭제)합니다.")
    public ResponseEntity<ApiResponse<Void>> withdraw(
            @AuthenticationPrincipal Long userId
    ) {
        userService.withdraw(userId);
        return ResponseEntity.ok(ApiResponse.success(null, "회원 탈퇴가 성공적으로 처리되었습니다."));
    }

    @PostMapping("/me/fcm-token")
    @Operation(summary = "FCM 토큰 등록", description = "푸시 알림 수신을 위한 FCM 토큰을 등록합니다.")
    public ResponseEntity<ApiResponse<Void>> registerFcmToken(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody FcmTokenRequest request
    ) {
        userService.updateFcmToken(userId, request.getFcmToken());
        return ResponseEntity.ok(ApiResponse.success(null, "FCM 토큰이 등록되었습니다."));
    }

    @DeleteMapping("/me/fcm-token")
    @Operation(summary = "FCM 토큰 삭제", description = "로그아웃 시 FCM 토큰을 삭제합니다.")
    public ResponseEntity<ApiResponse<Void>> removeFcmToken(
            @AuthenticationPrincipal Long userId
    ) {
        userService.clearFcmToken(userId);
        return ResponseEntity.ok(ApiResponse.success(null, "FCM 토큰이 삭제되었습니다."));
    }
}
