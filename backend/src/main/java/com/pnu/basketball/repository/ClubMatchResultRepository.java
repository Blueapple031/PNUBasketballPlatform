package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ClubMatchResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClubMatchResultRepository extends JpaRepository<ClubMatchResult, UUID> {

    Optional<ClubMatchResult> findByRequestId(UUID requestId);

    @Query("SELECT r FROM ClubMatchResult r WHERE r.homeApproved = true AND r.awayApproved = true AND r.adminApproved = false")
    List<ClubMatchResult> findPendingAdminApproval();
}
