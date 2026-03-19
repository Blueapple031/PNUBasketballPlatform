package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MatchRepository extends JpaRepository<Match, UUID> {

    Optional<Match> findByRecruitmentId(UUID recruitmentId);

    @Query("SELECT m FROM Match m JOIN MatchParticipation mp ON mp.match.id = m.id " +
            "WHERE mp.user.userId = :userId ORDER BY m.startAt DESC")
    List<Match> findByParticipantUserId(@Param("userId") Long userId);
}
