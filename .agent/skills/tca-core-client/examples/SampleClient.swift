//
//  SampleClient.swift
//  SampleClient
//
//  DependencyKey liveValue 구현 샘플
//  복사 후 {ClientName} 을 원하는 Client 이름으로 대체하세요.
//

import Foundation
import SampleClientInterface
import Dependencies
import APIClientInterface

// MARK: - Live 구현

extension SampleClient: @retroactive DependencyKey {
  public static let liveValue: SampleClient = .live()

  public static func live() -> Self {
    // MARK: 필요한 내부 의존성 초기화
    @Dependency(APIClient.self) var apiClient

    return .init(
      fetchItems: {
        // 실제 API 호출 예시
        let items: [SampleDTO] = try await apiClient.apiRequest(
          request: SampleAPI.list,
          as: [SampleDTO].self
        )
        return items.map { $0.toModel() }
      },

      fetchItem: { id in
        let dto: SampleDTO = try await apiClient.apiRequest(
          request: SampleAPI.detail(id: id),
          as: SampleDTO.self
        )
        return dto.toModel()
      },

      createItem: { title in
        let dto: SampleDTO = try await apiClient.apiRequest(
          request: SampleAPI.create(title: title),
          as: SampleDTO.self
        )
        return dto.toModel()
      },

      deleteItem: { id in
        try await apiClient.apiRequest(
          request: SampleAPI.delete(id: id),
          as: EmptyResponse.self
        )
      },

      isEnabled: {
        // 실제 플래그 확인 로직
        return true
      }
    )
  }
}

// MARK: - DTO (별도 파일로 분리 권장)

struct SampleDTO: Decodable {
  let id: String
  let title: String

  func toModel() -> SampleItem {
    SampleItem(id: id, title: title)
  }
}

// MARK: - API TargetType (별도 파일로 분리 권장)

enum SampleAPI: TargetType {
  case list
  case detail(id: String)
  case create(title: String)
  case delete(id: String)

  var baseURL: URL { URL(string: "https://api.example.com")! }
  var path: String {
    switch self {
    case .list: return "/samples"
    case .detail(let id): return "/samples/\(id)"
    case .create: return "/samples"
    case .delete(let id): return "/samples/\(id)"
    }
  }
  var method: HTTPMethod {
    switch self {
    case .list, .detail: return .get
    case .create: return .post
    case .delete: return .delete
    }
  }
  var parameters: [String: Any]? {
    switch self {
    case .create(let title): return ["title": title]
    default: return nil
    }
  }
  var headers: [String: String]? { nil }
}
