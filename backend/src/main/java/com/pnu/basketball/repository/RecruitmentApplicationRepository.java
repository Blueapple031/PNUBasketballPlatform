package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ApplicationStatus;
import com.pnu.basketball.domain.RecruitmentApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RecruitmentApplicationRepository extends JpaRepository<RecruitmentApplication, UUID> {

    List<RecruitmentApplication> findByRecruitmentId(UUID recruitmentId);

    List<RecruitmentApplication> findByRecruitmentIdAndStatus(UUID recruitmentId, ApplicationStatus status);

    Optional<RecruitmentApplication> findByRecruitmentIdAndApplicantUserId(UUID recruitmentId, Long applicantId);

    boolean existsByRecruitmentIdAndApplicantUserId(UUID recruitmentId, Long applicantId);

    long countByRecruitmentIdAndStatus(UUID recruitmentId, ApplicationStatus status);
}
