package com.pnu.basketball.service.recruitment;

import com.pnu.basketball.domain.RecruitmentGameFormat;
import com.pnu.basketball.domain.RecruitmentStatus;
import com.pnu.basketball.dto.request.RecruitmentApplyRequest;
import com.pnu.basketball.dto.request.RecruitmentCreateRequest;
import com.pnu.basketball.dto.response.RecruitmentDetailResponse;
import com.pnu.basketball.dto.response.RecruitmentListResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.UUID;

public interface RecruitmentService {

    RecruitmentDetailResponse create(Long userId, RecruitmentCreateRequest request);

    Page<RecruitmentListResponse> getList(RecruitmentStatus status, UUID locationId,
                                          RecruitmentGameFormat gameFormat,
                                          LocalDateTime startFrom, LocalDateTime startTo,
                                          Pageable pageable);

    RecruitmentDetailResponse getDetail(UUID recruitmentId, Long currentUserId);

    void apply(UUID recruitmentId, Long userId, RecruitmentApplyRequest request);

    void acceptApplication(UUID recruitmentId, UUID applicationId, Long userId);

    void rejectApplication(UUID recruitmentId, UUID applicationId, Long userId);

    RecruitmentDetailResponse confirm(UUID recruitmentId, Long userId);

    void cancel(UUID recruitmentId, Long userId);
}
