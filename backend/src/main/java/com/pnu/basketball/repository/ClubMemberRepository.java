package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ClubMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ClubMemberRepository extends JpaRepository<ClubMember, UUID> {
    Optional<ClubMember> findByUserUserId(Long userId);
    boolean existsByUserUserId(Long userId);
    long countByClub_Id(UUID clubId);
    List<ClubMember> findByClub_Id(UUID clubId);
}
