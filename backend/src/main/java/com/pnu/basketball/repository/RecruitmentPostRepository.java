package com.pnu.basketball.repository;

import com.pnu.basketball.domain.RecruitmentPost;
import com.pnu.basketball.domain.RecruitmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.UUID;

@Repository
public interface RecruitmentPostRepository extends JpaRepository<RecruitmentPost, UUID> {

    @Query("SELECT r FROM RecruitmentPost r " +
            "WHERE (:status IS NULL OR r.status = :status) " +
            "AND (:locationId IS NULL OR r.location.id = :locationId) " +
            "AND (:gameFormat IS NULL OR r.gameFormat = :gameFormat) " +
            "AND (:startFrom IS NULL OR r.startAt >= :startFrom) " +
            "AND (:startTo IS NULL OR r.startAt <= :startTo) " +
            "ORDER BY r.createdAt DESC")
    Page<RecruitmentPost> findAllWithFilters(
            @Param("status") RecruitmentStatus status,
            @Param("locationId") UUID locationId,
            @Param("gameFormat") com.pnu.basketball.domain.RecruitmentGameFormat gameFormat,
            @Param("startFrom") LocalDateTime startFrom,
            @Param("startTo") LocalDateTime startTo,
            Pageable pageable);

    Page<RecruitmentPost> findByAuthorUserIdOrderByCreatedAtDesc(Long authorId, Pageable pageable);
}
