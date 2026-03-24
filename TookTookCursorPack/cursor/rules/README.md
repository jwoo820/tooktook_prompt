# Cursor Rules 재사용 가이드

이 폴더는 토큰 절약을 위해 단일 통합 규칙만 유지합니다.

## 권장 사용 방식
1. 기본 적용: `00_unified_prompt_always.mdc` (always)
2. 프로젝트마다 필요한 값(앱명/명령어/아키텍처)만 이 파일에서 치환

## 우선 치환 권장 항목
- 앱 이름, 조직, 최소 iOS, Bundle ID
- 빌드 명령어 (`make`, `xcodebuild`, `fastlane` 등)
- 아키텍처 명칭 (예: TCA, MVVM, Clean Architecture)
- 네트워크 클라이언트 타입명 (예: `APIClient`, `NetworkClient`)
- 에러 공통 타입명 (예: `NetworkError`)

## Cursor 설정 팁
- 토큰 절약이 목표라면 현재 구조를 그대로 유지
- 규칙 확장이 필요할 때만 새 `.mdc`를 추가
