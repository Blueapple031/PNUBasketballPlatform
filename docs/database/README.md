# 딸바 데이터베이스 스키마

## 폴더 구조

```
docs/database/
├── schema.sql          # 메인 실행 파일 (전체 스키마 적용)
├── drop_all.sql        # 테이블/ENUM 전부 삭제
├── schemas/            # 도메인별 분리된 스키마
│   ├── 00_common.sql   # 확장(uuid-ossp), ENUM(match_state, club_role)
│   ├── 01_users.sql    # users (회원)
│   ├── 02_clubs.sql    # clubs, club_members (동아리)
│   ├── 03_matches.sql  # matches, match_participants (매치)
│   └── 04_posts.sql    # posts, comments (게시글)
└── migrations/         # 증분 마이그레이션 (컬럼 추가 등)
```

## 실행 방법

### 전체 스키마 적용 (신규 DB)

```bash
cd docs/database
psql -U postgres -d ddalba_DB -f schema.sql
```

또는 프로젝트 루트에서:

```bash
psql -U postgres -d ddalba_DB -f docs/database/schema.sql
```

> `\ir`(include relative)를 사용하므로 `schema.sql`이 있는 `docs/database/` 기준으로 `schemas/` 경로를 찾습니다.

### 기존 DB 초기화 후 재적용

```bash
psql -U postgres -d ddalba_DB -f docs/database/drop_all.sql
psql -U postgres -d ddalba_DB -f docs/database/schema.sql
```

### 마이그레이션 적용

`migrations/` 폴더의 SQL 파일을 순서대로 실행합니다.

```bash
psql -U postgres -d ddalba_DB -f docs/database/migrations/add_posts_is_pinned.sql
```

## 스키마 추가 시

1. `schemas/` 폴더에 새 파일 추가 (예: `05_polls.sql`)
2. `schema.sql`에 `\ir schemas/05_polls.sql` 추가
3. `drop_all.sql`에 새 테이블 DROP 추가 (자식 → 부모 순서)
