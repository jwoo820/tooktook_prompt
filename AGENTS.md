This file provides guidance to AI coding agents like Claude Code (claude.ai/code), Cursor AI, Codex, Gemini CLI, GitHub Copilot, and other AI coding assistants when working with code in this repository.

# TookTook iOS Agent Guide

## Scope
- 이 저장소의 AI 규칙은 `.cursor/rules/*.mdc`를 기준으로 적용한다.
- 원문 소스는 `.agents/docs`, `.agents/rules`이며, Cursor 적용본은 원문 기반으로 이식되어 있다.

## Always-On Principles
- 모든 설명은 한국어로 작성한다.
- iOS 관련 코드는 Swift 기준으로 작성한다.
- SwiftUI를 우선 제안하되 기존 UIKit 구조를 존중한다.
- 변경 범위는 최소화하고, 불필요한 리팩터링을 하지 않는다.
- 추측이 필요한 경우 "추측"임을 명시한다.

## Quality Checks
- Optional 처리 안정성
- 메모리 누수 가능성
- 스레드 안전성
- 생명주기 영향

## Rule Files (원문 이식)
- [.cursor/rules/01_context_always.mdc](.cursor/rules/01_context_always.mdc)
- [.cursor/rules/02_principles_always.mdc](.cursor/rules/02_principles_always.mdc)
- [.cursor/rules/11_architecture_auto.mdc](.cursor/rules/11_architecture_auto.mdc)
- [.cursor/rules/12_tca_state_auto.mdc](.cursor/rules/12_tca_state_auto.mdc)
- [.cursor/rules/13_network_auto.mdc](.cursor/rules/13_network_auto.mdc)
- [.cursor/rules/14_dto_error_auto.mdc](.cursor/rules/14_dto_error_auto.mdc)
- [.cursor/rules/15_naming_structure_auto.mdc](.cursor/rules/15_naming_structure_auto.mdc)
- [.cursor/rules/16_testing_antipatterns_auto.mdc](.cursor/rules/16_testing_antipatterns_auto.mdc)

## Reuse In Other Projects
- 다른 프로젝트로 복사 시 치환 포인트는 [.cursor/rules/README.md](.cursor/rules/README.md)를 따른다.
