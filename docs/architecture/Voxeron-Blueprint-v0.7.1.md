# 📐 Voxeron Platform Blueprint v0.7.1
## *Agentic Multi-Domain Architecture with Continuous Learning*
## **Dev-Hardened Release**

**Project Name:** Voxeron  
**Status:** Production-Ready Architecture - Dev-Hardened Release  
**Versioning:** Semantic Versioning (SemVer)  
**Supersedes:** v0.7.0 (technical refinements for implementation accuracy)  
**Primary Use Case:** Universal agentic voice orchestration across service sectors  
**Design Goal:** Scale from single-domain execution to multi-tenant, multi-domain orchestration without architectural rewrites  
**Core Innovation:** Mid-session domain routing with universal dispatcher pattern and automated continuous learning

---

## 1. Platform Overview

Voxeron is a **stateless compute platform with centralized session management**, designed for agentic orchestration of structured service interactions across multiple domains including hospitality, emergency services, technical dispatch, and public-sector triage.

Runtime execution workers are horizontally scalable and ephemeral, while session state persistence is managed through Redis (hot state) and PostgreSQL (durable state). This separation enables elastic scaling while maintaining conversation continuity and auditability.

Version 0.7.1 introduces two foundational capabilities that differentiate Voxeron as intelligent infrastructure rather than conversational middleware:

**1. Universal Dispatcher Pattern** - Enabling a single platform deployment to intelligently route and execute conversations across heterogeneous business domains through dynamic context switching and schema-first typed tool orchestration.

**2. Log-to-Logic Learning Pipeline** - An asynchronous learning system that transforms every conversation into deterministic improvement, creating a data moat where the platform becomes faster, cheaper, and more accurate with every interaction.

The platform maintains streaming-first duplex audio with interruption handling while adding cognitive orchestration capabilities that allow mid-session domain transitions without socket disconnection. Business logic execution remains asynchronous, observable, and protected by idempotency guarantees.

Voxeron is organized into four architectural planes with enhanced orchestration and learning capabilities:

- **Control Plane** - Configuration, governance, policy management, and automated learning  
- **Data Plane** - Stateless real-time voice execution with centralized session state management  
- **Integration Plane** - Asynchronous business actions and external systems  
- **Edge Plane** - On-site hardware resilience and local execution  

---

## 2. Architectural Principles

The architecture of Voxeron v0.7.1 is guided by expanded principles that enable agentic operation, continuous improvement, and operational safety.

**Core Principles:**
- **Stateless compute with centralized session management** - Workers are ephemeral and horizontally scalable; state persists in Redis and PostgreSQL
- Tenant isolation is enforced at every layer
- Integrations are event-driven and failure-aware
- Vendor dependencies are abstracted behind capability tiers and routing policies
- Streaming is the default interaction mode
- Deterministic behavior through typed contracts and validation
- Failure treated as first-class scenario with graceful degradation
- Privacy, consent, and data residency enforced by design
- Operational safety through staged rollouts and kill switches

**Agentic & Learning Principles (v0.7):**
- **Schema-first typed tool access** inspired by MCP philosophy
- **Domain routing** enables universal entry points with specialized execution
- **Mid-session context switching** without connection interruption
- **P0 safety overrides** provide deterministic guardrails for high-stakes scenarios (human-verified, never automated)
- **Dual-mode operation** supports both stochastic (agent-driven) and deterministic (rule-based) execution paths
- **Continuous learning** transforms operational telemetry into deterministic rules
- **Privacy-by-default in learning** with strict field-level controls and PII redaction at source
- **Supervised automation** where machine proposals require human approval before production deployment

---

## 3. High-Level Architecture

### 3.1 Control Plane

The control plane governs configuration, rollout, governance, and **automated learning** across all domains and tenants.

**Responsibilities:**
- Multi-domain tenant provisioning (tenants, locations, domains, sectors)
- Blueprint lifecycle management across sector types
- Universal dispatcher configuration and meta-tenant management
- Feature flags, staged rollouts, and emergency kill switches
- Cross-domain routing policies and domain classification rules
- Vendor capability tier routing policies (latency, cost, compliance requirements)
- Governance: audit trails, approval workflows, environment promotion
- API token issuance with domain-scoped permissions
- Safety policy configuration including P0 trigger definitions
- **Discovery Engine for automated learning**
- **Blueprint proposal approval and deployment workflow**

**Discovery Engine Component:**

The Discovery Engine is a Control Plane service that operates asynchronously to identify platform gaps and propose deterministic improvements.

Responsibilities:
- Aggregate telemetry from stochastic fallback events
- Cluster similar unmapped utterances using vector embeddings
- Validate intent mappings using high-reasoning audit models
- Generate versioned blueprint proposals
- Present proposals in approval dashboard with supporting evidence
- Deploy approved proposals to target tenant overlays
- Track learning velocity and cost impact metrics

Architecture:
- Batch processing (daily/off-peak) to avoid runtime impact
- Strict field-level privacy controls (allowed-fields-only schema)
- High-reasoning audit model tier for validation
- Version-controlled output (tenant overlay revisions)
- Human-in-the-loop approval gate before production deployment

The control plane remains free of real-time execution concerns while adding systematic learning capabilities.

---

### 3.2 Data & Orchestration Plane

The data plane executes live voice sessions using **stateless compute workers** with **centralized session state management** in Redis and PostgreSQL. The **Cognitive Orchestration Layer** is responsible for intelligent routing, dynamic context management, and **learning telemetry emission**.

#### 3.2.1 Stateless Compute Architecture

**Execution Model:**
- Runtime workers are stateless, ephemeral, and horizontally scalable
- Session state persisted in Redis (hot, TTL-based) and PostgreSQL (durable)
- Workers fetch session state at request start, update atomically, persist changes
- Worker failures do not cause data loss (state survives in persistence layer)
- Elastic scaling based on concurrent session load

**State Ownership:**
- **Ephemeral (in-memory only):** Streaming audio buffers, ASR partials, TTS chunks
- **Hot (Redis, TTL):** Active conversation context, tool result caches, temporary session data
- **Durable (PostgreSQL):** Session records, events, tool invocations, learning telemetry, audit trails

---

#### 3.2.2 Core Components

**Voice Gateway:**
- SIP/WebRTC termination with stable session IDs
- Duplex audio stream management
- Connection persistence across domain transitions
- **WebSocket lifecycle management with cleanup guarantees**

**Cognitive Orchestrator:**
The orchestration layer manages session lifecycle, domain routing, execution mode, and deterministic matching.

Components:
- **Domain Router (DR):** High-performance, low-latency classifier that performs zero-turn classification on initial audio (1-3 seconds) to map transcript to `tenant_id` and `domain_type` (Horeca, Emergency, Service, etc.)
- **Cognitive Controller:** Process manager that loads domain-specific blueprints, manages tool registry, orchestrates hot-swap operations, and **executes the deterministic parser fast path**
- **Deterministic Parser:** Executes blueprint-defined rules (regex patterns, alias maps, slot extractors) before LLM invocation to achieve zero-latency, zero-cost matching when possible
- **Session State Manager:** Maintains session context across domain transitions through centralized persistence
- **Tool Registry Controller:** Manages schema-first tool availability per domain and tenant
- **Logic Mode Supervisor:** Controls switching between STOCHASTIC (agent-driven) and DETERMINISTIC (safety-locked) execution
- **Telemetry Emitter:** Fires asynchronous learning events when deterministic matching fails and stochastic fallback occurs

---

#### 3.2.3 Deterministic Parser Contract

The Deterministic Parser is the first-pass execution engine that attempts to map user utterances to actions using blueprint-defined rules before invoking expensive LLM inference.

**Parser Input:**
- User utterance (transcript segment)
- Active blueprint rules (aliases, regex patterns, slot extractors)
- Session context (prior entities, conversation state)

**Parser Output (Typed Contract):**

```typescript
interface ParserResult {
  status: ParserStatus;
  reason_code: ReasonCode;
  matched_entity?: MatchedEntity;
  confidence?: number;
  execution_time_ms: number;
}

enum ParserStatus {
  MATCH = "MATCH",           // Complete successful match
  PARTIAL = "PARTIAL",       // Partial match, needs completion
  NO_MATCH = "NO_MATCH",     // No matching rule found
  AMBIGUOUS = "AMBIGUOUS"    // Multiple equally valid matches
}

enum ReasonCode {
  // Success reasons
  EXACT_ALIAS_MATCH = "EXACT_ALIAS_MATCH",
  REGEX_PATTERN_MATCH = "REGEX_PATTERN_MATCH",
  SLOT_EXTRACTION_SUCCESS = "SLOT_EXTRACTION_SUCCESS",
  
  // Failure reasons
  NO_ALIAS = "NO_ALIAS",
  NO_PATTERN = "NO_PATTERN",
  SLOT_MISSING = "SLOT_MISSING",
  LOW_CONFIDENCE = "LOW_CONFIDENCE",
  CONTEXT_INSUFFICIENT = "CONTEXT_INSUFFICIENT",
  
  // Ambiguity reasons
  MULTIPLE_MATCHES = "MULTIPLE_MATCHES",
  CONFLICTING_SLOTS = "CONFLICTING_SLOTS"
}

interface MatchedEntity {
  entity_type: string;       // "menu_item", "service_type", etc.
  entity_id: string;         // Database identifier
  matched_fields: Record<string, any>;
  rule_id: string;           // Which blueprint rule matched
}
```

**Execution Flow (Deterministic-First):**

```
1. ASR produces transcript segment
2. Cognitive Controller invokes Deterministic Parser
   ├─ Parser checks blueprint rules (aliases, patterns, slots)
   ├─ MATCH → Return ParserResult with entity
   │   └─ Execute action (0ms LLM latency, $0 cost)
   ├─ PARTIAL → Return ParserResult with partial data
   │   └─ May trigger clarification or LLM completion
   ├─ AMBIGUOUS → Return ParserResult with candidates
   │   └─ Trigger disambiguation (deterministic or agent-assisted)
   └─ NO_MATCH → Return ParserResult with reason_code
       └─ Trigger Stochastic Fallback
3. On NO_MATCH: Stochastic Fallback invokes agent
   ├─ Agent interprets intent and maps to action
   ├─ Telemetry emitted: DeterministicMatchFailed event
   └─ Response delivered to caller
4. Session continues normally
5. Learning Pipeline processes telemetry asynchronously
```

**Performance Contract:**
- Parser execution ≤ 5ms (p95)
- Alias lookup ≤ 1ms (p95)
- Rule evaluation ≤ 3ms (p95)
- Parser availability ≥ 99.99%

**Telemetry Obligations:**
Parser MUST emit structured telemetry on every invocation:
- `status` and `reason_code` for observability
- Execution time for performance monitoring
- On NO_MATCH: trigger learning event emission with redacted utterance

---

#### 3.2.4 Streaming Pipeline

**Streaming Components:**
- ASR partials with domain-aware language models
- Agent token streaming with dynamic prompt injection
- TTS chunk streaming with voice profile continuity

**AI Session Manager:**
- Dynamic context injection based on active domain
- Tool invocation with pre-execution validation
- Turn-taking and barge-in handling
- Agentic repair loops and self-correction
- Confirmation protocols per domain policy

