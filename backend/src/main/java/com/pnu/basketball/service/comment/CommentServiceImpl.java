package com.pnu.basketball.service.comment;

import com.pnu.basketball.domain.Comment;
import com.pnu.basketball.domain.Post;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.CreateCommentRequest;
import com.pnu.basketball.dto.request.UpdateCommentRequest;
import com.pnu.basketball.dto.response.CommentResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.CommentRepository;
import com.pnu.basketball.repository.PostRepository;
import com.pnu.basketball.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommentServiceImpl implements CommentService {

    private final CommentRepository commentRepository;
    private final PostRepository postRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public CommentResponse createComment(Long userId, UUID postId, CreateCommentRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        Comment comment = Comment.builder()
                .post(post)
                .user(user)
                .content(request.getContent())
                .build();
        commentRepository.save(comment);

        return toCommentResponse(comment);
    }

    @Override
    @Transactional
    public CommentResponse updateComment(Long userId, UUID postId, UUID commentId, UpdateCommentRequest request) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMENT_NOT_FOUND));

        if (!comment.getPost().getId().equals(postId)) {
            throw new CustomException(ErrorCode.COMMENT_NOT_FOUND);
        }

        if (!comment.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_COMMENT_EDIT);
        }

        comment.update(request.getContent());
        commentRepository.save(comment);

        return toCommentResponse(comment);
    }

    @Override
    @Transactional
    public void deleteComment(Long userId, UUID postId, UUID commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMENT_NOT_FOUND));

        if (!comment.getPost().getId().equals(postId)) {
            throw new CustomException(ErrorCode.COMMENT_NOT_FOUND);
        }

        if (!comment.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_COMMENT_EDIT);
        }

        commentRepository.delete(comment);
    }

    private CommentResponse toCommentResponse(Comment comment) {
        User author = comment.getUser();
        String profileImageUrl = author.getProfileImageUrl() != null ? author.getProfileImageUrl() : "";

        return CommentResponse.builder()
                .id(comment.getId())
                .authorId(author.getUserId())
                .authorName(author.getRealName())
                .authorProfileImageUrl(profileImageUrl)
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .updatedAt(comment.getUpdatedAt())
                .build();
    }
}
