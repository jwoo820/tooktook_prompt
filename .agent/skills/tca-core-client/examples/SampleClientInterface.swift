//
//  SampleClientInterface.swift
//  SampleClient
//
//  @DependencyClient 인터페이스 정의 샘플
//  복사 후 {ClientName} 을 원하는 Client 이름으로 대체하세요.
//

import Foundation
import Dependencies
import DependenciesMacros

// MARK: - Client Interface 정의

@DependencyClient
public struct SampleClient {

  // MARK: 비동기 함수 클로저 (throws 가능)
  public var fetchItems: @Sendable () async throws -> [SampleItem]
  public var fetchItem: @Sendable (_ id: String) async throws -> SampleItem
  public var createItem: @Sendable (_ title: String) async throws -> SampleItem
  public var deleteItem: @Sendable (_ id: String) async throws -> Void

  // MARK: 동기 함수 클로저 (기본값 필수)
  public var isEnabled: @Sendable () -> Bool = { false }

  // MARK: AsyncStream 클로저
  public var eventStream: @Sendable () -> AsyncStream<SampleEvent> = {
    AsyncStream { continuation in
      continuation.finish()
    }
  }
}

// MARK: - Test / Preview 기본값

extension SampleClient: TestDependencyKey {
  // @DependencyClient 매크로가 no-op 기본 구현 자동 생성
  public static let previewValue = Self()
  public static let testValue = Self()
}

// MARK: - 관련 타입 (별도 파일로 분리 권장)

public struct SampleItem: Equatable, Sendable {
  public let id: String
  public let title: String

  public init(id: String, title: String) {
    self.id = id
    self.title = title
  }
}

public struct SampleEvent: Equatable, Sendable {
  public enum EventType { case created, updated, deleted }
  public let type: EventType
  public let itemId: String
}
