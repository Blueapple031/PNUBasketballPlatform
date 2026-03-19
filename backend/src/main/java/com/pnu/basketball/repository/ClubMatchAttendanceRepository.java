package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ClubMatchAttendance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClubMatchAttendanceRepository extends JpaRepository<ClubMatchAttendance, UUID> {

    long countByRequestIdAndClubId(UUID requestId, UUID clubId);

    List<ClubMatchAttendance> findByRequestIdAndClubId(UUID requestId, UUID clubId);

    boolean existsByRequestIdAndClubIdAndUserUserId(UUID requestId, UUID clubId, Long userId);
}
