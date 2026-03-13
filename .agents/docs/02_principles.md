# TookTook iOS — AI 행동 원칙 · 판단 기준 · 리뷰 체크리스트

> AI가 이 프로젝트를 보조할 때 따르는 역할·판단 기준을 정의합니다.
> **이 프로젝트에서 AI는 "TookTook iOS 팀의 시니어 iOS 엔지니어 페어 프로그래머"로 동작합니다.**

---

## AI 행동 원칙

| 원칙 | 구체적인 행동 |
|------|-------------|
| **아키텍처 수호** | 레이어 의존성을 어기는 코드는 제안하지 않는다. 위반을 발견하면 즉시 지적한다 |
| **일관성 유지** | 코드 작성 전 동일 레이어의 기존 파일을 반드시 참조한다 |
| **최소 변경** | 요청 범위 밖의 수정은 하지 않는다. 심각한 버그가 보이면 "별도 수정 필요"로 표시한다 |
| **이유 명시** | 모든 설계 제안에 이유를 1~2줄로 덧붙인다 |
| **테스트 고려** | 새로운 `@DependencyClient` 작성 시 `testValue` / `previewValue`를 항상 같이 작성한다 |

## 코드 작성 우선순위

1. **정확성** — 의도한 기능이 올바르게 동작하는가
2. **아키텍처 적합성** — 레이어 의존성 방향을 지키는가
3. **가독성** — 팀원이 맥락 없이도 1분 안에 이해할 수 있는가
4. **테스트 가능성** — Dependency가 주입 가능한 구조인가
5. **성능** — 불필요한 렌더링·Effect가 없는가
6. **간결함** — 동일 동작을 더 짧게 쓸 수 있다면 짧게 쓴다

---

## 설계 판단 기준

### 새 코드를 어느 레이어에 놓을까?

```
→ UI에만 관련된 로직인가?              Feature (XxxCore / XxxView)
→ API를 호출하는 비즈니스 로직인가?    Domain  (XxxService)
→ 외부 I/O (네트워크·저장소·하드웨어)? Core    (XxxClient)
→ 여러 Feature에서 공통 사용?          Shared  (DesignSystem / Utils)
```

### `@Presents` vs `StackState` 언제 쓸까?

| 상황 | 선택 |
|------|------|
| 화면 위로 올라오는 모달·시트·풀스크린 커버 | `@Presents var xxx: XxxCore.State?` |
| 뒤로가기가 가능한 NavigationStack 푸시 | `StackState<XxxPath.State>` + `@Reducer enum XxxPath` |

### Effect를 언제 쓸까?

| 상황 | 코드 |
|------|------|
| 상태만 바꿀 때 | `return .none` |
| 비동기 작업 | `return .run { send in ... }` |
| 다른 Action으로만 전달 | `return .send(.xxx)` |
| 장기 실행 스트림 | `.run { }.cancellable(id: CancelID.xxx)` |

---

## 리팩토링 원칙

**해야 하는 것:**
- `core(_:_:)` 함수가 80줄 초과 → `// MARK: - 섹션명` 으로 분리
- `@DependencyClient` 구현체는 **Sources**, 인터페이스는 **Interface** 타겟에만
- DTO는 `Decodable`만 채택. Model 변환은 Service가 담당

**하면 안 되는 것:**
- Reducer 내부에서 `UIKit` / `SwiftUI` 직접 참조
- Feature 레이어에서 Core 레이어 직접 import
- `DispatchQueue.main.async` 사용 → `MainActor.run { }` 사용
- State에 클래스 타입 저장 (`@ObservationIgnored` 없이)

---

## 리뷰 체크리스트

### 아키텍처

- [ ] 레이어 의존성 방향이 올바른가 (`App → Feature → Domain → Core → Shared`)
- [ ] 모듈 이름이 레이어별 컨벤션을 따르는가 (`{기능명}Feature` / `{도메인명}Service` / `{기능명}Client`)
- [ ] 다른 모듈 참조 시 Interface 타겟만 참조하고 있는가
- [ ] Feature가 Core 레이어(`APIClient` 등)를 직접 import하지 않고 Domain Service를 거치는가
- [ ] 새 모듈을 `make module` 커맨드로 생성했는가
- [ ] Interface / Sources 타겟이 올바르게 분리되어 있는가

### TCA

- [ ] `State`에 `@ObservableState`가 붙어있는가
- [ ] 모든 Action case가 명시적으로 처리(return)되고 있는가
- [ ] `@DependencyClient`에 `testValue` / `previewValue`가 있는가
- [ ] 모달은 `@Presents`, 네비게이션은 `StackState`를 사용했는가
- [ ] 장기 실행 Effect에 `.cancellable(id: CancelID.xxx)`가 붙어있는가

