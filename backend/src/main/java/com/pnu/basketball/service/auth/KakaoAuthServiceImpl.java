package com.pnu.basketball.service.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.KakaoLoginRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ClubMemberRepository;
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
    private final ClubMemberRepository clubMemberRepository;
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
                                existingUser.linkKakao(profileImageUrl, kakaoId);
                                return userRepository.save(existingUser);
                            })
                            .orElseGet(() -> {
                                String realName = (nickname != null && !nickname.isEmpty()) ? nickname : email.split("@")[0];
                                User newUser = User.builder()
                                        .email(email)
                                        .realName(realName)
                                        .profileImageUrl(profileImageUrl)
                                        .loginType(LoginType.KAKAO)
                                        .kakaoId(kakaoId)
                                        .build();
                                log.info("카카오 로그인 신규 사용자 생성: email={}, realName={}", email, realName);
                                return userRepository.save(newUser);
                            }));

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
            log.warn("카카오 API 비정상 응답: status={}, body={}", response.getStatusCode(), response.getBody());
            return null;
        } catch (org.springframework.web.client.HttpClientErrorException e) {
            log.error("카카오 API HTTP 오류: status={}, body={}, msg={}", e.getStatusCode(), e.getResponseBodyAsString(), e.getMessage());
            return null;
        } catch (org.springframework.web.client.RestClientException e) {
            log.error("카카오 API 통신 실패: {}", e.getMessage());
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
