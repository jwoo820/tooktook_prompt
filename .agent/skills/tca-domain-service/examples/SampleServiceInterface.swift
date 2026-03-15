//
//  SampleServiceInterface.swift
//  SampleService
//
//  Domain Service Interface 정의 샘플
//  복사 후 {ServiceName} 을 원하는 Service 이름으로 대체하세요.
//

import Foundation
import Dependencies
import DependenciesMacros

// MARK: - Service Interface

@DependencyClient
public struct SampleService {

  // Feature에서 필요한 비즈니스 동작 정의
  public var fetchList: @Sendable () async throws -> [SampleDomainModel]
  public var fetchDetail: @Sendable (_ id: String) async throws -> SampleDomainModel
  public var create: @Sendable (_ request: SampleCreateRequest) async throws -> SampleDomainModel
  public var update: @Sendable (_ id: String, _ request: SampleUpdateRequest) async throws -> SampleDomainModel
  public var delete: @Sendable (_ id: String) async throws -> Void
}

extension SampleService: TestDependencyKey {
  public static let previewValue = Self()
  public static let testValue = Self()
}

// MARK: - Domain 모델 (DTO와 분리된 앱 내부 모델)

public struct SampleDomainModel: Equatable, Sendable {
  public let id: String
  public let title: String
  public let createdAt: Date
  public let author: AuthorModel

  public init(id: String, title: String, createdAt: Date, author: AuthorModel) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
    self.author = author
  }
}

public struct AuthorModel: Equatable, Sendable {
  public let id: String
  public let nickname: String
  public let profileImageURL: String?
}

public struct SampleCreateRequest: Equatable, Sendable {
  public let title: String
  public let content: String

  public init(title: String, content: String) {
    self.title = title
    self.content = content
  }
}

public struct SampleUpdateRequest: Equatable, Sendable {
  public let title: String?
  public let content: String?

  public init(title: String? = nil, content: String? = nil) {
    self.title = title
    self.content = content
  }
}
