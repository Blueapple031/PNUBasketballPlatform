package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Match;
import com.pnu.basketball.domain.MatchState;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface MatchRepository extends JpaRepository<Match, UUID> {
    List<Match> findByHomeClubIdOrAwayClubIdOrderByScheduledAtDesc(UUID homeClubId, UUID awayClubId);
    List<Match> findByStateOrderByScheduledAtAsc(MatchState state);
}