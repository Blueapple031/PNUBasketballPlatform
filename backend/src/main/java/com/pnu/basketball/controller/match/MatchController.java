package com.pnu.basketball.controller.match;

import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.MatchResponse;
import com.pnu.basketball.service.match.MatchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
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
}
