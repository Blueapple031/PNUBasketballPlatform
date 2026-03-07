package com.pnu.basketball.service.post;

import com.pnu.basketball.domain.Post;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.CommentResponse;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostListResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.CommentRepository;
import com.pnu.basketball.repository.PostRepository;
import com.pnu.basketball.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<PostListResponse> getPosts(Pageable pageable) {
        return postRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(this::toPostListResponse);
    }

    @Override
    @Transactional
    public PostDetailResponse getPost(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        post.incrementViewCount();
        postRepository.save(post);

        return toPostDetailResponse(post);
    }

    @Override
    @Transactional
    public PostDetailResponse createPost(Long userId, CreatePostRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Post post = Post.builder()
                .user(user)
                .title(request.getTitle())
                .content(request.getContent())
                .build();
        postRepository.save(post);

        return toPostDetailResponse(post);
    }

    @Override
    @Transactional
    public PostDetailResponse updatePost(Long userId, UUID postId, UpdatePostRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        if (!post.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_POST_EDIT);
        }

        post.update(request.getTitle(), request.getContent());
        postRepository.save(post);

        return toPostDetailResponse(post);
    }

    @Override
    @Transactional
    public void deletePost(Long userId, UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        if (!post.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.UNAUTHORIZED_POST_EDIT);
        }

        postRepository.delete(post);
    }

    private PostListResponse toPostListResponse(Post post) {
        User author = post.getUser();
        int commentCount = (int) commentRepository.countByPost_Id(post.getId());
        String profileImageUrl = author.getProfileImageUrl() != null ? author.getProfileImageUrl() : "";

        return PostListResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .authorName(author.getRealName())
                .authorProfileImageUrl(profileImageUrl)
                .viewCount(post.getViewCount())
                .commentCount(commentCount)
                .createdAt(post.getCreatedAt())
                .build();
    }

    private PostDetailResponse toPostDetailResponse(Post post) {
        User author = post.getUser();
        String profileImageUrl = author.getProfileImageUrl() != null ? author.getProfileImageUrl() : "";

        List<CommentResponse> comments = commentRepository.findByPost_IdOrderByCreatedAtAsc(post.getId())
                .stream()
                .map(this::toCommentResponse)
                .collect(Collectors.toList());

        return PostDetailResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .authorId(author.getUserId())
                .authorName(author.getRealName())
                .authorProfileImageUrl(profileImageUrl)
                .viewCount(post.getViewCount())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .comments(comments)
                .build();
    }

    private CommentResponse toCommentResponse(com.pnu.basketball.domain.Comment comment) {
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
