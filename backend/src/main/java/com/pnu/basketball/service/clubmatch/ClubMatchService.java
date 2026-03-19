package com.pnu.basketball.service.clubmatch;

import com.pnu.basketball.dto.request.ClubMatchCreateRequest;
import com.pnu.basketball.dto.request.ClubMatchResultRequest;
import com.pnu.basketball.dto.response.ClubMatchRequestResponse;
import com.pnu.basketball.dto.response.ClubMatchResultResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface ClubMatchService {

    ClubMatchRequestResponse createRequest(Long userId, ClubMatchCreateRequest request);

    void attend(UUID requestId, Long userId);

    Page<ClubMatchRequestResponse> getRequests(Pageable pageable);

    ClubMatchRequestResponse getRequestDetail(UUID requestId);

    ClubMatchRequestResponse matchOpponent(UUID requestId, UUID awayClubId, Long userId);

    ClubMatchRequestResponse confirmMatch(UUID requestId, Long userId);

    ClubMatchResultResponse submitResult(UUID requestId, Long userId, ClubMatchResultRequest request);

    ClubMatchResultResponse approveResult(UUID requestId, Long userId);

    List<ClubMatchResultResponse> getPendingAdminApproval();

    ClubMatchResultResponse adminConfirm(UUID requestId);
}
