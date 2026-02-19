package com.pnu.basketball.controller.club;

import com.pnu.basketball.dto.request.club.ClubCreateRequest;
import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.request.club.UpdateApplicationRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.club.ApplicationResponse;
import com.pnu.basketball.dto.response.club.ClubResponse;
import com.pnu.basketball.service.club.ClubService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clubs")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class ClubController {

    private final ClubService clubService;

    @PostMapping
    @Operation(summary = "동아리 생성", description = "새로운 동아리를 생성합니다. 생성자는 자동으로 주장이 됩니다.")
    public ResponseEntity<ApiResponse<ClubResponse>> createClub(
            @Valid @RequestBody ClubCreateRequest request,
            @AuthenticationPrincipal Long userId) {
        ClubResponse response = clubService.createClub(request, userId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "동아리가 성공적으로 생성되었습니다."));
    }

    @GetMapping
    @Operation(summary = "동아리 목록 조회", description = "모든 동아리 목록을 조회합니다.")
    public ResponseEntity<ApiResponse<List<ClubResponse>>> getAllClubs() {
        List<ClubResponse> clubs = clubService.getAllClubs();
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 목록 조회 성공"));
    }

    @GetMapping("/search")
    @Operation(summary = "동아리 검색", description = "키워드로 동아리를 검색합니다.")
    public ResponseEntity<ApiResponse<List<ClubResponse>>> searchClubs(
            @RequestParam String keyword) {
        List<ClubResponse> clubs = clubService.searchClubs(keyword);
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 검색 성공"));
    }

    @PatchMapping("/{id}")
    @Operation(summary = "동아리 수정", description = "동아리 주장만 동아리 정보를 수정할 수 있습니다.")
    public ResponseEntity<ApiResponse<ClubResponse>> updateClub(
            @PathVariable Long id,
            @Valid @RequestBody ClubUpdateRequest request,
            @AuthenticationPrincipal Long userId) {
        ClubResponse response = clubService.updateClub(id, request, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "동아리 정보가 성공적으로 수정되었습니다."));
    }

    @GetMapping("/{id}/applications")
    @Operation(summary = "신청 현황 확인", description = "동아리 주장만 가입 신청 현황을 확인할 수 있습니다.")
    public ResponseEntity<ApiResponse<List<ApplicationResponse>>> getApplications(
            @PathVariable Long id,
            @AuthenticationPrincipal Long userId) {
        List<ApplicationResponse> applications = clubService.getApplications(id, userId);
        return ResponseEntity.ok(ApiResponse.success(applications, "신청 현황 조회 성공"));
    }

    @PatchMapping("/{id}/applications/{userId}")
    @Operation(summary = "가입 승인/거절", description = "동아리 주장이 가입 신청을 승인하거나 거절합니다.")
    public ResponseEntity<ApiResponse<Void>> handleApplication(
            @PathVariable Long id,
            @PathVariable Long userId,
            @Valid @RequestBody UpdateApplicationRequest request,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.handleApplication(id, userId, request, currentUserId);
        String message = request.getStatus().name().equals("APPROVED") ? "가입 신청이 승인되었습니다." : "가입 신청이 거절되었습니다.";
        return ResponseEntity.ok(ApiResponse.success(null, message));
    }

    @PatchMapping("/{id}/captain")
    @Operation(summary = "주장 위임", description = "현재 주장이 다른 멤버에게 주장 권한을 위임합니다.")
    public ResponseEntity<ApiResponse<Void>> transferCaptain(
            @PathVariable Long id,
            @Valid @RequestBody TransferCaptainRequest request,
            @AuthenticationPrincipal Long userId) {
        clubService.transferCaptain(id, request, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "주장 권한이 성공적으로 위임되었습니다."));
    }

    @DeleteMapping("/{id}/members/{userId}")
    @Operation(summary = "멤버 탈퇴/추방", description = "본인은 자진 탈퇴, 주장은 멤버를 추방할 수 있습니다. 주장은 권한 위임 전까지 탈퇴할 수 없습니다.")
    public ResponseEntity<ApiResponse<Void>> removeMember(
            @PathVariable Long id,
            @PathVariable Long userId,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.removeMember(id, userId, currentUserId);
        String message = userId.equals(currentUserId) ? "동아리에서 탈퇴했습니다." : "멤버를 추방했습니다.";
        return ResponseEntity.ok(ApiResponse.success(null, message));
    }
}
