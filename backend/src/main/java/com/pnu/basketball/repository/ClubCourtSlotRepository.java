package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ClubCourtSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClubCourtSlotRepository extends JpaRepository<ClubCourtSlot, UUID> {

    List<ClubCourtSlot> findByClub_IdOrderByDayOfWeekAscStartTimeAsc(UUID clubId);

    List<ClubCourtSlot> findByVenue_IdAndDayOfWeekOrderByStartTimeAsc(UUID venueId, int dayOfWeek);

    List<ClubCourtSlot> findByDayOfWeekOrderByStartTimeAsc(int dayOfWeek);
}
