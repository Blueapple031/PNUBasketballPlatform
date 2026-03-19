# 실제 DB 스키마 덤프 스크립트 (PowerShell)
# schema.sql을 현재 DB 구조와 동기화할 때 사용합니다.
#
# 사용법:
#   1. DB 접속 정보를 환경변수로 설정 (또는 아래 변수 수정)
#   2. docs/database 폴더에서 실행: .\dump_schema.ps1
#   3. actual_schema.sql 생성됨 → schema.sql과 diff 비교
#
# 환경변수 예시 (application-secret.yml 참고):
#   $env:PGHOST = "ddalba-rds.cjiaygo2w28p.ap-northeast-2.rds.amazonaws.com"
#   $env:PGPORT = "5432"
#   $env:PGDATABASE = "ddalba_DB"
#   $env:PGUSER = "postgre"

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputFile = Join-Path $scriptDir "actual_schema.sql"

# pg_dump 경로 (PostgreSQL이 PATH에 있어야 함)
$pgDump = "pg_dump"

Write-Host "DB 스키마 덤프 중..."
Write-Host "  출력: $outputFile"

& $pgDump `
    --schema-only `
    --no-owner `
    --no-privileges `
    -f $outputFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "오류: pg_dump 실패. 환경변수 확인: PGHOST, PGPORT, PGDATABASE, PGPASSWORD" -ForegroundColor Red
    exit 1
}

Write-Host "완료. schema.sql과 비교:"
Write-Host "  diff schema.sql actual_schema.sql"
Write-Host "  또는 WinMerge 등으로 schema.sql vs actual_schema.sql 비교"
