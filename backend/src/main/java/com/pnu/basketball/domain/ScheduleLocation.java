package com.pnu.basketball.domain;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * MVP 관리 장소 (일정 탭)
 */
@Getter
@RequiredArgsConstructor
public enum ScheduleLocation {
    NUNGNEUNG_BON("넉넉한터 본관 방향"),
    NUNGNEUNG_PARK("넉넉한터 공원 방향"),
    ONCHEON_BUSAN("온천천 부산대역 농구장");

    private final String displayName;

    public static boolean isValid(String location) {
        if (location == null || location.isBlank()) return false;
        for (ScheduleLocation loc : values()) {
            if (loc.name().equals(location) || loc.getDisplayName().equals(location)) {
                return true;
            }
        }
        return false;
    }

    public static String toDisplayName(String enumName) {
        try {
            return valueOf(enumName).getDisplayName();
        } catch (IllegalArgumentException e) {
            return enumName;
        }
    }
}
