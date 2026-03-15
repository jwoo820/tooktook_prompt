---
name: tca-domain-service
description: TookTook iOS Domain 레이어의 Service 모듈을 생성하는 스킬. Interface/Sources 분리 패턴과 TCA DependencyClient를 사용하는 Domain Service 작성 방법을 안내합니다.
---

# TCA Domain Service 레이어 개발 가이드

## 개요

TookTook iOS Domain 레이어는 비즈니스 로직과 데이터 변환을 담당합니다.
각 Service는 `Interface/`에 TCA `@DependencyClient` 프로토콜을, `Sources/`에 Core Client를 조합한 실제 구현을 제공합니다.

## 디렉토리 구조

```
Projects/Domain/{ServiceName}/
├── Project.swift
├── Interface/
│   └── {ServiceName}Interface.swift    # @DependencyClient 정의
└── Sources/
    └── {ServiceName}.swift             # Core Client 의존/조합 구현
```

## Interface 작성 규칙

```swift
import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct {ServiceName}Service {
  // Feature에서 필요한 비즈니스 동작 정의
  public var fetchList: @Sendable () async throws -> [DomainModel]
  public var create: @Sendable (_ request: CreateRequest) async throws -> DomainModel
  public var delete: @Sendable (_ id: String) async throws -> Void
}

extension {ServiceName}Service: TestDependencyKey {
  public static let previewValue = Self()
  public static let testValue = Self()
}

// MARK: - Domain 모델 타입

public struct DomainModel: Equatable, Sendable {
  public let id: String
  // 필드 정의
}

public struct CreateRequest: Equatable, Sendable {
  // 요청 파라미터
}
```

## Sources (Live 구현) 작성 규칙

```swift
import Foundation
import {ServiceName}Interface
import APIClientInterface
import Dependencies

extension {ServiceName}Service: @retroactive DependencyKey {
  public static let liveValue: {ServiceName}Service = .live()

  public static func live() -> Self {
    @Dependency(APIClient.self) var apiClient

    return .init(
      fetchList: {
        let response: [{ServiceName}DTO] = try await apiClient.apiRequest(
          request: {ServiceName}API.list,
          as: [{ServiceName}DTO].self
        )
        return response.map { $0.toModel() }
      },
      create: { request in
        let dto: {ServiceName}DTO = try await apiClient.apiRequest(
          request: {ServiceName}API.create(request),
          as: {ServiceName}DTO.self
        )
        return dto.toModel()
      },
      delete: { id in
        try await apiClient.apiRequest(
          request: {ServiceName}API.delete(id: id),
          as: EmptyResponse.self
        )
      }
    )
  }
}
```

## Feature에서 사용하는 방법

```swift
@Reducer
public struct SomeCore {
  @Dependency({ServiceName}Service.self) var {serviceName}Service

  private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {
    case .onAppear:
      return .run { send in
        let list = try await {serviceName}Service.fetchList()
        await send(.listLoaded(list))
      }
    }
  }
}
```

## Project.swift 작성 규칙

```swift
import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

let project: Project = .makeTMABasedProject(
  module: Domain.{ServiceName},
  scripts: [],
  targets: [
    .sources,
    .interface,
    // .testing,   // Testing 헬퍼가 필요한 경우
  ],
  dependencies: [
    .sources: [
      .dependency(rootModule: Core.self),  // Core Client 의존
    ],
    .interface: [
      .dependency(rootModule: Shared.self),  // 공통 타입 의존
    ]
  ]
)
```

## 관련 샘플

- [`examples/SampleServiceInterface.swift`](examples/SampleServiceInterface.swift) — Interface 정의 샘플
- [`examples/SampleService.swift`](examples/SampleService.swift) — Live 구현 샘플

## 주의사항

- Domain 모델은 Interface에 정의하고, DTO는 Sources에만 존재해야 합니다.
- Service는 API 직접 호출 대신 Core Client를 통해 데이터를 가져옵니다.
- 복잡한 비즈니스 로직(필터링, 변환, 집계 등)은 Service에서 처리합니다.
