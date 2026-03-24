# Cursor Rules 재사용 가이드

이 폴더의 `.mdc` 파일은 `.agents/docs`, `.agents/rules` 원문을 최대한 유지해 Cursor 포맷으로 이식한 버전입니다.

## 다른 프로젝트에 적용할 때 (필수)
1. `01_context_always.mdc`의 앱 기본 정보 표를 프로젝트 값으로 치환
2. 빌드/배포 명령어를 프로젝트 실제 명령으로 치환
3. 레이어 구조가 다르면 `01_context_always.mdc`, `11_architecture_auto.mdc`의 의존성 규칙 수정
4. 상태관리가 TCA가 아니면 `12_tca_state_auto.mdc`를 비활성/삭제
5. 네트워크 추상화 방식이 다르면 `13_network_auto.mdc`, `14_dto_error_auto.mdc`를 프로젝트 규칙으로 교체

## 우선 치환 권장 항목
- 앱 이름, 조직, 최소 iOS, Bundle ID
- 워크스페이스/프로젝트 파일명
- 빌드 명령어 (`make`, `xcodebuild`, `fastlane` 등)
- 아키텍처 명칭 (예: TCA, MVVM, Clean Architecture)
- 네트워크 클라이언트 타입명 (예: `APIClient`, `NetworkClient`)
- 에러 공통 타입명 (예: `NetworkError`)

## Cursor 설정 팁
- `01_context_always.mdc`, `02_principles_always.mdc`는 Always 규칙으로 유지
- 나머지는 Auto Attached 규칙으로 유지하고 필요 시 `@규칙파일명`으로 수동 호출
- 규칙 길이가 길면 파일을 더 쪼개는 것이 적용 안정성에 유리
