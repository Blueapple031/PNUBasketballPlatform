package com.pnu.basketball.service.clubcourt;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.domain.ClubCourtSlot;
import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.Venue;
import com.pnu.basketball.dto.request.ClubCourtSlotCreateRequest;
import com.pnu.basketball.dto.request.ClubCourtSlotUpdateRequest;
import com.pnu.basketball.dto.response.ClubCourtSlotResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ClubCourtSlotRepository;
import com.pnu.basketball.repository.ClubMemberRepository;
import com.pnu.basketball.repository.ClubRepository;
import com.pnu.basketball.repository.VenueRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ClubCourtSlotServiceImpl implements ClubCourtSlotService {

    private final ClubCourtSlotRepository clubCourtSlotRepository;
    private final ClubRepository clubRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final VenueRepository venueRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ClubCourtSlotResponse> getCourtSlotsByClub(UUID clubId) {
        if (!clubRepository.existsById(clubId)) {
            throw new CustomException(ErrorCode.CLUB_NOT_FOUND);
        }
        return clubCourtSlotRepository.findByClub_IdOrderByDayOfWeekAscStartTimeAsc(clubId).stream()
                .map(this::toClubCourtSlotResponse)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ClubCourtSlotResponse createCourtSlot(Long userId, UUID clubId, ClubCourtSlotCreateRequest request) {
        Club club = clubRepository.findById(clubId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_NOT_FOUND));
        validateClubCaptainOrManager(userId, club);

        Venue venue = venueRepository.findById(request.getVenueId())
                .orElseThrow(() -> new CustomException(ErrorCode.VENUE_NOT_FOUND));

        if (request.getStartTime().compareTo(request.getEndTime()) >= 0) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "종료 시간은 시작 시간보다 이후여야 합니다.");
        }

        ClubCourtSlot slot = ClubCourtSlot.builder()
                .club(club)
                .venue(venue)
                .dayOfWeek(request.getDayOfWeek())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .build();
        slot = clubCourtSlotRepository.save(slot);

        return toClubCourtSlotResponse(slot);
    }

    @Override
    @Transactional
    public ClubCourtSlotResponse updateCourtSlot(Long userId, UUID clubId, UUID slotId, ClubCourtSlotUpdateRequest request) {
        ClubCourtSlot slot = clubCourtSlotRepository.findById(slotId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_COURT_SLOT_NOT_FOUND));

        if (!slot.getClub().getId().equals(clubId)) {
            throw new CustomException(ErrorCode.CLUB_COURT_SLOT_NOT_FOUND);
        }
        validateClubCaptainOrManager(userId, slot.getClub());

        int dayOfWeek = request.getDayOfWeek() != null ? request.getDayOfWeek() : slot.getDayOfWeek();
        LocalTime startTime = request.getStartTime() != null ? request.getStartTime() : slot.getStartTime();
        LocalTime endTime = request.getEndTime() != null ? request.getEndTime() : slot.getEndTime();

        if (startTime.compareTo(endTime) >= 0) {
            throw new CustomException(ErrorCode.INVALID_INPUT, "종료 시간은 시작 시간보다 이후여야 합니다.");
        }

        slot.update(dayOfWeek, startTime, endTime);
        clubCourtSlotRepository.save(slot);
        return toClubCourtSlotResponse(slot);
    }

    @Override
    @Transactional
    public void deleteCourtSlot(Long userId, UUID clubId, UUID slotId) {
        ClubCourtSlot slot = clubCourtSlotRepository.findById(slotId)
                .orElseThrow(() -> new CustomException(ErrorCode.CLUB_COURT_SLOT_NOT_FOUND));

        if (!slot.getClub().getId().equals(clubId)) {
            throw new CustomException(ErrorCode.CLUB_COURT_SLOT_NOT_FOUND);
        }
        validateClubCaptainOrManager(userId, slot.getClub());

        clubCourtSlotRepository.delete(slot);
    }

    private void validateClubCaptainOrManager(Long userId, Club club) {
        ClubMember member = clubMemberRepository.findByUserUserId(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOT_CLUB_MEMBER));
        if (!member.getClub().getId().equals(club.getId())) {
            throw new CustomException(ErrorCode.NOT_CLUB_MEMBER);
        }
        boolean isCaptain = club.getCaptain() != null && club.getCaptain().getUserId().equals(userId);
        boolean isManager = member.getRole().name().equals("MANAGER");
        if (!isCaptain && !isManager) {
            throw new CustomException(ErrorCode.NOT_CLUB_CAPTAIN);
        }
    }

    private ClubCourtSlotResponse toClubCourtSlotResponse(ClubCourtSlot slot) {
        return ClubCourtSlotResponse.builder()
                .id(slot.getId())
                .clubId(slot.getClub().getId())
                .clubName(slot.getClub().getName())
                .venueId(slot.getVenue().getId())
                .venueName(slot.getVenue().getName())
                .dayOfWeek(slot.getDayOfWeek())
                .startTime(slot.getStartTime())
                .endTime(slot.getEndTime())
                .build();
    }
}
