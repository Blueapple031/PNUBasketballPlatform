package com.pnu.basketball.service.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.KakaoLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.storage.TokenStorage;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class KakaoAuthServiceImpl implements KakaoAuthService {

    private static final String KAKAO_USER_ME_URL = "https://kapi.kakao.com/v2/user/me";

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final TokenStorage tokenStorage;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Override
    @Transactional
    public AuthResponse authenticate(KakaoLoginRequest request) {
        try {
            JsonNode kakaoUserInfo = fetchKakaoUserInfo(request.getAccessToken());

            if (kakaoUserInfo == null) {
                throw new CustomException(ErrorCode.KAKAO_TOKEN_INVALID);
            }

            String kakaoId = kakaoUserInfo.get("id").asText();
            String email = extractEmail(kakaoUserInfo, kakaoId);
            String nickname = extractNickname(kakaoUserInfo, email);
            String profileImageUrl = extractProfileImageUrl(kakaoUserInfo);

            boolean isNewUser = !userRepository.existsByKakaoId(kakaoId)
                    && !userRepository.existsByEmail(email);

            User user = userRepository.findByKakaoId(kakaoId)
                    .orElseGet(() -> userRepository.findByEmail(email)
                            .map(existingUser -> {
                                User updatedUser = User.builder()
                                        .userId(existingUser.getUserId())
                                        .email(existingUser.getEmail())
                                        .password(existingUser.getPassword())
                                        .nickname(existingUser.getNickname())
                                        .phoneNumber(existingUser.getPhoneNumber())
                                        .profileImageUrl(profileImageUrl)
                                        .loginType(LoginType.KAKAO)
                                        .googleId(existingUser.getGoogleId())
                                        .kakaoId(kakaoId)
                                        .build();
                                return userRepository.save(updatedUser);
                            })
                            .orElseGet(() -> {
                                String generatedNickname = generateNickname(nickname, email);
                                User newUser = User.builder()
                                        .email(email)
                                        .nickname(generatedNickname)
                                        .profileImageUrl(profileImageUrl)
                                        .loginType(LoginType.KAKAO)
                                        .kakaoId(kakaoId)
                                        .build();
                                log.info("카카오 로그인 신규 사용자 생성: email={}, nickname={}", email, generatedNickname);
                                return userRepository.save(newUser);
                            }));

            if (user.getDeletedAt() != null) {
                log.warn("탈퇴한 회원의 로그인 시도: userId={}, email={}", user.getUserId(), user.getEmail());
                throw new CustomException(ErrorCode.USER_DEACTIVATED, "이미 탈퇴한 회원입니다.");
            }

            user.updateLastLoginTime();
            userRepository.save(user);

            log.info("카카오 로그인 성공: userId={}, email={}, isNewUser={}", user.getUserId(), email, isNewUser);

            return generateAuthResponse(user, isNewUser);
        } catch (CustomException e) {
            throw e;
        } catch (Exception e) {
            log.error("카카오 로그인 실패: ", e);
            throw new CustomException(ErrorCode.KAKAO_API_ERROR);
        }
    }

    private JsonNode fetchKakaoUserInfo(String accessToken) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(accessToken);
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            HttpEntity<String> entity = new HttpEntity<>(headers);

            ResponseEntity<String> response = restTemplate.exchange(
                    KAKAO_USER_ME_URL,
                    HttpMethod.GET,
                    entity,
                    String.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                return objectMapper.readTree(response.getBody());
            }
            return null;
        } catch (Exception e) {
            log.error("카카오 사용자 정보 조회 실패: ", e);
            return null;
        }
    }

    private String extractEmail(JsonNode kakaoUserInfo, String kakaoId) {
        JsonNode kakaoAccount = kakaoUserInfo.get("kakao_account");
        if (kakaoAccount != null && kakaoAccount.has("email")) {
            String email = kakaoAccount.get("email").asText();
            if (email != null && !email.isEmpty()) {
                return email;
            }
        }
        return "kakao_" + kakaoId + "@kakao.user";
    }

    private String extractNickname(JsonNode kakaoUserInfo, String email) {
        JsonNode kakaoAccount = kakaoUserInfo.get("kakao_account");
        if (kakaoAccount != null) {
            JsonNode profile = kakaoAccount.get("profile");
            if (profile != null && profile.has("nickname")) {
                return profile.get("nickname").asText();
            }
        }
        return email.split("@")[0];
    }

    private String extractProfileImageUrl(JsonNode kakaoUserInfo) {
        JsonNode kakaoAccount = kakaoUserInfo.get("kakao_account");
        if (kakaoAccount != null) {
            JsonNode profile = kakaoAccount.get("profile");
            if (profile != null && profile.has("profile_image_url")) {
                return profile.get("profile_image_url").asText();
            }
        }
        return null;
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

        tokenStorage.saveRefreshToken(user.getUserId(), refreshToken, 7, TimeUnit.DAYS);

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
