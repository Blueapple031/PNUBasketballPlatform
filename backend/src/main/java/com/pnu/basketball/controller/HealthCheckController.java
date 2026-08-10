package com.pnu.basketball.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthCheckController {

    private final LocalDateTime startTime = LocalDateTime.now();

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", LocalDateTime.now());
        response.put("service", "넉터(NUKTU)");
        response.put("version", "1.0.0");
        response.put("startTime", startTime);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/status")
    public ResponseEntity<Map<String, String>> getStatus() {
        Map<String, String> status = new HashMap<>();
        status.put("server", "running");
        status.put("database", "connected");
        status.put("environment", "AWS EC2");
        
        return ResponseEntity.ok(status);
    }
}
