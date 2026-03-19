package com.pnu.basketball.repository;

import com.pnu.basketball.domain.RecruitmentPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface RecruitmentPostRepository extends JpaRepository<RecruitmentPost, UUID>,
        JpaSpecificationExecutor<RecruitmentPost> {

    Page<RecruitmentPost> findByAuthorUserIdOrderByCreatedAtDesc(Long authorId, Pageable pageable);
}
