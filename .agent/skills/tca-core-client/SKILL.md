---
name: tca-core-client
description: TookTook iOS Core 레이어의 TCA Dependency Client 모듈을 생성하는 스킬. @DependencyClient 매크로 기반의 Interface/Sources 분리 패턴과 DependencyKey 구현 방법을 안내합니다.
---

# TCA Core Client 개발 가이드

## 개요

TookTook iOS Core 레이어는 외부 서비스(네트워크, 저장소, 알림 등)와 앱 코드 사이의 인터페이스를 담당합니다.
각 Client는 `Interface/`에 프로토콜 정의, `Sources/`에 실제 구현을 분리하는 구조를 따릅니다.

## 디렉토리 구조

```
Projects/Core/{ClientName}/
├── Project.swift
├── Interface/
│   └── {ClientName}Interface.swift    # @DependencyClient 프로토콜 정의
└── Sources/
    └── {ClientName}.swift             # DependencyKey liveValue 구현
```

## Interface 작성 규칙

`@DependencyClient` 매크로를 사용해 클라이언트를 선언합니다.
`TestDependencyKey`를 채택해 Preview/Test 환경의 기본값도 함께 정의합니다.

```swift
import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct {ClientName}Client {
  // 비동기 함수 클로저
  public var fetchData: @Sendable () async throws -> [SomeModel]

  // 동기 함수 클로저
  public var isEnabled: @Sendable () -> Bool = { false }

  // 스트림 클로저
  public var stream: @Sendable () -> AsyncStream<SomeEvent> = {
    AsyncStream { continuation in continuation.finish() }
  }
}

extension {ClientName}Client: TestDependencyKey {
  public static let previewValue = Self()  // 매크로가 no-op 구현 자동 생성
  public static let testValue = Self()
}
```

## Sources (Live 구현) 작성 규칙

```swift
import Foundation
import {ClientName}Interface
import Dependencies

extension {ClientName}Client: @retroactive DependencyKey {
  public static let liveValue: {ClientName}Client = .live()

  public static func live() -> Self {
    // 필요한 의존성 초기화
    return .init(
      fetchData: {
        // 실제 네트워크/저장소 호출
      },
      isEnabled: {
        // 실제 값 반환
      }
    )
  }
}
```

## Feature에서 사용하는 방법

```swift
@Reducer
public struct SomeCore {
  @Dependency({ClientName}Client.self) var {clientName}Client

  private func core(_ state: inout State, _ action: Action) -> EffectOf<Self> {
    switch action {
    case .onAppear:
      return .run { send in
        let data = try await {clientName}Client.fetchData()
        await send(.dataLoaded(data))
      }
    // ...
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
  module: Core.{ClientName},
  scripts: [],
  targets: [
    .sources,
    .interface,
  ],
  dependencies: [
    .sources: [
      .dependency(module: Core.{ClientName}, target: .interface),
      // 필요 시 외부 라이브러리
    ],
    .interface: [
      // 인터페이스에서 필요한 기본 의존성
    ]
  ]
)
```

## 관련 샘플

- [`examples/SampleClientInterface.swift`](examples/SampleClientInterface.swift) — Interface 정의 샘플
- [`examples/SampleClient.swift`](examples/SampleClient.swift) — Live 구현 샘플

## 주의사항

- `@DependencyClient` 매크로는 선언된 모든 클로저에 대한 no-op 기본 구현을 자동 생성합니다.
- `testValue`와 `previewValue`는 항상 `Self()`를 사용합니다.
- Live 구현에서 `@retroactive DependencyKey`를 사용합니다.
- Dependency 주입은 항상 `@Dependency({ClientName}Client.self)` 형태로 사용합니다.
