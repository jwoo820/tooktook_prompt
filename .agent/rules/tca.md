# TookTook iOS — TCA / SwiftUI 규칙

---

## 규칙 T-1. Reducer 기본 구조를 통일한다

```swift
@Reducer
public struct HomeCore {
    @ObservableState
    public struct State {
        var isLoading: Bool = false
        var path = StackState<HomePath.State>()
        @Presents var comment: CommentCore.State?
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onLoad
        case onTapSearch
        case path(StackActionOf<HomePath>)
        case comment(PresentationAction<CommentCore.Action>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()                               // 항상 첫 번째
        Scope(state: \.list, action: \.list) { RecordPostFeedCore() }
        Reduce(self.core)
            .forEach(\.path, action: \.path)
            .ifLet(\.$comment, action: \.comment) { CommentCore() }
    }

    private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
        switch action {
        case .binding:      return .none
        case .onLoad:       return .none
        case .onTapSearch:
            state.comment = CommentCore.State(postID: 0, commentCount: 0)
            return .none
        case .comment:      return .none
        case .path:         return .none
        }
    }
}
```

---

## 규칙 T-2. State는 반드시 `@ObservableState`를 채택한다

```swift
// ❌ @ObservableState 없으면 SwiftUI가 변화를 감지 못함
public struct State { var count: Int = 0 }

// ✅
@ObservableState
public struct State { var count: Int = 0 }
```

---

## 규칙 T-3. 화면 전환은 `StackState` 또는 `@Presents`만 사용한다

| 상황 | 선택 |
|------|------|
| 모달 / 시트 / 풀스크린 커버 | `@Presents var xxx: XxxCore.State?` |
| 뒤로가기 가능한 NavigationStack 푸시 | `var path = StackState<XxxPath.State>()` |

```swift
// ❌ Bool 플래그 금지 — 상태 폭발, 타이밍 버그
var showDetail: Bool = false

// ✅ StackState — 푸시 네비게이션
var path = StackState<HomePath.State>()

// ✅ @Presents — 모달
@Presents var comment: CommentCore.State?

// Path 정의
extension HomeCore {
    @Reducer
    public enum HomePath {
        case memberProfile(MemberProfileCore)
        case userFeed(RecordPostUserFeedCore)
        case report(ReportCore)
    }
}
```

### View에서의 NavigationStack 사용

```swift
public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
        MainContentView(store: store)
    } destination: { store in
        switch store.case {
        case .detail(let s):        DetailView(store: s)
        case .memberProfile(let s): MemberProfileView(store: s)
        case .report(let s):        ReportView(store: s)
        }
    }
}
```

### View에서의 모달 사용

```swift
.fullScreenCover(
    item: $store.scope(state: \.modalFeature, action: \.modalFeature)
) { modalStore in
    ModalFeatureView(store: modalStore)
}
```

---

## 규칙 T-4. Effect 사용 기준

| 상황 | 코드 |
|------|------|
| 상태만 바꿀 때 | `return .none` |
| 비동기 작업 | `return .run { send in ... }` |
| 다른 Action으로만 전달 | `return .send(.xxx)` |
| 장기 실행 스트림 | `.run { }.cancellable(id: CancelID.xxx)` |

---

## 규칙 T-5. 장기 실행 Effect에는 반드시 `CancelID`를 사용한다

> **이유**: 화면이 사라진 뒤에도 Effect가 살아있으면 메모리 누수와 예상치 못한 Action 발행이 생긴다.

```swift
enum CancelID { case toastStream; case errorStream }

case .onLoad:
    return .merge(
        .run { send in
            for await toast in ToastStream.shared.subscribe() {
                await send(.toastReceived(toast))
            }
        }
        .cancellable(id: CancelID.toastStream),

        .run { [streamListener] send in
            for await event in streamListener.protocolAdapter.receive(GlobalErrorEvent.self) {
                await send(.showErrorDialog(event))
            }
        }
        .cancellable(id: CancelID.errorStream)
    )
```

---

## 규칙 T-6. switch 케이스가 많아지면 `// MARK:` 로 분리한다

```swift
private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {

    // MARK: - Binding
    case .binding: return .none

    // MARK: - List
    case .list(.loading(let isOn)):
        state.isLoading = isOn
        return .none

    // MARK: - Path
    case .path(.element(id: _, action: .memberProfile(.moveToDetail(let type)))):
        state.path.append(.userFeed(.init(type: type)))
        return .none
    case .path: return .none
    }
}
```

---

## 규칙 T-7. UIKit은 Reducer 내부에서 직접 사용하지 않는다

```swift
// ❌ Reducer 내 UIKit 직접 호출 — 테스트 불가
case .openStore:
    UIApplication.shared.open(url)
    return .none

// ✅ .run + MainActor
case .openStore:
    return .run { _ in
        guard let url = URL(string: "itms-apps://apps.apple.com/kr") else { return }
        await MainActor.run { UIApplication.shared.open(url) }
    }
```

---

## 규칙 T-8. `DispatchQueue.main.async` 대신 `MainActor.run`을 사용한다

```swift
// ❌ Swift Concurrency 데이터 레이스 위험
DispatchQueue.main.async { label.text = "완료" }

// ✅
await MainActor.run { label.text = "완료" }
```

---

## 규칙 T-9. Dependency 주입

```swift
// Feature에서 Domain Service 주입
@Dependency(SomeService.self) var someService
@Dependency(\.dismiss) var dismiss   // SwiftUI 환경 dismiss

// Effect 내 사용
case .onLoad:
    return .run { send in
        let result = try await someService.fetchList()
        await send(.listLoaded(result))
    }
```

---

## 규칙 T-10. `@DependencyClient`에는 반드시 `testValue`·`previewValue`를 정의한다

> **이유**: `testValue` 없으면 TCA TestStore에서 런타임 에러. `previewValue` 없으면 SwiftUI Preview 동작 안 함.

```swift
@DependencyClient
public struct AuthService {
    public var login:  @Sendable (APIClient, KeychainClient, LoginRequest) async throws -> Void
    public var logout: @Sendable (APIClient, KeychainClient) async throws -> Void
}

extension AuthService: TestDependencyKey {
    public static let previewValue = Self()
    public static let testValue    = Self()
}
```

---

## 규칙 T-11. TCA 테스트는 `TestStore`를 사용한다

```swift
@Test
func 로그인_성공_시_isLoading이_false가_된다() async {
    let store = TestStore(initialState: LoginCore.State()) {
        LoginCore()
    } withDependencies: {
        $0.authService.login = { _, _, _ in }  // 성공 mock
    }

    await store.send(.loginButtonTapped) { $0.isLoading = true }
    await store.receive(.loginSuccess)   { $0.isLoading = false }
}
```
