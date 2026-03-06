package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Club;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ClubRepository extends JpaRepository<Club, UUID> {
    boolean existsByName(String name);
}
