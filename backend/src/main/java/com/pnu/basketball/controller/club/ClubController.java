package com.pnu.basketball.controller.club;

import com.pnu.basketball.dto.request.club.ClubUpdateRequest;
import com.pnu.basketball.dto.request.club.TransferCaptainRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.club.ApplicationResponse;
import com.pnu.basketball.dto.response.club.ClubResponse;
import com.pnu.basketball.service.club.ClubService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
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

    @GetMapping("/list")
    @Operation(summary = "동아리 목록 조회", description = "등록된 모든 동아리 목록을 조회합니다.")
    public ResponseEntity<ApiResponse<List<ClubResponse>>> getClubs() {
        List<ClubResponse> clubs = clubService.getAllClubs();
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 목록 조회 성공"));
    }

    @GetMapping("/search")
    @Operation(summary = "동아리 검색", description = "동아리 이름 키워드로 동아리를 검색합니다.")
    public ResponseEntity<ApiResponse<List<ClubResponse>>> searchClubs(
            @RequestParam String keyword) {
        List<ClubResponse> clubs = clubService.searchClubs(keyword);
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 검색 성공"));
    }

    @PatchMapping("/{id}/info")
    @Operation(summary = "동아리 정보 수정", description = "동아리 주장만 동아리 기본 정보(이름, 로고, 설명)를 수정할 수 있습니다.")
    public ResponseEntity<ApiResponse<ClubResponse>> updateClub(
            @PathVariable Long id,
            @Valid @RequestBody ClubUpdateRequest request,
            @AuthenticationPrincipal Long userId) {
        ClubResponse response = clubService.updateClub(id, request, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "동아리 정보가 성공적으로 수정되었습니다."));
    }

    @GetMapping("/{id}/join-requests")
    @Operation(summary = "가입 신청 목록 조회", description = "동아리 주장만 가입을 신청한 유저 목록(이름, 프로필, 신청일)을 조회할 수 있습니다.")
    public ResponseEntity<ApiResponse<List<ApplicationResponse>>> getJoinRequests(
            @PathVariable Long id,
            @AuthenticationPrincipal Long userId) {
        List<ApplicationResponse> applications = clubService.getApplications(id, userId);
        return ResponseEntity.ok(ApiResponse.success(applications, "신청 현황 조회 성공"));
    }

    @PostMapping("/{id}/join-requests/{userId}/approve")
    @Operation(summary = "가입 신청 승인", description = "동아리 주장이 특정 유저의 가입 신청을 승인합니다.")
    public ResponseEntity<ApiResponse<Void>> approveJoinRequest(
            @PathVariable Long id,
            @PathVariable Long userId,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.approveJoinRequest(id, userId, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(null, "가입 신청이 승인되었습니다."));
    }

    @PostMapping("/{id}/join-requests/{userId}/reject")
    @Operation(summary = "가입 신청 거절", description = "동아리 주장이 특정 유저의 가입 신청을 거절합니다.")
    public ResponseEntity<ApiResponse<Void>> rejectJoinRequest(
            @PathVariable Long id,
            @PathVariable Long userId,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.rejectJoinRequest(id, userId, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(null, "가입 신청이 거절되었습니다."));
    }

    @PostMapping("/{id}/transfer-captain")
    @Operation(summary = "주장 권한 위임", description = "현재 주장이 해당 동아리 멤버에게 주장 권한을 위임합니다.")
    public ResponseEntity<ApiResponse<Void>> transferCaptain(
            @PathVariable Long id,
            @Valid @RequestBody TransferCaptainRequest request,
            @AuthenticationPrincipal Long userId) {
        clubService.transferCaptain(id, request, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "주장 권한이 성공적으로 위임되었습니다."));
    }

    @PostMapping("/{id}/leave")
    @Operation(summary = "동아리 탈퇴", description = "로그인한 사용자가 해당 동아리에서 자진 탈퇴합니다. 주장은 위임 전까지 탈퇴할 수 없습니다.")
    public ResponseEntity<ApiResponse<Void>> leaveClub(
            @PathVariable Long id,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.leaveClub(id, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(null, "동아리에서 탈퇴했습니다."));
    }

    @DeleteMapping("/{id}/members/{userId}")
    @Operation(summary = "멤버 추방", description = "동아리 주장이 특정 멤버를 강제 추방합니다. 주장은 추방할 수 없습니다.")
    public ResponseEntity<ApiResponse<Void>> kickMember(
            @PathVariable Long id,
            @PathVariable Long userId,
            @AuthenticationPrincipal Long currentUserId) {
        clubService.kickMember(id, userId, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(null, "멤버를 추방했습니다."));
    }
}
