package com.pnu.basketball.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DataAccessException;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthCheckController {

    private final LocalDateTime startTime = LocalDateTime.now();
    private final JdbcTemplate jdbcTemplate;
    private final RedisConnectionFactory redisConnectionFactory;
    private final String release;

    public HealthCheckController(
            JdbcTemplate jdbcTemplate,
            RedisConnectionFactory redisConnectionFactory,
            @Value("${app.release:unknown}") String release) {
        this.jdbcTemplate = jdbcTemplate;
        this.redisConnectionFactory = redisConnectionFactory;
        this.release = release;
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        return readiness();
    }

    @GetMapping("/health/live")
    public ResponseEntity<Map<String, Object>> liveness() {
        return ResponseEntity.ok(baseResponse("UP"));
    }

    @GetMapping("/health/ready")
    public ResponseEntity<Map<String, Object>> readiness() {
        Map<String, Object> response = baseResponse("UP");

        try {
            Integer databaseResult = jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            if (databaseResult == null || databaseResult != 1) {
                throw new IllegalStateException("unexpected database readiness result");
            }
            response.put("database", "UP");

            try (RedisConnection connection = redisConnectionFactory.getConnection()) {
                String pong = connection.ping();
                if (!"PONG".equalsIgnoreCase(pong)) {
                    throw new IllegalStateException("unexpected Redis readiness result");
                }
            }
            response.put("redis", "UP");
            return ResponseEntity.ok(response);
        } catch (DataAccessException | IllegalStateException exception) {
            response.put("status", "DOWN");
            response.put("dependencies", "UNAVAILABLE");
            return ResponseEntity.status(503).body(response);
        }
    }

    private Map<String, Object> baseResponse(String status) {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", status);
        response.put("timestamp", LocalDateTime.now());
        response.put("service", "PNU Basketball Platform");
        response.put("release", release);
        response.put("startTime", startTime);
        return response;
    }
}
