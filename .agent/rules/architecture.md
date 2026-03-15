# TookTook iOS — 아키텍처 규칙

---

## 규칙 A-1. 레이어 의존성 방향을 반드시 지킨다

```
App → Feature → Domain → Core → Shared
```

> **이유**: 역방향 의존이 생기면 순환 참조가 발생하고, 테스트 격리가 불가능해진다.

| 레이어 | 역할 | 의존 가능 |
|--------|------|-----------|
| **App** | 앱 진입점 | Feature |
| **Feature** | UI + TCA Reducer | Domain, Shared |
| **Domain** | 비즈니스 로직·Service | Core, Shared |
| **Core** | 외부 I/O 추상화 (Client) | Shared |
| **Shared** | DesignSystem·Utils·ThirdParty | 없음 |

```swift
// ❌ 금지: Feature에서 APIClient 직접 사용
import APIClientInterface
@Dependency(APIClient.self) var apiClient

// ✅ 올바름: Domain Service를 통해 접근
import AuthServiceInterface
@Dependency(AuthService.self) var authService
```

---

## 규칙 A-2. 모듈 이름은 레이어별 컨벤션을 따른다

| 레이어 | 네이밍 규칙 | 예시 |
|--------|------------|------|
| **Feature** | `{기능명}Feature` | `HomeFeature`, `ProfileFeature` |
| **Domain** | `{도메인명}Service` | `AuthService`, `RecordPostService` |
| **Core** | `{기능명}Client` | `APIClient`, `KeychainClient` |
| **Shared** | 제한 없음 | `DesignSystem`, `Utils`, `Logger` |

---

## 규칙 A-3. 모듈 간 참조는 반드시 Interface 타겟을 통한다

> **이유**: Sources(구현체)를 직접 참조하면 구현 세부사항에 결합된다. Interface만 참조하면 구현을 자유롭게 교체할 수 있다.

```swift
// ❌ 금지: 구현체 직접 참조
HomeFeature → ProfileFeatureSources

// ✅ 올바름: Interface 타겟만 참조
HomeFeature → ProfileFeatureInterface

// DependencyPlugin 사용 예
.dependency(module: Feature.ProfileFeature, type: .interface)
```

---

## 규칙 A-4. Interface 타겟에는 구현 코드를 넣지 않는다

```
XxxModule/
├── Interface/   ← 프로토콜·DTO·타입·@DependencyClient 정의만
└── Sources/     ← 실제 구현체 (DependencyKey 등록 포함)
```

---

## 규칙 A-5. 새 모듈은 반드시 `make module` 명령어로 생성한다

> **이유**: Tuist 템플릿이 Interface / Sources / Testing / Tests / Example 폴더와 Project.swift를 자동 생성한다. 수동 생성 시 워크스페이스가 깨질 수 있다.

```bash
make module layer="Feature" name="NotificationFeature"
make module layer="Core" name="CameraClient"
make module layer="Domain" name="VideoService"
```

---

## 프로젝트 폴더 구조

```
tooktook_ios/
├── Projects/
│   ├── App/
│   ├── Feature/
│   │   └── HomeFeature/
│   │       ├── Interface/          # 공개 계약
│   │       ├── Sources/            # {화면명}Core.swift / {화면명}View.swift
│   │       │   ├── Cell/
│   │       │   ├── CustomView/
│   │       │   ├── Model/
│   │       │   └── Type/           # {Context}Type.swift (열거형 분리)
│   │       ├── Testing/
│   │       ├── Tests/
│   │       ├── Example/
│   │       └── Project.swift
│   ├── Domain/
│   │   └── AuthService/
│   │       ├── Interface/
│   │       │   ├── API/            # {도메인}ServiceInterface.swift + APIRequest
│   │       │   ├── DTO/
│   │       │   └── Type/
│   │       └── Sources/
│   ├── Core/
│   │   ├── APIClient/
│   │   │   ├── Interface/          # APIClientInterface.swift, NetworkError.swift
│   │   │   └── Sources/            # Session, Interceptor, SSE
│   │   ├── CoreDTO/Interface/Model/
│   │   ├── KeychainClient/
│   │   ├── UserDefaultsClient/
│   │   └── ToastClient/
│   └── Shared/
│       ├── DesignSystem/
│       └── Utils/
├── Plugins/
│   ├── DependencyPlugin/
│   └── UtilityPlugin/
├── Tuist/
├── XCConfig/
│   ├── Env.xcconfig                # 환경별 키
│   └── Shared.xcconfig
├── fastlane/
├── Workspace.swift
├── Package.swift
└── Makefile
```

---

## 규칙 A-6. 한 파일에 하나의 주요 타입만 정의한다 (Path enum 예외)

```swift
// ✅ HomeCore.swift에 HomeCore + HomePath 함께 정의 (예외 허용)
@Reducer public struct HomeCore { ... }

extension HomeCore {
    @Reducer
    public enum HomePath {
        case memberProfile(MemberProfileCore)
        case report(ReportCore)
    }
}
```
