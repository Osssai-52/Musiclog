# 🎵 Musiclog

> **오늘의 감정을 기록하면, AI가 당신에게 어울리는 노래를 추천해드립니다.**

Musiclog는 일기와 음악을 연결하는 Flutter 기반 모바일 앱입니다. 매일의 감정과 생각을 일기로 기록하면, AI가 당신의 글을 분석하여 그 순간에 딱 맞는 노래를 추천해줍니다.

---

## ✨ 주요 기능

### 📝 일기 작성
- 매일의 감정과 생각을 자유롭게 기록
- 임시 저장(Draft) 기능으로 작성 중인 일기 보존
- 날짜별 일기 관리

### 🎧 AI 노래 추천
- OpenAI Embeddings를 활용한 의미론적 텍스트 분석
- 일기 내용과 노래 가사의 코사인 유사도 계산
- 당신의 감정에 가장 어울리는 노래를 자동 추천
- 추천 이유와 매칭된 가사 확인 가능

### 📅 캘린더 뷰
- 달력 형태로 일기 기록 한눈에 확인
- 추천된 노래의 앨범 커버로 날짜 표시
- 날짜 클릭 시 일기 상세 보기

### 📋 리스트 뷰
- 월별로 그룹화된 일기 목록
- 빠른 검색 및 탐색

### 📊 인사이트 (통계)
- 일기 작성 연속 기록(Streak) 확인
- 요일별 작성 패턴 분석
- 가장 많이 추천된 노래/아티스트 순위
- 월별 작성 추이 그래프

### ⚙️ 설정
- 🌓 다크/라이트 모드 전환
- 📏 텍스트 크기 조절
- 📤 Markdown/JSON 형식으로 일기 내보내기
- 🔄 사용된 노래 초기화 (중복 추천 허용)

---

## 🛠 사용 기술

| 분류 | 기술 |
|------|------|
| **Framework** | Flutter 3.x, Dart |
| **Local Database** | Hive |
| **AI/ML** | OpenAI Embeddings API |
| **Music API** | Apple Music API |
| **상태 관리** | ValueListenableBuilder, Provider Pattern |
| **UI** | Material Design 3, Custom Theme System |
| **기타** | table_calendar, shared_preferences, share_plus |

---

## 📱 페이지별 기능

| 페이지 | 기능 |
|--------|------|
| **홈 (캘린더)** | 달력에서 일기 작성 및 조회, 오늘 일기 작성 버튼 |
| **리스트** | 월별 일기 목록, 상세 보기 |
| **설정** | 내보내기, 인사이트, 테마 설정, 데이터 관리 |
| **인사이트** | 통계 대시보드, 작성 패턴 분석 |

---

## 👥 팀원

| 이름 | 역할 |
|------|------|
| **[팀원1 이름]** | [역할 - 예: Frontend, AI 추천 시스템] |
| **[팀원2 이름]** | [역할 - 예: UI/UX, 데이터 관리] |

---

## 📸 스크린샷

<!-- 움짤 4개 이상 또는 20초 이상의 동영상(사진 4장 이상) -->

| 캘린더 뷰 | 일기 작성 |
|:---------:|:---------:|
| ![캘린더](screenshots/calendar.gif) | ![일기 작성](screenshots/write.gif) |

| 노래 추천 | 인사이트 |
|:---------:|:---------:|
| ![추천](screenshots/recommend.gif) | ![통계](screenshots/insights.gif) |

<!-- 또는 동영상 링크 -->
<!-- 📹 [데모 영상 보기](https://youtube.com/your-demo-video) -->

---

## 📥 APK 다운로드

<!-- APK 파일 직접 업로드 또는 구글 드라이브 링크 -->
📦 [APK 다운로드 (Google Drive)](https://drive.google.com/your-apk-link)

또는 [Releases](https://github.com/Osssai-52/Musiclog/releases) 페이지에서 최신 버전을 다운로드하세요.

---

## 🚀 Getting Started

### 사전 요구사항
- Flutter SDK 3.10.4 이상
- Dart SDK
- Android Studio 또는 VS Code

### 설치 및 실행

```bash
# 저장소 클론
git clone https://github.com/Osssai-52/Musiclog.git
cd Musiclog

# 의존성 설치
flutter pub get

# Hive 어댑터 생성
flutter packages pub run build_runner build

# 앱 실행
flutter run
```

### 환경 변수 설정

`lib/constants/strings.dart` 파일에 API 키를 설정하세요:
```dart
class CustomStrings {
  static const clientId = 'YOUR_SPOTIFY_CLIENT_ID';
  static const clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
}
```

---

## 📂 프로젝트 구조

```
lib/
├── main.dart              # 앱 진입점
├── config/                # 테마 및 색상 설정
├── constants/             # 상수 정의
├── data/                  # 데이터 레이어
├── di/                    # 의존성 주입
├── domain/                # 도메인 레이어
│   ├── models/            # 데이터 모델 (DiaryEntry, Song 등)
│   ├── repositories/      # 리포지토리 인터페이스
│   ├── services/          # 서비스 (추천 서비스 등)
│   └── usecases/          # 유스케이스 (RecommendSongUseCase)
├── utils/                 # 유틸리티 함수
└── views/                 # UI 레이어
    ├── calendar_view.dart
    ├── list_view.dart
    ├── insights_view.dart
    ├── settings_view.dart
    └── widgets/           # 재사용 위젯
```

---

## 📄 라이선스

This project is licensed under the MIT License.

---

<p align="center">
  Made with ❤️ at <strong>KAIST 몰입캠프 2025 Winter</strong>
</p>
