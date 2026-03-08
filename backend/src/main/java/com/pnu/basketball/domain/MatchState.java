package com.pnu.basketball.domain;

/**
 * 경기 상태
 */
public enum MatchState {
    SCHEDULED,   // 예정됨
    PENDING,     // 모집 중 (인원 미달)
    CONFIRMED,   // 확정됨 (인원 충족, 일정에 표시)
    READY,       // 준비됨 (시작 직전)
    ONGOING,     // 진행 중
    DONE,        // 종료됨
    CANCELLED    // 취소됨
}
