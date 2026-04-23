# TCA / SwiftUI 상태관리 규칙

---

## 1. Reducer의 기본 구조를 통일한다

> **이유**: 구조가 통일되어야 어느 파일을 열어도 빠르게 파악할 수 있다.

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
        BindingReducer()
        Scope(state: \.list, action: \.list) { RecordPostFeedCore() }
        Reduce(self.core)
            .forEach(\.path, action: \.path)
            .ifLet(\.$comment, action: \.comment) { CommentCore() }
    }

    private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
        switch action {
        case .binding:    return .none
        case .onLoad:     return .none
        case .onTapSearch:
            state.comment = CommentCore.State(postID: 0, commentCount: 0)
            return .none
        case .comment:    return .none
        case .path:       return .none
        }
    }
}
```

---

## 2. `State`는 반드시 `@ObservableState`를 채택한다

> **이유**: `@ObservableState` 없이는 SwiftUI가 State 변화를 감지하지 못해 화면이 갱신되지 않는다.

```swift
// ❌
public struct State { var count: Int = 0 }

// ✅
@ObservableState
public struct State { var count: Int = 0 }
```

---

## 3. 화면 전환은 `StackState` 또는 `@Presents`만 사용한다

> **이유**: `Bool` 플래그로 화면을 관리하면 상태 수가 폭발적으로 늘어나고, 전환 타이밍 버그가 생기기 쉽다.

```swift
// ❌ Bool 플래그 방식
var showDetail: Bool = false
var showReport: Bool = false

// ✅ StackState — 뒤로가기 가능한 푸시 네비게이션
var path = StackState<HomePath.State>()

// ✅ @Presents — 모달 / 시트 / 풀스크린 커버
@Presents var comment: CommentCore.State?

// StackState와 함께 쓰는 Path Enum 정의
extension HomeCore {
    @Reducer
    public enum HomePath {
        case memberProfile(MemberProfileCore)
        case userFeed(RecordPostUserFeedCore)
        case report(ReportCore)
        case followManage(MemberFollowManageCore)
        case editProfile(ProfileModifyCore)
    }
}
```

**선택 기준**

| 상황 | 선택 |
|------|------|
| 화면 위로 올라오는 모달·시트·풀스크린 커버 | `@Presents var xxx: XxxCore.State?` |
| 뒤로가기가 가능한 NavigationStack 푸시 | `StackState<XxxPath.State>` + `@Reducer enum XxxPath` |

---

## 4. 장기 실행 Effect에는 반드시 `CancelID`를 사용한다

> **이유**: `CancelID` 없이 스트림을 구독하면 화면이 사라진 뒤에도 Effect가 살아있어 메모리 누수와 예상치 못한 Action 발행이 생긴다.

```swift
enum CancelID {
    case toastStream
    case errorStream
}

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

## 5. Effect 사용 기준

| 상황 | 코드 |
|------|------|
| 상태만 바꿀 때 | `return .none` |
| 비동기 작업 | `return .run { send in ... }` |
| 다른 Action으로만 전달 | `return .send(.xxx)` |
| 장기 실행 스트림 | `.run { }.cancellable(id: CancelID.xxx)` |

---

## 6. switch 케이스가 많아지면 `MARK`로 섹션을 분리한다

```swift
private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {

    // MARK: - Binding
    case .binding:
        return .none

    // MARK: - List
    case .list(.loading(let isOn)):
        state.isLoading = isOn
        return .none

    // MARK: - Path
    case .path(.element(id: _, action: .memberProfile(.moveToDetail(let type)))):
        state.path.append(.userFeed(.init(type: type)))
        return .none

    case .path:
        return .none
    }
}
```

> `core(_:_:)` 함수가 80줄 초과 시 반드시 `// MARK: - 섹션명`으로 분리.

---

## 7. UIKit은 Reducer 내부에서 직접 사용하지 않는다

> **이유**: Reducer는 순수 함수에 가까워야 테스트가 가능하다.

```swift
// ❌
case .openStore:
    UIApplication.shared.open(url)
    return .none

// ✅ .run 블록 + MainActor
case .openStore:
    return .run { _ in
        guard let url = URL(string: "itms-apps://apps.apple.com/kr") else { return }
        await MainActor.run {
            UIApplication.shared.open(url)
        }
    }
```

---

## 8. `DispatchQueue.main.async` 대신 `MainActor.run`을 사용한다

> **이유**: Swift Concurrency 환경에서 `DispatchQueue`는 actor 격리를 모르기 때문에 데이터 레이스가 발생할 수 있다.

```swift
// ❌
DispatchQueue.main.async {
    self.label.text = "완료"
}

// ✅
await MainActor.run {
    label.text = "완료"
}
```
