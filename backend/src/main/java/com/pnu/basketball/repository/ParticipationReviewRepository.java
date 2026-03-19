package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ParticipationReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ParticipationReviewRepository extends JpaRepository<ParticipationReview, UUID> {

    List<ParticipationReview> findByMatchId(UUID matchId);

    boolean existsByMatchIdAndReviewerUserIdAndRevieweeUserId(UUID matchId, Long reviewerId, Long revieweeId);

    long countByRevieweeUserId(Long revieweeId);
}
