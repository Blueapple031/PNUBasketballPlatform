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
import com.pnu.basketball.repository.ClubMemberRepository;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.storage.TokenStorage;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.annotation.PostConstruct;

import java.util.Arrays;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleAuthServiceImpl implements GoogleAuthService {

    private final UserRepository userRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final JwtUtil jwtUtil;
    private final TokenStorage tokenStorage;

    @Value("${google.oauth2.web-client-id:}")
    private String webClientId;

    @Value("${google.oauth2.android-client-id:}")
    private String androidClientId;

    @Value("${google.oauth2.client-id:}")
    private String legacyClientId;

    @Value("${spring.security.oauth2.client.registration.google.client-id:}")
    private String springGoogleClientId;

    @PostConstruct
    public void logGoogleConfig() {
        int count = (int) Arrays.asList(webClientId, androidClientId, legacyClientId, springGoogleClientId).stream()
                .filter(id -> id != null && !id.isEmpty())
                .distinct()
                .count();
        log.info("구글 OAuth 설정: 허용 클라이언트 ID {}개 로드됨", count);
        if (count == 0) {
            log.warn("구글 클라이언트 ID가 하나도 설정되지 않음. application-secret.yml의 google.oauth2 확인 필요");
        }
    }

    @Override
    @Transactional
    public AuthResponse authenticate(GoogleLoginRequest request) {
        log.info("[구글로그인] authenticate 호출됨 - 토큰 검증 시작");
        try {
            GoogleIdToken idToken = verifyGoogleToken(request.getIdToken());

            if (idToken == null) {
                throw new CustomException(ErrorCode.GOOGLE_TOKEN_INVALID);
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String pictureUrl = (String) payload.get("picture");
            String googleId = payload.getSubject();

            boolean isNewUser = !userRepository.existsByGoogleId(googleId)
                    && !userRepository.existsByEmail(email);

            User user = userRepository.findByGoogleId(googleId)
                    .orElseGet(() -> {
                        return userRepository.findByEmail(email)
                                .map(existingUser -> {
                                    existingUser.linkGoogle(pictureUrl, googleId);
                                    return userRepository.save(existingUser);
                                })
                                .orElseGet(() -> {
                                    String realName = (name != null && !name.isEmpty()) ? name : email.split("@")[0];
                                    User newUser = User.builder()
                                            .email(email)
                                            .realName(realName)
                                            .profileImageUrl(pictureUrl)
                                            .loginType(LoginType.GOOGLE)
                                            .googleId(googleId)
                                            .build();
                                    log.info("구글 로그인 신규 사용자 생성: email={}, realName={}", email, realName);
                                    return userRepository.save(newUser);
                                });
                    });

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
        List<String> clientIds = Arrays.asList(webClientId, androidClientId, legacyClientId, springGoogleClientId).stream()
                .filter(id -> id != null && !id.isEmpty())
                .distinct()
                .collect(Collectors.toList());

        try {
            if (clientIds.isEmpty()) {
                log.error("Google Client ID가 설정되지 않았습니다.");
                return null;
            }

            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    new GsonFactory())
                    .setAudience(clientIds)
                    .build();

            return verifier.verify(idTokenString);
        } catch (Exception e) {
            log.error("구글 토큰 검증 실패: {}", e.getMessage());
            try {
                String[] parts = idTokenString.split("\\.");
                if (parts.length >= 2) {
                    String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
                    JsonNode node = new ObjectMapper().readTree(payload);
                    String aud = node.has("aud") ? node.get("aud").asText() : "없음";
                    log.error("토큰 aud: {}, 허용 ID: {}", aud, clientIds);
                }
            } catch (Exception ex) {
                log.debug("토큰 디코딩 실패: {}", ex.getMessage());
            }
            return null;
        }
    }

    private AuthResponse generateAuthResponse(User user, boolean isNewUser) {
        String accessToken = jwtUtil.generateAccessToken(
                user.getUserId(),
                user.getEmail(),
                user.getRealName(),
                user.getLoginType().name()
        );

        String refreshToken = jwtUtil.generateRefreshToken(user.getUserId());
        tokenStorage.saveRefreshToken(user.getUserId(), refreshToken, 7, TimeUnit.DAYS);

        boolean needsClubSelection = Boolean.TRUE.equals(user.getIsPnuStudent())
                && !clubMemberRepository.existsByUserUserId(user.getUserId());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(3600L)
                .user(AuthResponse.UserInfo.builder()
                        .userId(user.getUserId())
                        .email(user.getEmail())
                        .realName(user.getRealName())
                        .profileImageUrl(user.getProfileImageUrl())
                        .loginType(user.getLoginType())
                        .isNewUser(isNewUser)
                        .needsClubSelection(needsClubSelection)
                        .build())
                .build();
    }
}
