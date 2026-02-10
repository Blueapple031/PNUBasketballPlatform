-- V1: Add last_login_at and deleted_at to users table

ALTER TABLE users ADD COLUMN last_login_at TIMESTAMP;
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP;

COMMENT ON COLUMN users.last_login_at IS '마지막 로그인 시간';
COMMENT ON COLUMN users.deleted_at IS '소프트 삭제 시간';