**Context Engine:**
- Hot cache (menu, service catalog, emergency protocols)
- TTL-based tool result caching
- Cross-domain context preservation during transitions
- Cache invalidation via domain-specific events

**Safety & Compliance Layer:**
- **P0 Guardrail System:** Parallel semantic safety filter scanning STT output for life-safety keywords (Gas, Fire, Leak, Medical, etc.) - **EXCLUDED FROM AUTOMATED LEARNING** (human-verified only)
- **Deterministic Override:** Immediate agent suspension and switch to pre-verified safety scripts
- PII redaction with domain-specific policies **applied before learning telemetry**
- Content policies and abuse detection
- Escalation triggers with priority classification
- Rate limiting per tenant and domain

---

#### 3.2.5 Streaming Lifecycle & Task Governance

**WebSocket Lifecycle Management:**

The platform must guarantee cleanup of all pending asynchronous operations when a WebSocket connection closes.

**Cleanup Contract:**

```python
# Pseudocode for connection closure handling
async def on_websocket_close(session_id: str):
    """
    Triggered on WebSocket disconnect, timeout, or error.
    MUST execute cleanup immediately to prevent resource leaks.
    """
    # 1. Cancel all pending tasks
    await cancel_all_session_tasks(session_id)
    
    # 2. Persist final session state
    await persist_session_state(session_id)
    
    # 3. Release streaming resources
    await cleanup_audio_streams(session_id)
    
    # 4. Emit session termination event
    await emit_event(SessionTerminated(session_id, reason="connection_closed"))

async def cancel_all_session_tasks(session_id: str):
    """
    Cancel all pending LLM, TTS, and tool invocation tasks.
    """
    tasks = get_active_tasks(session_id)
    for task in tasks:
        if task.status in [PENDING, RUNNING]:
            task.cancel()  # Send cancellation signal
            await task.wait_cancelled(timeout=2.0)  # Wait for graceful shutdown
            if not task.is_cancelled():
                task.force_kill()  # Hard kill if not responsive
```

**Task Categories:**
- **LLM Streaming:** Cancel token generation, release model resources
- **TTS Generation:** Cancel audio synthesis, clear output buffers
- **Tool Invocations:** Cancel HTTP requests where possible, mark as CANCELLED in audit log
- **ASR Processing:** Stop transcription, flush partial buffers

**Guarantees:**
- No orphaned processing after connection close
- All tasks cancelled within 2 seconds (p99)
- State persisted before resource cleanup
- Audit trail includes cancellation reason

**Failure Scenarios:**
- Caller hangs up mid-sentence → Cancel all pending tasks, persist state
- Network timeout → Same cleanup, mark reason as timeout
- Server restart → Workers terminate gracefully, state survives in Redis/PostgreSQL

This prevents resource leaks, reduces unnecessary compute costs, and ensures clean session lifecycle management.

---

### 3.3 Integration Plane

The integration plane translates conversational outcomes into durable business actions across multiple domains.

**Enhanced Responsibilities:**
- Domain-specific event dispatch via isolated queues
- Cross-domain action coordination where required
- Reliability patterns (retries, circuit breakers, idempotency)
- Action reconciliation and replay with domain context
- Multi-domain webhook management
- Operator remediation interfaces with domain-specific tooling
- **Learning event streaming to Discovery Engine**

**Domain-Specific Integration Categories:**
- **Hospitality:** POS systems, kitchen printers, reservation platforms
- **Emergency/Service:** Dispatch systems, priority queuing, technician routing
- **Public Sector:** Case management, appointment scheduling, information delivery

All integrations remain asynchronous and isolated from real-time execution to prevent external system failures from impacting voice sessions.

---

### 3.4 Edge Plane

The edge plane provides reliable interaction with on-site hardware and local execution capabilities.

**Responsibilities:**
- On-site edge agent for hardware tasks (printers, displays, IoT devices)
- Local spooling and deduplication
- Offline persistence and automatic reconciliation
- Health reporting and heartbeat monitoring
- Secure outbound connectivity (mTLS)
- Device-level circuit breakers and backpressure

Edge agents now support domain-specific device types and can be configured per domain category.

---

## 4. Universal Dispatcher Pattern

### 4.1 The "Voxeron Main" Meta-Tenant

Every Voxeron deployment includes a **meta-tenant** called `voxeron_main` that serves as the universal entry point for multi-domain routing.

**Meta-Tenant Characteristics:**
- Exactly one per deployment (platform-level singleton)
- Owns the discovery and classification phase
- Minimal blueprint focused on language detection and intent classification
- No business logic execution
- Enterprise clients may deploy private dispatchers (e.g., `enterprise_group_main`) scoped to their sub-tenant hierarchy

**Call Flow:**
1. All inbound calls initially route to `voxeron_main`
2. Domain Router performs zero-turn classification
3. Session hot-swaps to target tenant and domain
4. Execution proceeds under target tenant's blueprint

---

### 4.2 Mid-Session Hot-Swapping (Two-Stage Optimization)

Hot-swapping enables domain transitions without connection interruption or caller friction. Version 0.7.1 implements a **two-stage swap** to meet aggressive latency targets.

**Two-Stage Hot-Swap Architecture:**

**Stage A - Synchronous (Critical Path):**
- Update session routing pointer (tenant_id, domain_id)
- Load minimal greeting context
- Trigger initial greeting audio playback
- **Target Latency: ≤ 100ms** (imperceptible to caller)

**Stage B - Lazy Load (Background):**
- Fetch full menu/service catalog metadata
- Load complete tool registry
- Populate context cache
- Pre-warm integrations
- **Executes during greeting playback (3-5 seconds available)**

**Implementation Pattern:**

```python
async def execute_hot_swap(session_id: str, target_tenant: str, target_domain: str):
    # STAGE A - Synchronous Critical Path (~100ms)
    async with session_lock(session_id):
        # 1. Update routing (database write)
        await update_session_routing(session_id, target_tenant, target_domain)
        
        # 2. Load minimal greeting blueprint
        greeting_context = await load_greeting_context(target_tenant, target_domain)
        
        # 3. Update session state pointer
        session_state.active_domain = target_domain
        session_state.greeting_ready = True
        
        # 4. Trigger greeting TTS (starts immediately)
        await initiate_greeting_tts(greeting_context)
    
    # STAGE B - Lazy Background Load (during greeting playback)
    asyncio.create_task(lazy_load_domain_context(
        session_id, target_tenant, target_domain
    ))

async def lazy_load_domain_context(session_id: str, tenant: str, domain: str):
    """
    Runs in background during greeting playback.
    Has 3-5 seconds before user response expected.
    """
    # Load heavy resources in parallel
    await asyncio.gather(
        load_full_menu(tenant, domain),
        load_tool_registry(tenant, domain),
        populate_context_cache(tenant, domain),
        pre_warm_integrations(tenant, domain)
    )
    
    session_state.full_context_ready = True
```

**Performance Target:**
- Stage A (synchronous): ≤ 100ms (p95)
- Stage B (lazy): Complete before greeting finishes (≤ 4 seconds, p99)
- Total user-perceived latency: 0ms (greeting plays immediately)
- Fallback: If Stage B incomplete when user responds, use cached minimal context and continue loading

**Benefits:**
- Meets aggressive ≤ 200ms total swap SLO with margin
- Zero perceptible delay for caller
- Amortizes heavy loading across greeting playback time
- Graceful degradation if background load delayed

---

### 4.3 Multilingual Governance & Language Hysteresis

**Challenge:** Short utterances like "Ja", "Ok", "Si" are ambiguous and can trigger incorrect language switching mid-conversation.

**Solution: Two-Turn Confirmation Rule**

The system implements **language hysteresis** to prevent spurious language changes.

**Policy:**

```
Language switch requires TWO consecutive turns in the new language,
AND both utterances must exceed minimum confidence and length thresholds.
```

**Implementation:**

```python
class LanguageHysteresisPolicy:
    MIN_UTTERANCE_LENGTH = 6  # characters
    MIN_CONFIDENCE = 0.75
    REQUIRED_CONSECUTIVE_TURNS = 2
    
    def should_switch_language(
        self,
        current_language: str,
        detected_language: str,
        utterance: str,
        confidence: float,
        consecutive_count: int
    ) -> bool:
        # Ignore very short utterances
        if len(utterance.strip()) < self.MIN_UTTERANCE_LENGTH:
            return False
        
        # Ignore low confidence detections
        if confidence < self.MIN_CONFIDENCE:
            return False
        
        # Ignore if same as current language
        if detected_language == current_language:
            return False
        
        # Require two consecutive turns
        if consecutive_count < self.REQUIRED_CONSECUTIVE_TURNS:
            return False
        
        # All conditions met, switch allowed
        return True
```

**Examples:**

```
Turn 1: "I want pizza" (en, conf=0.98) → Session language: EN
Turn 2: "Ja" (nl, conf=0.62) → IGNORED (too short)
Turn 3: "With extra cheese" (en, conf=0.96) → Session language: EN (confirmed)

Turn 1: "Ik wil graag pizza" (nl, conf=0.95) → Session language: NL
Turn 2: "Ok" (en, conf=0.58) → IGNORED (too short, low conf)
Turn 3: "Met extra kaas" (nl, conf=0.94) → Session language: NL (confirmed)

Turn 1: "Hello, I need help" (en, conf=0.97) → Session language: EN
Turn 2: "Puedo hablar en español?" (es, conf=0.91) → Candidate switch (count=1)
Turn 3: "Sí, por favor ayúdame" (es, conf=0.94) → SWITCH to ES (count=2, threshold met)
```

**Rationale:**
- Prevents false positives from common short affirmatives
- Reduces caller frustration from accidental language switching
- Maintains flexibility for genuine multilingual callers
- Observable and tunable per deployment

**Telemetry:**
- All language detection events logged
- Ignored detections tracked for threshold tuning
- Switch events auditable with utterance evidence

---

### 4.4 Domain Classification Logic

The Domain Router uses a layered classification approach:

**Layer 1 - Explicit Routing:**
- Phone number mapping (dedicated lines per domain)
- Caller ID recognition (known customer to specific tenant)

**Layer 2 - Semantic Classification:**
- Zero-turn keyword detection (food terms → Horeca, emergency terms → Service)
- Language-specific intent patterns
- Confidence scoring with fallback to clarification

**Layer 3 - Interactive Disambiguation:**
- If confidence < threshold, orchestrator asks clarifying question
- User selection triggers immediate hot-swap
- Fallback options configurable per deployment

All routing decisions are logged as session metadata for auditability and optimization.

---

## 5. Agentic Capabilities & Tooling

### 5.1 Schema-First Tool Architecture (MCP-Inspired)

Voxeron v0.7.1 adopts a **schema-first** approach to tool access, inspired by the Model Context Protocol's design philosophy for secure, structured tool invocation while optimizing for low-latency voice streaming.

**Design Principles:**
- Tools are exposed as typed interfaces with JSON Schema validation
- Tool definitions include input/output schemas with strict validation
- Pre-execution policy enforcement for authorization and compliance
- Structured error responses enable self-correcting agent behavior
- Tool execution is observable and auditable

**MCP-Inspired vs. MCP-Compliant:**

