---
name: tca-feature
description: TookTook iOS Feature 레이어의 TCA(The Composable Architecture) 기반 기능 모듈을 생성하는 스킬. @Reducer, @ObservableState, StackState, PresentationState 패턴을 포함한 Reducer 및 SwiftUI View를 작성하는 방법을 안내합니다.
---

# TCA Feature 레이어 개발 가이드

## 개요

TookTook iOS는 [TMA(Tuist Micro Architecture)](https://docs.tuist.dev/en/guides/features/projects/tma-architecture) 기반의 Feature 모듈을 사용합니다.
각 Feature는 `Sources/XxxCore.swift`(Reducer)와 `Sources/XxxView.swift`(SwiftUI View)로 구성됩니다.

## 디렉토리 구조

```
Projects/Feature/{FeatureName}/
├── Project.swift                  # Tuist 프로젝트 정의
├── Sources/
│   ├── {FeatureName}Core.swift   # TCA Reducer
│   ├── {FeatureName}View.swift   # SwiftUI View
│   ├── Cell/                     # 리스트 셀 뷰 (필요 시)
│   ├── CustomView/               # 커스텀 뷰 컴포넌트 (필요 시)
│   ├── Model/                    # Feature 전용 모델 (필요 시)
│   └── Type/                     # Feature 전용 타입/열거형 (필요 시)
│       └── {ContextName}Type.swift
├── Interface/
│   └── {FeatureName}Interface.swift  # 외부 공개 인터페이스
├── Testing/
│   └── {FeatureName}Testing.swift    # 테스트 헬퍼
├── Tests/
│   └── {FeatureName}Tests.swift      # 유닛 테스트
├── Example/
│   └── Sources/
│       └── {FeatureName}ExampleApp.swift
└── Resources/
```

## Type/ 폴더 사용 규칙

Feature에서 사용하는 열거형(enum)이나 타입은 **Core 파일에 인라인으로 넣지 않고** `Type/` 폴더 내 별도 파일로 분리합니다.

### 네이밍 컨벤션

| 구분 | 패턴 | 예시 |
|------|------|------|
| Feature 전용 열거형 | `{Context}Type` | `DeleteAccountReasonType`, `HomeSectionType` |
| Feature 전용 모델 | `{Context}` | `ProfileItem` |

### 규칙

- **이름은 `~Type` 접미사를 사용합니다.** (예: `DeleteAccountReasonType`, `ProfileModifyFieldType`)
- **파일명은 타입명과 동일하게 합니다.** (예: `DeleteAccountReasonType.swift`)
- **UI 관련 프로퍼티 (`title`, `showsTextInput` 등)와 API 매핑 프로퍼티 (`reasonType` 등)를 하나의 타입에 함께 정의할 수 있습니다.**
- Core 파일에는 해당 타입 정의를 포함하지 않습니다. 참조만 합니다.

### 예시: DeleteAccountReasonType

```swift
// Sources/Type/DeleteAccountReasonType.swift

import DesignSystem

public enum DeleteAccountReasonType: String, CaseIterable, RadioItemProtocol {
  case deleteRecord  = "기록 삭제 목적"
  case etc           = "기타"

  public var title: String { rawValue }

  public var showsTextInput: Bool { self == .etc }

  /// API 명세의 reasonType 값
  public var reasonType: String {
    switch self {
    case .deleteRecord: return "RECORD_DELETION"
    case .etc:          return "OTHER"
    }
  }
}
```

## Feature Core (Reducer) 작성 규칙

### 1. 기본 Reducer 구조

```swift
import ComposableArchitecture

@Reducer
public struct {FeatureName}Core {
  @ObservableState
  public struct State {
    // 상태 프로퍼티 정의
    public init() {}
  }

  public enum Action: BindableAction {
    case binding(BindingAction<State>)
    // 액션 정의
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce(self.core)
  }

  private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {
    case .binding:
      return .none
    }
  }
}
```

### 2. Navigation (StackState) 패턴

화면 이동이 필요한 경우 `StackState`로 NavigationStack을 관리합니다:

```swift
@ObservableState
public struct State {
  var path = StackState<{FeatureName}Path.State>()
}

public enum Action: BindableAction {
  case binding(BindingAction<State>)
  case path(StackActionOf<{FeatureName}Path>)
}

public var body: some ReducerOf<Self> {
  BindingReducer()
  Reduce(self.core)
    .forEach(\.path, action: \.path)
}

// 하단에 Path 열거형 extension 정의
extension {FeatureName}Core {
  @Reducer
  public enum {FeatureName}Path {
    case detail(SomeDetailCore)
    case memberProfile(MemberProfileCore)
    case report(ReportCore)
  }
}
```

### 3. Sheet/FullScreenCover (PresentationState) 패턴

모달 표시가 필요한 경우 `@Presents`를 사용합니다:

```swift
@ObservableState
public struct State {
  @Presents var modalFeature: ModalFeatureCore.State?
}

public enum Action: BindableAction {
  case binding(BindingAction<State>)
  case modalFeature(PresentationAction<ModalFeatureCore.Action>)
}

public var body: some ReducerOf<Self> {
  BindingReducer()
  Reduce(self.core)
    .ifLet(\.$modalFeature, action: \.modalFeature) {
      ModalFeatureCore()
    }
}
```

### 4. Dependency 사용

TCA `@Dependency`를 사용해 외부 클라이언트를 주입합니다:

```swift
@Dependency(SomeClient.self) var someClient
@Dependency(\.dismiss) var dismiss  // SwiftUI 환경 dismiss

// Effect 내에서 사용
case .someAction:
  return .run { send in
    let result = try await someClient.fetchData()
    await send(.dataLoaded(result))
  }
```

### 5. 자식 Reducer 연결 (Scope)

```swift
@ObservableState
public struct State {
  var childState: ChildCore.State
}

public enum Action: BindableAction {
  case binding(BindingAction<State>)
  case child(ChildCore.Action)
}

public var body: some ReducerOf<Self> {
  BindingReducer()
  Scope(state: \.childState, action: \.child) {
    ChildCore()
  }
  Reduce(self.core)
}
```

## Feature View 작성 규칙

### 1. 기본 View 구조

```swift
import SwiftUI
import ComposableArchitecture

public struct {FeatureName}View: View {
  @Bindable var store: StoreOf<{FeatureName}Core>

  public init(store: StoreOf<{FeatureName}Core>) {
    self.store = store
  }

  public var body: some View {
    // 뷰 구현
  }
}
```

### 2. NavigationStack View 패턴

```swift
public var body: some View {
  NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
    // Root Content
    MainContentView(store: store)
  } destination: { store in
    switch store.case {
    case .detail(let detailStore):
      DetailView(store: detailStore)
    case .memberProfile(let profileStore):
      MemberProfileView(store: profileStore)
    case .report(let reportStore):
      ReportView(store: reportStore)
    }
  }
}
```

### 3. 모달 View 패턴

```swift
.fullScreenCover(
  item: $store.scope(state: \.modalFeature, action: \.modalFeature)
) { modalStore in
  ModalFeatureView(store: modalStore)
}
```

## Project.swift 작성 규칙

```swift
import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project: Project = .makeTMABasedProject(
  module: Feature.{FeatureName},
  scripts: [],
  targets: [
    .sources
    // 필요 시: .interface, .tests, .testing, .example
  ],
  dependencies: [
    .sources: [
      .dependency(rootModule: Domain.self),
      // 의존하는 Feature 모듈들
      .dependency(module: Feature.SomeFeature),
    ]
  ]
)
```

## 관련 샘플

- [`examples/SampleCore.swift`](examples/SampleCore.swift) — Reducer 전체 패턴 샘플
- [`examples/SampleView.swift`](examples/SampleView.swift) — SwiftUI View 전체 패턴 샘플
- [`examples/SampleProject.swift`](examples/SampleProject.swift) — Project.swift 샘플

## 주의사항

- `@ObservableState`는 State 구조체에 반드시 선언합니다.
- `Action`은 항상 `BindableAction`을 채택하고 `.binding(BindingAction<State>)` case를 포함합니다.
- Effect를 반환하지 않는 액션은 `.none`을 반환합니다.
- `body`의 첫 번째 Reducer는 항상 `BindingReducer()`입니다.
- Navigation path 조작 시 `state.path.append(...)` 또는 `state.path.removeAll()`을 사용합니다.
