package com.pnu.basketball.repository;

import com.pnu.basketball.domain.PollOption;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PollOptionRepository extends JpaRepository<PollOption, UUID> {

    List<PollOption> findByPoll_IdOrderBySortOrder(UUID pollId);

    Optional<PollOption> findByIdAndPoll_Id(UUID optionId, UUID pollId);
}
