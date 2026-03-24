---
source_id: seb-claude-tools
version: 1.0.0
---

# Agent Harness Design Patterns

Reference documentation for the 6 agent harness design patterns. Used by `/harness-architect` to select the right harness type for a given problem.

---

## Foundation: What Is a Harness?

A harness is the infrastructure that wraps an LLM and turns it into an agent. The harness — not the model — is the architecture. It provides: system prompts, tools, orchestration logic, state management, verification, and human-in-the-loop controls.

**Anthropic's formula:** Agent = Model + Harness
**LangChain's formula:** Agent = Model + Harness (same conclusion, independently reached)

The model is swappable. The harness is the moat.

---

## The 6 Harness Types

### 1. General Purpose Harness

**Definition:** A single agent in a loop with tools, memory, context management, and verification. The model reasons and acts by selecting from available tools across multiple turns.

**Architecture:**
```
[Human Task] → [Agent Loop] ←→ [Tools / APIs / Files]
                    ↓
              [Verification]
                    ↓
              [Output / Next iteration]
```

**Key components:**
- Context engineering (compaction, relevance filtering)
- Tool orchestration (selection, execution, result handling)
- State management (working memory + persistent state)
- Verification loops (self-check before completion)
- Session management (startup protocol, progress tracking)

**When to use:**
- Varied queries within a single domain
- Dynamic tool use where the agent decides what to do next
- Coding tasks, customer support, research, general automation
- When you need flexibility across diverse problem types
- **The default starting point** — start here unless requirements clearly point elsewhere

**When NOT to use:**
- Cross-domain problems requiring distinct expertise or security boundaries
- Simple single-turn tasks (overkill — just call the model directly)
- Tasks where context window pressure from many tools becomes unmanageable

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Flexible, reusable, simple to debug | Struggles with truly distinct expertise domains |
| One model to monitor and optimize | Context window pressure grows with tool count |
| Model-swappable — harness is the moat | Risk of infinite tool-call loops |

**Real implementations:** Claude Code, Claude Agent SDK, Cursor, Windsurf, LangChain DeepAgents

---

### 2. Specialized Harness

**Definition:** A harness purpose-built for a narrow, well-defined task domain. Receives structured task specifications with clear inputs, clear success criteria, and limited blast radius. Enforces domain-specific constraints.

**Architecture:**
```
[Task Queue] → [Task Spec] → [Specialized Agent] → [Verification] → [Output (e.g., PR)]
                                    ↓
                          [Domain-specific tools only]
                          [Isolated sandbox]
```

**Key components:**
- Structured task specification schema (clear inputs/outputs)
- Domain-specific tool set (not a general toolkit)
- Isolated execution sandbox per task
- Automated verification against success criteria
- Parallelizable — each agent is stateless

**When to use:**
- Production workloads with scoped, repeatable tasks
- Writing unit tests, fixing linter warnings, migrating APIs, updating docs
- When reliability matters more than flexibility
- When you need to run many tasks in parallel (batch processing)

**When NOT to use:**
- Open-ended, ambiguous, exploratory tasks
- Tasks requiring broad reasoning across multiple domains
- When the task definition cannot be tightly scoped in advance

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Extremely reliable within its domain | Rigid — can't adapt outside its spec |
| Parallelizable (Stripe: 1,300 PRs/week) | Requires engineering per domain |
| Predictable cost, small blast radius | Need many specialized harnesses for broad coverage |

**Real implementations:** Stripe Minions, Anthropic's initializer agent, domain-specific linting/migration agents

---

### 3. Autonomous Harness

**Definition:** A harness for long-running, self-directed agent work across multiple context windows without continuous human input. The human defines the task and reviews the result; everything in between is autonomous.

**Architecture:**
```
[Human Task] → [Initializer Agent] → [Progress File + Git Repo + Feature List]
                                              ↓
                                    [Executor Agent Session 1] → commit → progress update
                                              ↓
                                    [Executor Agent Session 2] → commit → progress update
                                              ↓
                                    [... Session N] → [Verification] → [Human Review]
```

**Key components:**
- **Initializer-executor split:** Initializer creates project structure, feature list, init script, progress file. Executors work incrementally across sessions.
- **Progress file:** Durable state between context windows (completed steps, blockers, decisions, next actions)
- **Git as memory:** Commits are the audit trail. Revert to recover from bad changes.
- **Feature list:** Structured JSON tracking completion status per feature
- **Session startup protocol:** pwd → read progress → read features → run tests → then work
- **Self-verification:** Build-verify-fix loop before marking anything complete
- **Continuation harness:** Hook that reinjects the prompt in a clean context window

