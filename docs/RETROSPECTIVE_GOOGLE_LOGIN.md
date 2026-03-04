# 구글 로그인 장애 회고 (Post-Mortem)

**일시**: 2026년 2월 22일  
**대상**: Flutter 앱 ↔ Spring Boot 백엔드 구글 OAuth 로그인  
**결과**: 해결 완료

---

## 1. 발생했던 오류들

### 1단계: ID 토큰을 가져올 수 없음
```
Exception: 구글 ID 토큰을 가져올 수 없습니다.
Android OAuth 및 GOOGLE_WEB_CLIENT_ID 설정을 확인하세요.
```

### 2단계: 토큰 검증 실패
```
CustomException: 구글 토큰 검증에 실패했습니다.
```

---

## 2. 근본 원인 분석

### 원인 1: Flutter에 Web Client ID 미전달

**문제**: `GOOGLE_WEB_CLIENT_ID`가 `String.fromEnvironment()`으로 읽히는데, 빌드 시 `--dart-define`으로 전달하지 않아 **빈 문자열**이 됨.

**결과**: `GoogleSignIn(serverClientId: null)` → Android에서 ID 토큰을 반환하지 않음.

**해결**: `defaultValue` 추가로 기본값 하드코딩
```dart
String.fromEnvironment('GOOGLE_WEB_CLIENT_ID',
  defaultValue: '234779227231-11ip2gu9o7bt1absesjmh1u58ovno9hv.apps.googleusercontent.com')
```

---

### 원인 2: 백엔드 Client ID 불일치

**문제**: 
- Flutter는 `serverClientId`(웹 클라이언트 ID)로 ID 토큰 발급 → 토큰의 `aud` = **웹 클라이언트 ID**
- 서버 `application-secret.yml`의 `google.oauth2.client-id`는 **Android 클라이언트 ID**로 설정됨
- `aud` ≠ 허용 ID → 검증 실패

**해결**: 
- `web-client-id`, `android-client-id` 둘 다 허용하도록 수정
- `spring.security.oauth2.client.registration.google.client-id`(웹 ID)를 폴백으로 추가

---

### 원인 3: 서버 application-secret.yml 미동기화

**문제**: `application-secret.yml`이 `.gitignore`에 포함되어 **Git에 올라가지 않음**.  
로컬과 서버의 설정이 달랐음.

- **로컬**: `web-client-id`, `android-client-id` 정상 설정
- **서버**: 예전 형식(`client-id`만 있고 Android ID로 설정) 또는 `google.oauth2` 섹션 누락

**해결**: `spring.security.oauth2.client.registration.google.client-id`를 폴백으로 사용해, 서버에 `google.oauth2`가 없어도 웹 클라이언트 ID로 검증 가능하게 함.

---

### 원인 4: Android / Web 클라이언트 ID 혼동

**혼동**: "왜 두 개가 필요한가?"

| 클라이언트 | 용도 | 사용 시점 |
|-----------|------|----------|
| **Android** | 앱 식별 (패키지명 + SHA-1) | 사용자가 "구글로 로그인" 탭할 때 |
| **Web** | 서버 검증용 ID 토큰 발급 | `serverClientId`로 ID 토큰의 `aud` 결정 |

`serverClientId` 없이 로그인하면 ID 토큰이 `null`이 됨.

---

## 3. 반성 및 교훈

### 개발 환경
- **로컬 vs 서버**: 로컬에서만 테스트하면 서버 설정 차이를 놓침
- **Gitignore 파일**: `.gitignore`된 설정은 배포 시 **수동 동기화** 필요
- **빌드 캐시**: `git pull`만으로는 부족. `./gradlew clean`으로 완전 재빌드 필요

### 설정 관리
- **민감 정보**: `application-secret.yml`은 Git에 올리지 않되, **예시 파일**(`application-secret.yml.example`)로 구조와 필수 키를 문서화할 것
- **환경별 검증**: 로컬/서버/스테이징 각각에서 동일 설정이 적용되는지 확인할 것

### 디버깅
- **초기 대응**: "토큰 검증 실패"만 보고는 원인 파악 불가
- **로그 강화**: `aud` 클레임, 허용 ID 목록, 예외 상세 로그를 추가해 원인 파악 시간 단축
- **단계별 검증**: 1) ID 토큰 수신 → 2) 백엔드 전달 → 3) 검증 로직을 단계별로 확인할 것

### OAuth 이해
- **플랫폼별 Client ID**: Android / Web / iOS 등 플랫폼마다 별도 Client ID 필요
- **serverClientId**: Android에서 서버 검증용 ID 토큰을 받으려면 Web Client ID를 `serverClientId`로 전달해야 함

---

## 4. 적용한 수정 사항 요약

| 위치 | 수정 내용 |
|------|----------|
| `auth_repository.dart` | `GOOGLE_WEB_CLIENT_ID`에 `defaultValue` 추가 |
| `application-secret.yml` | `web-client-id`, `android-client-id` 추가 |
| `GoogleAuthServiceImpl.java` | Web/Android/legacy/spring 4개 소스에서 Client ID 수집, 폴백 추가 |
| `GoogleAuthServiceImpl.java` | 검증 실패 시 `aud`·허용 ID·예외 상세 로그 출력 |

---

## 5. 향후 개선 사항

1. **application-secret.yml.example** 작성: 필수 키와 설명을 포함한 템플릿 제공
2. **배포 체크리스트**: 서버 배포 시 `application-secret.yml`의 `google.oauth2` 확인 항목 추가
3. **헬스체크**: 구글 OAuth 설정 로드 여부를 `/api/health` 등에서 간단히 확인

---

*"갑자기 된다"는 것은 우연이 아니라, 위 원인들이 순차적으로 해결된 결과다.*
