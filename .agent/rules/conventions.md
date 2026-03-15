# TookTook iOS — 네이밍 · 커밋 · PR · 리뷰 체크리스트

---

## 규칙 C-1. 파일 이름을 통일한다

| 대상 | 규칙 | 예시 |
|------|------|------|
| Reducer | `{화면명}Core.swift` | `HomeCore.swift` |
| View | `{화면명}View.swift` | `HomeView.swift` |
| Service Interface | `{도메인}ServiceInterface.swift` | `AuthServiceInterface.swift` |
| API Request | `{도메인}APIRequest.swift` | `AuthAPIRequest.swift` |
| DTO | `{내용}Data.swift` | `ProfileMemberData.swift` |
| Feature 전용 열거형 | `{Context}Type.swift` | `DeleteAccountReasonType.swift` |
| Path Enum | `{화면명}Path` (Core 파일 내부 extension) | `HomePath` |

---

## 규칙 C-2. Action 이름은 목적을 명확하게 표현한다

```swift
// ✅ 사용자 인터랙션 — "on" + 동사
case onTapSearch
case onTapLike(postId: Int)
case onTapProfile

// ✅ 화면 전환 — "moveTo" + 대상
case moveToDetail(type: FeedType)
case moveToFollowManage(followerCount: Int, followingCount: Int, isMine: Bool, memberID: Int?)

// ✅ 비동기 결과 — 명사 + 결과
case postsLoaded([Post])
case loginFailed(NetworkError)

// ✅ 시스템 이벤트
case onLoad
case tabReselected
case didChangeScenePhase(ScenePhase)

// ❌ 금지
case buttonTapped   // 어떤 버튼인지 불명확
case update         // 무엇을 업데이트하는지 불명확
case handle         // 의미 없음
case AAA            // 절대 금지
```

---

## 규칙 C-3. `// TODO:` 주석에는 날짜를 포함한다

```swift
// ❌
// TODO: 나중에 수정

// ✅
// TODO: 25.11.30 - 관련 action 네이밍 컨벤션 두는 것이 좋을듯
```

---

## 금지 패턴 총정리

| 금지 패턴 | 올바른 대안 |
|----------|------------|
| `URLSession` 직접 사용 | `APIClient.apiRequest(request:as:)` |
| Feature에서 `APIClient` 직접 주입 | `XxxService` 통해 접근 |
| `DispatchQueue.main.async` | `MainActor.run { }` |
| `Bool` 플래그 화면 전환 | `StackState` / `@Presents` |
| 하드코드 서버 URL | `API.apiBaseHost + "/path"` |
| DTO에 `Encodable` 채택 | `Decodable`만 채택 |
| `catch { }` 에러 무시 | 명시적 catch + Action 발행 |
| Action 이름에 `buttonTapped` / `update` | `onTapSearch` / `postsLoaded` |
| `// TODO:` 날짜 없는 주석 | `// TODO: 25.11.30 - 내용` |
| Reducer 내부 `UIKit` 직접 사용 | `.run { await MainActor.run { } }` |
| State에 클래스 타입 저장 | `@ObservationIgnored` 사용 또는 값 타입으로 변경 |
| 수동 모듈 생성 | `make module layer="..." name="..."` |
| DesignSystem 하드코딩 | `Color.xxx` / `Typography.xxx` 토큰 사용 |

---

## 커밋 컨벤션

커밋 메시지: `{type}: {내용}`

| 타입 | 사용 시점 |
|------|----------|
| `feature` | 새로운 기능 구현 |
| `add` | asset 혹은 라이브러리 추가 |
| `chore` | 버전 코드 수정·패키지 구조 변경·파일 이동·reformat 등 |
| `fix` | 버그·오류 해결 |
| `docs` | README, WIKI 등 문서 개정 |
| `refactor` | 내부 로직 변경 없이 코드 구조를 개선하는 리팩토링 |

> **주의**: 위 6가지 외 타입(`test`, `style`, `build` 등)은 절대 사용하지 않습니다. 애매한 경우 사용자에게 먼저 확인합니다.

> **주의**: `.agent/` 폴더 내부 파일은 **절대 커밋하지 않습니다.** (gitignore 처리 없이 수동 제외)

```
# 예시
feature: 검색 결과 페이지네이션 구현
fix: 팔로우 버튼 중복 탭 시 상태 꼬임 수정
chore: SearchFeature 유닛 테스트 설정 개선
refactor: HomeCore switch 케이스 MARK 섹션 분리
```

---

## PR 전 브랜치 전략 (Rebase & Merge)

> ⚠️ Git rebase는 히스토리를 재작성하는 예민한 작업입니다.
> AI가 rebase 명령어를 실행할 때는 **반드시 사용자에게 먼저 확인 후 단계별로 진행합니다.**

### Merge 방식

```
feature/mvp/main ──●──●──●──●  (Merge commit으로 합병 이력 가시화 ✅)
                        ↑
feature/mvp/KAN-99 ──●──●
```

### PR 전 필수 절차

```bash
# Step 1. main 기준 rebase
git rebase feature/mvp/main

# Step 2. 충돌 해결 후
git add .
git rebase --continue
# 이후 Xcode에서 빌드 확인

# Step 3. push
git push                # 일반 push
git push -f             # 이미 원격에 올라간 경우만 (로컬 내용 확인 필수!)
```

---

## 리뷰 체크리스트

### 아키텍처
- [ ] 레이어 의존성 방향 (`App → Feature → Domain → Core → Shared`)
- [ ] 모듈 이름이 레이어별 컨벤션을 따르는가
- [ ] 다른 모듈 참조 시 Interface 타겟만 참조하는가
- [ ] Feature가 Core 레이어를 직접 import하지 않는가
- [ ] 새 모듈을 `make module` 명령어로 생성했는가
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
- [ ] `// TODO:` 주석에 날짜가 포함되어 있는가
- [ ] 불필요한 import가 없는가
- [ ] UI 컴포넌트에 SwiftUI Preview가 있는가

### 빌드 / 배포
- [ ] Dev/Prod 환경 분기가 `#if DEV`로 처리되어 있는가
- [ ] 서버 URL이 `API.apiBaseHost`를 통해 접근하는가
- [ ] 환경별 키가 `XCConfig/Env.xcconfig`에서 관리되는가
