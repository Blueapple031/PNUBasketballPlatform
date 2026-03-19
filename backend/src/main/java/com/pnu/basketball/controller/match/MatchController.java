package com.pnu.basketball.controller.match;

import com.pnu.basketball.dto.request.ReviewSubmitRequest;
import com.pnu.basketball.dto.response.*;
import com.pnu.basketball.service.match.MatchService;
import com.pnu.basketball.service.review.ReviewService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class MatchController {

    private final MatchService matchService;
    private final ReviewService reviewService;

    @GetMapping
    @Operation(summary = "내 확정 경기 목록")
    public ResponseEntity<ApiResponse<List<MatchResponse>>> getMyMatches(
            @AuthenticationPrincipal Long userId) {
        List<MatchResponse> response = matchService.getMyMatches(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "경기 목록 조회 성공"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "경기 상세 조회")
    public ResponseEntity<ApiResponse<MatchResponse>> getMatch(@PathVariable UUID id) {
        MatchResponse response = matchService.getMatch(id);
        return ResponseEntity.ok(ApiResponse.success(response, "경기 상세 조회 성공"));
    }

    @PostMapping("/{id}/complete")
    @Operation(summary = "경기 완료 처리 (모집자/대표/관리자)")
    public ResponseEntity<ApiResponse<Void>> complete(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        matchService.completeMatch(id, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "경기가 완료 처리되었습니다."));
    }

    @GetMapping("/{id}/review-form")
    @Operation(summary = "리뷰 팝업용 참가자 목록 조회")
    public ResponseEntity<ApiResponse<ReviewFormResponse>> getReviewForm(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        ReviewFormResponse response = reviewService.getReviewForm(id, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "리뷰 폼 조회 성공"));
    }

    @PostMapping("/{id}/review")
    @Operation(summary = "리뷰 + 노쇼 일괄 제출")
    public ResponseEntity<ApiResponse<Void>> submitReview(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ReviewSubmitRequest request) {
        reviewService.submitReview(id, userId, request);
        return ResponseEntity.ok(ApiResponse.success(null, "리뷰가 제출되었습니다."));
    }

    @GetMapping("/admin/no-show-reports")
    @Operation(summary = "관리자: 노쇼 신고 대기 목록")
    public ResponseEntity<ApiResponse<List<NoShowReportResponse>>> getPendingNoShowReports() {
        List<NoShowReportResponse> response = reviewService.getPendingNoShowReports();
        return ResponseEntity.ok(ApiResponse.success(response, "노쇼 신고 목록 조회 성공"));
    }

    @PostMapping("/admin/no-show-reports/{reportId}/confirm")
    @Operation(summary = "관리자: 노쇼 확정")
    public ResponseEntity<ApiResponse<Void>> confirmNoShow(@PathVariable UUID reportId) {
        reviewService.confirmNoShow(reportId);
        return ResponseEntity.ok(ApiResponse.success(null, "노쇼가 확정되었습니다."));
    }

    @PostMapping("/admin/no-show-reports/{reportId}/reject")
    @Operation(summary = "관리자: 노쇼 반려")
    public ResponseEntity<ApiResponse<Void>> rejectNoShow(@PathVariable UUID reportId) {
        reviewService.rejectNoShow(reportId);
        return ResponseEntity.ok(ApiResponse.success(null, "노쇼 신고가 반려되었습니다."));
    }
}
