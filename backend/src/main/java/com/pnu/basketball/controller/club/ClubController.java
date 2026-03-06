package com.pnu.basketball.controller.club;

import com.pnu.basketball.dto.request.ClubSelectRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.ClubListResponse;
import com.pnu.basketball.dto.response.ClubSelectResponse;
import com.pnu.basketball.service.club.ClubService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clubs")
@RequiredArgsConstructor
public class ClubController {

    private final ClubService clubService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ClubListResponse>>> getClubs(@AuthenticationPrincipal Long userId) {
        List<ClubListResponse> clubs = clubService.getClubs();
        return ResponseEntity.ok(ApiResponse.success(clubs, "동아리 목록 조회 성공"));
    }

    @PostMapping("/select")
    public ResponseEntity<ApiResponse<ClubSelectResponse>> selectClub(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody ClubSelectRequest request) {
        ClubSelectResponse response = clubService.selectClub(userId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "동아리에 가입되었습니다."));
    }
}
