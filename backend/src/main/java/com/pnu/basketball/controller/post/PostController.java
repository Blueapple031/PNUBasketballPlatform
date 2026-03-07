package com.pnu.basketball.controller.post;

import com.pnu.basketball.dto.request.CreateCommentRequest;
import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdateCommentRequest;
import com.pnu.basketball.dto.request.TogglePinRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.CommentResponse;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostListResponse;
import com.pnu.basketball.service.comment.CommentService;
import com.pnu.basketball.service.post.PostService;
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
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;
    private final CommentService commentService;

    @GetMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPosts(
            @AuthenticationPrincipal Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        Pageable pageable = PageRequest.of(Math.max(0, page - 1), Math.min(size, 50));
        Page<PostListResponse> result = postService.getPosts(pageable);

        Map<String, Object> data = new HashMap<>();
        data.put("content", result.getContent());
        data.put("totalPages", result.getTotalPages());
        data.put("currentPage", page);
        data.put("totalElements", result.getTotalElements());

        return ResponseEntity.ok(ApiResponse.success(data, "게시글 목록 조회 성공"));
    }

    @GetMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostDetailResponse>> getPost(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId) {
        PostDetailResponse post = postService.getPost(postId);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글 조회 성공"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PostDetailResponse>> createPost(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CreatePostRequest request) {
        PostDetailResponse post = postService.createPost(userId, request);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글이 작성되었습니다."));
    }

    @PutMapping("/{postId}")
    public ResponseEntity<ApiResponse<PostDetailResponse>> updatePost(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @Valid @RequestBody UpdatePostRequest request) {
        PostDetailResponse post = postService.updatePost(userId, postId, request);
        return ResponseEntity.ok(ApiResponse.success(post, "게시글이 수정되었습니다."));
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId) {
        postService.deletePost(userId, postId);
        return ResponseEntity.ok(ApiResponse.success(null, "게시글이 삭제되었습니다."));
    }

    @PatchMapping("/{postId}/pin")
    public ResponseEntity<ApiResponse<PostDetailResponse>> pinPost(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @RequestBody TogglePinRequest request) {
        boolean isPinned = request.getIsPinned() != null && request.getIsPinned();
        PostDetailResponse post = postService.pinPost(userId, postId, isPinned);
        return ResponseEntity.ok(ApiResponse.success(post, isPinned ? "게시글이 상단 고정되었습니다." : "상단 고정이 해제되었습니다."));
    }

    @PostMapping("/{postId}/comments")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @Valid @RequestBody CreateCommentRequest request) {
        CommentResponse comment = commentService.createComment(userId, postId, request);
        return ResponseEntity.ok(ApiResponse.success(comment, "댓글이 작성되었습니다."));
    }

    @PutMapping("/{postId}/comments/{commentId}")
    public ResponseEntity<ApiResponse<CommentResponse>> updateComment(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @PathVariable UUID commentId,
            @Valid @RequestBody UpdateCommentRequest request) {
        CommentResponse comment = commentService.updateComment(userId, postId, commentId, request);
        return ResponseEntity.ok(ApiResponse.success(comment, "댓글이 수정되었습니다."));
    }

    @DeleteMapping("/{postId}/comments/{commentId}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @AuthenticationPrincipal Long userId,
            @PathVariable UUID postId,
            @PathVariable UUID commentId) {
        commentService.deleteComment(userId, postId, commentId);
        return ResponseEntity.ok(ApiResponse.success(null, "댓글이 삭제되었습니다."));
    }
}
