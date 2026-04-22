# 도시위원회 앱 (Dosicommu)

부산광역시 사하구의회 도시위원회 업무 관리 앱

---

## 기능

- 📅 회기별 이력 관리 (안건심사, 예산심사, 업무보고, 행감)
- 🔔 D-day 할일 알림
- 💬 단톡방 안내문 자동 생성
- 👥 위원 관리
- 🏢 부서 관리
- 📊 통계/현황

---

## 사전 검증(CI)

APK 빌드 전에 GitHub Actions `Flutter CI` 워크플로우에서 아래를 먼저 검증합니다.

1. `flutter pub get`
2. `flutter analyze`
3. `flutter test`
4. `flutter build apk --debug` (컴파일 확인)

PR을 올리면 자동으로 실행되어, 빌드 전에 오류를 미리 확인할 수 있습니다.

---

## APK 다운로드

1. GitHub → Actions 탭
2. 최신 "Build APK" 클릭
3. Artifacts에서 `dosicommu-apk` 다운로드
4. 안드로이드에서 설치

---

## GitHub Secrets 설정

| Name | Value |
|------|-------|
| `GOOGLE_SERVICES_JSON` | google-services.json 파일 내용 전체 |

---

## 설치 방법

1. APK 파일 다운로드
2. 안드로이드 → 설정 → 보안 → "알 수 없는 소스 허용"
3. APK 파일 설치