Voxeron follows the **philosophy** of MCP (typed contracts, capability-based access, structured context) but does not implement the full MCP transport protocol. This avoids protocol overhead that would increase latency in real-time voice scenarios.

Key alignments:
- Typed tool schemas (JSON Schema)
- Capability-based authorization
- Structured error envelopes
- Context injection patterns

Key deviations:
- Optimized for low-latency synchronous invocation (not JSON-RPC over async channels)
- Voice-specific timeout and retry policies
- Streaming-aware tool lifecycle

This approach signals architectural alignment with emerging standards while maintaining performance requirements for voice.

---

### 5.2 Shared Skills Registry

Cross-domain skills available to all agents:

| Skill Name | Logic Type | Description | Use Cases |
|------------|------------|-------------|-----------|
| `identity_verify` | Deterministic | Confirms caller identity through phone number, address, or account lookup | Service dispatch, account access, order history |
| `choice_resolver` | Agentic | Handles variations and ambiguity through intelligent probing questions | Menu customization, service option selection |
| `slot_filler` | Hybrid | Maps conversational entities (quantity, time, service type) to structured schemas | All domains requiring structured data capture |
| `availability_checker` | Deterministic | Queries real-time availability (menu items, service slots, technician dispatch) | Scheduling, ordering, resource allocation |
| `p0_escalator` | Deterministic | Immediate transfer to human operator with context handoff | Emergency scenarios, escalation triggers |
| `confirmation_loop` | Agentic | Validates collected information with caller before commitment | Transaction confirmation, appointment booking |

---

### 5.3 Domain-Specific Tool Categories

**Hospitality Domain (Horeca):**
- `get_menu()` - Retrieve current menu with availability
- `get_kitchen_status()` - Check operational capacity
- `create_pos_order()` - Submit order to POS system
- `dispatch_printer_ticket()` - Send kitchen ticket to printer
- `send_confirmation_message()` - SMS/email order confirmation

**Emergency/Service Domain (ABT):**
- `classify_emergency_priority()` - Triage severity (P0, P1, P2)
- `check_technician_availability()` - Real-time dispatch capacity
- `create_service_ticket()` - Generate work order
- `dispatch_emergency_protocol()` - Execute safety instructions
- `escalate_to_emergency_services()` - Transfer to 911/112 equivalent

**Public Sector Domain:**
- `lookup_citizen_record()` - Retrieve case history
- `schedule_appointment()` - Book service slots
- `provide_information()` - Deliver policy/procedural information
- `initiate_application()` - Begin formal request process

---

### 5.4 Pre-Execution Guardrails

Before any tool invocation, the **Policy Enforcement Point (PEP)** validates:

1. **Authorization:** Does current blueprint permit this tool?
2. **Tenant Scope:** Is the tool configured for this tenant?
3. **Input Validation:** Does the input conform to the tool's schema?
4. **Rate Limiting:** Has the tenant exceeded tool invocation quotas?
5. **Business Rules:** Are domain-specific constraints satisfied (e.g., operating hours)?

Failed validation returns structured error to agent for replanning rather than silent failure.

---

### 5.5 Self-Correcting Tool Execution

When a tool returns an error, the response includes:

```json
{
  "status": "error",
  "error_code": "ITEM_UNAVAILABLE",
  "user_message": "The Chicken Tikka Masala is currently unavailable.",
  "agent_guidance": "SUGGEST_ALTERNATIVE",
  "retry_permitted": false,
  "suggested_alternatives": ["Butter Chicken", "Lamb Rogan Josh"]
}
```

The agent uses this structured feedback to:
- Inform the caller naturally ("Unfortunately that item isn't available tonight")
- Replan the interaction ("Would you like to try the Butter Chicken instead?")
- Avoid repeated failed attempts
- Maintain conversational flow

---

## 6. P0 Safety Guardrail System

### 6.1 Life-Safety Override Architecture

For high-stakes domains (emergency services, technical safety), the platform implements deterministic safety overrides.

**Parallel Safety Filter:**
- Runs alongside primary agent processing
- Scans STT transcript stream for safety keywords in real-time
- Operates on semantic patterns, not exact string matching
- Latency budget ≤ 50ms to minimize delay

**P0 Trigger Keywords (Domain-Specific):**

*Emergency/Service (ABT):*
- Gas-related: leak, smell, odor, gas, propane, natural gas
- Water-related: flooding, burst, gushing, waterfall, spray
- Fire-related: fire, smoke, flames, burning, sparks
- Electrical: shock, sparking, exposed wires, smell burning
- Structural: collapse, falling, crack, unstable

*Healthcare (Future):*
- Medical: chest pain, difficulty breathing, unconscious, bleeding heavily
- Mental health: harm, suicide, overdose

**CRITICAL: P0 Safety Rules are EXCLUDED from Automated Learning**

Safety guardrails must remain human-verified and expert-reviewed. The Discovery Engine explicitly excludes P0 trigger keywords and safety scripts from automated modification. All safety logic changes require:
- Domain expert review (licensed professionals where applicable)
- Multi-stakeholder approval
- Staged testing in controlled environments
- Formal documentation and audit trail

---

### 6.2 P0 Override Execution

When a safety keyword is detected:

**Immediate Actions:**
1. **Agent Suspension:** Cognitive Controller switches `logic_mode` from `STOCHASTIC` to `DETERMINISTIC`
2. **Script Injection:** Pre-verified, domain-expert-reviewed safety script replaces agent output
3. **Read-Only Mode:** Agent continues receiving transcript for context but cannot generate responses
4. **Priority Escalation:** Session marked with P0 flag, elevated monitoring activated
5. **Audit Trail:** Full transcript and decision log preserved for compliance review

**Safety Script Characteristics:**
- Written and reviewed by domain experts (licensed professionals where required)
- Tested for clarity and comprehension
- Localized for language and cultural context
- Include mandatory information delivery (e.g., "If you smell gas, evacuate immediately and call from a safe location")
- Clear escalation path to human operator or emergency services

**Clearance Conditions:**
- Caller explicitly confirms safety situation resolved
- Human operator takes over session
- Predetermined timeout (configurable per domain)
- Session terminates

Once cleared, `logic_mode` may return to `STOCHASTIC` if session continues.

---

### 6.3 Safety vs. Flexibility Balance

The P0 system is designed to be conservative:
- False positives (unnecessarily triggering safety mode) are acceptable
- False negatives (missing a real emergency) are unacceptable
- Thresholds are configurable per tenant and domain
- Override behavior is auditable and improvable through review cycles

---

## 7. Blueprint Engine Evolution

### 7.1 Blueprint Type Hierarchy

Version 0.7.1 introduces a three-tier blueprint system with **learnable overlays**:

**Tier 1 - Dispatcher Blueprint:**
- Owned by `voxeron_main` meta-tenant
- Minimal conversational capability
- Focused on language detection and domain classification
- No business logic or tool execution
- Single purpose: route to appropriate domain

**Tier 2 - Sector Blueprint:**
- Generic conversational logic for a domain (Horeca, Emergency, Public Sector)
- Defines intents, slot structures, and validation rules common across all tenants in sector
- References sector-appropriate tool registry
- Establishes baseline safety and escalation policies
- **Contains static deterministic rules that apply universally**

**Tier 3 - Tenant Overlay (LEARNABLE):**
- Tenant-specific content and constraints
- Custom menu/service catalog
- Brand voice and personality
- Operating hours, policies, and business rules
- Tool configuration and integration endpoints
- **Alias maps and vocabulary patterns (updated by Discovery Engine)**
- **Version-controlled with revision history**

**Runtime Policy (Session-Level):**
- Per-session behavioral parameters
- Barge-in sensitivity, VAD thresholds
- Turn limits and timeout values
- Temporary overrides (e.g., holiday hours, emergency mode)

---

### 7.2 Blueprint Composition

Active blueprint is computed at session start and hot-swap:

```
Active Blueprint = Sector Blueprint 
                   + Tenant Overlay (versioned)
                   + Runtime Policy 
                   + Safety Guardrails (non-learnable)
```

Composition is deterministic, versioned, and cached for performance.

---

### 7.3 Enhanced Blueprint Responsibilities

Beyond v0.6.1 responsibilities, blueprints now define:

- **Domain Classification Hints:** Keywords and patterns that suggest this domain
- **Hot-Swap Eligibility:** Can this session transition to other domains mid-call?
- **Tool Access Control:** Which tools are permitted and under what conditions
- **Logic Mode Preferences:** Default to stochastic, deterministic, or hybrid
- **P0 Trigger Configuration:** Domain-specific safety keywords and override scripts (human-verified only)
- **Cross-Domain Handoff:** How to transfer context when escalating to different domain
- **Deterministic Parsing Rules:** Alias maps, regex patterns, slot extractors for fast-path matching
- **Learning Eligibility:** Which blueprint sections can be modified by Discovery Engine

---

## 8. Session Lifecycle & State Management

### 8.1 Enhanced Session State Schema

The session object tracks conversation state, orchestration metadata, and **learning telemetry**. State is persisted in Redis (hot) and PostgreSQL (durable).

**Core Session Fields:**
- `session_id` - Globally unique session identifier
- `tenant_id` - Current executing tenant
- `call_id` - Telephony connection identifier
- `start_timestamp` - Session initiation time
- `status` - Current session status (ACTIVE, ESCALATED, COMPLETED, etc.)

**Orchestration Fields:**
- `active_domain_id` - Current sector/domain context (e.g., `horeca_tajmahal`)
- `parent_orchestrator_id` - Reference to routing event from voxeron_main
- `domain_route_history` - Ordered list of domain transitions during session
- `logic_mode` - Current execution mode: `STOCHASTIC` | `DETERMINISTIC` | `HYBRID`
- `tool_execution_history` - Log of tool invocations with timestamps, inputs, outputs, and status
- `p0_trigger_log` - Record of any safety overrides activated
- `hot_swap_count` - Number of domain transitions in this session

**Learning Telemetry Fields:**
- `deterministic_match_attempted` - Boolean, did parser attempt rule matching
- `deterministic_match_succeeded` - Boolean, did parser find a match
- `stochastic_fallback_count` - Number of times agent was invoked due to parser miss
- `learning_eligible` - Boolean, can this session contribute to Discovery Engine

---

### 8.2 Session Lifecycle Stages

**Stage 1 - Initialization:**
- Connection established to `voxeron_main`
- `logic_mode` = `STOCHASTIC` (dispatcher agent)
- `active_domain_id` = `voxeron_main`
- Tool registry = minimal (language detection only)
- State persisted to Redis

**Stage 2 - Discovery & Classification:**
- Domain Router analyzes initial audio
- Classification decision recorded in `parent_orchestrator_id`
- Confidence scores logged for optimization
- State updated in Redis

**Stage 3 - Hot-Swap (Two-Stage):**
- **Stage A (Synchronous):**
  - `active_domain_id` updated to target domain
  - Minimal greeting context loaded
  - State persisted to Redis
  - Greeting TTS initiated
- **Stage B (Lazy Background):**
  - Blueprint, tools, and context loaded
  - Deterministic Parser rules loaded from tenant overlay
  - `domain_route_history` appended
  - `hot_swap_count` incremented
  - Full state updated in Redis
- WebSocket remains unchanged

