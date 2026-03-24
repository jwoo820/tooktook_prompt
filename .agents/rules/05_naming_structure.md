# TookTook iOS — 네이밍 · 파일 구조 규칙

---

## 규칙 7-1. Reducer·View·Service 파일 이름을 통일한다

> **이유**: 파일명만으로 역할을 즉시 알 수 있어야 한다.

| 대상 | 규칙 | 예시 |
|------|------|------|
| Reducer | `{화면명}Core.swift` | `HomeCore.swift` |
| View | `{화면명}View.swift` | `HomeView.swift` |
| Service Interface | `{도메인}ServiceInterface.swift` | `AuthServiceInterface.swift` |
| API Request | `{도메인}APIRequest.swift` | `AuthAPIRequest.swift` |
| DTO | `{내용}Data.swift` | `ProfileMemberData.swift` |
| Path Enum | `{화면명}Path` (Core 파일 내부 extension) | `HomePath`, `MyProfilePath` |

---

## 규칙 7-2. Action 이름은 목적을 명확하게 표현한다

> **이유**: Action은 앱에서 일어나는 모든 이벤트의 이름이다. 이름이 모호하면 어떤 상황에서 발생하는지 알기 어렵다.

```swift
// ✅ 사용자 인터랙션 — "on" + 동사
case onTapSearch
case onTapLike(postId: Int)
case onTapProfile

// ✅ 화면 전환 — "moveTo" + 대상
case moveToDetail(type: FeedType)
case moveToFollowManage(followerCount: Int, followingCount: Int, isMine: Bool, memberID: Int?)

// ✅ 비동기 결과 — 명사 + 결과
case postsLoaded([Post])
case loginFailed(NetworkError)

// ✅ 시스템 이벤트
case onLoad
case tabReselected
case didChangeScenePhase(ScenePhase)

// ❌ 금지
case buttonTapped       // 어떤 버튼인지 알 수 없음
case update             // 무엇을 업데이트하는지 알 수 없음
case handle             // 의미 없음
case AAA                // 절대 금지
```

---

## 규칙 7-3. `// TODO:` 주석에는 날짜를 포함한다

```swift
// ❌
// TODO: 나중에 수정

// ✅
// TODO: 25.11.30 - 관련 action 네이밍 컨벤션 두는 것이 좋을듯
```

---

## 규칙 8-1. 프로젝트 폴더 구조를 그대로 따른다

> **이유**: Tuist가 폴더 구조를 기반으로 프로젝트를 생성한다. 임의로 폴더를 만들거나 위치를 변경하면 `make dev` 시 프로젝트가 깨진다.

```
tooktook_ios/
├── Projects/
│   ├── App/                    # TookTook 앱 타겟
│   ├── Feature/
│   │   ├── HomeFeature/
│   │   │   ├── Interface/      # 공개 계약
│   │   │   ├── Sources/        # {화면명}Core.swift / {화면명}View.swift
│   │   │   │   ├── Cell/
│   │   │   │   ├── CustomView/
│   │   │   │   ├── Model/
│   │   │   │   └── Type/
│   │   │   ├── Testing/
│   │   │   ├── Tests/
│   │   │   ├── Example/
│   │   │   └── Project.swift
│   ├── Domain/
│   │   ├── AuthService/
│   │   │   ├── Interface/
│   │   │   │   ├── API/        # {도메인}ServiceInterface.swift + APIRequest
│   │   │   │   ├── DTO/
│   │   │   │   └── Type/
│   │   │   └── Sources/        # 실제 구현체
│   ├── Core/
│   │   ├── APIClient/
│   │   │   ├── Interface/      # APIClientInterface.swift, NetworkError.swift
│   │   │   └── Sources/        # Session, Interceptor, SSE
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
│   ├── Env.xcconfig            # 환경별 키 (Kakao 등)
│   └── Shared.xcconfig         # 공통 빌드 옵션
├── fastlane/
├── Workspace.swift
├── Package.swift               # SPM 의존성
└── Makefile
```

---

## 규칙 8-2. 한 파일에 하나의 주요 타입만 정의한다 (Path enum 예외)

```swift
// ✅ HomeCore.swift에 HomeCore + HomePath 함께 정의 (예외 허용)
@Reducer
public struct HomeCore { ... }

extension HomeCore {
    @Reducer
    public enum HomePath {
        case memberProfile(MemberProfileCore)
        case report(ReportCore)
    }
}
```
