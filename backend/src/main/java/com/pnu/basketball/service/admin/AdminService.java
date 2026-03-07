package com.pnu.basketball.service.admin;

import com.pnu.basketball.domain.MatchState;
import com.pnu.basketball.dto.request.AdminCreateClubRequest;
import com.pnu.basketball.dto.request.AdminSetCaptainRequest;
import com.pnu.basketball.dto.request.AdminUpdateMatchRequest;
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
}
