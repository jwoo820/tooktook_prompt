import ProjectDescription
import ProjectDescriptionHelpers
import DependencyPlugin

// MARK: - Feature 모듈 Project.swift 샘플
// 복사 후 {FeatureName} 을 원하는 Feature 이름으로 대체하세요.

let project: Project = .makeTMABasedProject(
  module: Feature.SampleFeature,         // Feature enum case 이름
  scripts: [],
  targets: [
    .sources,
    // .interface,   // 다른 Feature가 이 Feature의 타입에 접근해야 할 때
    // .tests,       // 유닛 테스트 포함 시
    // .testing,     // 테스트 목(Mock) 데이터 제공 시
    // .example,     // 데모 앱으로 단독 실행이 필요할 때
  ],
  dependencies: [
    .sources: [
      .dependency(rootModule: Domain.self),    // Domain 전체 의존
      // 특정 Feature에 의존할 때:
      // .dependency(module: Feature.SomeFeature),
    ]
  ]
)

// ----------------------------------------------------------------
// MARK: - Core(Client) 모듈 Project.swift 샘플
// ----------------------------------------------------------------
// let project: Project = .makeProject(
//   module: Core.SampleClient,
//   scripts: [],
//   product: .staticLibrary,
//   dependencies: [
//     .dependency(rootModule: Core.self)
//   ]
// )

// ----------------------------------------------------------------
// MARK: - Domain Service 모듈 Project.swift 샘플
// ----------------------------------------------------------------
// let project: Project = .makeTMABasedProject(
//   module: Domain.SampleService,
//   scripts: [],
//   targets: [
//     .sources,
//     .interface,
//     .testing,
//   ],
//   dependencies: [
//     .sources: [
//       .dependency(rootModule: Core.self),
//     ],
//     .interface: [
//       .dependency(rootModule: Shared.self),
//     ]
//   ]
// )
