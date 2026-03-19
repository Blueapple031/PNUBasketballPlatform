package com.pnu.basketball.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    // 400 Bad Request
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "유효하지 않은 입력값입니다."),
    INVALID_EMAIL_FORMAT(HttpStatus.BAD_REQUEST, "유효하지 않은 이메일 형식입니다."),
    INVALID_PASSWORD_FORMAT(HttpStatus.BAD_REQUEST, "비밀번호는 8자 이상이며 영문, 숫자, 특수문자를 포함해야 합니다."),
    INVALID_TOKEN(HttpStatus.BAD_REQUEST, "유효하지 않은 토큰입니다."),
    
    // 401 Unauthorized
    UNAUTHORIZED(HttpStatus.UNAUTHORIZED, "인증이 필요합니다."),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 일치하지 않습니다."),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다."),
    GOOGLE_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "구글 토큰 검증에 실패했습니다."),
    KAKAO_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "카카오 토큰 검증에 실패했습니다."),
    SOCIAL_LOGIN_USER_ACCESS_DENIED(HttpStatus.FORBIDDEN, "소셜 로그인 사용자는 접근할 수 없습니다."),
    INVALID_CURRENT_PASSWORD(HttpStatus.BAD_REQUEST, "현재 비밀번호가 일치하지 않습니다."),
    USER_DEACTIVATED(HttpStatus.FORBIDDEN, "탈퇴한 회원입니다."),
    
    // 404 Not Found
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    
    // 409 Conflict
    EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다."),
    STUDENT_ID_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 등록된 학번입니다."),
    NICKNAME_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 사용 중인 닉네임입니다."),

    // Club
    CLUB_NOT_FOUND(HttpStatus.NOT_FOUND, "동아리를 찾을 수 없습니다."),
    NOT_PNU_STUDENT(HttpStatus.FORBIDDEN, "학생만 동아리에 가입할 수 있습니다."),
    ALREADY_IN_CLUB(HttpStatus.BAD_REQUEST, "이미 동아리에 가입되어 있습니다."),
    NOT_CLUB_CAPTAIN(HttpStatus.FORBIDDEN, "동아리장만 소개글을 수정할 수 있습니다."),

    // Post & Comment
    POST_NOT_FOUND(HttpStatus.NOT_FOUND, "게시글을 찾을 수 없습니다."),
    POLL_NOT_FOUND(HttpStatus.NOT_FOUND, "투표를 찾을 수 없습니다."),
    POLL_OPTION_NOT_FOUND(HttpStatus.NOT_FOUND, "선택지를 찾을 수 없습니다."),
    POLL_ALREADY_VOTED(HttpStatus.BAD_REQUEST, "이미 투표하셨습니다."),
    POLL_EXPIRED(HttpStatus.BAD_REQUEST, "만료된 투표입니다."),
    COMMENT_NOT_FOUND(HttpStatus.NOT_FOUND, "댓글을 찾을 수 없습니다."),
    UNAUTHORIZED_POST_EDIT(HttpStatus.FORBIDDEN, "본인의 게시글만 수정/삭제할 수 있습니다."),
    UNAUTHORIZED_COMMENT_EDIT(HttpStatus.FORBIDDEN, "본인의 댓글만 수정/삭제할 수 있습니다."),

    // Schedule
    SCHEDULE_NOT_FOUND(HttpStatus.NOT_FOUND, "일정을 찾을 수 없습니다."),
    SCHEDULE_OVERLAP(HttpStatus.CONFLICT, "해당 장소의 같은 날짜·시간대에 이미 일정이 등록되어 있습니다."),
    SCHEDULE_LOCATION_NOT_FOUND(HttpStatus.NOT_FOUND, "매칭 장소를 찾을 수 없습니다."),
    SCHEDULE_LOCATION_NAME_EXISTS(HttpStatus.CONFLICT, "이미 존재하는 장소명입니다."),
    SCHEDULE_LOCATION_IN_USE(HttpStatus.BAD_REQUEST, "해당 장소에 등록된 일정이 있어 삭제할 수 없습니다."),

    // 500 Internal Server Error
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다."),
    GOOGLE_API_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "구글 API 통신 중 오류가 발생했습니다."),
    KAKAO_API_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "카카오 API 통신 중 오류가 발생했습니다.");
    
    private final HttpStatus httpStatus;
    private final String message;
}
