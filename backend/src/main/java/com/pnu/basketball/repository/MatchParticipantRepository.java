package com.pnu.basketball.repository;

import com.pnu.basketball.domain.MatchParticipant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface MatchParticipantRepository extends JpaRepository<MatchParticipant, UUID> {
    List<MatchParticipant> findByMatchId(UUID matchId);
    List<MatchParticipant> findByUserId(Long userId);
}
