# TookTook iOS — 테스트 규칙 · 금지 패턴 · 코드 예시

---

## 규칙 9-1. `@DependencyClient`에는 반드시 `testValue`와 `previewValue`를 정의한다

> **이유**: `testValue`가 없으면 TCA TestStore에서 런타임 에러가 발생한다. `previewValue`가 없으면 SwiftUI Preview가 동작하지 않는다.

```swift
@DependencyClient
public struct AuthService {
    public var login: @Sendable (APIClient, KeychainClient, LoginRequest) async throws -> Void
    public var logout: @Sendable (APIClient, KeychainClient) async throws -> Void
}

extension AuthService: TestDependencyKey {
    public static let previewValue = Self()
    public static let testValue = Self()
}
```

---

## 규칙 9-2. TCA 테스트는 `TestStore`를 사용한다

> **이유**: `TestStore`는 Action 발행 순서·State 변화·Effect 완료를 순차적으로 검증해 준다.

```swift
@Test
func 로그인_성공_시_isLoading이_false가_된다() async {
    let store = TestStore(initialState: LoginCore.State()) {
        LoginCore()
    } withDependencies: {
        $0.authService.login = { _, _, _ in }  // 성공 mock
    }

    await store.send(.loginButtonTapped) {
        $0.isLoading = true
    }
    await store.receive(.loginSuccess) {
        $0.isLoading = false
    }
}
```

---

## 금지 패턴 총정리

| 금지 패턴 | 올바른 대안 | 이유 |
|----------|------------|------|
| `URLSession` 직접 사용 | `APIClient.apiRequest(request:as:)` | 인증·에러처리·SSE가 이미 추상화됨 |
| Feature에서 `APIClient` 직접 주입 | `XxxService` 통해 접근 | 레이어 의존성 위반 |
| `DispatchQueue.main.async` | `MainActor.run { }` | Swift Concurrency 데이터 레이스 위험 |
| `Bool` 플래그 화면 전환 | `StackState` / `@Presents` | 상태 폭발·타이밍 버그 |
| hardcode 서버 URL | `API.apiBaseHost + "/path"` | Dev/Prod 환경 분기 누락 위험 |
| DTO에 `Encodable` 채택 | `Decodable`만 채택 | 역할 혼재, 오용 가능성 |
| `catch { }` 에러 무시 | 명시적 catch + Action 발행 | 사용자 피드백 누락 |
| Action 이름에 `buttonTapped` / `update` | `onTapSearch` / `postsLoaded` | 역할 불명확 |
| `// TODO:` 날짜 없는 주석 | `// TODO: 25.11.30 - 내용` | 언제 생긴 TODO인지 알 수 없음 |
| Reducer 내부 `UIKit` 직접 사용 | `.run { await MainActor.run { } }` | 테스트 불가 |

---

## 좋은 코드 / 나쁜 코드 예시

### Case 1. Reducer Action 처리

```swift
// ❌ 나쁜 코드
case .btn1:
    if state.x != nil && state.flag {
        DispatchQueue.main.async { ... }
        state.path.append(...)
    }
    return .none

// ✅ 좋은 코드
case .onTapProfile:
    guard loginCheckClient.isLoggedIn() else {
        return .send(.showLoginRequiredDialog)
    }
    state.path.append(.memberProfile(.init(type: .my)))
    return .none
```

### Case 2. API 호출

```swift
// ❌ 나쁜 코드
case .fetch:
    return .run { send in
        let url = URL(string: "https://api.example.com/posts")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let posts = try? JSONDecoder().decode([Post].self, from: data)
        await send(.loaded(posts ?? []))
    }

// ✅ 좋은 코드
case .fetch:
    return .run { [postService, apiClient] send in
        do {
            let posts = try await postService.fetchAll(apiClient)
            await send(.postsLoaded(posts))
        } catch let error as NetworkError {
            await send(.fetchFailed(error))
        }
    }
```

### Case 3. DesignSystem 활용

```swift
// ❌ 나쁜 코드
Text("제목")
    .font(.system(size: 18, weight: .bold))
    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))

// ✅ 좋은 코드
Text("제목")
    .font(Typography.titleBold)
    .foregroundColor(Color.textStrong)
```

### Case 4. NavigationStack

```swift
// ❌ 나쁜 코드
@ObservableState struct State {
    var showDetail = false
    var detailPost: Post?
}

// ✅ 좋은 코드
@ObservableState struct State {
    var path = StackState<HomePath.State>()
}

case .onTapPost(let post):
    state.path.append(.detail(.init(post: post)))
    return .none
```

### Case 5. 빌드 환경 분기

```swift
// ❌ 나쁜 코드
let isDebug = true
let serverURL = isDebug ? "https://dev.api.com" : "https://api.com"

// ✅ 좋은 코드
public var baseURL: String {
    return API.apiBaseHost + "/v1"
    // API.apiBaseHost가 내부적으로 #if DEV 분기 처리
}
```
