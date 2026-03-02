package com.pnu.basketball.service.board;

import com.pnu.basketball.dto.request.CreatePostRequest;
import com.pnu.basketball.dto.request.UpdatePostRequest;
import com.pnu.basketball.dto.response.PostDetailResponse;
import com.pnu.basketball.dto.response.PostResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface PostService {

    Page<PostResponse> getPostList(Pageable pageable);

    PostDetailResponse getPostDetail(Long postId);

    PostResponse createPost(Long userId, CreatePostRequest request);

    PostResponse updatePost(Long postId, Long userId, UpdatePostRequest request);

    void deletePost(Long postId, Long userId);
}
