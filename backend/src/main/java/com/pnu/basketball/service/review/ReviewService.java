package com.pnu.basketball.service.review;

import com.pnu.basketball.dto.request.ReviewSubmitRequest;
import com.pnu.basketball.dto.response.NoShowReportResponse;
import com.pnu.basketball.dto.response.ReviewFormResponse;

import java.util.List;
import java.util.UUID;

public interface ReviewService {

    ReviewFormResponse getReviewForm(UUID matchId, Long userId);

    void submitReview(UUID matchId, Long userId, ReviewSubmitRequest request);

    List<NoShowReportResponse> getPendingNoShowReports();

    void confirmNoShow(UUID reportId);

    void rejectNoShow(UUID reportId);
}
