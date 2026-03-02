-- V3: 게시판 - posts, comments 테이블
-- users 테이블과 호환 (user_id BIGINT)
-- idempotent: 이미 존재하면 스킵 (IF NOT EXISTS)

-- ============================================================
-- posts 테이블
-- ============================================================
CREATE TABLE IF NOT EXISTS posts (
    post_id         BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    content         TEXT NOT NULL,
    view_count      INTEGER NOT NULL DEFAULT 0,
    deleted_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS tr_posts_updated_at ON posts;
CREATE TRIGGER tr_posts_updated_at
    BEFORE UPDATE ON posts FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

COMMENT ON TABLE posts IS '게시글';
COMMENT ON COLUMN posts.post_id IS '게시글 ID (Primary Key)';
COMMENT ON COLUMN posts.user_id IS '작성자 (users.user_id)';
COMMENT ON COLUMN posts.title IS '제목';
COMMENT ON COLUMN posts.content IS '본문';
COMMENT ON COLUMN posts.view_count IS '조회수';
COMMENT ON COLUMN posts.deleted_at IS '소프트 삭제 시간';
COMMENT ON COLUMN posts.created_at IS '생성일시';
COMMENT ON COLUMN posts.updated_at IS '수정일시';

-- ============================================================
-- comments 테이블
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
    comment_id      BIGSERIAL PRIMARY KEY,
    post_id         BIGINT NOT NULL REFERENCES posts(post_id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    content         VARCHAR(1000) NOT NULL,
    deleted_at      TIMESTAMP,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS tr_comments_updated_at ON comments;
CREATE TRIGGER tr_comments_updated_at
    BEFORE UPDATE ON comments FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

COMMENT ON TABLE comments IS '답글(댓글)';
COMMENT ON COLUMN comments.comment_id IS '답글 ID (Primary Key)';
COMMENT ON COLUMN comments.post_id IS '게시글 ID (posts.post_id)';
COMMENT ON COLUMN comments.user_id IS '작성자 (users.user_id)';
COMMENT ON COLUMN comments.content IS '답글 내용';
COMMENT ON COLUMN comments.deleted_at IS '소프트 삭제 시간';
COMMENT ON COLUMN comments.created_at IS '생성일시';
COMMENT ON COLUMN comments.updated_at IS '수정일시';

-- ============================================================
-- 인덱스
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_deleted_at ON posts(deleted_at);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_not_deleted_created ON posts(created_at DESC) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_deleted_at ON comments(deleted_at);
CREATE INDEX IF NOT EXISTS idx_comments_post_not_deleted ON comments(post_id) WHERE deleted_at IS NULL;
