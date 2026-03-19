package com.pnu.basketball.controller.recruitment;

import com.pnu.basketball.domain.RecruitmentGameFormat;
import com.pnu.basketball.domain.RecruitmentStatus;
import com.pnu.basketball.dto.request.RecruitmentApplyRequest;
import com.pnu.basketball.dto.request.RecruitmentCreateRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.RecruitmentDetailResponse;
import com.pnu.basketball.dto.response.RecruitmentListResponse;
import com.pnu.basketball.service.recruitment.RecruitmentService;
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

import java.time.LocalDateTime;
import java.util.UUID;

@RestController
@RequestMapping("/api/recruitments")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class RecruitmentController {

    private final RecruitmentService recruitmentService;

    @PostMapping
    @Operation(summary = "모집글 생성")
    public ResponseEntity<ApiResponse<RecruitmentDetailResponse>> create(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody RecruitmentCreateRequest request) {
        RecruitmentDetailResponse response = recruitmentService.create(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "모집글이 생성되었습니다."));
    }

    @GetMapping
    @Operation(summary = "모집글 목록 조회")
    public ResponseEntity<ApiResponse<Page<RecruitmentListResponse>>> getList(
            @RequestParam(required = false) RecruitmentStatus status,
            @RequestParam(required = false) UUID locationId,
            @RequestParam(required = false) RecruitmentGameFormat gameFormat,
            @RequestParam(required = false) LocalDateTime startFrom,
            @RequestParam(required = false) LocalDateTime startTo,
            @PageableDefault(size = 20) Pageable pageable) {
        Page<RecruitmentListResponse> response = recruitmentService.getList(
                status, locationId, gameFormat, startFrom, startTo, pageable);
        return ResponseEntity.ok(ApiResponse.success(response, "모집글 목록 조회 성공"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "모집글 상세 조회")
    public ResponseEntity<ApiResponse<RecruitmentDetailResponse>> getDetail(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        RecruitmentDetailResponse response = recruitmentService.getDetail(id, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "모집글 상세 조회 성공"));
    }

    @PostMapping("/{id}/apply")
    @Operation(summary = "모집 신청")
    public ResponseEntity<ApiResponse<Void>> apply(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody RecruitmentApplyRequest request) {
        recruitmentService.apply(id, userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(null, "신청이 완료되었습니다."));
    }

    @PostMapping("/{id}/applications/{applicationId}/accept")
    @Operation(summary = "신청 수락")
    public ResponseEntity<ApiResponse<Void>> accept(
            @PathVariable UUID id,
            @PathVariable UUID applicationId,
            @AuthenticationPrincipal Long userId) {
        recruitmentService.acceptApplication(id, applicationId, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "신청이 수락되었습니다."));
    }

    @PostMapping("/{id}/applications/{applicationId}/reject")
    @Operation(summary = "신청 거절")
    public ResponseEntity<ApiResponse<Void>> reject(
            @PathVariable UUID id,
            @PathVariable UUID applicationId,
            @AuthenticationPrincipal Long userId) {
        recruitmentService.rejectApplication(id, applicationId, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "신청이 거절되었습니다."));
    }

    @PostMapping("/{id}/confirm")
    @Operation(summary = "모집 확정 → 경기 생성")
    public ResponseEntity<ApiResponse<RecruitmentDetailResponse>> confirm(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        RecruitmentDetailResponse response = recruitmentService.confirm(id, userId);
        return ResponseEntity.ok(ApiResponse.success(response, "모집이 확정되고 경기가 생성되었습니다."));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "모집 취소")
    public ResponseEntity<ApiResponse<Void>> cancel(
            @PathVariable UUID id,
            @AuthenticationPrincipal Long userId) {
        recruitmentService.cancel(id, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "모집이 취소되었습니다."));
    }
}
