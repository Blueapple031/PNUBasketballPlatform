package com.pnu.basketball.repository;

import com.pnu.basketball.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);
    Optional<User> findByKakaoId(String kakaoId);
    boolean existsByEmail(String email);
    boolean existsByNickname(String nickname);
    boolean existsByGoogleId(String googleId);
    boolean existsByKakaoId(String kakaoId);
}

