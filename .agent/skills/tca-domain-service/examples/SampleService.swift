//
//  SampleService.swift
//  SampleService
//
//  Domain Service Live 구현 샘플
//  복사 후 {ServiceName} 을 원하는 Service 이름으로 대체하세요.
//

import Foundation
import SampleServiceInterface
import APIClientInterface
import Dependencies

// MARK: - Live 구현

extension SampleService: @retroactive DependencyKey {
  public static let liveValue: SampleService = .live()

  public static func live() -> Self {
    @Dependency(APIClient.self) var apiClient

    return .init(
      fetchList: {
        let response: [SampleDTO] = try await apiClient.apiRequest(
          request: SampleAPI.list,
          as: [SampleDTO].self
        )
        return response.map { $0.toDomain() }
      },

      fetchDetail: { id in
        let dto: SampleDTO = try await apiClient.apiRequest(
          request: SampleAPI.detail(id: id),
          as: SampleDTO.self
        )
        return dto.toDomain()
      },

      create: { request in
        let body = SampleCreateBody(title: request.title, content: request.content)
        let dto: SampleDTO = try await apiClient.apiRequest(
          request: SampleAPI.create(body: body),
          as: SampleDTO.self
        )
        return dto.toDomain()
      },

      update: { id, request in
        let body = SampleUpdateBody(title: request.title, content: request.content)
        let dto: SampleDTO = try await apiClient.apiRequest(
          request: SampleAPI.update(id: id, body: body),
          as: SampleDTO.self
        )
        return dto.toDomain()
      },

      delete: { id in
        try await apiClient.apiRequest(
          request: SampleAPI.delete(id: id),
          as: EmptyResponse.self
        )
      }
    )
  }
}

// MARK: - DTO (Sources에만 존재, Interface에 노출 금지)

private struct SampleDTO: Decodable {
  let id: String
  let title: String
  let content: String
  let createdAt: String
  let author: AuthorDTO

  func toDomain() -> SampleDomainModel {
    SampleDomainModel(
      id: id,
      title: title,
      createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
      author: author.toDomain()
    )
  }
}

private struct AuthorDTO: Decodable {
  let id: String
  let nickname: String
  let profileImageURL: String?

  func toDomain() -> AuthorModel {
    AuthorModel(id: id, nickname: nickname, profileImageURL: profileImageURL)
  }
}

// MARK: - Request Body (Sources에만 존재)

private struct SampleCreateBody: Encodable {
  let title: String
  let content: String
}

private struct SampleUpdateBody: Encodable {
  let title: String?
  let content: String?
}

// MARK: - API TargetType (별도 파일로 분리 권장)

private enum SampleAPI: TargetType {
  case list
  case detail(id: String)
  case create(body: SampleCreateBody)
  case update(id: String, body: SampleUpdateBody)
  case delete(id: String)

  var baseURL: URL { URL(string: "https://api.example.com")! }
  var path: String {
    switch self {
    case .list: return "/samples"
    case .detail(let id): return "/samples/\(id)"
    case .create: return "/samples"
    case .update(let id, _): return "/samples/\(id)"
    case .delete(let id): return "/samples/\(id)"
    }
  }
  var method: HTTPMethod {
    switch self {
    case .list, .detail: return .get
    case .create: return .post
    case .update: return .patch
    case .delete: return .delete
    }
  }
  var parameters: [String: Any]? { nil }
  var headers: [String: String]? { nil }
}
