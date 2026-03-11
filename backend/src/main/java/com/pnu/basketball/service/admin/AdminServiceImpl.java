package com.pnu.basketball.service.admin;

import com.pnu.basketball.domain.*;
import com.pnu.basketball.dto.request.*;
import com.pnu.basketball.dto.response.*;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.*;
import com.pnu.basketball.dto.request.ScheduleCreateRequest;
import com.pnu.basketball.dto.request.ScheduleUpdateRequest;
import com.pnu.basketball.service.notification.FcmService;
import com.pnu.basketball.service.poll.PollService;
import com.pnu.basketball.service.schedule.ScheduleLocationService;
import com.pnu.basketball.service.schedule.ScheduleService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final UserRepository userRepository;
    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final PollRepository pollRepository;
    private final PollService pollService;
    private final FcmService fcmService;
    private final ScheduleService scheduleService;
    private final ScheduleLocationService scheduleLocationService;

    @Override
    @Transactional(readOnly = true)
    public AdminStatsResponse getStats() {
        long userCount = userRepository.count();
        long clubCount = clubRepository.count();
        return AdminStatsResponse.builder()
                .userCount(userCount)
                .clubCount(clubCount)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminUserListResponse> getUsers(Boolean isPnuStudent, String search, Pageable pageable) {
        String searchTrimmed = (search != null && !search.trim().isEmpty()) ? search.trim() : null;
        return userRepository.findAllForAdmin(isPnuStudent, searchTrimmed, pageable)
                .map(this::toAdminUserListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public AdminUserDetailResponse getUserDetail(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        String clubName = clubMemberRepository.findByUserUserId(userId)
                .map(cm -> cm.getClub().getName())
                .orElse(null);
        return AdminUserDetailResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .realName(user.getRealName())
                .phoneNumber(user.getPhoneNumber())
                .dateOfBirth(user.getDateOfBirth())
                .isPnuStudent(user.getIsPnuStudent())
                .department(user.getDepartment())
                .studentId(user.getStudentId())
                .clubName(clubName)
                .wins(user.getWins())
                .games(user.getGames())
                .totalScore(user.getTotalScore())
                .createdAt(user.getCreatedAt())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public Page<AdminClubListResponse> getClubs(Pageable pageable) {
        return clubRepository.findAll(pageable)
                .map(this::toAdminClubListResponse);
    }

    @Override
    @Transactional
    public AdminClubListResponse createClub(AdminCreateClubRequest request) {
        Club club = Club.builder()
                .name(request.getName())
                .logoUrl(request.getLogoUrl())
                .introduction(request.getIntroduction())
                .build();
        club = clubRepository.save(club);
        return toAdminClubListResponse(club);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminUserListResponse> getClubMembers(UUID clubId) {
        return clubMemberRepository.findByClub_Id(clubId).stream()
                .map(cm -> toAdminUserListResponse(cm.getUser()))
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public void setCaptain(UUID clubId, AdminSetCaptainRequest request) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));
        User newCaptain = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        ClubMember newCaptainMember = clubMemberRepository.findByClub_Id(clubId).stream()
                .filter(cm -> cm.getUser().getUserId().equals(request.getUserId()))
                .findFirst()
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_INPUT, "해당 동아리 멤버가 아닙니다."));

        clubMemberRepository.findByClub_Id(clubId).forEach(cm -> {
            if (cm.getRole() == ClubRole.PRESIDENT) {
                cm.setRole(ClubRole.MEMBER);
                clubMemberRepository.save(cm);
            }
        });

        newCaptainMember.setRole(ClubRole.PRESIDENT);
        clubMemberRepository.save(newCaptainMember);

        club.setCaptain(newCaptain);
        clubRepository.save(club);
    }

    private AdminUserListResponse toAdminUserListResponse(User user) {
        String clubName = clubMemberRepository.findByUserUserId(user.getUserId())
                .map(cm -> cm.getClub().getName())
                .orElse(null);
        return AdminUserListResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .realName(user.getRealName())
                .isPnuStudent(user.getIsPnuStudent())
                .department(user.getDepartment())
                .studentId(user.getStudentId())
                .clubName(clubName)
                .createdAt(user.getCreatedAt())
                .build();
    }

    private AdminClubListResponse toAdminClubListResponse(Club club) {
        String captainName = club.getCaptain() != null ? club.getCaptain().getRealName() : null;
        Long captainId = club.getCaptain() != null ? club.getCaptain().getUserId() : null;
        long memberCount = clubMemberRepository.countByClub_Id(club.getId());
        return AdminClubListResponse.builder()
                .clubId(club.getId())
                .name(club.getName())
                .logoUrl(club.getLogoUrl())
                .introduction(club.getIntroduction())
                .captainName(captainName)
                .captainId(captainId)
                .memberCount(memberCount)
                .build();
    }

    // ========== 게시글/댓글 관리 ==========

    @Override
    @Transactional(readOnly = true)
    public Page<PostListResponse> getPosts(Pageable pageable) {
        return postRepository.findAllByOrderByIsPinnedDescCreatedAtDesc(pageable)
                .map(this::toPostListResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public PostDetailResponse getPost(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
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
    public PostDetailResponse updatePost(UUID postId, UpdatePostRequest request) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
        post.update(request.getTitle(), request.getContent());
        postRepository.save(post);
        return toPostDetailResponse(post);
    }

    @Override
    @Transactional
    public void deletePost(UUID postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
        postRepository.delete(post);
    }

    @Override
    @Transactional
    public PostDetailResponse pinPost(UUID postId, boolean isPinned) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
        post.setPinned(isPinned);
        postRepository.save(post);

        if (isPinned) {
            fcmService.sendToAllUsers("공지", "새 공지: " + post.getTitle());
        }

        return toPostDetailResponse(post);
    }

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
    public void deleteComment(UUID commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMENT_NOT_FOUND));
        commentRepository.delete(comment);
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
                .isPinned(post.getIsPinned())
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
                .isPinned(post.getIsPinned())
                .createdAt(post.getCreatedAt())
                .updatedAt(post.getUpdatedAt())
                .comments(comments)
                .poll(pollRepository.findByPost_Id(post.getId())
                        .map(p -> pollService.getPollByPostId(post.getId(), null))
                        .orElse(null))
                .build();
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

    // ========== 매칭 장소 관리 ==========

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleLocationResponse> getScheduleLocations() {
        return scheduleLocationService.getAllLocations();
    }

    @Override
    @Transactional
    public ScheduleLocationResponse createScheduleLocation(ScheduleLocationCreateRequest request) {
        return scheduleLocationService.createLocation(request);
    }

    @Override
    @Transactional
    public ScheduleLocationResponse updateScheduleLocation(UUID id, ScheduleLocationUpdateRequest request) {
        return scheduleLocationService.updateLocation(id, request);
    }

    @Override
    @Transactional
    public void deleteScheduleLocation(UUID id) {
        scheduleLocationService.deleteLocation(id);
    }

    // ========== 일정 관리 ==========

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleResponse> getSchedules(LocalDate startDate, LocalDate endDate, UUID locationId) {
        return scheduleService.getSchedules(startDate, endDate, locationId);
    }

    @Override
    @Transactional(readOnly = true)
    public ScheduleResponse getSchedule(UUID id) {
        return scheduleService.getSchedule(id);
    }

    @Override
    @Transactional
    public ScheduleCreateResult createSchedule(ScheduleCreateRequest request) {
        return scheduleService.createSchedule(request);
    }

    @Override
    @Transactional
    public ScheduleResponse updateSchedule(UUID id, ScheduleUpdateRequest request) {
        return scheduleService.updateSchedule(id, request);
    }

    @Override
    @Transactional
    public void deleteSchedule(UUID id) {
        scheduleService.deleteSchedule(id);
    }
}
