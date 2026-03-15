//
//  SampleCore.swift
//  {FeatureName}Feature
//
//  샘플 TCA Reducer - 복사 후 {FeatureName} 을 원하는 이름으로 대체하세요.
//

import ComposableArchitecture

// MARK: - 기본 Reducer 패턴 (Navigation + Modal 포함)

@Reducer
public struct SampleCore {

  // MARK: - State

  @ObservableState
  public struct State {

    // MARK: 일반 상태
    var items: [SampleItem] = []
    var isLoading: Bool = false

    // MARK: NavigationStack (push 방식 화면 이동)
    var path = StackState<SamplePath.State>()

    // MARK: Modal (@Presents: sheet / fullScreenCover 방식)
    @Presents var detailModal: SampleDetailCore.State?

    public init() {}
  }

  // MARK: - Action

  public enum Action: BindableAction {
    case binding(BindingAction<State>)

    // MARK: 뷰 이벤트
    case onAppear
    case onTapItem(SampleItem)
    case onTapSearch

    // MARK: 비동기 결과
    case itemsLoaded([SampleItem])

    // MARK: Navigation
    case path(StackActionOf<SamplePath>)

    // MARK: Modal
    case detailModal(PresentationAction<SampleDetailCore.Action>)
  }

  // MARK: - Dependency

  @Dependency(SampleClient.self) var sampleClient

  // MARK: - Init

  public init() {}

  // MARK: - Body

  public var body: some ReducerOf<Self> {
    BindingReducer()

    // 자식 Reducer가 있을 경우 Scope로 연결
    // Scope(state: \.child, action: \.child) {
    //   ChildCore()
    // }

    Reduce(self.core)
      .forEach(\.path, action: \.path)
      .ifLet(\.$detailModal, action: \.detailModal) {
        SampleDetailCore()
      }
  }

  // MARK: - Core Logic

  private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {

    case .onAppear:
      state.isLoading = true
      return .run { send in
        let items = try await sampleClient.fetchItems()
        await send(.itemsLoaded(items))
      }

    case .itemsLoaded(let items):
      state.isLoading = false
      state.items = items
      return .none

    case .onTapItem(let item):
      // push 방식 이동
      state.path.append(.detail(.init(item: item)))
      return .none

    case .onTapSearch:
      // modal 방식 이동
      state.detailModal = SampleDetailCore.State()
      return .none

    // MARK: - Path 하위 액션 처리
    case .path(.element(id: _, action: .detail(.goBack))):
      state.path.removeAll()
      return .none

    case .path:
      return .none

    // MARK: - Modal 하위 액션 처리
    case .detailModal(.presented(.dismiss)):
      state.detailModal = nil
      return .none

    case .detailModal:
      return .none

    case .binding:
      return .none
    }
  }
}

// MARK: - NavigationStack Path 정의

extension SampleCore {
  @Reducer
  public enum SamplePath {
    case detail(SampleDetailCore)
    // case memberProfile(MemberProfileCore)
    // case report(ReportCore)
  }
}

// MARK: - 더미 타입 (실제 구현으로 대체)

public struct SampleItem: Identifiable, Equatable {
  public let id: String
  public let title: String
}
