package com.pnu.basketball.domain;

/**
 * 경기 상태
 */
public enum MatchState {
    SCHEDULED,   // 예정됨
    READY,       // 준비됨 (시작 직전)
    ONGOING,     // 진행 중
    DONE,        // 종료됨
    CANCELLED    // 취소됨
}
