---
source_id: seb-claude-tools
version: 1.0.0
---

# Pattern Selection Guide

Use this guide to choose the right agentic design pattern(s) for your problem. Start by identifying your primary challenge, then follow the decision trees and recommendations.

---

## Quick Decision Tree

```
What's your primary challenge?
│
├── "My task is too complex for a single prompt"
│   ├── Steps are sequential? → Prompt Chaining
│   ├── Steps are independent? → Parallelization
│   └── Need different specialists? → Multi-Agent Collaboration
│
├── "Different inputs need different handling"
│   └── Routing
│
├── "Output quality isn't good enough"
│   ├── Need iterative improvement? → Reflection
│   ├── Need explicit reasoning? → Reasoning Techniques (CoT)
│   ├── Need external validation? → LLM-as-a-Judge
│   └── Need clear goals? → Goal Setting and Monitoring
│
├── "Agent needs external capabilities"
│   ├── APIs, databases, code? → Tool Use
│   ├── Document search? → RAG (Knowledge Retrieval)
│   └── Need tool standardization? → MCP
│
├── "Need to maintain state/context"
│   ├── Conversation history? → Memory Management
│   └── Cross-session learning? → Memory + Adaptation
│
├── "Concerned about safety/reliability"
│   ├── Input/output validation? → Guardrails
│   ├── Need human oversight? → Human-in-the-Loop
│   └── External failures? → Exception Handling
│
├── "Need to optimize costs/latency"
│   └── Resource-Aware Optimization
│
└── "Building distributed agent systems"
    ├── Same organization? → Multi-Agent Collaboration
    └── Cross-organization? → Inter-Agent Communication (A2A)
```

---

## Problem-Based Selection

### "I need to process data through multiple transformation steps"

**Primary Pattern:** Prompt Chaining

**Complementary Patterns:**
- Add Guardrails for input/output validation at each step
- Add Memory if context needs to persist across chains
- Add Exception Handling if any step might fail

**Example Scenario:**
> Extract entities from documents → Normalize to schema → Generate report

```
Document → [Extract] → [Transform] → [Generate] → Report
               ↑              ↑              ↑
           Guardrail      Guardrail      Guardrail
```

---

### "My system handles different types of requests"

**Primary Pattern:** Routing

**Complementary Patterns:**
- Add Multi-Agent for specialized handlers per route
- Add Resource Optimization to route simple queries to cheaper models
- Add Guardrails to validate before routing

**Example Scenario:**
> Customer support handling: technical issues vs. billing vs. general inquiries

```
User Query → [Router] → Technical Agent
                     → Billing Agent
                     → General Agent
```

**Selection Criteria:**

| If you have... | Use... |
|----------------|--------|
| 2-5 distinct categories | Simple LLM-based routing |
| Many categories with overlap | Multi-label classification + routing |
| Cost sensitivity | Rule-based pre-filter + LLM routing |

---

### "I need to gather information from multiple sources"

**Primary Pattern:** Parallelization

**Complementary Patterns:**
- Add Prompt Chaining for synthesis after parallel gathering
- Add Exception Handling for unreliable sources
- Add RAG if sources are document-based

**Example Scenario:**
> Research task requiring web search, database query, and API calls

```
            ┌─ [Web Researcher] ─┐
Query → ─┬─┼─ [DB Researcher]   ─┼─→ [Merger] → Report
         └─┼─ [API Researcher]  ─┘
```

---

### "My output quality is inconsistent"

**Pattern Selection Matrix:**

| Problem | Solution |
|---------|----------|
| Missing edge cases | Reflection with critique loop |
| Logical errors | Reasoning (Chain-of-Thought) |
| Format issues | Guardrails (Pydantic validation) |
| Factual errors | RAG + Guardrails |
| Unclear requirements | Goal Setting and Monitoring |

**Recommended Combination:**
```
Generate → [Reflect] → [Validate] → Output
    ↑          │
    └──────────┘ (iteration loop)
```

---

### "I need to integrate external systems"

**Primary Pattern:** Tool Use

**Tool Selection Guide:**

| Need | Tool Type |
|------|-----------|
| Web data | Search tools (Google, Serper) |
| Database | SQL/query tools |
| APIs | Custom function tools |
| Code execution | Code interpreter |
| File operations | Filesystem tools |

**Complementary Patterns:**
- Add MCP for standardized tool interfaces
- Add Exception Handling for API failures
- Add Guardrails to validate tool inputs

---

### "Context gets lost in long conversations"

**Primary Pattern:** Memory Management

**Memory Type Selection:**

| Scenario | Memory Type |
|----------|-------------|
| Multi-turn chat | Conversation Buffer |
| Long conversations | Conversation Summary |
| User preferences | Long-term Store |
| Search over history | Vector Memory |

**Complementary Patterns:**
- Add RAG for retrieving relevant past context
- Add Personalization callbacks

---

### "I'm worried about safety and misuse"

**Layered Defense Pattern:**

