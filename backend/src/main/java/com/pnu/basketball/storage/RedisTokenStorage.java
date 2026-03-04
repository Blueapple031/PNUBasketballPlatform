package com.pnu.basketball.storage;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Slf4j
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(name = "app.token-storage", havingValue = "redis", matchIfMissing = true)
public class RedisTokenStorage implements TokenStorage {

    private final RedisTemplate<String, String> redisTemplate;

    @Override
    public void saveRefreshToken(Long userId, String token, long amount, TimeUnit unit) {
        redisTemplate.opsForValue().set(
                REFRESH_TOKEN_PREFIX + userId,
                token,
                amount,
                unit
        );
    }

    @Override
    public String getRefreshToken(Long userId) {
        return redisTemplate.opsForValue().get(REFRESH_TOKEN_PREFIX + userId);
    }

    @Override
    public void deleteRefreshToken(Long userId) {
        redisTemplate.delete(REFRESH_TOKEN_PREFIX + userId);
    }
}
