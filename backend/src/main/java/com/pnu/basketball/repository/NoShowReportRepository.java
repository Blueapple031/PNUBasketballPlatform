package com.pnu.basketball.repository;

import com.pnu.basketball.domain.NoShowReport;
import com.pnu.basketball.domain.NoShowReportStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NoShowReportRepository extends JpaRepository<NoShowReport, UUID> {

    List<NoShowReport> findByMatchId(UUID matchId);

    List<NoShowReport> findByStatus(NoShowReportStatus status);

    boolean existsByMatchIdAndReporterUserIdAndReportedUserUserId(UUID matchId, Long reporterId, Long reportedUserId);

    long countByMatchIdAndReportedUserUserId(UUID matchId, Long reportedUserId);
}
