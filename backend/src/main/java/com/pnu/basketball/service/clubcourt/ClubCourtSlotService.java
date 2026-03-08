package com.pnu.basketball.service.clubcourt;

import com.pnu.basketball.dto.request.ClubCourtSlotCreateRequest;
import com.pnu.basketball.dto.request.ClubCourtSlotUpdateRequest;
import com.pnu.basketball.dto.response.ClubCourtSlotResponse;

import java.util.List;
import java.util.UUID;

public interface ClubCourtSlotService {
    List<ClubCourtSlotResponse> getCourtSlotsByClub(UUID clubId);

    /** 관리자 전용: 동아리장/매니저 검증 없이 생성 */
    ClubCourtSlotResponse createCourtSlotByAdmin(UUID clubId, ClubCourtSlotCreateRequest request);
    /** 관리자 전용: 동아리장/매니저 검증 없이 수정 */
    ClubCourtSlotResponse updateCourtSlotByAdmin(UUID clubId, UUID slotId, ClubCourtSlotUpdateRequest request);
    /** 관리자 전용: 동아리장/매니저 검증 없이 삭제 */
    void deleteCourtSlotByAdmin(UUID clubId, UUID slotId);
}