**When to use:**
- Complex tasks spanning hours or days (building features, research, multi-file refactors)
- When the cost of human supervision per step is prohibitive
- When incremental progress across many sessions is the right model

**When NOT to use:**
- High-stakes decisions requiring human judgment at each step
- Tasks with large, irreversible blast radius
- Short, bounded tasks where a single session suffices
- Safety-critical domains without robust verification

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Multi-day projects without babysitting | Prone to "drift" over many sessions |
| Filesystem + git = durable, inspectable state | Expensive (many context windows) |
| Scales to arbitrarily complex work | "Declares victory prematurely" without strong verification |

**Real implementations:** Anthropic's long-running coding harness, Claude Code with takt, LangChain DeepAgents, Hightouch's agent harness

---

### 4. Hierarchical Harness

**Definition:** A multi-level architecture where a top-level supervisor/planner decomposes complex tasks and delegates to lower-level worker agents. Workers may further decompose, creating a tree.

**Architecture:**
```
[Complex Task] → [Supervisor/Planner]
                        ↓
              ┌─────────┼─────────┐
              ↓         ↓         ↓
         [Worker A] [Worker B] [Worker C]
              ↓         ↓         ↓
         [Result A] [Result B] [Result C]
              └─────────┼─────────┘
                        ↓
              [Supervisor: Synthesize] → [Output]
```

