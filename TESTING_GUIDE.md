# 🧪 테스트 준비 가이드 (Testing Guide)

> **딸바 (PNU Basketball Platform)** 인증 기능 테스트를 위한 상세 가이드  
> **작성일**: 2026-01

---

## 📋 목차

1. [필수 소프트웨어 설치 확인](#1-필수-소프트웨어-설치-확인)
2. [데이터베이스 설정](#2-데이터베이스-설정)
3. [Redis 설정](#3-redis-설정)
4. [환경 변수 설정](#4-환경-변수-설정-선택사항)
5. [Backend 빌드 및 실행](#5-backend-빌드-및-실행)
6. [Frontend 빌드 및 실행](#6-frontend-빌드-및-실행)
7. [API 테스트](#7-api-테스트)
8. [Frontend 통합 테스트](#8-frontend-통합-테스트)
9. [문제 해결 체크리스트](#9-문제-해결-체크리스트)
10. [테스트 시나리오](#10-테스트-시나리오)

---

## 1. 필수 소프트웨어 설치 확인

### Backend
- [ ] **Java 17 이상 설치 확인**
  ```bash
  java -version
  # Java 17 이상이어야 함
  ```
- [ ] **Gradle 설치 확인** (또는 Gradle Wrapper 사용)
  ```bash
  gradle -v
  # 또는 backend 폴더에 gradlew 파일이 있는지 확인
  ```

### Database & Cache
- [ ] **PostgreSQL 설치 및 실행 확인**
  ```bash
  psql --version
  # PostgreSQL 서비스 실행 확인
  ```
- [ ] **Redis 설치 및 실행 확인**
  ```bash
  redis-cli ping
  # PONG 응답이 나와야 함
  ```

### Frontend
- [ ] **Flutter SDK 설치 확인**
  ```bash
  flutter --version
  flutter doctor
  ```
- [ ] **Android Studio 또는 Xcode 설치** (모바일 테스트용)

---

## 2. 데이터베이스 설정

### PostgreSQL 데이터베이스 생성

```bash
# 방법 1: createdb 명령어 사용
createdb basketball_db

# 방법 2: psql에서 직접 생성
psql -U postgres
CREATE DATABASE basketball_db;
\q
```

### 스키마 적용

```bash
# 스키마 파일 실행
psql -U postgres -d basketball_db -f docs/database/schema.sql

# 또는 psql에서 직접 실행
psql -U postgres -d basketball_db
\i docs/database/schema.sql
\q
```

### 연결 테스트

```bash
psql -U postgres -d basketball_db
# 연결 성공 시 프롬프트가 나타남
\dt  # 테이블 목록 확인
\q   # 종료
```

---

## 3. Redis 설정

### Redis 서버 실행

```bash
# Windows
redis-server

# macOS (Homebrew)
brew services start redis

# Linux
sudo systemctl start redis
# 또는
redis-server
```

### Redis 연결 테스트

```bash
redis-cli ping
# PONG 응답 확인

# Redis에 직접 접속하여 테스트
redis-cli
> SET test "hello"
> GET test
> exit
```

---

## 4. 환경 변수 설정 (선택사항)

### Backend 환경 변수

`backend/src/main/resources/application.yml` 파일을 확인하고 필요시 수정:

```yaml
# PostgreSQL 설정
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/basketball_db
    username: postgres  # 본인의 PostgreSQL 사용자명
    password:          # 본인의 PostgreSQL 비밀번호

# Redis 설정
spring:
  redis:
    host: localhost
    port: 6379
    password:  # Redis 비밀번호가 있다면 설정

# JWT Secret (운영 환경에서는 반드시 변경!)
jwt:
  secret: your-secret-key-change-in-production-min-256-bits

# 구글 로그인 (테스트 시 선택사항)
google:
  oauth2:
    client-id: ${GOOGLE_CLIENT_ID:}  # 구글 로그인 테스트 시 필요
```

### 환경 변수로 설정하는 방법 (권장)

**Windows:**
```cmd
set GOOGLE_CLIENT_ID=your-client-id
set GOOGLE_CLIENT_SECRET=your-client-secret
set JWT_SECRET=your-secret-key-min-256-bits
```

**Linux/macOS:**
```bash
export GOOGLE_CLIENT_ID=your-client-id
export GOOGLE_CLIENT_SECRET=your-client-secret
export JWT_SECRET=your-secret-key-min-256-bits
```

---

## 5. Backend 빌드 및 실행

### 의존성 다운로드 및 빌드

```bash
cd backend

# Gradle Wrapper 사용 시
./gradlew build

# 또는 일반 Gradle 사용 시
gradle build
```

### 애플리케이션 실행

```bash
# Gradle Wrapper 사용 시
./gradlew bootRun

# 또는 일반 Gradle 사용 시
gradle bootRun

# 또는 빌드된 JAR 실행
java -jar build/libs/basketball-backend-0.0.1-SNAPSHOT.jar
```

### 실행 확인

- 서버가 정상적으로 시작되면 콘솔에 다음과 같은 메시지가 표시됩니다:
  ```
  Started BasketballApplication in X.XXX seconds
  ```
- 브라우저에서 접속 확인:
  - **Swagger UI**: `http://localhost:8080/swagger-ui.html`
  - **API Docs**: `http://localhost:8080/api-docs`

---

## 6. Frontend 빌드 및 실행

### 패키지 설치

```bash
cd frontend

# 패키지 설치
flutter pub get

# JSON Serialization 파일 생성 (필수!)
flutter pub run build_runner build --delete-conflicting-outputs
```

### API 엔드포인트 확인

`frontend/lib/core/constants/api_endpoints.dart` 파일 확인:
```dart
static const String baseUrl = 'http://localhost:8080';
```
- Backend 서버 주소와 일치하는지 확인
- 실제 기기에서 테스트하는 경우: `http://[본인IP]:8080`으로 변경 필요

### 앱 실행

```bash
# 에뮬레이터/시뮬레이터 실행
flutter emulators --launch <emulator_id>

# 앱 실행
flutter run

# 특정 디바이스에서 실행
flutter run -d <device_id>
```

### 실행 확인

- 앱이 정상적으로 실행되면 로그인 화면이 표시됩니다
- 콘솔에서 에러 메시지 확인

---

## 7. API 테스트

### Swagger UI를 통한 테스트

1. 브라우저에서 `http://localhost:8080/swagger-ui.html` 접속
2. API 엔드포인트 확인 및 테스트:
   - `POST /api/auth/signup` - 회원가입
   - `POST /api/auth/login` - 로그인
   - `GET /api/auth/check-email` - 이메일 중복 확인
   - `GET /api/auth/check-nickname` - 닉네임 중복 확인
   - `POST /api/auth/google` - 구글 로그인 (ID Token 필요)
   - `POST /api/auth/refresh` - 토큰 갱신
   - `GET /api/auth/me` - 현재 사용자 정보 (인증 필요)

### cURL을 통한 테스트

```bash
# 1. 회원가입
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test1234!",
    "nickname": "테스트유저",
    "phoneNumber": "010-1234-5678"
  }'

# 2. 로그인
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test1234!"
  }'

# 3. 이메일 중복 확인
curl -X GET "http://localhost:8080/api/auth/check-email?email=test@example.com"

# 4. 사용자 정보 조회 (인증 필요)
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Postman을 통한 테스트

1. Postman 설치 및 실행
2. Collection 생성:
   - `POST /api/auth/signup`
   - `POST /api/auth/login`
   - `GET /api/auth/me` (Authorization 헤더에 Bearer 토큰 추가)
3. 각 요청 테스트 및 응답 확인

---

## 8. Frontend 통합 테스트

### 로그인 화면 테스트

1. 앱 실행 후 로그인 화면 확인
2. 회원가입 버튼 클릭 → 회원가입 화면 이동 확인
3. **회원가입 테스트**:
   - 이메일: `test@example.com`
   - 비밀번호: `Test1234!`
   - 닉네임: `테스트유저`
   - 전화번호: `010-1234-5678` (선택)
4. **로그인 테스트**:
   - 위에서 생성한 계정으로 로그인
   - 성공 시 홈 화면으로 이동 확인

### 구글 로그인 테스트 (선택사항)

1. 구글 클라우드 콘솔에서 OAuth 2.0 클라이언트 ID 생성
2. `application.yml`에 클라이언트 ID 설정
3. 앱에서 "구글로 로그인" 버튼 클릭
4. 구글 계정 선택 및 로그인 확인

---

## 9. 문제 해결 체크리스트

### Backend 실행 오류

- [ ] PostgreSQL 서버가 실행 중인지 확인
- [ ] 데이터베이스 `basketball_db`가 생성되었는지 확인
- [ ] `application.yml`의 데이터베이스 연결 정보 확인
- [ ] Redis 서버가 실행 중인지 확인
- [ ] 포트 8080이 사용 중이 아닌지 확인

### Frontend 실행 오류

- [ ] `flutter pub get` 실행 완료 확인
- [ ] `build_runner` 실행 완료 확인 (JSON serialization 파일 생성)
- [ ] `api_endpoints.dart`의 baseUrl이 올바른지 확인
- [ ] Android/iOS 시뮬레이터가 실행 중인지 확인

### API 연결 오류

- [ ] Backend 서버가 실행 중인지 확인
- [ ] CORS 설정 확인 (개발 환경에서는 localhost 허용)
- [ ] 네트워크 연결 확인
- [ ] 실제 기기에서 테스트 시 IP 주소 확인

### 데이터베이스 오류

- [ ] PostgreSQL 서비스 실행 확인
- [ ] 데이터베이스 사용자 권한 확인
- [ ] 스키마가 정상적으로 적용되었는지 확인
  ```sql
  \dt  -- 테이블 목록 확인
  SELECT * FROM users;  -- 데이터 확인
  ```

---

## 10. 테스트 시나리오

### 기본 플로우 테스트

#### 1. 회원가입
- [ ] 이메일 중복 확인 API 호출
- [ ] 닉네임 중복 확인 API 호출
- [ ] 회원가입 API 호출
- [ ] 응답에서 Access Token, Refresh Token 확인

#### 2. 로그인
- [ ] 로그인 API 호출
- [ ] 응답에서 토큰 확인
- [ ] 토큰이 Secure Storage에 저장되었는지 확인

#### 3. 사용자 정보 조회
- [ ] `/api/auth/me` API 호출 (인증 헤더 포함)
- [ ] 사용자 정보 응답 확인

#### 4. 토큰 갱신
- [ ] Access Token 만료 시뮬레이션
- [ ] Refresh Token으로 새 Access Token 발급 확인

#### 5. 로그아웃
- [ ] 로그아웃 API 호출
- [ ] 토큰이 삭제되었는지 확인

---

## 🚀 빠른 시작 명령어 요약

```bash
# 1. PostgreSQL 데이터베이스 생성
createdb basketball_db
psql -U postgres -d basketball_db -f docs/database/schema.sql

# 2. Redis 실행 (별도 터미널)
redis-server

# 3. Backend 실행
cd backend
./gradlew bootRun

# 4. Frontend 실행 (별도 터미널)
cd frontend
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 📝 참고 사항

### 테스트 계정 예시

```
이메일: test@example.com
비밀번호: Test1234!
닉네임: 테스트유저
```

### 주요 엔드포인트

| 엔드포인트 | 메서드 | 인증 필요 | 설명 |
|-----------|--------|----------|------|
| `/api/auth/signup` | POST | ❌ | 회원가입 |
| `/api/auth/login` | POST | ❌ | 로그인 |
| `/api/auth/google` | POST | ❌ | 구글 로그인 |
| `/api/auth/refresh` | POST | ❌ | 토큰 갱신 |
| `/api/auth/logout` | POST | ✅ | 로그아웃 |
| `/api/auth/me` | GET | ✅ | 사용자 정보 조회 |
| `/api/auth/check-email` | GET | ❌ | 이메일 중복 확인 |
| `/api/auth/check-nickname` | GET | ❌ | 닉네임 중복 확인 |

### 포트 정보

- **Backend**: `8080`
- **PostgreSQL**: `5432`
- **Redis**: `6379`

---

**문서 작성일**: 2026년 1월  
**최종 수정일**: 2026년 1월  
**작성자**: 딸바 개발팀

