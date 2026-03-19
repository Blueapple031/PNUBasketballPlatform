package com.pnu.basketball.domain;

public enum ClubMatchStatus {
    GATHERING,   // 홈팀 인원 모집 중
    READY,       // 홈팀 5인 이상 확보, 상대 지정 가능
    MATCHED,     // 상대팀 지정 완료
    CONFIRMED,   // 양팀 5인 이상 확보, 일정 확정
    DONE,        // 경기 종료
    CANCELLED    // 취소
}
