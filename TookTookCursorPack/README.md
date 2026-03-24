# TookTook Cursor Pack

Cursor 규칙만 한 번에 옮겨 재사용하기 위한 번들입니다.
외부 폴더 참조 없이 `cursor/rules` 단일 파일 기반으로 동작합니다.

## 포함 구조

- `cursor/rules/00_unified_prompt_always.mdc`: 단일 통합 규칙
- `cursor/rules/README.md`: 사용 가이드

## 경량 동작 방식

- Always 적용: `cursor/rules/00_unified_prompt_always.mdc` 1개
- 추가 참조 파일 없이 단일 파일로 처리

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