**Key components:**
- Task decomposition logic (supervisor breaks down work)
- Agent routing/dispatch (which worker handles what)
- Context filtering (each worker gets only relevant context)
- Result aggregation and synthesis
- Dynamic plan updating (plan adapts as results come in)
- Escalation paths (worker can't handle → back to supervisor)

**When to use:**
- Ambiguous, open-ended problems requiring multi-step reasoning
- Tasks where the number and nature of sub-tasks can't be predicted in advance
- Research projects, complex code changes spanning many files
- Multi-domain analysis requiring synthesis

**When NOT to use:**
- Simple, well-defined tasks (unnecessary coordination overhead)
- When latency is critical — multi-level delegation is slow
- When cost must be tightly controlled — many model calls accumulate

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Handles highly complex, ambiguous problems | Significant architectural complexity |
| Each agent has focused context | High latency from nested delegation |
| Can mix model tiers (expensive planner, cheap workers) | High cost from many model calls |

**Real implementations:** LangGraph Supervisor, Google Cloud hierarchical decomposition, Microsoft Magentic-One, Hightouch planner-executor

---

### 5. Multi-Agent Harness

**Definition:** Multiple specialized agents coordinate to solve a problem via an orchestrator, peer protocol, or routing mechanism. Unlike Hierarchical, the structure can be flat (peer-to-peer, handoff, coordinator-routed).

**Architecture (varies by sub-pattern):**

**Sequential (pipeline):**
```
[Input] → [Agent A] → [Agent B] → [Agent C] → [Output]
```

**Parallel (fan-out/fan-in):**
```
              ┌→ [Agent A] →┐
[Input] → [Fan-out]         [Fan-in] → [Output]
              └→ [Agent B] →┘
```

**Handoff:**
```
[Input] → [Agent A] ←→ [Agent B] ←→ [Agent C]
          (active agent transfers control dynamically)
```

**Coordinator:**
```
[Input] → [Coordinator] → routes to → [Specialist A/B/C] → [Coordinator] → [Output]
```

**Key components:**
- Agent registry and routing
- Context handoff mechanisms
- Result aggregation and conflict resolution
- Shared state or message passing
- Security boundaries per agent

**When to use:**
- Cross-functional or cross-domain problems
- Tasks requiring distinct security boundaries per agent
- When different agents need different tool access or model capabilities
- Scenarios benefiting from parallel specialization (researcher + writer + reviewer)

**When NOT to use:**
- When a single agent can reliably handle the task
- When coordination overhead isn't justified
- Azure: "Justify the added complexity by demonstrating that a single agent can't reliably handle the task"

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Each agent is focused and maintainable | Coordination overhead multiplies |
| Security isolation per agent | Handoff patterns risk infinite loops |
| Can parallelize independent work | Debugging distributed interactions is hard |

**Real implementations:** LangGraph multi-agent, Microsoft Agent Framework, OpenAI Swarm, AutoGen, CrewAI

---

### 6. DAG Harness

**Definition:** Workflows structured as a Directed Acyclic Graph — nodes are agent steps, edges are dependencies. Independent nodes run in parallel, dependent nodes wait. No cycles.

**Architecture:**
```
[Start] → [Step A] → [Step C] ─→ [Step E] → [End]
       ↘ [Step B] ↗           ↘ [Step F] ↗
                    [Step D] ──→ [Step F]
```

**Key components:**
- Graph definition (nodes + directed edges)
- Dependency resolver (topological sort)
- Parallel execution engine
- State passing between nodes
- Error handling and retry per node
- Checkpoint/resume capability

**When to use:**
- Well-defined workflows with known steps and clear dependencies
- Data processing pipelines, structured ETL
- When you need deterministic execution order with parallel optimization
- When the acyclic constraint (no infinite loops) is a safety requirement

**When NOT to use:**
- Open-ended tasks where workflow can't be defined in advance
- Tasks requiring dynamic decision-making about next steps
- Hightouch: DAGs are "a very poor fit for open-ended tasks"

**Trade-offs:**
| Pro | Con |
|-----|-----|
| Predictable, debuggable, observable | Rigid — can't adapt dynamically |
| Automatic parallelization of independent branches | Overhead for simple linear workflows |
| No infinite loops by design | Requires hybrid approach for dynamic decisions |
| Built-in resilience (retry, fallback per node) | |

**Real implementations:** LangGraph (graph-based), DAGent, Apache Airflow patterns applied to agents, Conductor

---

## Pattern Relationships

```
Complexity / Dynamism Spectrum:

DAG ──── Specialized ──── General Purpose ──── Multi-Agent ──── Hierarchical ──── Autonomous
(most rigid,              (flexible,                              (most dynamic,
 deterministic)            single-agent)                           self-directed)
```

**Containment relationships:**
- **General Purpose** is the base primitive — all others build on it
- **Specialized** constrains General Purpose to a narrow domain
- **Autonomous** extends General Purpose with session persistence + self-direction
- **Multi-Agent** composes multiple General Purpose or Specialized agents
- **Hierarchical** is a tree-topology Multi-Agent pattern
- **DAG** is a dependency-graph-topology (deterministic)

---

## Anthropic's Workflow Patterns (Building Blocks Within Harnesses)

These are composable patterns that implement the internal orchestration within any harness type:

| Pattern | Mechanism | Best For |
|---------|-----------|----------|
| **Prompt Chaining** | Output of step N feeds step N+1, gates between steps | Fixed sequential subtasks |
| **Routing** | Classifier directs input to specialized handlers | Distinct input categories |
| **Parallelization** | Sectioning (split task) or Voting (same task, multiple attempts) | Independent subtasks |
| **Orchestrator-Workers** | Central LLM dynamically decomposes and delegates | Unpredictable subtasks |
| **Evaluator-Optimizer** | Generator + evaluator in a loop | Iterative refinement |

These are building blocks, not prescriptive. They combine freely within any harness type.

---

## Common Combinations

| Combination | Use Case |
|-------------|----------|
| Hierarchical + Specialized workers | Complex problem → decompose → reliable narrow execution |
| Autonomous + Hierarchical | Multi-day project with dynamic planning and delegation |
| DAG + General Purpose nodes | Deterministic pipeline where some nodes need flexible agent reasoning |
| Multi-Agent + Specialized | Cross-domain with reliable domain-specific agents |
| Autonomous + Specialized | Long-running batch of narrow tasks with progress tracking |

---

## Sources

- Anthropic: "Building Effective Agents" (Dec 2024)
- Anthropic: "Effective Harnesses for Long-Running Agents"
- LangChain: "The Anatomy of an Agent Harness"
- LangChain: "Improving Deep Agents with Harness Engineering"
- Google Cloud: "Choose a Design Pattern for Your Agentic AI System"
- Azure: "AI Agent Orchestration Patterns"
- Martin Fowler / Birgitta Bockeler: "Harness Engineering"
- Stripe: Minions Architecture (Specialized Harness at scale)
- Hightouch: Long-Running Agent Harness (Autonomous + Hierarchical)
