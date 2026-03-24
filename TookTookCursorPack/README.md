# TookTook Cursor Pack

Cursor 규칙만 한 번에 옮겨 재사용하기 위한 번들입니다.

## 포함 구조

- `cursor/rules`: Cursor `.mdc` 규칙 (통합 + 상세)

## 경량 동작 방식

- Always 적용: `00 + 01 + 02`
- 상세 규칙: `11~16` Auto Attached
- 토큰 절약이 필요하면 `01/02`를 수동으로 내릴 수 있음

## 규칙 파일 역할

- `00_unified_prompt_always.mdc`: 공통 통합 규칙
- `01_context_always.mdc`: 프로젝트 컨텍스트
- `02_principles_always.mdc`: 행동 원칙/리뷰 체크리스트
- `11~16`: 아키텍처, TCA, 네트워크, DTO/에러, 네이밍, 테스트 상세 규칙

## 빠른 설치

대상 프로젝트 루트에서 아래 실행:

```bash
bash TookTookCursorPack/install.sh
```

또는 경로를 직접 지정:

```bash
bash TookTookCursorPack/install.sh /path/to/target-project
```

## 설치 결과

- `cursor/rules/*`  -> `<target>/.cursor/rules/*`
