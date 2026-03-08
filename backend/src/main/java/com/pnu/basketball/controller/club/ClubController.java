package com.pnu.basketball.controller.club;

import com.pnu.basketball.dto.request.ClubCourtSlotCreateRequest;
import com.pnu.basketball.dto.request.ClubCourtSlotUpdateRequest;
import com.pnu.basketball.dto.request.ClubSelectRequest;
import com.pnu.basketball.dto.request.ClubUpdateIntroductionRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ClubCourtSlotResponse;
import com.pnu.basketball.dto.response.ClubListResponse;
import com.pnu.basketball.dto.response.ClubMemberResponse;
import com.pnu.basketball.dto.response.ClubSelectResponse;
import com.pnu.basketball.service.club.ClubService;
import com.pnu.basketball.service.clubcourt.ClubCourtSlotService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/clubs")
@RequiredArgsConstructor
public class ClubController {

    private final ClubService clubService;
    private final ClubCourtSlotService clubCourtSlotService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ClubListResponse>>> getClubs(@AuthenticationPrincipal Long userId) {
        List<ClubListResponse> clubs = clubService.getClubs();
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 목록 조회 성공"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ClubListResponse>> getMyClub(@AuthenticationPrincipal Long userId) {
        ClubListResponse club = clubService.getMyClub(userId);
        return ResponseEntity.ok(ApiResponse.success(club, "내 동아리 조회 성공"));
    }

    @GetMapping("/{clubId}/members")
    public ResponseEntity<ApiResponse<List<ClubMemberResponse>>> getClubMembers(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID clubId) {
        List<ClubMemberResponse> members = clubService.getClubMembers(clubId);
        return ResponseEntity.ok(ApiResponse.success(members, "동아리 멤버 조회 성공"));
    }

    @PatchMapping("/me")
    public ResponseEntity<ApiResponse<ClubListResponse>> updateMyClubIntroduction(
            @AuthenticationPrincipal Long userId,
            @RequestBody ClubUpdateIntroductionRequest request) {
        ClubListResponse club = clubService.updateMyClubIntroduction(userId, request);
        return ResponseEntity.ok(ApiResponse.success(club, "동아리 소개글이 수정되었습니다."));
    }

    @PostMapping("/select")
    public ResponseEntity<ApiResponse<ClubSelectResponse>> selectClub(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ClubSelectRequest request) {
        ClubSelectResponse response = clubService.selectClub(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "동아리에 가입되었습니다."));
    }

    @GetMapping("/{clubId}/court-slots")
    public ResponseEntity<ApiResponse<List<ClubCourtSlotResponse>>> getCourtSlots(
            @PathVariable UUID clubId) {
        List<ClubCourtSlotResponse> slots = clubCourtSlotService.getCourtSlotsByClub(clubId);
        return ResponseEntity.ok(ApiResponse.success(slots, "코트 사용시간 조회 성공"));
    }

    @PostMapping("/{clubId}/court-slots")
    public ResponseEntity<ApiResponse<ClubCourtSlotResponse>> createCourtSlot(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID clubId,
            @Valid @RequestBody ClubCourtSlotCreateRequest request) {
        ClubCourtSlotResponse response = clubCourtSlotService.createCourtSlot(userId, clubId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "코트 사용시간이 등록되었습니다."));
    }

    @PutMapping("/{clubId}/court-slots/{slotId}")
    public ResponseEntity<ApiResponse<ClubCourtSlotResponse>> updateCourtSlot(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID clubId,
            @PathVariable UUID slotId,
            @Valid @RequestBody ClubCourtSlotUpdateRequest request) {
        ClubCourtSlotResponse response = clubCourtSlotService.updateCourtSlot(userId, clubId, slotId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "코트 사용시간이 수정되었습니다."));
    }

    @DeleteMapping("/{clubId}/court-slots/{slotId}")
    public ResponseEntity<ApiResponse<Void>> deleteCourtSlot(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID clubId,
            @PathVariable UUID slotId) {
        clubCourtSlotService.deleteCourtSlot(userId, clubId, slotId);
        return ResponseEntity.ok(ApiResponse.success(null, "코트 사용시간이 삭제되었습니다."));
    }
}
