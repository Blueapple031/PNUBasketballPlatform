# 백엔드 자동 배포 가이드 (GitHub Actions + Docker)

`main` 브랜치의 `backend/**` 또는 `docker-compose.yml`이 변경되면 Docker 이미지를 빌드해
GitHub Container Registry(GHCR)에 push하고, 서버에서 `docker compose`로 재배포합니다.

---

## 1. 사전 준비

### 1.1 서버 설정 (Ubuntu)

```bash
# 1. 배포 디렉터리 생성
mkdir -p ~/PNUBasketballPlatform/config
mkdir -p ~/PNUBasketballPlatform/logs
cd ~/PNUBasketballPlatform

# 2. Docker / Docker Compose v2 플러그인 설치 확인
docker -v
docker compose version   # v2 플러그인 (하이픈 없는 "docker compose") 필요

# 3. .env 생성 (postgres 자격증명 + S3 백업 설정)
# .env.example을 참고해 ~/PNUBasketballPlatform/.env 로 직접 생성 (Git에는 없음)
```

> **현재 상태:** `docker-compose.yml`에 `postgres` 서비스가 준비되어 있지만, 운영 DB는 아직 AWS RDS에 있습니다.
> 인프라(컨테이너 + 백업 스크립트)만 먼저 구성한 상태이며, 실제 RDS → 컨테이너 데이터 이전/전환은 별도로 진행해야 합니다.
> 전환 전까지는 `config/application-secret.yml`의 `spring.datasource.url`이 계속 RDS를 가리켜야 합니다.

### 1.2 SSH 키 생성 (로컬 PC에서)

GitHub Actions가 서버에 접속하려면 **비밀번호 없는 SSH 키**가 필요합니다.

```bash
# 1. 배포 전용 키 생성 (기존 키와 별도)
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/deploy_key -N ""

# 2. 공개키를 서버에 등록
ssh-copy-id -i ~/.ssh/deploy_key.pub ubuntu@서버IP

# 3. 접속 테스트
ssh -i ~/.ssh/deploy_key ubuntu@서버IP
```

### 1.3 GitHub Secrets 등록

GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

| Secret 이름 | 설명 | 예시 |
|------------|------|------|
| `SSH_HOST` | 서버 IP 또는 도메인 | `172.31.35.164` |
| `SSH_USER` | SSH 로그인 사용자 | `ubuntu` |
| `SSH_PRIVATE_KEY` | 개인키 전체 내용 | `-----BEGIN OPENSSH PRIVATE KEY-----` ... |
| `SSH_PORT` | (선택) SSH 포트, 기본 22 | `22` |

GHCR 로그인은 워크플로우 내장 `GITHUB_TOKEN`을 사용하므로 별도 레지스트리 secret은 필요 없습니다.

**SSH_PRIVATE_KEY** 입력 방법:

```bash
# Windows (PowerShell)
Get-Content $env:USERPROFILE\.ssh\deploy_key -Raw

# Mac/Linux
cat ~/.ssh/deploy_key
```

출력된 전체 내용을 복사해 Secret에 붙여넣기 (줄바꿈 포함).

---

## 2. 배포 흐름

1. `main` 브랜치에 `backend/**` 또는 `docker-compose.yml` 변경사항 push
2. GitHub Actions가 자동 실행
3. Gradle로 JAR 빌드 (`bootJar`)
4. `backend/Dockerfile`로 이미지 빌드 → GHCR(`ghcr.io/blueapple031/pnubasketballplatform-backend`)에 push (`latest`, 커밋 SHA 태그)
5. `docker-compose.yml`을 서버 `~/PNUBasketballPlatform/`에 복사
6. SSH로 서버 접속 → `docker login ghcr.io` → `docker compose pull backend` → `docker compose up -d`
7. 사용하지 않는 이전 이미지 정리 (`docker image prune -f`)

`redis`, `postgres`는 `docker-compose.yml`에 정의된 컨테이너로 함께 관리되며, 데이터는 각각 named volume(`redis-data`, `postgres-data`)에 보존됩니다.

---

## 3. 프로파일 및 설정

컨테이너는 `SPRING_PROFILES_ACTIVE=prod`로 실행됩니다 (`docker-compose.yml`의 `environment`).

- `application.yml` (공통, 이미지에 포함)
- `application-prod.yml` (서버 전용) ← **서버에 직접 생성 필요**
- `application-secret.yml` (비밀값) ← Git에 올리지 말고 서버에만 둠

서버의 `~/PNUBasketballPlatform/config/`가 컨테이너 `/app/config`에 읽기 전용으로 마운트됩니다.

