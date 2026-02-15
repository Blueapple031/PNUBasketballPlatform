-- Clubs 테이블 생성
CREATE TABLE IF NOT EXISTS clubs (
    club_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    captain_id BIGINT REFERENCES users(user_id),
    logo_url VARCHAR(500),
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Club_Members 테이블 생성 (다대다 관계)
CREATE TABLE IF NOT EXISTS club_members (
    club_id BIGINT REFERENCES clubs(club_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (club_id, user_id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_clubs_name ON clubs(name);
CREATE INDEX IF NOT EXISTS idx_club_members_club_id ON club_members(club_id);
CREATE INDEX IF NOT EXISTS idx_club_members_user_id ON club_members(user_id);

CREATE TRIGGER update_clubs_updated_at
    BEFORE UPDATE ON clubs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Clubs 테이블 코멘트
COMMENT ON TABLE clubs IS '동아리 정보 테이블';
COMMENT ON COLUMN clubs.club_id IS '동아리 ID (Primary Key)';
COMMENT ON COLUMN clubs.name IS '동아리 이름 (Unique)';
COMMENT ON COLUMN clubs.captain_id IS '주장 User ID (FK)';
COMMENT ON COLUMN clubs.logo_url IS '동아리 로고 이미지 URL';
COMMENT ON COLUMN clubs.description IS '동아리 설명';
COMMENT ON COLUMN clubs.created_at IS '생성일시';
COMMENT ON COLUMN clubs.updated_at IS '수정일시';

-- Club_Members 테이블 코멘트
COMMENT ON TABLE club_members IS '동아리-회원 관계 테이블';
COMMENT ON COLUMN club_members.club_id IS '동아리 ID (FK)';
COMMENT ON COLUMN club_members.user_id IS '사용자 ID (FK)';
COMMENT ON COLUMN club_members.joined_at IS '가입일시';
