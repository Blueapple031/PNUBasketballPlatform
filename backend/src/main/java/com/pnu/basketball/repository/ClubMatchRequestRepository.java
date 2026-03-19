package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ClubMatchRequest;
import com.pnu.basketball.domain.ClubMatchStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ClubMatchRequestRepository extends JpaRepository<ClubMatchRequest, UUID> {

    Page<ClubMatchRequest> findByStatusInOrderByCreatedAtDesc(List<ClubMatchStatus> statuses, Pageable pageable);

    @Query("SELECT r FROM ClubMatchRequest r WHERE r.homeClub.id = :clubId OR r.awayClub.id = :clubId ORDER BY r.createdAt DESC")
    Page<ClubMatchRequest> findByClubId(@Param("clubId") UUID clubId, Pageable pageable);

    List<ClubMatchRequest> findByStatusOrderByCreatedAtDesc(ClubMatchStatus status);
}