```
1. Input Layer:     [Content Moderation] → Block harmful inputs
2. Process Layer:   [Guardrails] → Validate at each step
3. Output Layer:    [Output Validation] → Schema + safety checks
4. Human Layer:     [Human-in-the-Loop] → Approval for sensitive actions
```

**Pattern Selection by Risk Level:**

| Risk Level | Patterns |
|------------|----------|
| Low (internal tool) | Basic Guardrails |
| Medium (user-facing) | Guardrails + Output Validation |
| High (critical decisions) | All above + Human-in-the-Loop |
| Regulated (finance, health) | All above + Audit Logging |

---

### "External services are unreliable"

**Primary Pattern:** Exception Handling and Recovery

**Strategy Selection:**

| Failure Mode | Strategy |
|--------------|----------|
| Transient errors | Retry with exponential backoff |
| Service unavailable | Fallback to alternative service |
| Partial failures | Graceful degradation |
| Unknown errors | Human escalation |

**Implementation:**
```
[Primary Handler] → success? → [Response]
        ↓ fail
[Fallback Handler] → success? → [Response]
        ↓ fail
[Human Escalation]
```

---

### "I need to optimize for cost and latency"

**Primary Pattern:** Resource-Aware Optimization

**Model Tier Strategy:**

| Query Type | Recommended Model |
|------------|-------------------|
| Simple factual | Small/Fast (GPT-4o-mini, Gemini Flash) |
| Complex reasoning | Large/Capable (GPT-4, Claude, Gemini Pro) |
| Creative writing | Medium with high temperature |
| Code generation | Specialized code models |

**Complementary Patterns:**
- Add Routing to classify query complexity
- Add Caching for repeated queries
- Add Parallelization to reduce latency

---

## Architecture Selection by Scale

### Small Scale (Single Agent)

**Patterns to Start With:**
1. Prompt Chaining
2. Tool Use
3. Basic Guardrails

```
User → [Single Agent with Tools] → Response
```

### Medium Scale (Specialized Agents)

**Add These Patterns:**
1. Routing
2. Multi-Agent (2-5 specialists)
3. Memory Management
4. Exception Handling

```
User → [Router] → [Specialist Agent 1]
              → [Specialist Agent 2] → [Aggregator] → Response
              → [Specialist Agent 3]
```

### Large Scale (Agent Ecosystem)

**Full Pattern Stack:**
1. All medium scale patterns
2. Inter-Agent Communication (A2A)
3. MCP for tool standardization
4. Comprehensive Guardrails
5. Evaluation and Monitoring

```
┌─────────────────────────────────────┐
│          Orchestration Layer         │
│   Routing, Prioritization, Queue     │
└─────────────────────────────────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│Agent 1│ │Agent 2│ │Agent 3│ ← Each has tools via MCP
└───────┘ └───────┘ └───────┘
    │         │         │
    └─────────┼─────────┘
              ▼
┌─────────────────────────────────────┐
│     Shared Services Layer            │
│   Memory, Guardrails, Evaluation     │
└─────────────────────────────────────┘
```

---

## Pattern Combinations Matrix

Common effective combinations:

| Combination | Use Case |
|-------------|----------|
| Prompt Chaining + Reflection | Quality-critical generation |
| Routing + Multi-Agent | Multi-domain support |
| Parallelization + Prompt Chaining | Research and synthesis |
| RAG + Guardrails | Factual Q&A |
| Tool Use + Exception Handling | Reliable external access |
| Human-in-the-Loop + Guardrails | High-stakes decisions |
| Memory + Personalization | Conversational AI |
| Goal Setting + Reflection | Code/content generation |
| Resource Optimization + Routing | Cost-effective at scale |

---

## Anti-Pattern Warnings

When selecting patterns, avoid:

| Temptation | Why It's Wrong | Better Approach |
|------------|----------------|-----------------|
| Using Multi-Agent for simple tasks | Overhead, complexity | Single agent with tools |
| Adding Reflection everywhere | Latency, cost | Only for quality-critical outputs |
| Over-engineering routing | Maintenance burden | Start with 2-3 routes, expand |
| Ignoring Memory limits | Context overflow | Use summary memory or RAG |
| Skipping Guardrails | Safety risks | Always validate inputs/outputs |

---

## Framework Selection by Pattern

| Pattern | LangChain | Google ADK | CrewAI |
|---------|-----------|------------|--------|
| Prompt Chaining | LCEL | SequentialAgent | Tasks |
| Routing | RunnableBranch | sub_agents | N/A |
| Parallelization | RunnableParallel | ParallelAgent | Parallel Process |
| Reflection | Custom loop | SequentialAgent | Custom |
| Tool Use | create_tool_calling_agent | FunctionTool | Tool decorator |
| Multi-Agent | LangGraph | Agent hierarchy | Crew |
| Memory | Memory classes | SessionService | Memory |
| Guardrails | Pydantic + custom | Callbacks | guardrail param |

---

*Use this guide to start, then iterate based on real-world performance.*
