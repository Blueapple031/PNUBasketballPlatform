#!/bin/bash
# PostgreSQL 컨테이너(pnu-postgres)를 pg_dump로 백업해 S3에 업로드
# crontab에 등록해 주기적으로 실행 (예: 매일 새벽 3시)
#   0 3 * * * cd ~/PNUBasketballPlatform && ./scripts/backup-db-to-s3.sh >> logs/backup.log 2>&1

set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck disable=SC1091
[ -f .env ] && source .env

: "${POSTGRES_USER:?POSTGRES_USER not set (.env 확인)}"
: "${POSTGRES_DB:?POSTGRES_DB not set (.env 확인)}"
: "${S3_BACKUP_BUCKET:?S3_BACKUP_BUCKET not set (.env 확인)}"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="/tmp/pnu-db-${TIMESTAMP}.sql.gz"

echo "[$TIMESTAMP] pg_dump 시작 (db=${POSTGRES_DB})"
docker exec pnu-postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_FILE"

echo "[$TIMESTAMP] S3 업로드: s3://${S3_BACKUP_BUCKET}/postgres/${TIMESTAMP}.sql.gz"
aws s3 cp "$BACKUP_FILE" "s3://${S3_BACKUP_BUCKET}/postgres/${TIMESTAMP}.sql.gz"

rm -f "$BACKUP_FILE"
echo "[$TIMESTAMP] 백업 완료"
