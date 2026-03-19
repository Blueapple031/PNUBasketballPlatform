package com.pnu.basketball.repository;

import com.pnu.basketball.domain.RecruitmentGameFormat;
import com.pnu.basketball.domain.RecruitmentPost;
import com.pnu.basketball.domain.RecruitmentStatus;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * PostgreSQL "could not determine data type of parameter" 오류 방지:
 * null 파라미터를 WHERE 절에 전달하지 않고, Specification으로 동적 쿼리 구성.
 */
public final class RecruitmentSpecification {

    private RecruitmentSpecification() {
    }

    public static Specification<RecruitmentPost> withFilters(
            RecruitmentStatus status,
            UUID locationId,
            RecruitmentGameFormat gameFormat,
            LocalDateTime startFrom,
            LocalDateTime startTo) {
        return Specification
                .where(statusEquals(status))
                .and(locationIdEquals(locationId))
                .and(gameFormatEquals(gameFormat))
                .and(startAtAfterOrEqual(startFrom))
                .and(startAtBeforeOrEqual(startTo));
    }

    private static Specification<RecruitmentPost> statusEquals(RecruitmentStatus status) {
        return (root, query, cb) -> status == null ? cb.conjunction() : cb.equal(root.get("status"), status);
    }

    private static Specification<RecruitmentPost> locationIdEquals(UUID locationId) {
        return (root, query, cb) -> locationId == null
                ? cb.conjunction()
                : cb.equal(root.get("location").get("id"), locationId);
    }

    private static Specification<RecruitmentPost> gameFormatEquals(RecruitmentGameFormat gameFormat) {
        return (root, query, cb) -> gameFormat == null
                ? cb.conjunction()
                : cb.equal(root.get("gameFormat"), gameFormat);
    }

    private static Specification<RecruitmentPost> startAtAfterOrEqual(LocalDateTime startFrom) {
        return (root, query, cb) -> startFrom == null
                ? cb.conjunction()
                : cb.greaterThanOrEqualTo(root.get("startAt"), startFrom);
    }

    private static Specification<RecruitmentPost> startAtBeforeOrEqual(LocalDateTime startTo) {
        return (root, query, cb) -> startTo == null
                ? cb.conjunction()
                : cb.lessThanOrEqualTo(root.get("startAt"), startTo);
    }
}
