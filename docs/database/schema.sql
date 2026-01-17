-- PostgreSQL Database Schema for 딸바 (PNU Basketball Platform)
-- 생성일: 2026-01

-- Users 테이블 생성
CREATE TABLE IF NOT EXISTS users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255),  -- NULL 가능 (구글 로그인 사용자)
    nickname VARCHAR(50) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    profile_image_url VARCHAR(500),
    login_type VARCHAR(20) NOT NULL DEFAULT 'EMAIL',  -- EMAIL, GOOGLE
    google_id VARCHAR(255) UNIQUE,  -- 구글 사용자 ID
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_nickname ON users(nickname);

-- updated_at 자동 업데이트를 위한 트리거 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- updated_at 트리거 생성
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 코멘트 추가
COMMENT ON TABLE users IS '사용자 정보 테이블';
COMMENT ON COLUMN users.user_id IS '사용자 ID (Primary Key)';
COMMENT ON COLUMN users.email IS '이메일 (Unique)';
COMMENT ON COLUMN users.password IS '암호화된 비밀번호 (구글 로그인 사용자는 NULL)';
COMMENT ON COLUMN users.nickname IS '닉네임 (Unique)';
COMMENT ON COLUMN users.phone_number IS '전화번호';
COMMENT ON COLUMN users.profile_image_url IS '프로필 이미지 URL';
COMMENT ON COLUMN users.login_type IS '로그인 타입 (EMAIL, GOOGLE)';
COMMENT ON COLUMN users.google_id IS '구글 사용자 ID (구글 로그인 사용자만)';
COMMENT ON COLUMN users.created_at IS '생성일시';
COMMENT ON COLUMN users.updated_at IS '수정일시';

