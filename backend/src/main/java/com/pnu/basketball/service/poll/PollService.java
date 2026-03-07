package com.pnu.basketball.service.poll;

import com.pnu.basketball.dto.response.PollResponse;
import com.pnu.basketball.dto.response.VoteResultResponse;

import java.util.UUID;

public interface PollService {

    PollResponse getPollByPostId(UUID postId, Long userId);

    VoteResultResponse vote(Long userId, UUID postId, UUID optionId);
}
