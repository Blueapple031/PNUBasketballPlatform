#!/bin/bash
set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository_root="$(cd "$script_dir/../.." && pwd)"
docker_bin="${DOCKER_BIN:-docker}"
postgres_image=postgres:17-alpine@sha256:742f40ea20b9ff2ff31db5458d127452988a2164df9e17441e191f3b72252193
container="basketball-schema-ci-${GITHUB_RUN_ID:-local}-$$"

cleanup() {
  "$docker_bin" rm -f -v "$container" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for migration in \
  docs/database/schema.sql \
  docs/database/migrations/add_recruitment_posts.sql \
  docs/database/migrations/add_matches_and_participations.sql \
  docs/database/migrations/add_club_match_requests.sql; do
  test -s "$repository_root/$migration"
done

"$docker_bin" run --detach \
  --name "$container" \
  --tmpfs /var/lib/postgresql/data:rw,nosuid,size=512m \
  --env POSTGRES_USER=basketball \
  --env POSTGRES_PASSWORD=schema-test-only \
  --env POSTGRES_DB=basketball \
  "$postgres_image" >/dev/null

ready=false
attempt=1
while [ "$attempt" -le 60 ]; do
  if "$docker_bin" exec "$container" pg_isready -U basketball -d basketball >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 1
  attempt=$((attempt + 1))
done
if [ "$ready" != true ]; then
  echo "schema-test PostgreSQL did not become ready" >&2
  exit 1
fi

"$docker_bin" cp "$repository_root/docs/database" "$container:/bootstrap"
for migration in \
  schema.sql \
  migrations/add_recruitment_posts.sql \
  migrations/add_matches_and_participations.sql \
  migrations/add_club_match_requests.sql; do
  "$docker_bin" exec "$container" psql \
    --set ON_ERROR_STOP=1 \
    --username basketball \
    --dbname basketball \
    --file "/bootstrap/$migration" >/dev/null
done

table_count="$($docker_bin exec "$container" psql \
  --username basketball --dbname basketball --tuples-only --no-align \
  --command "select count(*) from pg_tables where schemaname = 'public';" | tr -d '[:space:]')"
if [ "$table_count" != 19 ]; then
  echo "fresh schema produced unexpected public table count: $table_count" >&2
  exit 1
fi

for table in users schedules recruitment_posts matches club_match_requests club_match_results; do
  "$docker_bin" exec "$container" psql \
    --username basketball --dbname basketball --tuples-only --no-align \
    --command "select 1 from pg_tables where schemaname = 'public' and tablename = '$table';" |
    grep -qx 1
done

echo "fresh PostgreSQL schema bootstrap passed: public_tables=$table_count"
