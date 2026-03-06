package com.pnu.basketball.service.auth;

import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.LoginRequest;
import com.pnu.basketball.dto.request.SignupRequest;
import com.pnu.basketball.dto.response.AuthResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ClubMemberRepository;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.storage.TokenStorage;
import com.pnu.basketball.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final ClubMemberRepository clubMemberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final TokenStorage tokenStorage;

    @Override
    @Transactional
    public AuthResponse signup(SignupRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new CustomException(ErrorCode.EMAIL_ALREADY_EXISTS);
        }

        if (Boolean.TRUE.equals(request.getIsPnuStudent()) && request.getStudentId() != null && !request.getStudentId().isBlank()) {
            if (userRepository.existsByStudentId(request.getStudentId())) {
                throw new CustomException(ErrorCode.STUDENT_ID_ALREADY_EXISTS);
            }
        }

        String encodedPassword = passwordEncoder.encode(request.getPassword());

        User user = User.builder()
                .email(request.getEmail())
                .password(encodedPassword)
                .realName(request.getRealName())
                .phoneNumber(request.getPhoneNumber())
                .dateOfBirth(request.getDateOfBirth())
                .isPnuStudent(request.getIsPnuStudent() != null ? request.getIsPnuStudent() : false)
                .department(request.getIsPnuStudent() != null && request.getIsPnuStudent() ? request.getDepartment() : null)
                .studentId(request.getIsPnuStudent() != null && request.getIsPnuStudent() ? request.getStudentId() : null)
                .loginType(LoginType.EMAIL)
                .build();

        user = userRepository.save(user);

        log.info("새 사용자 가입: userId={}, email={}", user.getUserId(), user.getEmail());

        return generateAuthResponse(user, false);
    }

    @Override
    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (user.getPassword() == null || !passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_CREDENTIALS);
        }

        log.info("사용자 로그인: userId={}, email={}", user.getUserId(), user.getEmail());

        return generateAuthResponse(user, false);
    }

    @Override
    public AuthResponse refreshToken(String refreshToken) {
        try {
            if (jwtUtil.isTokenExpired(refreshToken)) {
                throw new CustomException(ErrorCode.TOKEN_EXPIRED);
            }

            Long userId = jwtUtil.extractUserId(refreshToken);

            String storedToken = tokenStorage.getRefreshToken(userId);
            if (storedToken == null || !storedToken.equals(refreshToken)) {
                throw new CustomException(ErrorCode.INVALID_TOKEN);
            }

            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            String newAccessToken = jwtUtil.generateAccessToken(
                    user.getUserId(),
                    user.getEmail(),
                    user.getRealName(),
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
        tokenStorage.deleteRefreshToken(userId);
        log.info("사용자 로그아웃: userId={}", userId);
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
