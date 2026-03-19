package com.pnu.basketball.repository;

import com.pnu.basketball.domain.RecruitmentPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface RecruitmentPostRepository extends JpaRepository<RecruitmentPost, UUID>,
        JpaSpecificationExecutor<RecruitmentPost> {

    Page<RecruitmentPost> findByAuthorUserIdOrderByCreatedAtDesc(Long authorId, Pageable pageable);

    @Query("""
            SELECT p FROM RecruitmentPost p
            WHERE p.location.id = :locationId
            AND p.status = com.pnu.basketball.domain.RecruitmentStatus.OPEN
            AND p.id != :excludeId
            AND p.startAt < :endAt
            AND p.endAt > :startAt
            """)
    List<RecruitmentPost> findOverlappingOpenPosts(
            @Param("locationId") UUID locationId,
            @Param("excludeId") UUID excludeId,
            @Param("startAt") LocalDateTime startAt,
            @Param("endAt") LocalDateTime endAt);
}
