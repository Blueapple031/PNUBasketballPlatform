# Nginx API 프록시 설정 참고

`/api/auth/kakao` 등 API 경로가 502를 반환할 때, 서버의 Nginx 설정을 점검할 때 참고하세요.

---

## 1. 확인할 Nginx 설정

서버(예: ddalba.duckdns.org)에 SSH 접속 후:

```bash
# Nginx 설정 파일 위치 (Ubuntu/Debian)
sudo cat /etc/nginx/sites-enabled/default
# 또는
sudo cat /etc/nginx/conf.d/*.conf
```

---

## 2. API 경로가 백엔드로 전달되어야 함

`/api` 경로가 Spring Boot(기본 포트 8080)로 프록시되어야 합니다.

### 예시 설정 (참고용)

```nginx
server {
    listen 80;
    server_name ddalba.duckdns.org;

    # HTTPS 리다이렉트 (Let's Encrypt 사용 시)
    # return 301 https://$server_name$request_uri;

    # API 요청 → Spring Boot로 전달
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 정적 파일 등 다른 location...
}
```

### HTTPS 사용 시

```nginx
server {
    listen 443 ssl;
    server_name ddalba.duckdns.org;

    ssl_certificate /etc/letsencrypt/live/ddalba.duckdns.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ddalba.duckdns.org/privkey.pem;

    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 3. 점검 체크리스트

| 항목 | 확인 방법 |
|------|----------|
| **백엔드 실행 여부** | `ps aux \| grep app.jar` 또는 `curl http://localhost:8080/api/health` |
| **proxy_pass 포트** | `proxy_pass http://127.0.0.1:8080` (Spring Boot 기본 포트) |
| **location /api/** | `/api/`로 시작하는 경로가 백엔드로 전달되는지 |
| **Nginx 재시작** | `sudo nginx -t && sudo systemctl reload nginx` |

---

## 4. 로컬에서 엔드포인트 테스트

```powershell
# 프로젝트 루트에서
.\scripts\verify-kakao-api.ps1 https://ddalba.duckdns.org
```

502가 나오면:
1. 서버 SSH 접속
2. `curl http://localhost:8080/api/health` → 백엔드 직접 응답 확인
3. Nginx 설정에서 `location /api/` → `proxy_pass` 확인