```
~/PNUBasketballPlatform/
├── docker-compose.yml       # CI가 매 배포마다 갱신
├── config/
│   ├── application-prod.yml       # app.token-storage: redis 등 (선택)
│   └── application-secret.yml     # DB, Redis, JWT, OAuth 비밀값 ← 필수!
└── logs/                    # 컨테이너 로그가 쌓이는 위치 (호스트에서 확인 가능)
```

**application-secret.yml 생성/수정 시 주의:**
1. 로컬의 `backend/src/main/resources/application-secret.yml`을 참고해 동일한 키로 작성
2. `spring.datasource.*` (RDS 접속 정보)는 기존과 동일하게 유지
3. **`spring.redis.host`를 `localhost`가 아닌 `redis`로 변경** ← Redis가 같은 docker network의 `redis` 컨테이너로 이동했기 때문에 필수

**application-prod.yml** 예시 (`backend/src/main/resources/application-prod.yml.example` 참고):

```yaml
app:
  token-storage: redis
```

---

## 4. 수동 배포 실행

GitHub → **Actions** → **Deploy Backend** → **Run workflow**
`backend/` 변경 없이도 수동으로 배포를 실행할 수 있습니다.

로컬에서 직접 재배포하고 싶다면 서버에서:

```bash
cd ~/PNUBasketballPlatform
docker compose pull backend
docker compose up -d
```

---

## 5. DB 백업 (S3)

`scripts/backup-db-to-s3.sh`가 `postgres` 컨테이너를 `pg_dump`로 덤프해 S3에 업로드합니다.

**사전 준비 (서버):**
1. AWS CLI 설치 (`sudo apt install awscli` 또는 `aws configure`로 자격증명 설정)
   - EC2라면 S3 write 권한이 있는 **IAM 인스턴스 역할**을 붙이는 걸 권장 (별도 키 관리 불필요)
   - 인스턴스 역할이 없다면 `.env`에 `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`를 채워서 사용
2. `.env`에 `S3_BACKUP_BUCKET`, `AWS_DEFAULT_REGION` 설정 (`.env.example` 참고)
3. 스크립트 실행 권한 확인: `chmod +x scripts/backup-db-to-s3.sh`

**수동 실행:**
```bash
cd ~/PNUBasketballPlatform
./scripts/backup-db-to-s3.sh
```

**정기 백업 (crontab):**
```bash
crontab -e
# 매일 새벽 3시 백업
0 3 * * * cd ~/PNUBasketballPlatform && ./scripts/backup-db-to-s3.sh >> logs/backup.log 2>&1
```

S3 버킷의 오래된 백업 자동 삭제는 스크립트가 아니라 **S3 버킷의 수명 주기(Lifecycle) 규칙**으로 설정하는 걸 권장합니다 (AWS 콘솔 → 버킷 → 관리 → 수명 주기 규칙).

---

## 6. 트러블슈팅

| 문제 | 확인 사항 |
|------|----------|
| SSH 연결 실패 | `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY` 확인, 서버 방화벽 22번 포트 개방 |
| GHCR pull 실패 (`unauthorized`) | 서버에서 `docker login ghcr.io`가 성공했는지 확인. 리포지토리가 private이면 패키지도 기본 private이므로 로그인 필요 |
| 컨테이너가 바로 종료됨 | `docker compose logs backend`로 에러 로그 확인 (대부분 `config/application-secret.yml` 누락/오타) |
| **DataSource 'url' not specified** | `config/application-secret.yml`이 서버에 있는지 확인. 이 파일 없으면 DB 연결 불가 |
| DB 연결 실패 | `spring.datasource.url/username/password` 확인 (RDS 보안그룹에서 서버 IP 허용 여부도 확인) |
| Redis 연결 실패 | `application-secret.yml`의 `spring.redis.host`가 `redis`(컨테이너 서비스명)로 되어 있는지 확인. `localhost`로 남아있으면 연결 안 됨 |
| 포트 충돌 | 기존 방식(native `java -jar`)이 남아있다면 `pkill -f app.jar`로 완전히 종료 후 컨테이너 기동 |
| 이미지가 오래된 버전으로 보임 | `docker compose pull backend`가 최신 태그를 받았는지, `docker images`로 로컬 캐시 확인 후 `docker compose up -d --force-recreate backend` |
| `postgres` 컨테이너 기동 실패 (`ports are not available`) | 호스트의 5432 포트가 이미 사용 중 (native postgres 등). `docker-compose.yml`의 포트 매핑을 바꾸거나 기존 프로세스 정리 |
| 백업 스크립트가 자격증명 오류로 실패 | `.env`의 `S3_BACKUP_BUCKET`/`AWS_DEFAULT_REGION` 확인, IAM 인스턴스 역할 또는 `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` 설정 여부 확인 |
