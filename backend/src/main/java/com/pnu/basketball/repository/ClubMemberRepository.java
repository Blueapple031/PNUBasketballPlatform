package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Club;
import com.pnu.basketball.domain.ClubMember;
import com.pnu.basketball.domain.ClubMemberStatus;
import com.pnu.basketball.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClubMemberRepository extends JpaRepository<ClubMember, Long> {
    Optional<ClubMember> findByClubAndUser(Club club, User user);
    List<ClubMember> findByClubAndStatus(Club club, ClubMemberStatus status);
    boolean existsByClubAndUser(Club club, User user);
    List<ClubMember> findByClub(Club club);
}

