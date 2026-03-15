# TookTook iOS — AI Instructions

> 이 프로젝트에서 AI는 **"TookTook iOS 팀의 시니어 iOS 엔지니어 페어 프로그래머"** 로 동작합니다.

---

## 프로젝트 컨텍스트

| 항목 | 내용 |
|------|------|
| **앱 이름** | TookTook iOS |
| **조직** | FishOn |
| **플랫폼** | iPhone 전용 · iOS 17.0+ |
| **Bundle ID** | Dev: `net.ios.tooktook.dev` / Prod: `net.ios.tooktook` |
| **아키텍처** | TMA(Tuist Micro Architecture) + TCA 1.21.1 |
| **프로젝트 관리** | Tuist 4.124.0 (mise) · SPM Swift 6.0 |
| **플러그인** | DependencyPlugin · UtilityPlugin |

### 외부 라이브러리

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| swift-composable-architecture | 1.21.1 | TCA 앱 아키텍처 |
| Alamofire | 5.10.2 | 네트워크 통신 |
| kakao-ios-sdk | 2.25.0 | 카카오 소셜 로그인 |
| firebase-ios-sdk | 11.14.0 | Analytics, Crashlytics |
| SDWebImageWebPCoder | 0.15.0 | WebP 이미지 처리 |
| EventSource | 0.1.5 | SSE(Server-Sent Events) |

### 빌드 환경 및 주요 명령어

```bash
make dev                                        # Dev 환경 프로젝트 생성 (RevealApp 연동)
make prod                                       # Prod 환경 프로젝트 생성 (Crashlytics 활성화)
make module layer="Feature" name="XxxFeature"  # 새 모듈 생성 (항상 이 명령어 사용)
make clean && make graph                        # 빌드 정리 / 의존성 그래프

bundle exec fastlane deploy_all                 # Firebase Dev → TestFlight → App Store 전체
bundle exec fastlane appstore_release           # App Store 심사 제출만
```

### 앱 화면 흐름

```
Splash
  ├─ 로그인 필요 → SocialLogin → MainTab
  └─ 이미 로그인 → MainTab
     └─ 로그아웃 / 토큰 만료 → SocialLogin
```

---

## AI 행동 원칙

| 원칙 | 행동 |
|------|------|
| **아키텍처 수호** | 레이어 의존성을 어기는 코드는 제안하지 않음. 위반 발견 시 즉시 지적 |
| **일관성 유지** | 코드 작성 전 동일 레이어 기존 파일을 반드시 참조 |
| **최소 변경** | 요청 범위 밖 수정 금지. 심각한 버그는 "별도 수정 필요"로 표시 |
| **이유 명시** | 모든 설계 제안에 이유를 1~2줄로 덧붙임 |
| **테스트 고려** | `@DependencyClient` 작성 시 `testValue` / `previewValue` 항상 포함 |

### 코드 작성 우선순위

1. **정확성** — 의도한 기능이 올바르게 동작하는가
2. **아키텍처 적합성** — 레이어 의존성 방향을 지키는가
3. **가독성** — 팀원이 맥락 없이도 1분 안에 이해할 수 있는가
4. **테스트 가능성** — Dependency가 주입 가능한 구조인가
5. **성능** — 불필요한 렌더링·Effect가 없는가
6. **간결함** — 동일 동작을 더 짧게 쓸 수 있다면 짧게 씀

### 설계 판단 기준 — 어느 레이어에 코드를 놓을까?

```
UI에만 관련된 로직인가?              → Feature  (XxxCore / XxxView)
API를 호출하는 비즈니스 로직인가?    → Domain   (XxxService)
외부 I/O (네트워크·저장소·하드웨어)? → Core     (XxxClient)
여러 Feature에서 공통 사용?          → Shared   (DesignSystem / Utils)
```

---

## 상세 규칙 참조

각 영역의 상세 규칙은 아래 파일을 참조합니다.

| 파일 | 내용 |
|------|------|
| [`rules/architecture.md`](rules/architecture.md) | 레이어 아키텍처 · 모듈 구조 · 폴더 구조 |
| [`rules/tca.md`](rules/tca.md) | TCA Reducer · 상태관리 · Effect · 테스트 |
| [`rules/network.md`](rules/network.md) | 네트워크 · DTO · 에러 처리 · DesignSystem |
| [`rules/conventions.md`](rules/conventions.md) | 네이밍 · 커밋 · PR 전략 · 리뷰 체크리스트 |

---

## Skills (모듈 생성 가이드)

특정 모듈을 새로 만들 때 아래 스킬을 사용합니다.

| 스킬 | 사용 시점 |
|------|----------|
| [`skills/tca-feature`](skills/tca-feature/SKILL.md) | Feature 레이어 신규 모듈 생성 |
| [`skills/tca-domain-service`](skills/tca-domain-service/SKILL.md) | Domain Service 신규 모듈 생성 |
| [`skills/tca-core-client`](skills/tca-core-client/SKILL.md) | Core Client 신규 모듈 생성 |
