package com.pnu.basketball.repository;

import com.pnu.basketball.domain.PollVote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PollVoteRepository extends JpaRepository<PollVote, UUID> {

    boolean existsByPoll_IdAndUser_UserId(UUID pollId, Long userId);

    Optional<PollVote> findByPoll_IdAndUser_UserId(UUID pollId, Long userId);

    List<PollVote> findByPoll_Id(UUID pollId);
}
