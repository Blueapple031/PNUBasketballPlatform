package com.pnu.basketball.service.poll;

import com.pnu.basketball.domain.Poll;
import com.pnu.basketball.domain.PollOption;
import com.pnu.basketball.domain.PollVote;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.response.PollOptionResponse;
import com.pnu.basketball.dto.response.PollResponse;
import com.pnu.basketball.dto.response.VoteResultResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.PollOptionRepository;
import com.pnu.basketball.repository.PollRepository;
import com.pnu.basketball.repository.PollVoteRepository;
import com.pnu.basketball.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PollServiceImpl implements PollService {

    private final PollRepository pollRepository;
    private final PollOptionRepository pollOptionRepository;
    private final PollVoteRepository pollVoteRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public PollResponse getPollByPostId(UUID postId, Long userId) {
        Poll poll = pollRepository.findByPost_Id(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POLL_NOT_FOUND));

        List<PollOption> options = pollOptionRepository.findByPoll_IdOrderBySortOrder(poll.getId());
        List<PollVote> votes = pollVoteRepository.findByPoll_Id(poll.getId());

        Map<UUID, Long> voteCountByOption = votes.stream()
                .collect(Collectors.groupingBy(v -> v.getOption().getId(), Collectors.counting()));

        UUID myVoteOptionId = null;
        if (userId != null) {
            myVoteOptionId = pollVoteRepository.findByPoll_IdAndUser_UserId(poll.getId(), userId)
                    .map(v -> v.getOption().getId())
                    .orElse(null);
        }

        List<PollOptionResponse> optionResponses = options.stream()
                .map(opt -> PollOptionResponse.builder()
                        .id(opt.getId())
                        .text(opt.getOptionText())
                        .voteCount(voteCountByOption.getOrDefault(opt.getId(), 0L).intValue())
                        .build())
                .collect(Collectors.toList());

        return PollResponse.builder()
                .id(poll.getId())
                .question(poll.getQuestion())
                .options(optionResponses)
                .expiresAt(poll.getExpiresAt())
                .totalVotes(votes.size())
                .myVoteOptionId(myVoteOptionId)
                .build();
    }

    @Override
    @Transactional
    public VoteResultResponse vote(Long userId, UUID postId, UUID optionId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        Poll poll = pollRepository.findByPost_Id(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POLL_NOT_FOUND));

        if (poll.isExpired()) {
            throw new CustomException(ErrorCode.POLL_EXPIRED);
        }

        if (pollVoteRepository.existsByPoll_IdAndUser_UserId(poll.getId(), userId)) {
            throw new CustomException(ErrorCode.POLL_ALREADY_VOTED);
        }

        PollOption option = pollOptionRepository.findByIdAndPoll_Id(optionId, poll.getId())
                .orElseThrow(() -> new CustomException(ErrorCode.POLL_OPTION_NOT_FOUND));

        PollVote vote = PollVote.builder()
                .poll(poll)
                .option(option)
                .user(user)
                .build();
        pollVoteRepository.save(vote);

        return VoteResultResponse.builder()
                .pollId(poll.getId())
                .optionId(optionId)
                .message("투표가 반영되었습니다.")
                .build();
    }
}
