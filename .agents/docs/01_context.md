# TookTook iOS — 프로젝트 컨텍스트

> AI가 이 프로젝트에 관한 모든 응답을 할 때 항상 참조해야 하는 기준입니다.

---

## 앱 기본 정보

| 항목 | 내용 |
|------|------|
| **앱 이름** | TookTook iOS |
| **조직** | FishOn |
| **플랫폼** | iPhone 전용 |
| **최소 iOS** | 17.0 |
| **Bundle ID (Dev)** | `net.ios.tooktook.dev` |
| **Bundle ID (Prod)** | `net.ios.tooktook` |
| **워크스페이스** | `TookTook.xcworkspace` |

## 개발 도구

| 도구 | 버전 / 내용 |
|------|------------|
| **Tuist** | 4.124.0 (mise로 버전 관리) |
| **Swift Package Manager** | Swift Tools 6.0 |
| **Fastlane** | 배포 자동화 (`fastlane/.env` 환경변수) |

## 외부 라이브러리

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| swift-composable-architecture | 1.21.1 | TCA 앱 아키텍처 |
| Alamofire | 5.10.2 | 네트워크 통신 |
| kakao-ios-sdk | 2.25.0 | 카카오 소셜 로그인 |
| firebase-ios-sdk | 11.14.0 | Analytics, Crashlytics |
| SDWebImageWebPCoder | 0.15.0 | WebP 이미지 처리 |
| EventSource | 0.1.5 | SSE(Server-Sent Events) |

## 빌드 환경

| 환경 | 명령어 | 특징 |
|------|--------|------|
| **Dev** | `make dev` | RevealApp 연동, dSYM 미생성 |
| **Prod** | `make prod` | Firebase Crashlytics 활성화, dSYM 생성 |

## 레이어 구조 및 모듈 규칙

```
App → Feature → Domain → Core → Shared
```

| 레이어 | 역할 | 네이밍 규칙 | 주요 모듈 |
|--------|------|------------|-----------|
| **App** | 진입점, AppCore | — | TookTook 타겟 |
| **Feature** | UI + TCA Reducer | `{기능명}Feature` | HomeFeature, RecordPostFeature 외 |
| **Domain** | 비즈니스 로직 | `{도메인명}Service` | AuthService, ProfileService 외 |
| **Core** | 외부 I/O 추상화 | `{기능명}Client` | APIClient, KeychainClient 외 |
| **Shared** | 공통 모듈 | 제한 없음 | DesignSystem, Utils, ThirdParty_* |

### 모듈 간 참조 원칙

- 모듈 간 참조는 반드시 **Source → Interface** 방향으로만 한다
- Feature가 다른 Feature를 참조할 때도 Interface 타겟만 참조한다
- **Feature가 Core 레이어(`APIClient` 등)를 직접 사용하는 것은 원칙적으로 금지**

```
// ❌ HomeFeature → ProfileFeatureSources
// ✅ HomeFeature → ProfileFeatureInterface
```

## 앱 화면 흐름

```
Splash
  ├─ 로그인 필요 → SocialLogin → MainTab
  └─ 이미 로그인 → MainTab
     └─ 로그아웃 / 토큰 만료 → SocialLogin
```

## 주요 명령어

```bash
make dev                                         # 개발 환경 프로젝트 생성
make prod                                        # 운영 환경 프로젝트 생성
make module layer="Feature" name="XxxFeature"   # 새 모듈 생성
make clean                                       # 빌드 파일 정리
make graph                                       # 모듈 의존성 그래프 생성

bundle exec fastlane deploy_all                  # Firebase Dev → TestFlight → App Store 전체
bundle exec fastlane appstore_release            # App Store 심사 제출만
```
