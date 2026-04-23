# 리뷰 체크리스트

> PR 작성 전·코드 리뷰 시 순서대로 확인한다.

---

## 아키텍처

- [ ] 레이어 의존성 방향이 올바른가 (`App → Feature → Domain → Core → Shared`)
- [ ] 모듈 이름이 레이어별 컨벤션을 따르는가 (`{기능명}Feature` / `{도메인명}Service` / `{기능명}Client`)
- [ ] 다른 모듈 참조 시 Interface 타겟만 참조하고 있는가
- [ ] Feature가 Core 레이어(`APIClient` 등)를 직접 import하지 않고 Domain Service를 거치는가
- [ ] 새 모듈을 `make module` 커맨드로 생성했는가
- [ ] Interface / Sources 타겟이 올바르게 분리되어 있는가

## TCA

- [ ] `State`에 `@ObservableState`가 붙어있는가
- [ ] 모든 Action case가 명시적으로 처리(return)되고 있는가
- [ ] `@DependencyClient`에 `testValue` / `previewValue`가 있는가
- [ ] 모달은 `@Presents`, 네비게이션은 `StackState`를 사용했는가
- [ ] 장기 실행 Effect에 `.cancellable(id: CancelID.xxx)`가 붙어있는가

## 네트워크

- [ ] `TargetType` enum으로 API 요청을 정의했는가
- [ ] `NetworkError`로 에러를 처리했는가
- [ ] `tokenRefreshFailed`가 `AppCore`까지 전파되는가

## DesignSystem

- [ ] 컬러는 `Color.xxx` 토큰을 사용했는가
- [ ] 폰트는 `Typography.xxx`를 사용했는가
- [ ] 이미 존재하는 공통 컴포넌트를 중복 구현하지 않았는가

## 코드 품질

- [ ] Action 이름이 역할을 명확히 설명하는가
- [ ] `// TODO:` 주석에 날짜가 포함되어 있는가 (예: `// TODO: 25.11.30`)
- [ ] 불필요한 import가 없는가
- [ ] UI 컴포넌트에 SwiftUI Preview가 있는가

## 빌드 / 배포

- [ ] Dev/Prod 환경 분기가 `#if DEV`로 처리되어 있는가
- [ ] 서버 URL이 `API.apiBaseHost`를 통해 접근하는가
- [ ] 환경별 키가 `XCConfig/Env.xcconfig`에서 관리되는가

## Optional 안정성 · 메모리 · 스레드

- [ ] 강제 언래핑(`!`)이 필요한 위치인가, 안전한 바인딩으로 대체 가능한가
- [ ] 클로저 내부 `self` 캡처가 메모리 누수를 만들지 않는가 (`[weak self]` 검토)
- [ ] 비동기 작업이 View 생명주기를 벗어나도 안전한가 (`CancelID` 사용 여부)
