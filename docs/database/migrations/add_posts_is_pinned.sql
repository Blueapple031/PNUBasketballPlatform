-- posts 테이블에 is_pinned 컬럼 추가
ALTER TABLE posts ADD COLUMN IF NOT EXISTS is_pinned BOOLEAN NOT NULL DEFAULT false;
