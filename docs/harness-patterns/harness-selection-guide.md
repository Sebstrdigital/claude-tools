---
source_id: seb-claude-tools
version: 1.0.0
---

# Harness Selection Guide

Decision framework for choosing the right agent harness type. Used by `/harness-architect` to map interview requirements to a harness recommendation.

---

## Quick Decision Tree

```
Is the task a single model call?
├── Yes → No harness needed. Direct API call.
└── No ↓

Is the workflow fully predictable with known steps?
├── Yes → Are steps independent (parallelizable)?
│         ├── Yes → DAG Harness
│         └── No  → DAG Harness (linear) or Specialized Harness
└── No ↓

Is it a single, narrow domain?
├── Yes → Is the task repeatable and parallelizable?
│         ├── Yes → Specialized Harness
│         └── No  → Does it span multiple sessions/days?
│                   ├── Yes → Autonomous Harness
│                   └── No  → General Purpose Harness
└── No ↓

Does it require multiple distinct expertise domains?
├── Yes → Can one supervisor decompose the work?
│         ├── Yes → Hierarchical Harness
│         └── No  → Multi-Agent Harness (coordinator or handoff)
└── No → General Purpose Harness (with good tools)
```

---

## Signal-to-Type Mapping

Use these signals from the interview to identify the right harness type:

### Signals → General Purpose Harness
- Single domain, varied tasks within it
- User says "it depends on the situation" about workflow steps
- Tool use is dynamic — agent needs to decide what to do next
- No clear parallelization opportunity
- Fits in a single session
- "I need a flexible assistant for X"

### Signals → Specialized Harness
- User describes a very specific, repeatable process
- "We do this 50 times a day" / "same steps every time"
- Clear input schema and output schema
- Small blast radius per task
- Parallelization would multiply throughput
- "We need reliability, not flexibility"

### Signals → Autonomous Harness
- Task spans hours or days
- "I want to define the goal and come back to a result"
- Incremental progress is natural (features, chapters, analyses)
- Human review at milestones, not at every step
- Git-friendly work (code, docs, configs)
- "I don't want to babysit it"

### Signals → Hierarchical Harness
- Ambiguous problem requiring decomposition
- "I'm not sure exactly what the subtasks are"
- Needs planning before execution
- Different subtasks need different approaches
- Synthesis required — combining partial results into a whole
- "The agent needs to figure out the plan"

### Signals → Multi-Agent Harness
- Multiple distinct domains or expertise areas
- Security boundaries needed between agents
- "Agent A shouldn't have access to what Agent B does"
- Different tool sets per specialty
- Natural role separation (researcher, writer, reviewer)
- Cross-functional workflow

### Signals → DAG Harness
- User can draw the workflow as a flowchart
- "First we do A and B in parallel, then C depends on both"
- Steps are well-known and don't change between runs
- Determinism and auditability are important
- Retry/fallback per step is needed
- "We need a reliable pipeline"

---

## Complexity vs. Dynamism Matrix

```
         Deterministic ←──────────────────────→ Dynamic

Simple   [DAG]           [Specialized]          [General Purpose]

Complex  [DAG + nodes]   [Multi-Agent]          [Hierarchical]
                                                [Autonomous]
```

**Rule of thumb:** Start at the simplest harness type that satisfies requirements. Move right (more dynamic) only when the workflow genuinely can't be predetermined. Move down (more complex) only when a single agent genuinely can't handle it.

---

## Platform Affinity

Some harness types naturally fit certain platforms better:

| Harness Type | Best Platform Fit | Also Works On |
|-------------|-------------------|---------------|
| General Purpose | Claude Code, Claude Agent SDK | LangGraph, any |
| Specialized | Claude Code (skills), Cloud Code | LangGraph, CrewAI |
| Autonomous | Claude Code + takt, Cloud Code | LangGraph (checkpointing) |
| Hierarchical | LangGraph (supervisor), CrewAI | Claude Code (nested agents) |
| Multi-Agent | LangGraph, CrewAI, AutoGen | Claude Code (agent chain) |
| DAG | LangGraph (native DAG), Airflow | Custom (topology sort) |

---

## Anti-Patterns in Harness Selection

| Anti-Pattern | Description | Fix |
|-------------|-------------|-----|
| **Premature Multi-Agent** | Jumping to multi-agent when single agent + good tools would work | Start with General Purpose, add agents only when a specific failure mode demands it |
| **DAG for Dynamic Work** | Forcing open-ended tasks into rigid graph structures | Use General Purpose or Hierarchical instead |
| **Autonomous Without Verification** | Long-running agent with no self-check mechanism | Add build-verify-fix loop, progress files, test gates |
| **General Purpose for Batch** | Using flexible agent for 500 identical tasks | Switch to Specialized — parallelize with narrow scope |
| **Hierarchical Without Clear Decomposition** | Adding supervisor layer when the task doesn't actually need decomposition | Only use when subtasks genuinely can't be predicted |
| **Over-tooled Specialized** | Giving a specialized agent tools it doesn't need | Strip to minimal tool set for the narrow domain |

---

## Hybrid Patterns

Real-world harnesses often combine types:

### Autonomous + Hierarchical
A long-running supervisor that plans across sessions and delegates to workers.
**Example:** Multi-day feature development — planner creates feature list, delegates to coding workers, tracks progress across sessions.

### Hierarchical + Specialized Workers
Complex decomposition at the top, reliable narrow execution at the bottom.
**Example:** Code migration — supervisor identifies files to migrate, specialized workers handle each file type.

### DAG + General Purpose Nodes
Deterministic pipeline with some nodes requiring flexible reasoning.
**Example:** Data pipeline where most steps are deterministic transforms but one step requires LLM judgment.

### Multi-Agent + Autonomous
Multiple specialists that maintain state across sessions.
**Example:** Research team — each agent researches different aspects over days, coordinator synthesizes.

---

## Escalation Path

When the chosen harness type doesn't work:

```
General Purpose failing?
├── Too rigid → Check if Autonomous would help (multi-session persistence)
├── Too broad → Check if Specialized would help (narrow the scope)
└── Too complex → Check if Hierarchical would help (decomposition)

Specialized failing?
├── Tasks too varied → Upgrade to General Purpose
├── Need coordination → Add Multi-Agent layer
└── Tasks too complex → Add Hierarchical decomposition

DAG failing?
├── Steps unknown → Switch to General Purpose or Hierarchical
├── Need dynamic routing → Add Router pattern within DAG
└── Steps depend on results → Consider Hierarchical instead
```
