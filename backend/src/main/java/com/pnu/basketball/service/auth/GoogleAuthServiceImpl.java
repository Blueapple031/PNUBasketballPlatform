package com.pnu.basketball.service.auth;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.GoogleLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleAuthServiceImpl implements GoogleAuthService {
    
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final RedisTemplate<String, String> redisTemplate;
    
    @Value("${google.oauth2.client-id}")
    private String googleClientId;
    
    private static final String REFRESH_TOKEN_PREFIX = "refresh_token:";
    
    @Override
    @Transactional
    public AuthResponse authenticate(GoogleLoginRequest request) {
        try {
            // Google ID Token 검증
            GoogleIdToken idToken = verifyGoogleToken(request.getIdToken());
            
            if (idToken == null) {
                throw new CustomException(ErrorCode.GOOGLE_TOKEN_INVALID);
            }
            
            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String pictureUrl = (String) payload.get("picture");
            String googleId = payload.getSubject();
            
            // 기존 사용자 조회 또는 신규 생성
            User user = userRepository.findByGoogleId(googleId)
                    .orElseGet(() -> {
                        // 이메일로도 조회 (기존 이메일 로그인 사용자가 구글 로그인 시도)
                        return userRepository.findByEmail(email)
                                .map(existingUser -> {
                                    // 기존 사용자에 구글 정보 연결
                                    User updatedUser = User.builder()
                                            .userId(existingUser.getUserId())
                                            .email(existingUser.getEmail())
                                            .password(existingUser.getPassword())
                                            .nickname(existingUser.getNickname())
                                            .phoneNumber(existingUser.getPhoneNumber())
                                            .profileImageUrl(pictureUrl)
                                            .loginType(LoginType.GOOGLE)
                                            .googleId(googleId)
                                            .build();
                                    return userRepository.save(updatedUser);
                                })
                                .orElseGet(() -> {
                                    // 신규 사용자 생성
                                    String nickname = generateNickname(name, email);
                                    User newUser = User.builder()
                                            .email(email)
                                            .nickname(nickname)
                                            .profileImageUrl(pictureUrl)
                                            .loginType(LoginType.GOOGLE)
                                            .googleId(googleId)
                                            .build();
                                    log.info("구글 로그인 신규 사용자 생성: email={}, nickname={}", email, nickname);
                                    return userRepository.save(newUser);
                                });
                    });
            
            boolean isNewUser = user.getGoogleId() == null || 
                               !userRepository.existsByGoogleId(googleId);
            
            log.info("구글 로그인 성공: userId={}, email={}, isNewUser={}", user.getUserId(), email, isNewUser);
            
            return generateAuthResponse(user, isNewUser);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("구글 로그인 실패: ", e);
            throw new CustomException(ErrorCode.GOOGLE_API_ERROR);
        }
    }
    
    private GoogleIdToken verifyGoogleToken(String idTokenString) {
        try {
            if (googleClientId == null || googleClientId.isEmpty()) {
                log.warn("Google Client ID가 설정되지 않았습니다.");
                return null;
            }
            
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
            
            return verifier.verify(idTokenString);
        } catch (Exception e) {
            log.error("구글 토큰 검증 실패: ", e);
            return null;
        }
    }
    
    private String generateNickname(String name, String email) {
        String baseNickname = name != null && !name.isEmpty() ? name : email.split("@")[0];
        String nickname = baseNickname;
        int suffix = 1;
        
        while (userRepository.existsByNickname(nickname)) {
            nickname = baseNickname + suffix;
            suffix++;
        }
        
        return nickname;
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

