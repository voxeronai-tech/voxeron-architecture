# Voxeron – Project Status

Last updated: 2026-01-03
Owner: Marcel (Voxeron)

## Architecture Lock
- Locked Architecture Version: v0.7.1 (APPROVED)
- Tag: v0.7.1
- Branch: release/v0.7.1
- Blueprint Doc: docs/architecture/Voxeron-Platform-Blueprint-v0.7.1.md
- Rule: v0.7.1 is architecture-locked (no changes without bumping minor version)

## Current Active Release (Implementation)
- Target Release: v0.7.2
- Working Branch: release/v0.7.2
- Sprint: Sprint 1 (Week 1) – Deterministic Core
- Goal: Break up fat SessionController → introduce Cognitive Orchestrator + Deterministic Parser

## Sprint 1 Scope (Acceptance Criteria)
### AC-1.1 ParserResult Typed Contract
- Implement ParserResult with:
  - status (MATCH | PARTIAL | NO_MATCH | AMBIGUOUS)
  - reason_code (EXACT_ALIAS_MATCH, REGEX_PATTERN_MATCH, SLOT_..., NO_ALIAS, etc.)
  - matched_entity (optional)
  - confidence (optional)
  - execution_time_ms (required)
- If exact alias found → MATCH + EXACT_ALIAS_MATCH
- If no match → NO_MATCH + emit DeterministicMatchFailed telemetry async
- Always measure execution_time_ms

### AC-1.2 Deterministic-First Execution Flow
- Orchestrator calls Deterministic Parser BEFORE any LLM call
- MATCH → skip LLM and execute tool/action directly
- NO_MATCH → fallback to stochastic/agent path within <50ms after parser completion
- No stream resets, pops, or socket reconnect caused by transitions

### AC-1.3 Centralized Session State (Redis)
- Worker must not rely on local RAM state between turns
- On each utterance: fetch SessionState from Redis using session_id
- After turn: persist updated state to Redis with TTL 24h
- If Redis unavailable: log critical + fail gracefully (no zombie turns)

## Current Repo State
- main: baseline runtime repo (v0.6.x baseline)
- release/v0.7.1: architecture lock + stability fixes (tagged v0.7.1)
- Next: create release/v0.7.2 from main or from release/v0.7.1 (decision recorded below)

## Decision Log (Keep this short)
- 2026-01-03: v0.7.1 locked as architecture release, implementation continues on v0.7.2

## Known Risks / Pain Points
- SessionController too fat, mixing policy + state + routing + LLM calls
- Need clean cancellation on websocket close (avoid orphan tasks)
- Avoid language flip-flops (“ja/ok”)

## Next 3 Actions
1) Create milestone + issues for v0.7.2 (Sprint 1)
2) Create branch release/v0.7.2
3) Implement ParserResult + Deterministic Parser skeleton + Orchestrator entrypoint