**Stage 4 - Domain Execution (Deterministic-First):**
- For each user utterance:
  - Parser attempts rule matching
  - On success: execute action, log match
  - On failure: invoke agent, emit telemetry event
- `stochastic_fallback_count` incremented on each agent invocation
- Tools invoked as needed, logged in `tool_execution_history`
- `logic_mode` may change based on P0 triggers or domain policy
- State continuously persisted to Redis (hot) with periodic PostgreSQL writes (durable)

**Stage 5 - Completion/Escalation:**
- Session terminates or transfers to human
- All state persisted to PostgreSQL for audit and analytics
- **Learning events emitted to Discovery Engine queue (if learning_eligible)**
- Events emitted for downstream processing
- Redis state expires after TTL

---

### 8.3 State Persistence Strategy

**Transient (In-Memory Only):**
- Active streaming buffers (audio, ASR partials, TTS chunks)
- Temporary computation state
- Lifespan: Current processing cycle only

**Hot State (Redis, TTL-based):**
- Active conversation context
- Tool result caches
- Session state for active calls
- TTL: 1 hour default, configurable
- Lifespan: Duration of call + buffer

**Durable State (PostgreSQL):**
- `sessions` table with all orchestration and learning fields
- `session_events` table with routing decisions
- `tool_invocations` table with full execution history
- `p0_activations` table with safety override audit trail
- `learning_events` table with privacy-controlled telemetry
- Lifespan: Per retention policy (configurable per tenant/domain)

All state transitions are observable and auditable.

---

## 9. Multi-Domain Reference Implementations

### 9.1 Hospitality Domain (Horeca) - Taj Mahal Restaurant

**Enhanced with deterministic-first execution:**

Call flow now includes:
- Domain classification entry point
- **Deterministic parser attempts alias matching** (e.g., "garlic naan" → `item_id: 42`)
- Tool-based menu retrieval on cache miss
- Self-correcting availability handling
- **Stochastic fallback for unknown variations** (e.g., "that cheesy bread thing")
- Cross-domain escalation (e.g., to customer service domain if complaint)

**Example Deterministic Match:**
```
User: "I'd like two garlic naans"
Parser: Checks tenant overlay alias map
  - "garlic naan" → item_id: 42, category: bread
  - "two" → quantity: 2
Result: ParserResult(
  status=MATCH,
  reason_code=EXACT_ALIAS_MATCH,
  matched_entity={entity_type: "menu_item", entity_id: "42", quantity: 2},
  execution_time_ms=1.2
)
Action: Add to order (0ms agent latency, $0 LLM cost)
Telemetry: deterministic_match_succeeded = true
```

**Example Stochastic Fallback:**
```
User: "Can I get some of that bubbly bread with cheese?"
Parser: No alias match found
Result: ParserResult(
  status=NO_MATCH,
  reason_code=NO_ALIAS,
  execution_time_ms=2.1
)
Fallback: Invoke agent with context
Agent: Interprets as "cheese naan" → item_id: 43
Telemetry: 
  - deterministic_match_attempted = true
  - deterministic_match_succeeded = false
  - inference_confidence = 0.87
Event: DeterministicMatchFailed emitted to learning queue
Discovery Engine: Clusters with similar misses, proposes alias addition
```

Standard flow remains:
1. Session bootstrap and hot-swap to Horeca domain
2. Greeting and language confirmation (with hysteresis policy)
3. Intent detection (order, reservation, inquiry)
4. Slot filling with parser-first, then agentic choice resolution
5. Availability validation via tools
6. Confirmation loop
7. Asynchronous POS write-back
8. Kitchen printer dispatch via Edge Plane
9. Customer confirmation message
10. Metrics emission and learning events

---

### 9.2 Emergency/Service Domain (ABT) - Technical Dispatch

**Reference Implementation:**

ABT Loodgieter (Plumbing Service) demonstrates emergency handling, P0 safety protocols, and service-specific learning.

**Call Flow:**

**Phase 1 - Safety Triage:**
- Immediate P0 keyword scanning begins
- If safety trigger detected → P0 Override activates (deterministic, non-learnable)
- System delivers deterministic safety instructions
- Option to escalate to emergency services

**Phase 2 - Non-Emergency Service Intake:**
- Caller describes issue (leak, clog, broken fixture)
- **Deterministic Parser attempts service type classification** (common phrases → service codes)
- On parser miss: Agent interprets and maps to service catalog
- `identity_verify` skill confirms address and customer account
- `classify_emergency_priority` tool determines urgency (P0/P1/P2)
- `check_technician_availability` queries dispatch system

**Example Learning Opportunity:**
```
User: "My toilet is overflowing and water is everywhere"
Parser: Checks service type aliases
  - "toilet" → service_category: plumbing
  - "overflowing" → priority_hint: P1
  - No exact phrase match for "water is everywhere"
Result: ParserResult(
  status=PARTIAL,
  reason_code=SLOT_MISSING,
  matched_entity={service_category: "plumbing", priority_hint: "P1"},
  execution_time_ms=2.8
)
Action: Parser partially succeeds (category), agent fills urgency context
Telemetry: Partial match logged, phrase variation captured
Discovery Engine: May propose alias "water everywhere" → priority_modifier: urgent
```

**Phase 3 - Scheduling:**
- For P1: Immediate dispatch, ETA communicated
- For P2: Appointment slot selection
- Confirmation loop with address verification

**Phase 4 - Ticket Creation:**
- `create_service_ticket` tool generates work order
- Integration with technician dispatch system
- Customer receives confirmation SMS with ticket number and ETA

**Phase 5 - Follow-up:**
- Optional: Pre-arrival reminder
- Post-service satisfaction check

**Human Escalation Triggers:**
- P0 safety situation requiring expert guidance
- Customer distress or confusion
- Complex diagnostic scenarios beyond agent capability
- Integration system unavailability

---

### 9.3 Public Sector Domain (Future)

**Placeholder for municipal services, healthcare intake, citizen support:**

Potential applications:
- Appointment scheduling for government services
- Information delivery (operating hours, requirements, procedures)
- Application intake for permits, licenses, benefits
- Triage for social services

Blueprint will emphasize:
- Privacy and data minimization
- Multi-language support
- Accessibility compliance
- Clear escalation paths to human caseworkers
- **Vocabulary learning for department-specific terminology**

---

## 10. Data Model (Streamlined for v0.7.1)

### 10.1 Tenancy & Configuration

**Tables:**

`tenants`:
- `tenant_id` - UUID
- `tenant_name` - String
- `default_domain_id` - FK to tenant_domains
- `supported_domains` - Array of domain types
- `dispatcher_eligible` - Boolean
- `learning_enabled` - Boolean
- `learning_consent_date` - Timestamp
- `tier` - ENUM (STARTER, PROFESSIONAL, ENTERPRISE)

`tenant_domains`:
- `domain_id` - UUID
- `tenant_id` - FK to tenants
- `domain_type` - ENUM (HORECA, EMERGENCY_SERVICE, PUBLIC_SECTOR, GENERAL)
- `blueprint_id` - FK to blueprints
- `tool_configuration` - JSONB
- `p0_triggers_enabled` - Boolean
- `safety_keyword_set_id` - FK to safety configuration

---

### 10.2 Blueprint Management

`blueprints`:
- `blueprint_id` - UUID
- `blueprint_type` - ENUM (DISPATCHER, SECTOR, OVERLAY)
- `parent_blueprint_id` - FK for overlays
- `version` - Semantic version string
- `supported_tools` - Array of tool names
- `default_logic_mode` - ENUM (STOCHASTIC, DETERMINISTIC, HYBRID)
- `learning_eligible_sections` - Array of section names
- `deterministic_rules` - JSONB (alias maps, patterns, extractors)
- `created_at` - Timestamp
- `created_by` - User or system identifier

`blueprint_versions`:
- `version_id` - UUID
- `blueprint_id` - FK to blueprints
- `version` - Semantic version
- `created_at` - Timestamp
- `created_by` - ENUM (MANUAL, DISCOVERY_ENGINE, MIGRATION)
- `changelog` - Text description
- `rules_snapshot` - JSONB snapshot
- `parent_version_id` - FK for history chain

---

### 10.3 Runtime & Orchestration

`sessions`:
- `session_id` - UUID
- `tenant_id` - FK
- `active_domain_id` - FK to tenant_domains
- `parent_orchestrator_id` - FK to routing_events
- `call_id` - Telephony identifier
- `start_timestamp` - Timestamp
- `end_timestamp` - Timestamp (nullable)
- `status` - ENUM (ACTIVE, ESCALATED, COMPLETED, CANCELLED, ERROR)
- `logic_mode` - ENUM (STOCHASTIC, DETERMINISTIC, HYBRID)
- `hot_swap_count` - Integer
- `p0_activated` - Boolean
- `deterministic_match_attempted` - Boolean
- `deterministic_match_succeeded` - Boolean
- `stochastic_fallback_count` - Integer
- `learning_eligible` - Boolean

`routing_events`:
- `event_id` - UUID
- `session_id` - FK to sessions
- `classification_timestamp` - Timestamp
- `source_domain` - String
- `target_domain` - String
- `classification_confidence` - Numeric (0.0-1.0)
- `classification_method` - ENUM (EXPLICIT, SEMANTIC, INTERACTIVE)
- `routing_latency_ms` - Integer

`tool_invocations`:
- `invocation_id` - UUID
- `session_id` - FK to sessions
- `tool_name` - String
- `invocation_timestamp` - Timestamp
- `input_payload` - JSONB
- `output_payload` - JSONB
- `status` - ENUM (SUCCESS, ERROR, TIMEOUT, CANCELLED)
- `error_code` - String (nullable)
- `latency_ms` - Integer

`p0_activations`:
- `activation_id` - UUID
- `session_id` - FK to sessions
- `activation_timestamp` - Timestamp
- `trigger_keywords` - Array of strings
- `safety_script_id` - FK to safety_scripts
- `clearance_timestamp` - Timestamp (nullable)
- `clearance_method` - ENUM (USER_CONFIRMED, HUMAN_HANDOFF, TIMEOUT, SESSION_END)

---

### 10.4 Learning Infrastructure (Streamlined for v0.7.1)

**Strict Privacy Controls:**

All learning tables implement **allowed-fields-only** schema to prevent inadvertent PII storage.

`learning_events`:
- `event_id` - UUID
- `session_id` - FK to sessions
- `tenant_id` - FK to tenants
- `domain_id` - FK to tenant_domains
- `timestamp` - Timestamp
- `event_type` - ENUM (DETERMINISTIC_MATCH_FAILED, STOCHASTIC_FALLBACK_INVOKED, PARTIAL_MATCH)
- **`utterance_redacted`** - VARCHAR(100) - **STRICT LENGTH LIMIT, PII-redacted phrase only**
- `intent_inferred` - String (nullable)
- `confidence_score` - Numeric (0.0-1.0, nullable)
- `matched_item_id` - String (nullable)
- **`redaction_version`** - String - **Tracks which PII redaction rules were applied**
- **`pii_redaction_applied`** - Boolean - **MUST be TRUE before storage**

**Field-Level Constraints:**
- `utterance_redacted`: MAX 100 characters, no free-text beyond redacted phrase
- Must pass PII redaction filter before INSERT
- `redaction_version` enables audit of privacy policy changes over time
- No JSON/BLOB fields for unstructured data

