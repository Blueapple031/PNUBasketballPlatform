package com.pnu.basketball.controller.admin;

import com.pnu.basketball.domain.MatchState;
import com.pnu.basketball.dto.request.AdminCreateClubRequest;
import com.pnu.basketball.dto.request.AdminSetCaptainRequest;
import com.pnu.basketball.dto.request.AdminUpdateMatchRequest;
import com.pnu.basketball.dto.response.*;
import com.pnu.basketball.service.admin.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminStatsResponse>> getStats() {
        AdminStatsResponse stats = adminService.getStats();
        return ResponseEntity.ok(ApiResponse.success(stats, "통계 조회 성공"));
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUsers(
            @RequestParam(required = false) Boolean isPnuStudent,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page - 1, Math.min(size, 50));
        Page<AdminUserListResponse> result = adminService.getUsers(isPnuStudent, search, pageable);
        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getContent());
        data.put("totalElements", result.getTotalElements());
        data.put("totalPages", result.getTotalPages());
        data.put("currentPage", page);
        data.put("size", result.getSize());
        return ResponseEntity.ok(ApiResponse.success(data, "유저 목록 조회 성공"));
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<ApiResponse<AdminUserDetailResponse>> getUserDetail(@PathVariable Long id) {
        AdminUserDetailResponse response = adminService.getUserDetail(id);
        return ResponseEntity.ok(ApiResponse.success(response, "유저 상세 조회 성공"));
    }

    @GetMapping("/clubs")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getClubs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        Pageable pageable = PageRequest.of(page - 1, size);
        Page<AdminClubListResponse> result = adminService.getClubs(pageable);
        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getContent());
        data.put("totalElements", result.getTotalElements());
        return ResponseEntity.ok(ApiResponse.success(data, "동아리 목록 조회 성공"));
    }

    @PostMapping("/clubs")
    public ResponseEntity<ApiResponse<AdminClubListResponse>> createClub(
            @Valid @RequestBody AdminCreateClubRequest request) {
        AdminClubListResponse response = adminService.createClub(request);
        return ResponseEntity.ok(ApiResponse.success(response, "동아리 생성 성공"));
    }

    @GetMapping("/clubs/{id}/members")
    public ResponseEntity<ApiResponse<java.util.List<AdminUserListResponse>>> getClubMembers(@PathVariable UUID id) {
        java.util.List<AdminUserListResponse> members = adminService.getClubMembers(id);
        return ResponseEntity.ok(ApiResponse.success(members, "동아리 멤버 조회 성공"));
    }

    @PutMapping("/clubs/{id}/captain")
    public ResponseEntity<ApiResponse<Void>> setCaptain(
            @PathVariable UUID id,
            @Valid @RequestBody AdminSetCaptainRequest request) {
        adminService.setCaptain(id, request);
        return ResponseEntity.ok(ApiResponse.success(null, "동아리장 설정 완료"));
    }

    @GetMapping("/matches")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMatches(
            @RequestParam(required = false) MatchState state,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page - 1, Math.min(size, 50));
        Page<AdminMatchListResponse> result = adminService.getMatches(state, pageable);
        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getContent());
        data.put("totalElements", result.getTotalElements());
        data.put("totalPages", result.getTotalPages());
        data.put("currentPage", page);
        return ResponseEntity.ok(ApiResponse.success(data, "매치 목록 조회 성공"));
    }

    @GetMapping("/matches/{id}")
    public ResponseEntity<ApiResponse<AdminMatchListResponse>> getMatchDetail(@PathVariable UUID id) {
        AdminMatchListResponse response = adminService.getMatchDetail(id);
        return ResponseEntity.ok(ApiResponse.success(response, "매치 상세 조회 성공"));
    }

    @PutMapping("/matches/{id}")
    public ResponseEntity<ApiResponse<AdminMatchListResponse>> updateMatch(
            @PathVariable UUID id,
            @RequestBody AdminUpdateMatchRequest request) {
        AdminMatchListResponse response = adminService.updateMatch(id, request);
        return ResponseEntity.ok(ApiResponse.success(response, "매치 수정 완료"));
    }
}
