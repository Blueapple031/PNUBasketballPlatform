# schema.sql ↔ 실제 DB 동기화 가이드

`schema.sql`은 현재 DB 구조를 문서화한 참조 스키마입니다. 실제 DB와 차이가 있을 때 아래 절차로 동기화할 수 있습니다.

## 1. 실제 DB 스키마 덤프

### Windows (PowerShell)

```powershell
cd docs/database

# DB 접속 정보 설정 (application-secret.yml 참고)
$env:PGHOST = "ddalba-rds.cjiaygo2w28p.ap-northeast-2.rds.amazonaws.com"
$env:PGPORT = "5432"
$env:PGDATABASE = "ddalba_DB"
$env:PGUSER = "postgre"
$env:PGPASSWORD = "비밀번호"

.\dump_schema.ps1
```

### Linux / Mac

```bash
cd docs/database

export PGHOST=ddalba-rds.cjiaygo2w28p.ap-northeast-2.rds.amazonaws.com
export PGDATABASE=ddalba_DB
export PGUSER=postgre
export PGPASSWORD=비밀번호

./dump_schema.sh
```

실행 후 `actual_schema.sql`이 생성됩니다.

## 2. 차이 확인

- `actual_schema.sql`과 `schema.sql`을 diff로 비교
- WinMerge, VS Code, `diff schema.sql actual_schema.sql` 등 사용
- pg_dump 출력 형식이 다를 수 있으므로, **테이블/컬럼/타입/제약조건** 차이에 집중

## 3. schema.sql 수정

`actual_schema.sql`을 참고해 `schema.sql`을 수정합니다.

- 누락된 테이블/컬럼 추가
- 타입·제약조건 변경 반영
- 불필요한 항목 제거 (실제 DB에 없는 경우)

## 4. schemas/ 폴더 동기화

`schema.sql` 수정 후, 해당 변경을 `schemas/` 폴더의 개별 스키마 파일에도 반영하는 것이 좋습니다.

- `01_users.sql` – users
- `02_clubs.sql` – clubs, club_members
- `04_posts.sql` – posts, comments
- `05_polls.sql` – polls, poll_options, poll_votes
- `05_schedules.sql` – schedule_locations, schedules
