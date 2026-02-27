#!/bin/bash
# 백엔드 애플리케이션 재시작 스크립트
# GitHub Actions 배포 시 서버에서 실행됨

set -e
cd ~/PNUBasketballPlatform

# 기존 프로세스 종료 (app.jar 또는 basketball 관련)
PID=$(pgrep -f "app.jar" || true)
if [ -n "$PID" ]; then
  echo "기존 프로세스 종료 중 (PID: $PID)"
  kill $PID 2>/dev/null || true
  sleep 3
  kill -9 $PID 2>/dev/null || true
fi

# JAR 실행 (application.yml 등 설정은 서버의 application-*.yml 참조)
echo "애플리케이션 시작 중..."
nohup java -jar app.jar --spring.profiles.active=prod > app.log 2>&1 &

echo "배포 완료. PID: $!"
