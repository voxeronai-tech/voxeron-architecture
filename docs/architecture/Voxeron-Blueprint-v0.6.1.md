# 📐 Voxeron Platform Blueprint v0.6.1 Addendum

**Title:** Deterministic Semantic Gate, Verification Gates, and Telemetry Audit Window  
**Status:** Clarifying addendum (non-breaking)  
**Applies to:** Voxeron Platform Blueprint v0.6 (Locked Baseline)  
**Date:** 2026-01-20  

---

## 1. Purpose

This document is a **clarifying addendum** to Blueprint v0.6. It does **not** change the four-plane model (Control, Data, Integration, Edge). Instead, it documents the **rules of engagement** and technical invariants realized during the RC1-4 and S1-4 development cycles:

- **Deterministic-first execution** (The "Semantic Gate")
- **Dual-layer verification gates** (ADR-004)
- **Telemetry-based audit window** (S1-4A)

---

## 2. Architectural Fit (Refining the Planes)

While the planes remain separate, their internal responsibilities are now more precisely defined:

### 2.1 Data Plane: Deterministic Session Orchestration

The **Data Plane** is the exclusive home of real-time execution logic.

- **Refinement:** All session logic (turn-taking, slot-filling, confirmation latching, and cart mutations) is now governed by a **Deterministic State Machine**.
- **The Invariant:** LLM output is treated as a *non-authoritative suggestion*. No state mutation or transactional commitment may occur without validation against the deterministic Semantic Gate.

### 2.2 Control Plane: Governance of Runtime Policies

The **Control Plane** remains responsible for "the rules of the game," but not the play-by-play execution.

- **Refinement:** Deterministic behavior thresholds (e.g., confidence scores for auto-confirmation) are managed as **Runtime Policies** in the Control Plane and injected into the Data Plane at session start.

### 2.3 Observability (Cross-Cutting)

Telemetry (S1-4) is confirmed as a cross-cutting concern that must not impact session latency.

- **The Invariant:** PII redaction (Email/Phone/Digits) is an enforced data-plane invariant before any event reaches the persistence layer.

---

## 3. The Semantic Gate (Primary Runtime Interface)

### 3.1 Definition

The **Semantic Gate** is the architectural boundary in the Data Plane where Voxeron decides if an utterance is actionable.

### 3.2 Non-negotiable Rules

1. **Deterministic Priority:** Intent evaluation against the `MenuSnapshot` and State-Machine occurs before any generative processing.  
2. **Validation-Required Mutation:** LLM output must never directly mutate the order state. It must be parsed into a typed contract that is then validated by the controller.  
3. **Latched Confirmation:** Critical actions (e.g., finalizing an order) require an explicit "Latch" state where the user must confirm the deterministic summary.

---

## 4. Verification Gates (ADR-004)

Blueprint v0.6 required reliability; v0.6.1 formalizes **Verification** as an infrastructure invariant. We adopt the four-layer verification hierarchy:

- **A1 (Micro Linguistic):** Pure normalization (fast, universal).  
- **A2 (Tenant Linguistic):** Alias and prefix logic (fast, tenant-scoped).  
- **B1 (Controller Golden):** Headless regression of the state-machine (deterministic).  
- **B2 (Integration Smoke):** Full-stack STT/LLM/TTS validation (nightly/asynchronous).  

**Consequence:** A passing regression suite is not "storytelling"; it is a **mathematical proof** of platform invariants.

---

## 5. Telemetry Audit Window (S1-4A)

To support the Blueprint’s goal of "Operational Safety," we introduce the **S1-4A Audit Window**. Before any new generative behavior (S2+) is activated, the platform must correlate telemetry data to quantify:

1. **Scope Drift:** Frequency of LLM suggestions falling outside the `MenuSnapshot`.  
2. **Conversion Friction:** Correlation between specific intents (e.g., complex spice queries) and session abandonment.  
3. **Funnel Integrity:** Explicit lifecycle markers (`CALL_STARTED`, `ORDER_CONFIRMED`) are now mandatory to provide a high-integrity success baseline.

---

## 6. What Remains Untouched

To preserve the integrity of the locked v0.6 baseline, the following core sections remain strictly unchanged:

- **Section 3:** The four-plane hierarchy.  
- **Section 12:** Security and Compliance (Row-Level Security and encryption models).  
- **Section 14:** Scaling Model (Stateless session workers).  
- **Section 9:** Edge Agent responsibilities and mTLS connectivity.  

---

**Voxeron Platform Blueprint v0.6.1 Addendum**  
*Clarifying the Deterministic-First Engineering Contract*
