package com.pnu.basketball.service.post;

import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostListResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface PostService {

    Page<PostListResponse> getPosts(Pageable pageable);

    PostDetailResponse getPost(UUID postId);

    PostDetailResponse createPost(Long userId, CreatePostRequest request);

    PostDetailResponse updatePost(Long userId, UUID postId, UpdatePostRequest request);

    void deletePost(Long userId, UUID postId);

    PostDetailResponse pinPost(Long userId, UUID postId, boolean isPinned);
}
