package com.pnu.basketball.service.comment;

import com.pnu.basketball.dto.request.CreateCommentRequest;
import com.pnu.basketball.dto.request.UpdateCommentRequest;
import com.pnu.basketball.dto.response.CommentResponse;

import java.util.UUID;

public interface CommentService {

    CommentResponse createComment(Long userId, UUID postId, CreateCommentRequest request);

    CommentResponse updateComment(Long userId, UUID postId, UUID commentId, UpdateCommentRequest request);

    void deleteComment(Long userId, UUID postId, UUID commentId);
}
