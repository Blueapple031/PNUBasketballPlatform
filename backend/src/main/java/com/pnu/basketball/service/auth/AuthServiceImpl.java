package com.pnu.basketball.service.auth;

import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.LoginRequest;
import com.pnu.basketball.dto.request.SignupRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final RedisTemplate<String, String> redisTemplate;
    
    private static final String REFRESH_TOKEN_PREFIX = "refresh_token:";
    
    @Override
    @Transactional
    public AuthResponse signup(SignupRequest request) {
        // 이메일 중복 확인
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new CustomException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }
        
        // 닉네임 중복 확인
        if (userRepository.existsByNickname(request.getNickname())) {
            throw new CustomException(ErrorCode.NICKNAME_ALREADY_EXISTS);
        }
        
        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        
        // 사용자 생성
        User user = User.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .nickname(request.getNickname())
                .phoneNumber(request.getPhoneNumber())
                .loginType(LoginType.EMAIL)
                .build();
        
        user = userRepository.save(user);
        
        log.info("새 사용자 가입: userId={}, email={}", user.getUserId(), user.getEmail());
        
        // 토큰 발급
        return generateAuthResponse(user, false);
    }
    
    @Override
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        // 비밀번호 확인
        if (user.getPassword() == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_CREDENTIALS);
        }
        
        log.info("사용자 로그인: userId={}, email={}", user.getUserId(), user.getEmail());
        
        return generateAuthResponse(user, false);
    }
    
    @Override
    public AuthResponse refreshToken(String refreshToken) {
        try {
            // Refresh Token 검증
            if (jwtUtil.isTokenExpired(refreshToken)) {
                throw new CustomException(ErrorCode.TOKEN_EXPIRED);
            }
            
            Long userId = jwtUtil.extractUserId(refreshToken);
            
            // Redis에서 Refresh Token 확인
            String storedToken = redisTemplate.opsForValue().get(REFRESH_TOKEN_PREFIX + userId);
            if (storedToken == null || !storedToken.equals(refreshToken)) {
                throw new CustomException(ErrorCode.INVALID_TOKEN);
            }
            
            // 새로운 Access Token 발급
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
            
            String newAccessToken = jwtUtil.generateAccessToken(
                    user.getUserId(),
                    user.getEmail(),
                    user.getNickname(),
                    user.getLoginType().name()
            );
            
            log.info("토큰 갱신: userId={}", userId);
            
            return AuthResponse.builder()
                    .accessToken(newAccessToken)
                    .tokenType("Bearer")
                    .expiresIn(3600L)
                    .build();
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("토큰 갱신 실패: ", e);
            throw new CustomException(ErrorCode.INVALID_TOKEN);
        }
    }
    
    @Override
    public void logout(Long userId, String refreshToken) {
        // Redis에서 Refresh Token 삭제
        redisTemplate.delete(REFRESH_TOKEN_PREFIX + userId);
        log.info("사용자 로그아웃: userId={}", userId);
    }
    
    private AuthResponse generateAuthResponse(User user, boolean isNewUser) {
        String accessToken = jwtUtil.generateAccessToken(
                user.getUserId(),
                user.getEmail(),
                user.getNickname(),
                user.getLoginType().name()
        );
        
        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());
        
        // Redis에 Refresh Token 저장 (7일)
        redisTemplate.opsForValue().set(
                REFRESH_TOKEN_PREFIX + user.getUserId(),
                refreshToken,
                7,
                TimeUnit.DAYS
        );
        
        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(3600L)
                .user(AuthResponse.UserInfo.builder()
                        .userId(user.getUserId())
                        .email(user.getEmail())
                        .nickname(user.getNickname())
                        .profileImageUrl(user.getProfileImageUrl())
                        .loginType(user.getLoginType())
                        .isNewUser(isNewUser)
                        .build())
                .build();
    }
}

