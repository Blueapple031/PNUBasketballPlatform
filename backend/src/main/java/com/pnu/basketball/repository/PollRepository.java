package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Poll;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PollRepository extends JpaRepository<Poll, UUID> {

    Optional<Poll> findByPost_Id(UUID postId);

    boolean existsByPost_Id(UUID postId);
}
