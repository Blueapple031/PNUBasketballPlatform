package com.pnu.basketball.service.admin;

import com.pnu.basketball.domain.MatchState;
import com.pnu.basketball.dto.request.*;
import com.pnu.basketball.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface AdminService {

    AdminStatsResponse getStats();

    Page<AdminUserListResponse> getUsers(Boolean isPnuStudent, String search, Pageable pageable);

    AdminUserDetailResponse getUserDetail(Long userId);

    Page<AdminClubListResponse> getClubs(Pageable pageable);

    AdminClubListResponse createClub(AdminCreateClubRequest request);

    List<AdminUserListResponse> getClubMembers(UUID clubId);

    void setCaptain(UUID clubId, AdminSetCaptainRequest request);

    Page<AdminMatchListResponse> getMatches(MatchState state, Pageable pageable);

    AdminMatchListResponse getMatchDetail(UUID matchId);

    AdminMatchListResponse updateMatch(UUID matchId, AdminUpdateMatchRequest request);

    // 게시글/댓글 관리
    Page<PostListResponse> getPosts(Pageable pageable);

    PostDetailResponse getPost(UUID postId);

    PostDetailResponse createPost(Long userId, CreatePostRequest request);

    PostDetailResponse updatePost(UUID postId, UpdatePostRequest request);

    void deletePost(UUID postId);

    PostDetailResponse pinPost(UUID postId, boolean isPinned);

    CommentResponse createComment(Long userId, UUID postId, CreateCommentRequest request);

    void deleteComment(UUID commentId);
}
