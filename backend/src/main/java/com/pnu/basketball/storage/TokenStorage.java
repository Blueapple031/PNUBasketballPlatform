package com.pnu.basketball.storage;

import java.util.concurrent.TimeUnit;

/**
 * Refresh Token 저장소 인터페이스.
 * Redis 또는 인메모리 구현체를 사용할 수 있습니다.
 */
public interface TokenStorage {

    String REFRESH_TOKEN_PREFIX = "refresh_token:";

    void saveRefreshToken(Long userId, String token, long amount, TimeUnit unit);

    String getRefreshToken(Long userId);

    void deleteRefreshToken(Long userId);
}
