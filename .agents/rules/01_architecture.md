# TookTook iOS — 아키텍처 규칙

> 이 프로젝트에서 반드시 지켜야 하는 **구조적 규칙**을 정의합니다.

---

## 프로젝트 컨텍스트

| 항목 | 내용 |
|------|------|
| **앱** | TookTook iOS · FishOn · iPhone 전용 · iOS 17.0+ |
| **Bundle ID** | Dev: `net.ios.tooktook.dev` / Prod: `net.ios.tooktook` |
| **프로젝트 관리** | Tuist 4.124.0 (mise) |
| **패키지 관리** | SPM · Swift 6.0 |
| **아키텍처** | TMA(Tuist Micro Architecture) + TCA(Composable Architecture) 1.21.1 |
| **플러그인** | DependencyPlugin(모듈 의존성) · UtilityPlugin(BuildConfiguration/AppEnv) |

---

## 규칙 1-1. 레이어 의존성 방향을 반드시 지킨다

```
App → Feature → Domain → Core → Shared
```

> **이유**: 역방향 의존이 생기면 모듈 간 순환 참조가 발생하고, 테스트 격리가 불가능해진다.

| 레이어 | 역할 | 의존 가능 |
|--------|------|-----------|
| **App** | 앱 진입점 | Feature |
| **Feature** | UI + TCA Reducer | Domain, Shared |
| **Domain** | 비즈니스 로직·Service | Core, Shared |
| **Core** | 외부 I/O 추상화 (Client) | Shared |
| **Shared** | DesignSystem·Utils·ThirdParty | 없음 |

```swift
// ❌ 금지: Feature에서 APIClient 직접 import
import APIClientInterface
@Dependency(APIClient.self) var apiClient

// ✅ 올바름: Domain의 Service를 통해 접근
import AuthServiceInterface
@Dependency(AuthService.self) var authService
```

---

## 규칙 1-2. 모듈 이름은 레이어별 컨벤션을 따른다

> **이유**: 파일명만으로 어느 레이어·역할인지 즉시 알아야 한다.

| 레이어 | 네이밍 규칙 | 예시 |
|--------|------------|------|
| **Feature** | `{기능명}Feature` | `HomeFeature`, `ProfileFeature` |
| **Domain** | `{도메인명}Service` | `AuthService`, `RecordPostService` |
| **Core** | `{기능명}Client` | `APIClient`, `KeychainClient` |
| **Shared** | 제한 없음 | `DesignSystem`, `Utils`, `Logger` |

---

## 규칙 1-3. 모듈 간 참조는 반드시 Interface 타겟을 통한다

> **이유**: Source(구현체)를 직접 참조하면 구현 세부사항에 결합된다. Interface만 참조하면 구현을 자유롭게 교체(테스트 목업, 서버 변경)할 수 있다.

```
// ❌ 금지: 구현체 직접 참조
HomeFeature → ProfileFeatureSources

// ✅ 올바름: Interface 타겟만 참조
HomeFeature → ProfileFeatureInterface
```

```swift
// ✅ 모듈 참조 예시 (DependencyPlugin 기반)
.dependency(module: Feature.ProfileFeature, type: .interface)  // Sources가 아닌 Interface
```

---

## 규칙 1-4. Interface 타겟에는 구현 코드를 넣지 않는다

> **이유**: Interface는 다른 모듈이 import하는 공개 계약이다. 구현이 섞이면 의존성 그래프가 복잡해지고 테스트 격리가 어려워진다.

```
XxxModule/
├── Interface/   ← 프로토콜·DTO·타입·@DependencyClient 정의만
└── Sources/     ← 실제 구현체 (DependencyKey 등록 포함)
```

---

## 규칙 1-5. 새 모듈은 반드시 `make module` 명령어로 생성한다

> **이유**: Tuist 템플릿이 자동으로 Interface / Sources / Testing / Tests / Example 폴더와 Project.swift를 생성한다. 수동 생성 시 구조가 불일치해 워크스페이스가 깨질 수 있다.

```bash
make module layer="Feature" name="NotificationFeature"
make module layer="Core" name="CameraClient"
make module layer="Domain" name="VideoService"
```