`learning_proposals` (Simplified from v0.7.0):
- `proposal_id` - UUID
- `tenant_id` - FK to tenants
- `blueprint_id` - FK to blueprints (target overlay)
- `proposed_at` - Timestamp
- `proposed_by` - ENUM (DISCOVERY_ENGINE, MANUAL)
- `proposal_type` - ENUM (ALIAS_ADD, REGEX_ADD, SLOT_EXTRACTOR_ADD)
- `proposal_content` - JSONB (the actual rule change)
- `supporting_sample_count` - Integer
- `confidence_avg` - Numeric (0.0-1.0)
- `status` - ENUM (DRAFT, PENDING_APPROVAL, APPROVED, REJECTED, DEPLOYED, ROLLED_BACK)
- `impact_estimate_weekly_sessions` - Integer (nullable)
- `impact_estimate_cost_savings_usd` - Numeric (nullable)

`proposal_status`:
- `status_id` - UUID
- `proposal_id` - FK to learning_proposals
- `status_timestamp` - Timestamp
- `status` - ENUM (matches learning_proposals.status)
- `reviewer_id` - User identifier (nullable)
- `review_notes` - Text (nullable)
- `deployed_version` - String (nullable, blueprint version created)

**Note:** Complex clustering tables, automated patch versioning, and multi-stage validation workflows are moved to **v0.8 roadmap**. Version 0.7.1 focuses on minimal viable learning pipeline with human-in-loop approval.

---

### 10.5 Domain Content

**Horeca Domain:**

`menu_items`:
- `item_id` - UUID
- `tenant_id` - FK
- `item_name` - String
- `category` - String
- `price` - Numeric
- `available` - Boolean
- `alias_variations` - Array of strings (includes learned aliases)

`kitchen_status`:
- `status_id` - UUID
- `tenant_id` - FK
- `updated_at` - Timestamp
- `capacity_percentage` - Integer (0-100)
- `estimated_wait_minutes` - Integer

**Emergency/Service Domain:**

`service_catalog`:
- `service_id` - UUID
- `tenant_id` - FK
- `service_type` - String
- `priority_classification` - ENUM (P0, P1, P2)
- `sla_target_minutes` - Integer
- `safety_protocol_id` - FK to safety_scripts (nullable)
- `common_phrases` - Array of strings (learned vocabulary)

`technician_availability`:
- `availability_id` - UUID
- `tenant_id` - FK
- `technician_id` - String
- `timestamp` - Timestamp
- `available` - Boolean
- `geographic_zone` - String
- `certifications` - Array of strings

**Safety Configuration:**

`p0_safety_keywords`:
- `keyword_id` - UUID
- `domain_type` - ENUM
- `keyword_pattern` - String
- `language_code` - String (ISO 639-1)
- `severity` - ENUM (P0, P1)
- `safety_script_id` - FK to safety_scripts
- **`learning_excluded`** - Boolean (ALWAYS TRUE)

`safety_scripts`:
- `script_id` - UUID
- `domain_type` - ENUM
- `language_code` - String
- `script_content` - Text
- `approved_by` - String (professional reviewer identifier)
- `approval_date` - Timestamp
- `modification_requires` - ENUM (DOMAIN_EXPERT, LEGAL, MEDICAL, MULTI_STAKEHOLDER)

---

## 11. Integration Layer Enhancements

### 11.1 Domain-Specific Integration Patterns

**Horeca Integrations:**
- POS systems (Square, Toast, Lightspeed)
- Kitchen display systems
- Reservation platforms (OpenTable, Resy)
- Loyalty and CRM systems

**Emergency/Service Integrations:**
- Dispatch management systems
- Technician routing platforms
- Emergency service APIs (112/911)
- SMS/notification services for alerts
- Fleet management systems

**Public Sector Integrations:**
- Case management systems
- Appointment scheduling platforms
- Citizen identity verification
- Government databases (with appropriate authorization)

**Learning Infrastructure Integrations:**
- Discovery Engine queue (learning events)
- Approval dashboard webhooks
- Version control systems (blueprint changes)
- Analytics platforms (learning velocity metrics)

---

### 11.2 Enhanced Event Contracts

**Learning Events (v0.7.1):**

`DeterministicMatchFailed`:
```json
{
  "event_type": "DeterministicMatchFailed",
  "session_id": "sess_abc123",
  "tenant_id": "taj_mahal",
  "domain_id": "horeca_tajmahal",
  "timestamp": "2026-01-03T19:42:17Z",
  "parser_result": {
    "status": "NO_MATCH",
    "reason_code": "NO_ALIAS",
    "execution_time_ms": 2.1
  },
  "utterance_redacted": "[USER] that cheesy flatbread",
  "agent_inference": {
    "mapped_to": "item_id:43",
    "item_name": "Cheese Naan",
    "confidence": 0.87
  },
  "redaction_version": "v1.2",
  "pii_redaction_applied": true
}
```

`StochasticFallbackInvoked`:
```json
{
  "event_type": "StochasticFallbackInvoked",
  "session_id": "sess_xyz789",
  "tenant_id": "abt_plumbing",
  "domain_id": "service_abt",
  "timestamp": "2026-01-03T14:22:08Z",
  "utterance_redacted": "[USER] water coming through ceiling",
  "intent_detected": "service_request",
  "service_mapped": "emergency_leak",
  "priority_inferred": "P1",
  "confidence": 0.94
}
```

`LearningProposalCreated`:
```json
{
  "event_type": "LearningProposalCreated",
  "proposal_id": "prop_001",
  "tenant_id": "taj_mahal",
  "blueprint_id": "taj_overlay_v42",
  "proposed_at": "2026-01-04T02:15:00Z",
  "proposed_by": "DISCOVERY_ENGINE",
  "proposal_type": "ALIAS_ADD",
  "supporting_sample_count": 12,
  "confidence_avg": 0.89,
  "status": "PENDING_APPROVAL"
}
```

`LearningProposalApproved`:
```json
{
  "event_type": "LearningProposalApproved",
  "proposal_id": "prop_001",
  "approved_by": "user_operator_42",
  "approved_at": "2026-01-04T09:30:00Z",
  "deployed_version": "taj_overlay_v43",
  "deployment_timestamp": "2026-01-04T09:35:12Z"
}
```

---

## 12. Vendor Abstraction & Capability Tiers

### 12.1 Vendor-Neutral Capability Model

Voxeron abstracts vendor dependencies behind **capability tiers** rather than specific brand names. This enables flexible vendor selection, multi-vendor strategies, and future-proofing.

**Capability Tier Definitions:**

**Tier 1 - High-Speed, Cost-Optimized:**
- Use case: High-volume runtime interactions where cost and latency are primary concerns
- Characteristics: Fast inference (<300ms), low cost per token
- Example applications: Menu item recognition, simple slot filling, routine confirmations
- Routing preference: Horeca domain standard flows

**Tier 2 - Balanced Performance:**
- Use case: Standard conversational interactions requiring moderate reasoning
- Characteristics: Good latency (<500ms), reasonable accuracy, moderate cost
- Example applications: Service triage, appointment scheduling, general information delivery
- Routing preference: Public sector, non-emergency service

**Tier 3 - High-Reasoning Runtime:**
- Use case: Complex conversational scenarios requiring nuanced understanding
- Characteristics: Advanced reasoning, better context handling, higher cost acceptable
- Example applications: Complex service diagnostics, multi-step problem solving, repair strategies
- Routing preference: Emergency service (non-P0), complex Horeca customizations

**Tier 4 - Audit & Validation Models:**
- Use case: Offline batch processing for learning pipeline validation
- Characteristics: Highest reasoning capability, cost secondary to accuracy, no latency requirements
- Example applications: Discovery Engine cluster validation, pattern verification, quality assurance
- Routing preference: Learning infrastructure only

**Tier 5 - Specialized Domain Models:**
- Use case: Domain-specific fine-tuned or specialized capabilities
- Characteristics: Optimized for specific vocabulary/patterns, may sacrifice generality
- Example applications: Medical terminology, legal language, technical jargon
- Routing preference: Regulated sectors (healthcare, legal, finance)

---

### 12.2 Domain-Aware Routing

Routing decisions now consider domain requirements and map to capability tiers:

**Horeca Domain Preferences:**
- Primary: Tier 1 (latency-optimized for quick order taking)
- Fallback: Tier 2 (for complex customizations)
- ASR: Optimized for food/menu vocabulary
- TTS: Natural, friendly voice profiles

**Emergency Domain Preferences:**
- Primary: Tier 3 (accuracy-prioritized, critical information must be correct)
- P0 Override: Deterministic (no model dependency)
- ASR: High accuracy, background noise robust
- TTS: Clear, authoritative voice

**Public Sector Preferences:**
- Primary: Tier 2 (balanced performance for routine interactions)
- Escalation: Tier 3 (complex policy questions)
- ASR: Multi-language with accent handling
- TTS: Accessible (slower pace, clear enunciation)

**Learning Infrastructure:**
- Discovery Engine: Tier 4 (high-reasoning for validation)
- Clustering: Specialized embedding models
- No real-time latency requirements

---

### 12.3 Routing Metadata

Routing decisions record:
- Capability tier selected and reasoning
- Specific model/provider used (for audit, not hardcoded dependency)
- Fallback providers if primary unavailable
- Performance baselines for monitoring
- Cost attribution per tier

This abstraction enables:
- Vendor negotiation leverage (not locked to single provider)
- Multi-vendor strategies (different tiers from different providers)
- Seamless vendor migration (tier contract remains stable)
- Future-proofing (new vendors map to existing tiers)

---

## 13. Observability & Operations

### 13.1 Enhanced Metrics

**Orchestration Metrics:**
- Domain classification accuracy and confidence scores
- Hot-swap latency Stage A (synchronous, target ≤ 100ms)
- Hot-swap latency Stage B (lazy load, target ≤ 4s)
- Domain transition patterns (% calls requiring multiple domains)
- Dispatcher → Domain mapping effectiveness

**Safety Metrics:**
- P0 trigger frequency by domain and keyword
- False positive rate for safety overrides
- Average time in deterministic mode
- Escalation to emergency services rate
- Safety script execution success rate

**Agentic Performance:**
- Tool invocation success rate by tool type
- Self-correction loop frequency
- Tool latency by domain and integration
- Agent replanning effectiveness

**Learning Metrics:**
- **Deterministic Match Rate:** % of utterances handled without agent inference
- **Stochastic Fallback Rate:** % requiring agent interpretation
- **Learning Velocity:** Proposals created/approved/deployed per week
- **Cost Avoidance:** $ saved by deterministic matching vs. agent calls (based on tier pricing)
- **Latency Improvement:** Average ms saved per deterministic match
- **Proposal Quality:** % of deployed proposals still active after 30 days
- **Coverage Growth:** % increase in deterministic vocabulary over time

**Domain-Specific KPIs:**
- *Horeca:* Order completion rate, average order value, menu item recognition accuracy, learned alias usage frequency
- *Emergency/Service:* Average triage time, P0/P1/P2 distribution, technician dispatch efficiency, service phrase recognition rate
- *Public Sector:* Appointment booking success, information delivery effectiveness, department terminology coverage

---

### 13.2 Enhanced Tracing

