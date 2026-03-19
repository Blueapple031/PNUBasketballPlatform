# 백엔드 자동 배포 가이드 (GitHub Actions)

`main` 브랜치의 `backend/` 폴더가 변경되면 Ubuntu 서버로 자동 배포됩니다.

---

## 1. 사전 준비

### 1.1 서버 설정 (Ubuntu)

```bash
# 1. 배포 디렉터리 생성
mkdir -p ~/PNUBasketballPlatform
cd ~/PNUBasketballPlatform

# 2. Java 17 설치 확인
java -version  # OpenJDK 17 이상 필요

# 3. PostgreSQL, Redis 등 백엔드 의존 서비스 실행 중인지 확인
```

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

1. `main` 브랜치에 `backend/**` 변경사항 push
2. GitHub Actions가 자동 실행
3. Gradle로 JAR 빌드
4. SCP로 `app.jar`를 서버 `~/PNUBasketballPlatform/`에 전송
5. SSH로 기존 프로세스 종료 후 `java -jar app.jar` 실행

---

## 3. 프로파일 및 설정

서버에서는 `--spring.profiles.active=prod`로 실행됩니다.

- `application.yml` (공통)
- `application-prod.yml` (서버 전용) ← **서버에 직접 생성 필요**
- `application-secret.yml` (비밀값) ← Git에 올리지 말고 서버에만 둠

서버에 JAR와 같은 디렉터리에 `config/` 폴더를 만들어 설정을 넣습니다.
**application-secret.yml은 반드시 서버에 수동으로 생성해야 합니다.** (Git에 없음)

```
~/PNUBasketballPlatform/
├── app.jar
└── config/
    ├── application-prod.yml   # app.token-storage: redis 등 (선택)
    └── application-secret.yml # DB, Redis, JWT, OAuth 비밀값 ← 필수!
```

Spring Boot는 `app.jar`와 같은 디렉터리의 `config/`를 자동으로 읽습니다.

**application-secret.yml 생성 방법:**
1. 로컬의 `backend/src/main/resources/application-secret.yml.example` 참고
2. 서버에서 `mkdir -p ~/PNUBasketballPlatform/config`
3. `config/application-secret.yml` 파일 생성 후 spring.datasource, jwt.secret 등 채우기

**application-prod.yml** 예시 (`backend/src/main/resources/application-prod.yml.example` 참고):

```yaml
app:
  token-storage: redis
```

---

## 4. 수동 배포 실행

GitHub → **Actions** → **Deploy Backend** → **Run workflow**  
`backend/` 변경 없이도 수동으로 배포를 실행할 수 있습니다.

---

## 5. 트러블슈팅

| 문제 | 확인 사항 |
|------|----------|
| SSH 연결 실패 | `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY` 확인, 서버 방화벽 22번 포트 개방 |
| JAR 실행 실패 | 서버에서 `java -jar app.jar` 직접 실행해 에러 로그 확인 |
| **DataSource 'url' not specified** | `config/application-secret.yml`이 서버에 있는지 확인. 이 파일 없으면 DB 연결 불가. `application-secret.yml.example` 참고해 생성 |
| DB 연결 실패 | `application-secret.yml`의 spring.datasource.url, username, password 확인 (RDS 보안그룹에서 서버 IP 허용 여부도 확인) |
| Redis 연결 실패 | prod 프로파일 사용 시 Redis 필요. `config/application-secret.yml`에 redis.host/port 설정. Redis 미사용 시 `config/application-prod.yml`에 `app.token-storage: memory` 추가 |
| Spring Data Redis 로그 노이즈 | local 프로파일 사용 시 `application-local.yml`이 Redis 자동설정을 비활성화함 |
| 포트 충돌 | 기존 프로세스가 완전히 종료되지 않았을 수 있음 → `pkill -f app.jar` 후 재시작 |
