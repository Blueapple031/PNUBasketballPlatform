package com.pnu.basketball.repository;

import com.pnu.basketball.domain.MatchParticipation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MatchParticipationRepository extends JpaRepository<MatchParticipation, UUID> {

    List<MatchParticipation> findByMatchId(UUID matchId);

    boolean existsByMatchIdAndUserUserId(UUID matchId, Long userId);
}