### 네트워크

- [ ] `TargetType` enum으로 API 요청을 정의했는가
- [ ] `NetworkError`로 에러를 처리했는가
- [ ] `tokenRefreshFailed`가 `AppCore`까지 전파되는가

### DesignSystem

- [ ] 컬러는 `Color.xxx` 토큰을 사용했는가
- [ ] 폰트는 `Typography.xxx`를 사용했는가
- [ ] 이미 존재하는 공통 컴포넌트를 중복 구현하지 않았는가

### 코드 품질

- [ ] Action 이름이 역할을 명확히 설명하는가
- [ ] `// TODO:` 주석에 날짜가 포함되어 있는가 (예: `// TODO: 25.11.30`)
- [ ] 불필요한 import가 없는가
- [ ] UI 컴포넌트에 SwiftUI Preview가 있는가

### 빌드 / 배포

- [ ] Dev/Prod 환경 분기가 `#if DEV`로 처리되어 있는가
- [ ] 서버 URL이 `API.apiBaseHost`를 통해 접근하는가
- [ ] 환경별 키가 `XCConfig/Env.xcconfig`에서 관리되는가

---

## 커밋 컨벤션

커밋 메시지는 `{type}: {내용}` 형식으로 작성합니다.

| 타입 | 사용 시점 |
|------|----------|
| `feature` | 새로운 기능 구현 |
| `add` | asset 혹은 라이브러리 추가 |
| `chore` | 잡일 (버전 코드 수정, 패키지 구조 변경, 파일 이동, 변수명·reformat 등) |
| `fix` | 버그·오류 해결 |
| `docs` | README, WIKI 등 문서 개정 |
| `refactor` | 내부 로직 변경 없이 코드 구조를 개선하는 리팩토링 |

### 커밋 시 주의사항
- **허용된 타입만 사용**: 위에 명시된 6가지 커밋 타입(`feature`, `add`, `chore`, `fix`, `docs`, `refactor`) 외에는 **절대 다른 타입(예: `test`, `style`, `build` 등)을 임의로 사용하지 않습니다.** 조건에 부합하지 않는 애매한 작업이 있다면 반드시 사용자에게 먼저 물어봅니다.
- `.agents/` 폴더 내부에 있는 파일들은 개인 AI 설정용이므로 **절대 커밋하지 않습니다.** (gitignore 처리도 하지 않고 수동으로 제외합니다)

```
# 예시
feature: 검색 결과 페이지네이션 구현
fix: 팔로우 버튼 중복 탭 시 상태 꼬임 수정
chore: SearchFeature 유닛 테스트 설정 개선
refactor: HomeCore switch 케이스 MARK 섹션 분리
docs: rules에 커밋 컨벤션 추가
```

---

## PR 전 브랜치 전략 (Rebase & Merge)

> ⚠️ **Git rebase는 히스토리를 재작성하는 예민한 작업입니다.**
> AI가 rebase 관련 명령어를 실행할 때는 **반드시 사용자에게 먼저 확인을 받고, 단계별로 진행합니다.**

### 지향하는 Merge 방식

```
feature/mvp/main ──●──●──●──●  (Merge commit으로 합병 이력이 가시적으로 남음 ✅)
                        ↑
feature/mvp/KAN-99 ──●──●
```

작업 브랜치를 main에 합병할 때 **Merge commit**을 남겨서 어떤 브랜치가 언제 합병되었는지 그래프에서 가시적으로 확인할 수 있게 한다.

### PR 전 필수 절차 (Rebase)

PR을 올리기 전, 작업 브랜치를 main 최신 커밋 기준으로 rebase하여 충돌을 미리 해소하고 깔끔한 이력을 만든다.

**Step 1.** 내 작업 브랜치에서 main 기준으로 rebase

```bash
# 내 작업 브랜치에서 실행
git rebase feature/mvp/main
```

**Step 2.** 충돌이 발생했다면 해결 후 빌드 확인

```bash
# 충돌 해결 후
git add .
git rebase --continue
# 이후 Xcode에서 빌드 확인
```

**Step 3.** 원격 브랜치에 push

```bash
# 최초 push이거나 충돌 없는 경우
git push

# 이미 원격에 올라가 있어 push가 거부되는 경우에만 사용
# ⚠️ 강제 push는 원격 히스토리를 덮어씁니다. 로컬 내용이 맞는지 반드시 확인 후 실행!
git push -f
```

> `-f` (강제 push)는 로컬과 원격의 상태가 달라 일반 push가 거부될 때만 사용합니다.
> 평소에는 지양하세요 — 작업 내용을 날릴 수 있습니다.


