package com.pnu.basketball.storage;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

/**
 * 로컬 개발용 인메모리 토큰 저장소.
 * Redis 없이 개발할 때 사용합니다.
 * 프로파일: local 또는 app.token-storage=memory
 */
@Slf4j
@Component
@ConditionalOnProperty(name = "app.token-storage", havingValue = "memory")
public class InMemoryTokenStorage implements TokenStorage {

    private final Map<String, String> store = new ConcurrentHashMap<>();

    @Override
    public void saveRefreshToken(Long userId, String token, long amount, TimeUnit unit) {
        String key = REFRESH_TOKEN_PREFIX + userId;
        store.put(key, token);
        log.debug("인메모리 저장: userId={} (TTL {} {}는 무시됨 - 앱 재시작 시 초기화)", userId, amount, unit);
    }

    @Override
    public String getRefreshToken(Long userId) {
        return store.get(REFRESH_TOKEN_PREFIX + userId);
    }

    @Override
    public void deleteRefreshToken(Long userId) {
        store.remove(REFRESH_TOKEN_PREFIX + userId);
    }
}
