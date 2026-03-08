package com.pnu.basketball.service.clubcourt;

import com.pnu.basketball.dto.request.ClubCourtSlotCreateRequest;
import com.pnu.basketball.dto.request.ClubCourtSlotUpdateRequest;
import com.pnu.basketball.dto.response.ClubCourtSlotResponse;

import java.util.List;
import java.util.UUID;

public interface ClubCourtSlotService {
    List<ClubCourtSlotResponse> getCourtSlotsByClub(UUID clubId);
    ClubCourtSlotResponse createCourtSlot(Long userId, UUID clubId, ClubCourtSlotCreateRequest request);
    ClubCourtSlotResponse updateCourtSlot(Long userId, UUID clubId, UUID slotId, ClubCourtSlotUpdateRequest request);
    void deleteCourtSlot(Long userId, UUID clubId, UUID slotId);
}
