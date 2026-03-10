package com.pnu.basketball.controller.admin;

import com.pnu.basketball.dto.request.*;
import com.pnu.basketball.dto.response.*;
import com.pnu.basketball.service.admin.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
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

    // ========== 게시글/댓글 관리 ==========

    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(page - 1, Math.min(size, 50));
        Page<PostListResponse> result = adminService.getPosts(pageable);
        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getContent());
        data.put("totalPages", result.getTotalPages());
        data.put("currentPage", page);
        data.put("totalElements", result.getTotalElements());
        return ResponseEntity.ok(ApiResponse.success(data, "게시글 목록 조회 성공"));
    }

    @GetMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<PostDetailResponse>> getPost(@PathVariable UUID id) {
        PostDetailResponse post = adminService.getPost(id);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글 조회 성공"));
    }

    @PostMapping("/posts")
    public ResponseEntity<ApiResponse<PostDetailResponse>> createPost(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CreatePostRequest request) {
        PostDetailResponse post = adminService.createPost(userId, request);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글이 작성되었습니다."));
    }

    @PutMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<PostDetailResponse>> updatePost(
            @PathVariable UUID id,
            @Valid @RequestBody UpdatePostRequest request) {
        PostDetailResponse post = adminService.updatePost(id, request);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글이 수정되었습니다."));
    }

    @DeleteMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePost(@PathVariable UUID id) {
        adminService.deletePost(id);
        return ResponseEntity.ok(ApiResponse.success(null, "게시글이 삭제되었습니다."));
    }

    @PatchMapping("/posts/{id}/pin")
    public ResponseEntity<ApiResponse<PostDetailResponse>> pinPost(
            @PathVariable UUID id,
            @RequestBody Map<String, Boolean> body) {
        boolean isPinned = body != null && Boolean.TRUE.equals(body.get("isPinned"));
        PostDetailResponse post = adminService.pinPost(id, isPinned);
        return ResponseEntity.ok(ApiResponse.success(post, isPinned ? "상단 고정되었습니다." : "고정이 해제되었습니다."));
    }

    @PostMapping("/posts/{postId}/comments")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @Valid @RequestBody CreateCommentRequest request) {
        CommentResponse comment = adminService.createComment(userId, postId, request);
        return ResponseEntity.ok(ApiResponse.success(comment, "댓글이 작성되었습니다."));
    }

    @DeleteMapping("/comments/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(@PathVariable UUID id) {
        adminService.deleteComment(id);
        return ResponseEntity.ok(ApiResponse.success(null, "댓글이 삭제되었습니다."));
    }
}
