package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Match;
import com.pnu.basketball.domain.MatchState;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface MatchRepository extends JpaRepository<Match, UUID> {
    List<Match> findByHomeClubIdOrAwayClubIdOrderByScheduledAtDesc(UUID homeClubId, UUID awayClubId);
    List<Match> findByStateOrderByScheduledAtAsc(MatchState state);
}
feat(be): 카카오 소셜 로그인 API 추가

- KakaoAuthService, KakaoAuthServiceImpl 구현
- POST /api/auth/kakao 엔드포인트 추가
- KakaoLoginRequest DTO, ErrorCode(KAKAO_*), LoginType.KAKAO 추가
- UserRepository findByKakaoId, existsByKakaoId 추가
- Flutter 카카오 로그인 연동 (auth_service, auth_repository, login_screen)