Distributed traces now include:
- Domain routing decisions and confidence
- Blueprint composition chain
- Tool invocation sequences with ParserResult data
- Logic mode transitions (STOCHASTIC ↔ DETERMINISTIC)
- P0 activation and clearance
- **Deterministic parser attempts and ParserResult status/reason_code**
- **Stochastic fallback triggers and agent inference**
- **Learning event emission timestamps**
- **Task cancellation events on WebSocket closure**

All traces correlated by `session_id` and `correlation_id` across planes.

---

### 13.3 Operational Runbooks

**Enhanced Runbooks for v0.7.1:**

*Discovery Engine Failure:*
- Symptoms: No proposals created for >7 days despite stochastic fallbacks
- Response: Check queue health, verify batch job execution, inspect clustering service
- Escalation: Manual vocabulary review if learning pipeline blocked

*Proposal Deployment Regression:*
- Symptoms: Increased stochastic fallback rate after proposal deployment
- Response: Identify problematic proposal via metrics, rollback to prior blueprint version
- Escalation: Disable automated approval if systematic quality issue

*Learning Telemetry Loss:*
- Symptoms: Zero learning events emitted despite active sessions
- Response: Verify PII redaction service health, check event queue connectivity, validate field-level schema enforcement
- Escalation: Investigate data plane telemetry emission logic

*WebSocket Cleanup Failure:*
- Symptoms: Orphaned LLM/TTS tasks continuing after session end
- Response: Check task cancellation logic, verify cleanup timeouts, inspect worker resource usage
- Escalation: Force worker restart if resource leak confirmed

*Language Hysteresis False Rejection:*
- Symptoms: User complaints about system not recognizing language switch
- Response: Review hysteresis thresholds, check consecutive turn tracking logic
- Escalation: Adjust MIN_UTTERANCE_LENGTH or REQUIRED_CONSECUTIVE_TURNS for affected language pairs

---

## 14. Security & Compliance

### 14.1 Enhanced Tenant Isolation

Domain-scoped isolation enforced:
- Tool invocations validated against tenant-domain permissions
- Cross-domain data leakage prevention
- Separate queue isolation per domain type
- Domain-specific encryption keys where required
- **Learning data isolated per tenant** (proposals never mix tenant vocabularies)

---

### 14.2 Privacy-by-Design in Learning Pipeline

**Strict Field-Level Controls:**

All learning telemetry implements **allowed-fields-only** schema to prevent inadvertent PII storage.

**Redaction Pipeline:**
1. User utterance captured in session (ephemeral memory)
2. **Real-time PII detection** (names, phone numbers, addresses, payment info, medical data)
3. Redacted placeholder insertion (e.g., "[USER]" for names, "[PHONE]" for numbers)
4. **Length validation:** Redacted utterance truncated to MAX 100 characters
5. **Field validation:** Only permitted fields populated (no free-text JSON)
6. **Redaction version stamped** for audit trail
7. **`pii_redaction_applied` flag verified TRUE** before database INSERT
8. Original PII-containing utterance NEVER persists beyond data plane ephemeral memory

**Enforcement:**
- Database schema enforces VARCHAR(100) limit on `utterance_redacted`
- INSERT triggers verify `pii_redaction_applied = TRUE`
- No TEXT/BLOB fields allowed in learning tables
- Annual audit of redaction rules and effectiveness

**Tenant Learning Consent:**
- Explicit opt-in required (`learning_enabled` flag in tenants table)
- Consent timestamp tracked for compliance
- Right to opt-out at any time (stops future telemetry)
- Right to request deletion of historical learning data
- Transparency: tenants can view all learning events derived from their calls

**Cross-Tenant Isolation:**
- Proposals operate within single tenant scope only
- No cross-tenant pattern aggregation
- Blueprint changes scoped to originating tenant
- Enterprise clients with multi-location deployments can opt into cross-location learning within their tenant boundary

---

### 14.3 Safety & Compliance Certification

**Domain-Specific Requirements:**

*Emergency Services:*
- Safety script review by licensed professionals
- Regular audit of P0 trigger accuracy
- Compliance with emergency communication standards
- Liability insurance and legal review
- **P0 rules explicitly excluded from Discovery Engine scope**

*Healthcare (Future):*
- HIPAA compliance for US deployments
- Medical professional review of scripts
- Consent and privacy-by-default
- Regional medical device regulations
- **Learning limited to non-clinical vocabulary only**

*Public Sector:*
- Accessibility compliance (WCAG equivalent for voice)
- Data residency per jurisdiction
- GDPR/data protection regulations
- Audit trail retention requirements
- **Learning subject to FOIA and transparency requirements**

---

## 15. Data Flywheel & Asynchronous Learning

### 15.1 The Observation-Inference-Proposal Loop

Version 0.7.1 formalizes the transition from manual log review to an automated **Log-to-Logic (L2L) Pipeline**. The system treats every stochastic fallback as a learning opportunity, systematically converting operational experience into deterministic improvements.

**The Data Moat Thesis:**

Traditional voice AI platforms maintain constant operational costs and latency because every call requires model inference. Voxeron v0.7.1 introduces a **cost-deflationary feedback loop** where increased usage reduces per-call costs and latency through automated vocabulary expansion.

The more the platform is used, the more deterministic it becomes:
- Stochastic calls (expensive, slow, variable) → Deterministic calls (free, instant, reliable)
- Manual vocabulary curation → Automated alias discovery
- Static blueprints → Self-improving overlays
- Operational burden → Competitive advantage

This creates a sustainable data moat where incumbents with call volume have structurally lower costs than new entrants.

---

### 15.2 Learning Pipeline Architecture

**Components:**

1. **Telemetry Emission (Data Plane)**
   - Session controller emits learning events on every stochastic fallback
   - Fire-and-forget async to avoid runtime latency impact
   - Mandatory PII redaction and field validation before event creation
   - Events queued to learning infrastructure

2. **Discovery Engine (Control Plane)**
   - Batch processor (runs daily/off-peak to avoid resource contention)
   - Aggregates learning events per tenant/domain
   - Clusters similar utterances using vector embeddings
   - Validates patterns using Tier 4 high-reasoning audit models

3. **Governance Workflow (Control Plane)**
   - Proposed changes staged in approval dashboard
   - Human review with supporting evidence (sample utterances, confidence, impact)
   - Approval triggers versioned blueprint update
   - Deployment creates new tenant overlay revision

4. **Feedback Loop (Runtime)**
   - Updated blueprints loaded into data plane
   - Deterministic parser now matches previously unmapped phrases
   - Reduced stochastic fallback rate
   - New learning opportunities identified for remaining gaps

---

### 15.3 Telemetry Requirements

**Rich Traces for Learning:**

The Data Plane `SessionController` must emit structured telemetry enabling automated improvement:

**Required Fields (Strict Schema):**
- **`parser_result.status`:** Binary outcome (MATCH/NO_MATCH/PARTIAL/AMBIGUOUS)
- **`parser_result.reason_code`:** Specific failure reason for NO_MATCH cases
- **`utterance_redacted`:** PII-stripped user phrase (MAX 100 chars)
- **`agent_inference`:** Model's interpretation and confidence score (when fallback occurs)
- **`redaction_version`:** Which PII rules were applied
- **`pii_redaction_applied`:** Boolean verification flag (MUST be TRUE)

**Prohibited Fields:**
- Free-text notes or comments
- Unstructured JSON beyond defined schema
- Any field not explicitly in allowed-fields list
- Raw audio or unredacted transcripts

**Example Telemetry:**
```json
{
  "session_id": "sess_abc123",
  "tenant_id": "taj_mahal",
  "domain_id": "horeca_tajmahal",
  "timestamp": "2026-01-03T19:42:17Z",
  "parser_result": {
    "status": "NO_MATCH",
    "reason_code": "NO_ALIAS",
    "execution_time_ms": 2.1
  },
  "utterance_redacted": "[USER] that bubbly cheese bread",
  "agent_inference": {
    "intent": "add_to_order",
    "item_id": 43,
    "item_name": "Cheese Naan",
    "confidence": 0.87
  },
  "redaction_version": "v1.2",
  "pii_redaction_applied": true
}
```

**Performance Guarantee:**
Telemetry emission must NOT block session execution. All events are fire-and-forget with async queue delivery.

---

### 15.4 Discovery Engine Operations (Simplified for v0.7.1)

**Daily Batch Processing:**

The Discovery Engine aggregates similar unmapped utterances to identify systematic vocabulary gaps.

**Simplified Process:**
1. **Extraction:** Pull all `DeterministicMatchFailed` events for tenant/domain from past 7 days
2. **Grouping:** Manually or semi-automatically cluster similar phrases
3. **Validation:** Review by human operator or Tier 4 audit model
4. **Proposal Creation:** Generate structured proposal with supporting evidence
5. **Approval Workflow:** Present to operator for decision
6. **Deployment:** On approval, create new blueprint version with added aliases

**Note:** Advanced clustering algorithms, multi-stage validation, and automated confidence scoring are **v0.8 roadmap items**. Version 0.7.1 establishes the infrastructure and governance workflow with human-in-loop at multiple stages.

---

### 15.5 Governance & Approval Workflow

Learning is **asynchronous and supervised**. Human approval is required before changes reach production.

**Approval Dashboard:**

Operators see:
- Proposed change with diff view (before/after blueprint rules)
- Supporting evidence (sample utterances, occurrence count)
- Impact estimates (affected sessions, cost/latency savings)
- Options: Approve, Reject, Request Changes

**Approval Actions:**

*Approve:*
- Proposal status → APPROVED
- New blueprint version created (e.g., `taj_overlay_v42` → `taj_overlay_v43`)
- Deterministic rules updated with new aliases
- Changelog auto-generated
- Deployed to runtime within 5 minutes
- `LearningProposalApproved` event emitted

*Reject:*
- Proposal status → REJECTED
- Reviewer notes explain reasoning
- No blueprint change

*Request Changes:*
- Proposal returned for refinement
- Operator can suggest specific modifications
- Re-review cycle initiated

**Version Control:**

Every approved proposal creates a new semantic version:
- `taj_overlay_v42` → `taj_overlay_v43` (patch increment)
- Full changelog maintained
- Rollback capability preserved (can revert to any prior version)
- Attribution tracked (manual vs. discovery_engine)

---

### 15.6 Deployment & Feedback

**Blueprint Update Propagation:**

When proposal approved:
1. New blueprint version saved in PostgreSQL
2. Control Plane cache invalidated
3. Active sessions continue with current version (no mid-call disruption)
4. New sessions load updated blueprint within 60 seconds
5. Redis cache warmed with new rules

**Runtime Impact:**

Next time a caller says "bubbly cheese bread":
1. Deterministic Parser checks updated alias map
2. Match found: `"bubbly cheese bread" → item_id: 43`
3. Action executed immediately (0ms agent latency, $0 model cost)
4. No stochastic fallback required
5. `deterministic_match_succeeded = true`

**Continuous Improvement:**

The cycle repeats:
- Remaining gaps generate new learning events
- Discovery Engine identifies next proposals
- Vocabulary coverage expands over time
- Deterministic match rate increases
- Cost and latency decrease asymptotically

---

### 15.7 Learning Scope (v0.7.1)

