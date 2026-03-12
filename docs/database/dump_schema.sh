#!/bin/bash
# 실제 DB 스키마 덤프 스크립트 (Bash)
# schema.sql을 현재 DB 구조와 동기화할 때 사용합니다.
#
# 사용법:
#   1. DB 접속 정보를 환경변수로 설정
#      export PGHOST=ddalba-rds.cjiaygo2w28p.ap-northeast-2.rds.amazonaws.com
#      export PGDATABASE=ddalba_DB
#      export PGUSER=postgre
#      export PGPASSWORD=...
#   2. docs/database 폴더에서 실행: ./dump_schema.sh
#   3. actual_schema.sql 생성됨 → schema.sql과 diff 비교

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT="$SCRIPT_DIR/actual_schema.sql"

echo "DB 스키마 덤프 중..."
echo "  출력: $OUTPUT"

pg_dump \
    --schema-only \
    --no-owner \
    --no-privileges \
    -f "$OUTPUT"

echo "완료. schema.sql과 비교:"
echo "  diff schema.sql actual_schema.sql"
