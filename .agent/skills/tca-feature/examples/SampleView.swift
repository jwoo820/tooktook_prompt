//
//  SampleView.swift
//  {FeatureName}Feature
//
//  샘플 SwiftUI View - 복사 후 {FeatureName} 을 원하는 이름으로 대체하세요.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

// MARK: - 기본 View 패턴 (NavigationStack + Modal 포함)

public struct SampleView: View {
  @Bindable var store: StoreOf<SampleCore>

  public init(store: StoreOf<SampleCore>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      content
    } destination: { store in
      // 각 path case에 맞는 View를 반환
      switch store.case {
      case .detail(let detailStore):
        SampleDetailView(store: detailStore)
      }
    }
    // MARK: - FullScreenCover (Modal)
    .fullScreenCover(
      item: $store.scope(state: \.detailModal, action: \.detailModal)
    ) { modalStore in
      SampleDetailView(store: modalStore)
    }
    // MARK: - Sheet (Modal)
    // .sheet(
    //   item: $store.scope(state: \.sheetModal, action: \.sheetModal)
    // ) { sheetStore in
    //   SomeSheetView(store: sheetStore)
    // }
  }

  // MARK: - 루트 콘텐츠

  private var content: some View {
    VStack(spacing: 0) {

      // 네비게이션 바 (DesignSystem 제공)
      NavigationBar()
        .addLeading {
          Text("제목")
            .font(Typography.titleBold)
        }
        .addTrailing {
          Button {
            store.send(.onTapSearch)
          } label: {
            Image(systemName: "magnifyingglass")
          }
        }

      // 로딩 + 리스트
      if store.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        listView
      }
    }
    .background(Color.backgroundLv0)
    .ignoresSafeArea(edges: .bottom)
    .onAppear {
      store.send(.onAppear)
    }
  }

  // MARK: - 리스트 뷰

  private var listView: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(store.items) { item in
          SampleItemCell(item: item)
            .onTapGesture {
              store.send(.onTapItem(item))
            }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 12)
    }
  }
}

// MARK: - 셀 컴포넌트 (별도 파일 Cell/ 폴더로 분리 권장)

private struct SampleItemCell: View {
  let item: SampleItem

  var body: some View {
    HStack {
      Text(item.title)
        .font(Typography.bodyMedium)
        .foregroundColor(Color.textStrong)
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(Color.textPlaceholder)
    }
    .padding(16)
    .background(Color.backgroundLv1)
    .cornerRadius(12)
  }
}