**In Scope:**
- Menu item aliases and variations (Horeca)
- Service type phrases (Emergency/Service)
- Simple slot extraction patterns (quantity, time)
- Entity synonyms and colloquialisms

**Explicitly Out of Scope:**
- P0 safety keywords and scripts (MUST remain human-verified)
- Intent classification logic (too complex for v0.7.1 automation)
- Multi-turn repair strategies
- Cross-domain routing rules
- Pricing or business policy rules
- Complex clustering algorithms (manual grouping in v0.7.1)

**Future Learning (v0.8+):**
- Automated clustering with confidence scoring
- Intent pattern discovery
- Repair strategy optimization
- Contextual disambiguation rules
- Cross-session personalization

Narrow scope in v0.7.1 allows proving the data moat thesis with concrete, measurable improvements before expanding to more complex learning domains.

---

### 15.8 Illustrative Business Case

**Operational Efficiency & Margin Expansion:**

The L2L Pipeline is the primary driver of platform profitability and competitive defensibility.

**Economic Model Comparison:**

*Traditional Voice AI Economics:*
- Every call requires model inference
- Cost per call remains constant over time
- No economies of scale beyond volume discounts

*Voxeron v0.7.1 Economics:*
- Initial calls require model inference (stochastic)
- Learning identifies vocabulary gaps
- Subsequent similar calls use deterministic matching (free)
- Cost per call decreases with usage
- Marginal cost approaches zero for mature tenants

**Illustrative Cost Trajectory (Example: Taj Mahal Restaurant)**

**Assumptions:**
- Tier 1 model cost: $0.01 per 1,000 tokens
- Average stochastic call: 2,000 tokens ($0.02 cost)
- Deterministic call: 0 tokens ($0.00 cost)
- Starting deterministic match rate: 40%
- Learning velocity: +5% deterministic rate per month

```
Week 1:  Deterministic: 40%, Avg Cost/Call: $0.012
Week 4:  Deterministic: 65%, Avg Cost/Call: $0.007
Week 12: Deterministic: 82%, Avg Cost/Call: $0.0036
Week 24: Deterministic: 91%, Avg Cost/Call: $0.0018
Week 52: Deterministic: 95%, Avg Cost/Call: $0.001

Illustrative Savings vs. Static Model Platform: ~92% cost reduction after 1 year
```

**Disclaimer:** These figures are illustrative examples based on stated assumptions. Actual results will vary based on call volume, domain complexity, vocabulary diversity, and model pricing. This is not a guarantee of specific cost savings.

**Latency Improvements:**

Deterministic matching is effectively instantaneous compared to model inference:
- Model inference: 200-400ms (network + processing)
- Deterministic match: <1ms (local lookup)
- User-perceivable latency reduction: ~300ms per matched phrase
- Improved conversation flow and customer satisfaction

**Competitive Moat Mechanics:**

1. **Data Advantage:** High-volume tenants accumulate vocabulary faster, creating switching costs
2. **First-Mover Benefit:** Early adopters reach deterministic maturity sooner, enjoy cost advantage
3. **Network Effects:** Similar tenants in same sector benefit from shared sector blueprint improvements (future capability)
4. **Barrier to Entry:** New competitors start with 100% stochastic costs, cannot match mature Voxeron pricing

---

### 15.9 Privacy & Compliance in Learning

**Privacy-by-Design Principles:**

All learning infrastructure operates under strict privacy guarantees:

**Allowed-Fields-Only Schema:**
- Only explicitly defined fields permitted in learning tables
- VARCHAR length limits enforced at database level
- No free-text or unstructured data fields
- INSERT triggers validate schema compliance

**PII Redaction at Source:**
- Utterances sanitized BEFORE entering learning pipeline
- Names → [USER]
- Phone numbers → [PHONE]
- Addresses → [ADDRESS]
- Credit cards → [PAYMENT]
- Original PII never stored in `learning_events` table
- `redaction_version` tracked for audit

**Tenant Data Isolation:**
- Proposals never combine data across tenants
- Each tenant's vocabulary evolves independently
- Blueprint changes scoped to originating tenant only
- No cross-tenant pattern sharing without explicit consent

**Right to Opt-Out:**
- `learning_enabled` flag per tenant
- Can disable at any time
- Future telemetry stops immediately
- Historical data retained for audit but not used for new proposals

**Right to Deletion:**
- Tenants can request deletion of all learning_events
- Cascades to dependent proposals
- Blueprint versions created from deleted data remain (derivative work) but source removed
- GDPR/CCPA compliant retention policies

**Transparency:**
- Tenants can view all learning events derived from their calls
- Approval dashboard shows which utterances contributed to proposals
- Full audit trail of Discovery Engine decisions

**Consent Management:**
- Initial onboarding includes learning opt-in
- Consent timestamp tracked for compliance
- Re-consent required for material changes to learning scope
- Clear documentation of what is/isn't learned

---

### 15.10 Safety Exclusions

**P0 Safety Rules are PERMANENTLY EXCLUDED from Automated Learning:**

Life-safety logic must remain human-verified and expert-reviewed. The Discovery Engine explicitly excludes:
- P0 trigger keywords
- Safety override scripts
- Emergency escalation logic
- Medical/clinical terminology (in healthcare domains)
- Legal compliance rules

**Enforcement Mechanisms:**
- Safety sections marked `learning_excluded: true` in blueprint schema
- Discovery Engine filters out safety-related events before processing
- Approval dashboard prevents accidental approval of safety changes
- Separate governance workflow for safety changes (multi-stakeholder, expert review)

**Safety vs. Service Vocabulary:**

Example boundary:
- **Service Learning (ALLOWED):** "My toilet is overflowing" → service_type: plumbing, priority: P1
- **Safety Learning (FORBIDDEN):** "I smell gas" → P0_TRIGGER (deterministic, never modified by automation)

This separation ensures operational efficiency gains do not compromise life-safety guarantees.

---

## 16. Performance Targets & SLOs

### 16.1 Orchestration SLOs

**Domain Routing (p95):**
- Classification latency ≤ 150ms
- Hot-swap Stage A (synchronous) ≤ 100ms
- Hot-swap Stage B (lazy load) ≤ 4 seconds (p99)
- Total user-perceived routing overhead ≤ 0ms (greeting plays immediately)
- Classification accuracy ≥ 95%

**P0 Safety System (p99):**
- Trigger detection latency ≤ 50ms
- Script injection latency ≤ 100ms
- False negative rate ≤ 0.1% (life-safety critical)
- Acceptable false positive rate ≤ 5%

**Deterministic Parsing (p95):**
- Parser execution latency ≤ 5ms
- Alias lookup latency ≤ 1ms
- Rule evaluation latency ≤ 3ms
- Parser availability ≥ 99.99%

---

### 16.2 Domain-Specific SLOs

**Horeca:**
- Order completion rate ≥ 92%
- Average handle time ≤ 3 minutes
- Menu item recognition accuracy ≥ 97%
- POS write success ≥ 99.5%
- **Deterministic match rate ≥ 85% (mature tenants, 6+ months)**

**Emergency/Service:**
- P0 triage time ≤ 30 seconds
- Technician dispatch success ≥ 98%
- Emergency escalation latency ≤ 10 seconds
- Service ticket creation success ≥ 99.9%
- **Service type classification accuracy ≥ 93%**

**Platform-Wide:**
- Session worker availability ≥ 99.9%
- Integration dispatch availability ≥ 99.9%
- Edge agent online ratio ≥ 99.0%

---

### 16.3 Learning Pipeline SLOs

**Telemetry Performance:**
- Event emission async overhead ≤ 10ms on session thread
- PII redaction latency ≤ 5ms
- Queue delivery success rate ≥ 99.9%
- Telemetry data loss rate ≤ 0.1%
- Field-level schema validation ≤ 2ms

**Discovery Engine Performance:**
- Batch processing frequency: Daily (off-peak hours)
- Proposal creation latency: Within 24 hours of batch start
- Approval dashboard delivery: ≤ 1 hour after proposal creation

**Governance Performance:**
- Blueprint deployment after approval ≤ 5 minutes
- Cache propagation ≤ 60 seconds
- Rollback execution ≤ 2 minutes

**Learning Velocity (Target Metrics):**
- Time from first stochastic fallback to proposal deployment (Learning Latency): ≤ 14 days (v0.7.1 with human approval overhead)
- Proposal approval rate ≥ 70% (quality indicator)
- Deterministic match rate improvement ≥ 3% per month (early tenants, v0.7.1 manual process)

**Learning Quality:**
- Proposal regression rate (changes causing increased fallbacks) ≤ 3%
- Deployed proposal retention rate (still active after 30 days) ≥ 90%

---

## 17. Migration from v0.6.1

### 17.1 Backward Compatibility

Version 0.7.1 is backward compatible with v0.6.1 deployments:

- Existing single-domain tenants continue operating without changes
- Universal dispatcher is opt-in via feature flag
- Learning pipeline is opt-in via `learning_enabled` flag
- Blueprint structure is additive (new fields, no removals)
- Tool contracts unchanged (new tools added, existing maintained)
- Event schemas expanded but original events preserved
- Database migrations are additive (new tables/columns, no breaking changes)

---

### 17.2 Migration Path

**Phase 1 - Infrastructure Enhancement:**
- Deploy Cognitive Orchestrator components
- Add `voxeron_main` meta-tenant
- Extend database schema with v0.7.1 fields (orchestration + learning tables)
- Deploy Discovery Engine service
- Deploy PII redaction pipeline with field-level validation
- Deploy enhanced monitoring and safety systems

**Phase 2 - Single-Domain Enhancement:**
- Migrate existing tenants to new blueprint structure
- Add deterministic parsing rules to tenant overlays (initial manual population)
- Enable schema-first tool registry
- Activate P0 safety system for applicable domains
- Validate performance against SLOs
- **Enable learning telemetry emission (opt-in per tenant)**
- **Verify PII redaction and field validation**

**Phase 3 - Learning Pipeline Activation:**
- Enable Discovery Engine for pilot tenants
- Configure approval dashboard access
- Run initial proposal generation (manual process in v0.7.1)
- Review and approve first proposals
- Monitor deterministic match rate improvements
- Validate cost/latency impact

**Phase 4 - Multi-Domain Activation:**
- Enable universal dispatcher for pilot tenants
- Configure domain routing policies
- Test hot-swap two-stage behavior under load
- Validate language hysteresis policy
- Monitor classification accuracy
- Progressive rollout to additional tenants

**Phase 5 - Full Rollout:**
- Progressive rollout with canary deployments
- Domain-by-domain activation
- Tenant-by-tenant learning enablement
- Continuous monitoring and optimization
- Documentation and training for operators

---

## 18. Change Control & Versioning

### 18.1 Version 0.7.1 Contract Surface

The following are locked for v0.7.1 patch versions (v0.7.1.x):

**Immutable:**
- Core 4-plane architecture
- Stateless compute with centralized session management model
- Session state schema (additive changes only)
- Tool contract interfaces (new tools permitted, existing cannot change)
- Event schemas (new events permitted, existing cannot change)
- P0 override mechanism and safety guarantees
- Hot-swap two-stage lifecycle and guarantees
- Learning pipeline privacy guarantees (PII redaction, field-level controls, tenant isolation)
- ParserResult typed contract
- Language hysteresis policy framework
- Blueprint proposal approval workflow

