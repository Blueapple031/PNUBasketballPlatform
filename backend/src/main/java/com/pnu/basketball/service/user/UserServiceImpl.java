package com.pnu.basketball.service.user;

import com.pnu.basketball.domain.LoginType;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.dto.request.CompleteProfileRequest;
import com.pnu.basketball.dto.request.UpdatePasswordRequest;
import com.pnu.basketball.dto.request.UpdateProfileRequest;
import com.pnu.basketball.dto.response.UserResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.UserRepository;
import com.pnu.basketball.storage.TokenStorage;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenStorage tokenStorage;
    
    @Override
    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        return toUserResponse(user);
    }
    
    @Override
    @Transactional
    public UserResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (request.getNickname() != null && !request.getNickname().isBlank()) {
            if (userRepository.existsByNicknameAndUserIdNot(request.getNickname(), userId)) {
                throw new CustomException(ErrorCode.NICKNAME_ALREADY_EXISTS);
            }
        }

        user.updateProfile(
                request.getRealName(),
                request.getPhoneNumber(),
                request.getProfileImageUrl(),
                request.getNickname(),
                request.getPosition()
        );
        
        return toUserResponse(user);
    }

    @Override
    @Transactional
    public UserResponse completeProfile(Long userId, CompleteProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (Boolean.TRUE.equals(request.getIsPnuStudent()) && request.getStudentId() != null && !request.getStudentId().isBlank()) {
            if (userRepository.existsByStudentIdAndUserIdNot(request.getStudentId(), userId)) {
                throw new CustomException(ErrorCode.STUDENT_ID_ALREADY_EXISTS);
            }
        }

        if (request.getNickname() != null && !request.getNickname().isBlank()) {
            if (userRepository.existsByNicknameAndUserIdNot(request.getNickname(), userId)) {
                throw new CustomException(ErrorCode.NICKNAME_ALREADY_EXISTS);
            }
        }

        user.completeProfile(
                request.getRealName(),
                request.getDateOfBirth(),
                request.getIsPnuStudent(),
                request.getIsPnuStudent() != null && request.getIsPnuStudent() ? request.getDepartment() : null,
                request.getIsPnuStudent() != null && request.getIsPnuStudent() ? request.getStudentId() : null,
                request.getNickname(),
                request.getPosition()
        );
        userRepository.save(user);

        return toUserResponse(user);
    }
    
    private UserResponse toUserResponse(User user) {
        return UserResponse.builder()
                .userId(user.getUserId())
                .email(user.getEmail())
                .realName(user.getRealName())
                .phoneNumber(user.getPhoneNumber())
                .profileImageUrl(user.getProfileImageUrl())
                .loginType(user.getLoginType())
                .dateOfBirth(user.getDateOfBirth())
                .isPnuStudent(user.getIsPnuStudent())
                .department(user.getDepartment())
                .studentId(user.getStudentId())
                .createdAt(user.getCreatedAt())
                .nickname(user.getNickname())
                .position(user.getPosition())
                .exp(user.getExp())
                .noShowCount(user.getNoShowCount())
                .participationCount(user.getParticipationCount())
                .build();
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean checkEmailAvailability(String email) {
        return !userRepository.existsByEmail(email);
    }
    
    @Override
    @Transactional(readOnly = true)
    public boolean checkRealNameAvailability(String realName) {
        return true;  // 본명은 동명이인 허용
    }

    @Override
    @Transactional
    public void updatePassword(Long userId, UpdatePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 소셜 로그인 사용자인지 확인
        if (user.getLoginType() == LoginType.GOOGLE || user.getLoginType() == LoginType.KAKAO) {
            throw new CustomException(ErrorCode.SOCIAL_LOGIN_USER_ACCESS_DENIED, "소셜 로그인 사용자는 비밀번호를 변경할 수 없습니다.");
        }

        // 현재 비밀번호 확인
        if (user.getPassword() == null || !passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_CURRENT_PASSWORD);
        }

        // 새 비밀번호 암호화 및 저장
        user.updatePassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    @Override
    @Transactional
    public void withdraw(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        tokenStorage.deleteRefreshToken(userId);
        userRepository.delete(user);
    }

    @Override
    @Transactional
    public void updateFcmToken(Long userId, String fcmToken) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        user.updateFcmToken(fcmToken);
        userRepository.save(user);
    }

    @Override
    @Transactional
    public void clearFcmToken(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        user.clearFcmToken();
        userRepository.save(user);
    }
}
