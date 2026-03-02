package com.pnu.basketball.service.board;

import com.pnu.basketball.dto.request.CreateCommentRequest;
import com.pnu.basketball.dto.request.UpdateCommentRequest;
import com.pnu.basketball.dto.response.CommentResponse;

public interface CommentService {

    CommentResponse createComment(Long postId, Long userId, CreateCommentRequest request);

    CommentResponse updateComment(Long postId, Long commentId, Long userId, UpdateCommentRequest request);

    void deleteComment(Long postId, Long commentId, Long userId);
}
