package com.pnu.basketball.controller.board;

import com.pnu.basketball.dto.request.CreateCommentRequest;
import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdateCommentRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.CommentResponse;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostResponse;
import com.pnu.basketball.service.board.CommentService;
import com.pnu.basketball.service.board.PostService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/board")
@RequiredArgsConstructor
public class BoardController {

    private final PostService postService;
    private final CommentService commentService;

    @GetMapping("/posts/list")
    @Operation(summary = "게시글 목록 조회", description = "삭제되지 않은 게시글 목록을 최신순으로 조회합니다. 비로그인 사용자도 접근 가능합니다.")
    public ResponseEntity<ApiResponse<Page<PostResponse>>> getPostList(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        Pageable pageable = PageRequest.of(page, Math.min(size, 50));
        Page<PostResponse> result = postService.getPostList(pageable);
        return ResponseEntity.ok(ApiResponse.success(result, "게시글 목록 조회 성공"));
    }

    @GetMapping("/posts/{postId}/detail")
    @Operation(summary = "게시글 상세 조회", description = "게시글 상세 정보와 답글 목록을 조회합니다. 조회 시 조회수가 1 증가합니다.")
    public ResponseEntity<ApiResponse<PostDetailResponse>> getPostDetail(@PathVariable Long postId) {
        PostDetailResponse result = postService.getPostDetail(postId);
        return ResponseEntity.ok(ApiResponse.success(result, "게시글 조회 성공"));
    }

    @PostMapping("/posts/create")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "게시글 작성", description = "로그인한 사용자가 새 게시글을 작성합니다.")
    public ResponseEntity<ApiResponse<PostResponse>> createPost(
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CreatePostRequest request
    ) {
        PostResponse result = postService.createPost(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(result, "게시글이 성공적으로 작성되었습니다."));
    }

    @PutMapping("/posts/{postId}/update")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "게시글 수정", description = "게시글 작성자가 본인 게시글의 제목과 본문을 수정합니다.")
    public ResponseEntity<ApiResponse<PostResponse>> updatePost(
            @PathVariable Long postId,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody UpdatePostRequest request
    ) {
        PostResponse result = postService.updatePost(postId, userId, request);
        return ResponseEntity.ok(ApiResponse.success(result, "게시글이 성공적으로 수정되었습니다."));
    }

    @DeleteMapping("/posts/{postId}/delete")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "게시글 삭제", description = "게시글 작성자가 본인 게시글을 소프트 삭제합니다.")
    public ResponseEntity<ApiResponse<Void>> deletePost(
            @PathVariable Long postId,
            @AuthenticationPrincipal Long userId
    ) {
        postService.deletePost(postId, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "게시글이 성공적으로 삭제되었습니다."));
    }

    @PostMapping("/posts/{postId}/comments/create")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "답글 작성", description = "로그인한 사용자가 게시글에 답글을 작성합니다.")
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @PathVariable Long postId,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody CreateCommentRequest request
    ) {
        CommentResponse result = commentService.createComment(postId, userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(result, "답글이 성공적으로 작성되었습니다."));
    }

    @PutMapping("/posts/{postId}/comments/{commentId}/update")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "답글 수정", description = "답글 작성자가 본인 답글의 내용을 수정합니다.")
    public ResponseEntity<ApiResponse<CommentResponse>> updateComment(
            @PathVariable Long postId,
            @PathVariable Long commentId,
            @AuthenticationPrincipal Long userId,
            @Valid @RequestBody UpdateCommentRequest request
    ) {
        CommentResponse result = commentService.updateComment(postId, commentId, userId, request);
        return ResponseEntity.ok(ApiResponse.success(result, "답글이 성공적으로 수정되었습니다."));
    }

    @DeleteMapping("/posts/{postId}/comments/{commentId}/delete")
    @SecurityRequirement(name = "bearerAuth")
    @Operation(summary = "답글 삭제", description = "답글 작성자가 본인 답글을 소프트 삭제합니다.")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable Long postId,
            @PathVariable Long commentId,
            @AuthenticationPrincipal Long userId
    ) {
        commentService.deleteComment(postId, commentId, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "답글이 성공적으로 삭제되었습니다."));
    }
}
