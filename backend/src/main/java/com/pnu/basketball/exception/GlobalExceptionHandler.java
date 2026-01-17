package com.pnu.basketball.exception;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(CustomException.class)
    public ResponseEntity<Map<String, Object>> handleCustomException(CustomException e) {
        log.error("CustomException: {}", e.getMessage());
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        
        Map<String, Object> error = new HashMap<>();
        error.put("code", e.getErrorCode().name());
        error.put("message", e.getMessage());
        
        response.put("error", error);
        
        return ResponseEntity.status(e.getErrorCode().getHttpStatus()).body(response);
    }
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> handleValidationException(MethodArgumentNotValidException e) {
        log.error("ValidationException: {}", e.getMessage());
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        
        Map<String, Object> error = new HashMap<>();
        error.put("code", ErrorCode.INVALID_INPUT.name());
        
        Map<String, String> details = new HashMap<>();
        e.getBindingResult().getAllErrors().forEach((errorItem) -> {
            String fieldName = ((FieldError) errorItem).getField();
            String errorMessage = errorItem.getDefaultMessage();
            details.put(fieldName, errorMessage);
        });
        
        error.put("message", "입력값 검증에 실패했습니다.");
        error.put("details", details);
        
        response.put("error", error);
        
        return ResponseEntity.status(ErrorCode.INVALID_INPUT.getHttpStatus()).body(response);
    }
    
    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleException(Exception e) {
        log.error("Unexpected error: ", e);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        
        Map<String, Object> error = new HashMap<>();
        error.put("code", ErrorCode.INTERNAL_SERVER_ERROR.name());
        error.put("message", ErrorCode.INTERNAL_SERVER_ERROR.getMessage());
        
        response.put("error", error);
        
        return ResponseEntity.status(ErrorCode.INTERNAL_SERVER_ERROR.getHttpStatus()).body(response);
    }
}

