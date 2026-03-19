package com.pnu.basketball.controller.clubmatch;

import com.pnu.basketball.dto.request.ClubMatchCreateRequest;
import com.pnu.basketball.dto.request.ClubMatchResultRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ClubMatchRequestResponse;
import com.pnu.basketball.dto.response.ClubMatchResultResponse;
import com.pnu.basketball.service.clubmatch.ClubMatchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/club-matches/requests")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class ClubMatchController {

    private final ClubMatchService clubMatchService;

    @PostMapping
    @Operation(summary = "친선전 신청 (홈팀 대표)")
    public ResponseEntity<ApiResponse<ClubMatchRequestResponse>> createRequest(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ClubMatchCreateRequest request) {
        ClubMatchRequestResponse response = clubMatchService.createRequest(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "친선전 신청이 생성되었습니다."));
    }

    @PostMapping("/{id}/attend")
    @Operation(summary = "참가 의사 등록")
    public ResponseEntity<ApiResponse<Void>> attend(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        clubMatchService.attend(id, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "참가 의사가 등록되었습니다."));
    }

    @GetMapping
    @Operation(summary = "친선전 신청 목록 조회")
    public ResponseEntity<ApiResponse<Page<ClubMatchRequestResponse>>> getRequests(
            @PageableDefault(size = 20) Pageable pageable) {
        Page<ClubMatchRequestResponse> response = clubMatchService.getRequests(pageable);
        return ResponseEntity.ok(ApiResponse.success(response, "친선전 목록 조회 성공"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "친선전 상세 조회")
    public ResponseEntity<ApiResponse<ClubMatchRequestResponse>> getDetail(@PathVariable UUID id) {
        ClubMatchRequestResponse response = clubMatchService.getRequestDetail(id);
        return ResponseEntity.ok(ApiResponse.success(response, "친선전 상세 조회 성공"));
    }

    @PostMapping("/{id}/match")
    @Operation(summary = "상대 동아리 지정 (홈팀 대표)")
    public ResponseEntity<ApiResponse<ClubMatchRequestResponse>> matchOpponent(
            @PathVariable UUID id,
            @RequestParam UUID awayClubId,
            @AuthenticationPrincipal Long userId) {
        ClubMatchRequestResponse response = clubMatchService.matchOpponent(id, awayClubId, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "상대 동아리가 지정되었습니다."));
    }

    @PostMapping("/{id}/confirm")
    @Operation(summary = "경기 확정 (양팀 5명↑)")
    public ResponseEntity<ApiResponse<ClubMatchRequestResponse>> confirm(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        ClubMatchRequestResponse response = clubMatchService.confirmMatch(id, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "경기가 확정되었습니다."));
    }

    @PostMapping("/{id}/result")
    @Operation(summary = "결과 입력 (홈팀 대표)")
    public ResponseEntity<ApiResponse<ClubMatchResultResponse>> submitResult(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ClubMatchResultRequest request) {
        ClubMatchResultResponse response = clubMatchService.submitResult(id, userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "결과가 입력되었습니다."));
    }

    @PostMapping("/{id}/approve-result")
    @Operation(summary = "결과 승인 (대표)")
    public ResponseEntity<ApiResponse<ClubMatchResultResponse>> approveResult(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        ClubMatchResultResponse response = clubMatchService.approveResult(id, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "결과가 승인되었습니다."));
    }

    @GetMapping("/admin/pending")
    @Operation(summary = "관리자: 승인 대기 목록")
    public ResponseEntity<ApiResponse<List<ClubMatchResultResponse>>> getPendingAdminApproval() {
        List<ClubMatchResultResponse> response = clubMatchService.getPendingAdminApproval();
        return ResponseEntity.ok(ApiResponse.success(response, "승인 대기 목록 조회 성공"));
    }

    @PostMapping("/admin/{id}/confirm")
    @Operation(summary = "관리자: 최종 기록 확정")
    public ResponseEntity<ApiResponse<ClubMatchResultResponse>> adminConfirm(@PathVariable UUID id) {
        ClubMatchResultResponse response = clubMatchService.adminConfirm(id);
        return ResponseEntity.ok(ApiResponse.success(response, "관리자 최종 확정 완료"));
    }
}
