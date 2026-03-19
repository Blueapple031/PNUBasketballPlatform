package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Club;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ClubRepository extends JpaRepository<Club, UUID> {
    boolean existsByName(String name);

    /** 승리 수 기준 내림차순 정렬 (순위용) */
    java.util.List<Club> findAllByOrderByWinsDesc();
}
