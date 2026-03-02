package com.pnu.basketball.service.board;

import com.pnu.basketball.domain.Post;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostResponse;
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
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostServiceImpl implements PostService {

    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<PostResponse> getPostList(Pageable pageable) {
        Page<Post> posts = postRepository.findAllNotDeleted(pageable);
        List<Long> postIds = posts.getContent().stream().map(Post::getPostId).toList();
        var countMap = postIds.isEmpty() ? java.util.Map.<Long, Long>of()
                : commentRepository.countByPostIds(postIds).stream()
                .collect(java.util.stream.Collectors.toMap(row -> (Long) row[0], row -> (Long) row[1]));
        return posts.map(p -> toPostResponseWithCount(p, countMap.getOrDefault(p.getPostId(), 0L)));
    }

    @Override
    @Transactional(readOnly = true)
    public PostDetailResponse getPostDetail(Long postId) {
        Post post = postRepository.findByIdAndDeletedAtIsNull(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        post.incrementViewCount();
        postRepository.save(post);

        long commentCount = commentRepository.findByPostIdAndDeletedAtIsNull(postId).size();
        return toPostDetailResponse(post, commentCount);
    }

    @Override
    @Transactional
    public PostResponse createPost(Long userId, CreatePostRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Post post = Post.builder()
                .user(user)
                .title(request.getTitle())
                .content(request.getContent())
                .build();

        Post saved = postRepository.save(post);
        return toPostResponse(saved);
    }

    @Override
    @Transactional
    public PostResponse updatePost(Long postId, Long userId, UpdatePostRequest request) {
        Post post = postRepository.findByIdAndDeletedAtIsNull(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        if (!post.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.ACCESS_DENIED, "본인 게시글만 수정할 수 있습니다.");
        }

        post.update(request.getTitle(), request.getContent());
        postRepository.save(post);

        return toPostResponse(post);
    }

    @Override
    @Transactional
    public void deletePost(Long postId, Long userId) {
        Post post = postRepository.findByIdAndDeletedAtIsNull(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        if (!post.getUser().getUserId().equals(userId)) {
            throw new CustomException(ErrorCode.ACCESS_DENIED, "본인 게시글만 삭제할 수 있습니다.");
        }

        post.softDelete();
        postRepository.save(post);
    }

    private PostResponse toPostResponse(Post post) {
        return toPostResponseWithCount(post, 0L);
    }

    private PostResponse toPostResponseWithCount(Post post, long commentCount) {
        return PostResponse.builder()
                .postId(post.getPostId())
                .userId(post.getUser().getUserId())
                .authorNickname(post.getUser().getNickname())
                .title(post.getTitle())
                .content(post.getContent())
                .viewCount(post.getViewCount())
                .commentCount((int) commentCount)
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .build();
    }

    private PostDetailResponse toPostDetailResponse(Post post, long commentCount) {
        List<com.pnu.basketball.dto.response.CommentResponse> comments = commentRepository
                .findByPostIdAndDeletedAtIsNull(post.getPostId())
                .stream()
                .map(c -> com.pnu.basketball.dto.response.CommentResponse.builder()
                        .commentId(c.getCommentId())
                        .postId(c.getPost().getPostId())
                        .userId(c.getUser().getUserId())
                        .authorNickname(c.getUser().getNickname())
                        .content(c.getContent())
                        .createdAt(c.getCreatedAt())
                        .updatedAt(c.getUpdatedAt())
                        .build())
                .collect(Collectors.toList());

        return PostDetailResponse.builder()
                .postId(post.getPostId())
                .userId(post.getUser().getUserId())
                .authorNickname(post.getUser().getNickname())
                .title(post.getTitle())
                .content(post.getContent())
                .viewCount(post.getViewCount())
                .commentCount((int) commentCount)
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .comments(comments)
                .build();
    }
}