**Additive:**
- New domain types
- New tools in existing categories
- New events
- New optional blueprint fields
- New safety keyword patterns
- New learning scopes (beyond vocabulary/slots)
- Performance optimizations
- Additional tier definitions

**Breaking (requires v0.8):**
- Changes to routing decision semantics
- Modifications to logic mode definitions
- Tool contract signature changes
- Session state field removal or renaming
- Event payload restructuring
- Learning pipeline architecture changes
- PII redaction policy changes
- ParserResult schema modifications

---

## 19. Future Roadmap Considerations

### 19.1 Potential v0.8 Directions

**Learning Expansion:**
- Automated clustering with confidence scoring (reduce manual intervention)
- Intent pattern discovery (beyond vocabulary)
- Repair strategy optimization
- Contextual disambiguation rules
- Cross-session personalization (with consent)
- Multi-tenant sector learning (shared patterns with privacy)

**Platform Capabilities:**
- Multi-modal expansion (video/screen sharing for complex service scenarios)
- Proactive outbound (system-initiated calls for reminders, follow-ups, surveys)
- Federated deployment (multi-region orchestration with data residency)
- Advanced agentic reasoning (multi-step planning, uncertainty quantification)
- Blockchain/audit ledger (immutable audit trail for regulated sectors)

**Domain Expansion:**
- Healthcare intake and triage
- Legal consultation scheduling
- Financial services support
- Educational institution services
- Government citizen services

---

## 20. Architectural Decision Records

All v0.7.1 architectural decisions documented in ADR format:

- **ADR-007:** Universal Dispatcher Pattern
- **ADR-008:** Mid-Session Hot-Swapping Mechanism (Two-Stage Optimization)
- **ADR-009:** P0 Safety Override System
- **ADR-010:** Schema-First Tool Architecture (MCP-Inspired)
- **ADR-011:** Domain Router Classification Approach
- **ADR-012:** Logic Mode Duality (Stochastic vs Deterministic)
- **ADR-013:** Log-to-Logic Learning Pipeline
- **ADR-014:** Privacy-by-Design in Learning Infrastructure (Allowed-Fields-Only)
- **ADR-015:** Deterministic-First Execution Model (Typed ParserResult Contract)
- **ADR-016:** Supervised Automation Governance
- **ADR-017:** Stateless Compute with Centralized Session Management
- **ADR-018:** Vendor Abstraction via Capability Tiers
- **ADR-019:** Language Hysteresis Policy (Two-Turn Confirmation)
- **ADR-020:** Streaming Lifecycle & Task Governance (WebSocket Cleanup Contract)

Full ADR content maintained in `/docs/architecture/ADR/` directory.

---

**Voxeron Platform Blueprint v0.7.1**  
**Agentic Multi-Domain Architecture with Continuous Learning**  
**Dev-Hardened Release**  
**Released: January 2026**  
**Status: Production-Ready Architecture**

---

## Appendix A: Glossary

**Allowed-Fields-Only Schema:** Privacy control pattern where database tables explicitly define permitted fields, preventing inadvertent PII storage through free-text or unstructured data

**Capability Tier:** Vendor-neutral classification of model/provider capabilities (cost, latency, reasoning) enabling flexible routing without brand lock-in

**Cognitive Controller:** Component managing blueprint loading, tool registry, execution mode, deterministic parsing, and orchestration

**Data Moat:** Competitive advantage created by accumulated operational data that improves product economics over time

**Deterministic Match:** Utterance successfully mapped to action using blueprint rules without model inference

**Deterministic Mode:** Execution using pre-verified scripts rather than agent generation (used for P0 safety overrides)

**Deterministic Parser:** Fast-path rule engine that attempts pattern matching before invoking agent inference

**Discovery Engine:** Control Plane service that aggregates learning telemetry and proposes blueprint improvements

**Domain Router (DR):** High-speed classifier determining target domain from initial audio

**Hot-Swap (Two-Stage):** Mid-session context transition optimized with synchronous critical path (Stage A, ≤100ms) and lazy background loading (Stage B, during greeting)

**Language Hysteresis:** Policy requiring multiple consecutive turns in new language before switching to prevent spurious changes from short utterances

**L2L Pipeline:** Log-to-Logic learning system transforming operational telemetry into deterministic rules

**Logic Mode:** Current execution strategy (STOCHASTIC for agent-driven, DETERMINISTIC for safety-locked, HYBRID for mixed)

**MCP-Inspired:** Following Model Context Protocol design philosophy (schema-first, typed contracts) without full protocol implementation

**Meta-Tenant:** Platform-level tenant (voxeron_main) serving as universal entry point

**P0 Override:** Safety-critical deterministic script activation (excluded from automated learning, human-verified only)

**ParserResult:** Typed contract returned by Deterministic Parser containing status, reason_code, and matched entity

**Stochastic Fallback:** Agent invoked because deterministic parser found no matching rule (triggers learning event)

**Stochastic Mode:** Agent-driven execution with probabilistic responses

**Stateless Compute:** Architecture where runtime workers are ephemeral and horizontally scalable, with state persisted in centralized Redis/PostgreSQL

**Tenant Overlay:** Tenant-specific blueprint layer containing learnable vocabulary and rules (version-controlled)

**Tier 4 Audit Model:** High-reasoning capability tier used for offline validation in Discovery Engine

**Tool:** Typed interface for executing business logic or retrieving information (schema-first design)

**Zero-Turn Classification:** Domain routing based on first few seconds of audio without explicit user input

---

## Appendix B: Migration Checklist

For operators migrating from v0.6.1 to v0.7.1:

**Infrastructure:**
- [ ] Review and approve v0.7.1 architectural changes
- [ ] Provision infrastructure for Cognitive Orchestrator
- [ ] Deploy Discovery Engine service
- [ ] Extend database schema with v0.7.1 fields (orchestration + learning tables)
- [ ] Deploy PII redaction pipeline with field-level validation enforcement
- [ ] Deploy enhanced monitoring dashboards
- [ ] Configure `voxeron_main` meta-tenant
- [ ] Set up capability tier routing policies

**Blueprint Migration:**
- [ ] Migrate existing blueprints to new structure
- [ ] Add deterministic parsing rules (initial manual population)
- [ ] Define domain routing policies
- [ ] Configure P0 safety keywords (if applicable)
- [ ] Mark safety sections as `learning_excluded`
- [ ] Configure language hysteresis thresholds

**Learning Pipeline:**
- [ ] Configure Discovery Engine batch schedule
- [ ] Set up approval dashboard access and permissions
- [ ] Define learning consent workflow for tenant onboarding
- [ ] Configure PII redaction rules and allowed-fields schema
- [ ] Set learning velocity and quality SLOs
- [ ] Establish proposal review process

**Testing & Validation:**
- [ ] Test hot-swap two-stage behavior in staging
- [ ] Validate deterministic parser ParserResult contract
- [ ] Test language hysteresis with multilingual scenarios
- [ ] Run Discovery Engine on historical data (pilot)
- [ ] Review and approve test proposals
- [ ] Validate performance against SLOs
- [ ] Verify PII redaction effectiveness and field-level controls
- [ ] Test WebSocket cleanup and task cancellation
- [ ] Test rollback procedures

**Operations:**
- [ ] Train operations team on new runbooks
- [ ] Configure alerting for learning pipeline health
- [ ] Set up cost/latency monitoring dashboards (tier-based)
- [ ] Document approval workflow for operators
- [ ] Establish escalation paths for proposal regressions

**Rollout:**
- [ ] Enable universal dispatcher for pilot tenants
- [ ] Enable learning telemetry for pilot tenants
- [ ] Monitor classification accuracy and optimize
- [ ] Review first week of learning events and proposals
- [ ] Progressive rollout to production tenants
- [ ] Document domain-specific customizations
- [ ] Schedule post-deployment review
- [ ] Gather operator feedback on approval workflow

---

## Appendix C: Learning Pipeline FAQ

**Q: How long until I see cost savings?**
A: Depends on call volume. High-volume tenants (50+ calls/day) typically see measurable improvements within 2-4 weeks. Lower-volume tenants may take 6-8 weeks to accumulate sufficient data. Note that v0.7.1 uses manual proposal review which adds 3-7 days to the learning cycle.

**Q: Can I review what the system learned before it goes live?**
A: Yes. All proposals require human approval. The dashboard shows sample utterances (PII-redacted), occurrence counts, and impact estimates. You can approve, reject, or request changes.

**Q: What happens if a learned rule causes problems?**
A: Blueprint versions are immutable and rollback is instant (≤2 minutes). If a deployed proposal causes increased fallbacks or errors, operators can revert to the prior version immediately.

**Q: Does learning work across my multiple restaurant locations?**
A: Within your tenant boundary, yes. If you have 5 locations under one tenant, vocabulary learned at Location A will benefit Location B automatically. Cross-tenant learning is not enabled in v0.7.1.

**Q: Will the system learn unsafe shortcuts?**
A: No. P0 safety rules are permanently excluded from automated learning (marked `learning_excluded: true`). Only operational vocabulary (menu items, service phrases, etc.) is learned. Safety logic requires expert human review through separate governance workflow.

**Q: What if I don't want learning enabled?**
A: Learning is opt-in. Set `learning_enabled: false` for your tenant and no telemetry will be collected. The platform works exactly like v0.6.1 for tenants who opt out.

**Q: How is my customer data protected in the learning pipeline?**
A: Multiple layers: (1) PII redacted before telemetry leaves data plane, (2) Allowed-fields-only schema prevents unstructured data storage, (3) 100-character limit on utterances, (4) Redaction version tracked for audit, (5) `pii_redaction_applied` flag verified before database insert. Only semantic content of requests is learned, never personal information.

**Q: Can I see what data contributed to a learned rule?**
A: Yes. The approval dashboard shows all sample utterances (PII-redacted, max 100 chars each) that formed each proposal. Full audit trail maintained for compliance.

**Q: How do you prevent the system from learning incorrect mappings?**
A: Multiple validation layers in v0.7.1: (1) Manual grouping of similar phrases, (2) Optional Tier 4 high-reasoning model validation, (3) Human approval required before production, (4) Regression monitoring post-deployment. Proposals with <70% operator approval rate trigger quality review.

**Q: What's the ROI timeline?**
A: The illustrative business case (Section 15.8) shows potential 50% cost reduction within 6 months and 75% within 12 months for high-volume tenants, based on stated assumptions. Actual results vary significantly based on call volume, domain complexity, and vocabulary diversity. This is not a guarantee.

**Q: Why is the learning cycle 14 days in v0.7.1 vs. 7 days in v0.7.0?**
A: Version 0.7.1 prioritizes governance and quality over speed. Manual proposal review, human validation, and approval workflows add 3-7 days but significantly reduce regression risk. Automated clustering and faster cycles are planned for v0.8.

**Q: What does "allowed-fields-only" mean for privacy?**
A: The learning database schema explicitly defines which fields can store data. Free-text notes, unstructured JSON, or any field not in the approved list will be rejected. This prevents accidental PII storage even if redaction fails. It's an architectural privacy guarantee, not just a policy.

---

**End of Voxeron Platform Blueprint v0.7.1 - Dev-Hardened Release**