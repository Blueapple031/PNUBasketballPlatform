package com.pnu.basketball.service.admin;

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

    // 게시글/댓글 관리
    Page<PostListResponse> getPosts(Pageable pageable);

    PostDetailResponse getPost(UUID postId);

    PostDetailResponse createPost(Long userId, CreatePostRequest request);

    PostDetailResponse updatePost(UUID postId, UpdatePostRequest request);

    void deletePost(UUID postId);

    PostDetailResponse pinPost(UUID postId, boolean isPinned);

    CommentResponse createComment(Long userId, UUID postId, CreateCommentRequest request);

    void deleteComment(UUID commentId);

    // 일정 관리
    List<ScheduleResponse> getSchedules(java.time.LocalDate startDate, java.time.LocalDate endDate, String location);

    ScheduleResponse getSchedule(UUID id);

    ScheduleResponse createSchedule(ScheduleCreateRequest request);

    ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request);

    void deleteSchedule(UUID id);
}
