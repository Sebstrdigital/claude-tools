---
source_id: seb-claude-tools
version: 1.0.0
---

# Anti-Patterns and Pitfalls in Agentic Design

This document catalogs common mistakes, anti-patterns, and pitfalls when implementing agentic systems. Use this to avoid known issues and improve your agent architectures.

---

## Table of Contents

1. [Architecture Anti-Patterns](#architecture-anti-patterns)
2. [Prompt and Reasoning Pitfalls](#prompt-and-reasoning-pitfalls)
3. [Memory and State Mistakes](#memory-and-state-mistakes)
4. [Tool Use Pitfalls](#tool-use-pitfalls)
5. [Multi-Agent Coordination Issues](#multi-agent-coordination-issues)
6. [Safety and Reliability Gaps](#safety-and-reliability-gaps)
7. [Performance and Cost Traps](#performance-and-cost-traps)
8. [Testing and Evaluation Blindspots](#testing-and-evaluation-blindspots)

---

## Architecture Anti-Patterns

### 1. The God Agent

**Anti-Pattern:**
Creating a single agent that handles everything - routing, processing, tools, memory, and output.

**Symptoms:**
- Massive system prompts (2000+ tokens)
- Inconsistent behavior across different query types
- Hard to debug or improve
- Context window overflow

**Why It Happens:**
- "It's simpler to have one agent"
- Avoiding the complexity of multi-agent setup
- Incremental feature additions without refactoring

**Solution:**
Decompose into specialized agents with clear responsibilities:
```
WRONG:
[God Agent: handles billing, technical support, sales, refunds, scheduling...]

RIGHT:
[Router] → [Billing Agent]
        → [Technical Agent]
        → [Sales Agent]
        → [Scheduling Agent]
```

---

### 2. Premature Multi-Agent Architecture

**Anti-Pattern:**
Jumping to a complex multi-agent system when a single agent with tools would suffice.

**Symptoms:**
- Excessive agent-to-agent communication overhead
- Simple tasks taking 10+ seconds
- Over-engineered for the problem scope
- High costs from multiple LLM calls

**Why It Happens:**
- Excitement about multi-agent architectures
- Copying patterns from complex use cases
- Not validating if complexity is warranted

**Solution:**
Start simple, add complexity only when needed:
```
Phase 1: Single agent with tools
Phase 2: Add routing if distinct domains emerge
Phase 3: Add specialized agents if quality/performance demands it
```

---

### 3. The Circular Reference

**Anti-Pattern:**
Agents that can call each other in cycles without termination conditions.

**Symptoms:**
- Infinite loops
- Stack overflow errors
- Runaway costs
- Timeout errors

**Example:**
```
Agent A: "I'll ask Agent B"
Agent B: "I need to consult Agent A"
Agent A: "I'll ask Agent B"
... (infinite loop)
```

**Solution:**
- Set maximum delegation depth
- Track visited agents in state
- Implement explicit termination conditions
- Use directed acyclic graphs (DAG) for agent relationships

---

### 4. Missing Error Boundaries

**Anti-Pattern:**
No isolation between agent components, allowing one failure to cascade through the system.

**Symptoms:**
- Single tool failure crashes entire agent
- Errors propagate across unrelated components
- No graceful degradation

**Solution:**
```python
# WRONG: No error handling
result = tool_a() + tool_b() + tool_c()

# RIGHT: Isolated error handling
results = {}
for tool in [tool_a, tool_b, tool_c]:
    try:
        results[tool.name] = tool()
    except Exception as e:
        results[tool.name] = {"error": str(e), "fallback": True}
        # Continue with degraded functionality
```

---

## Prompt and Reasoning Pitfalls

### 5. Instruction Overload

**Anti-Pattern:**
Cramming too many instructions, rules, and edge cases into system prompts.

**Symptoms:**
- Agent ignores some instructions
- Contradictory behaviors
- Increasing prompt just adds more problems
- Performance degrades with prompt length

**Why It Happens:**
- Adding rules for every edge case discovered
- Copy-pasting instructions without curation
- Fear of missing cases

**Solution:**
- Use hierarchical prompts (general principles + specific rules)
- Implement guardrails in code, not prompts
- Split into specialized agents with focused instructions
- Test prompt comprehension regularly

---

### 6. Implicit Goal Confusion

**Anti-Pattern:**
Assuming the LLM understands unstated goals or priorities.

**Symptoms:**
- Agent prioritizes wrong aspects of task
- Outputs miss key requirements
- "It should have known what I meant"

**Example:**
```
WRONG:
"Write code for a user login system"
(Agent writes insecure code because security wasn't mentioned)

RIGHT:
"Write secure code for a user login system. Security requirements:
- Password hashing with bcrypt
- Rate limiting on attempts
- Input sanitization"
```

**Solution:**
- Make goals explicit in prompts
- Use Goal Setting and Monitoring pattern
- Define acceptance criteria

---

### 7. Reflection Without Criteria

**Anti-Pattern:**
Implementing reflection loops without clear evaluation criteria.

**Symptoms:**
- Reflection doesn't improve output
- Agent makes arbitrary changes
- Loops until max iterations without real progress

**Solution:**
```python
# WRONG: Vague reflection
critique_prompt = "Is this code good? If not, improve it."

# RIGHT: Specific criteria
critique_prompt = """
Evaluate this code against:
1. Does it handle null inputs? (Required)
2. Are all functions < 20 lines? (Style)
3. Is there error handling for external calls? (Required)
4. Are variable names descriptive? (Style)

For each failed criterion, provide specific fix.
"""
```

---

### 8. Missing Chain-of-Thought for Complex Tasks

**Anti-Pattern:**
Asking for complex outputs directly without reasoning steps.

**Symptoms:**
- Inconsistent quality on complex tasks
- Errors in multi-step reasoning
- Agent skips important considerations

**Solution:**
Add explicit reasoning structure:
```
WRONG:
"Calculate the total cost including discounts and taxes"

RIGHT:
"Calculate the total cost by:
1. First, list all items and their base prices
2. Then, apply applicable discounts to each
3. Then, calculate subtotal
4. Then, apply tax rate
5. Finally, provide the total with breakdown"
```

---

## Memory and State Mistakes

### 9. Unbounded Memory Growth

**Anti-Pattern:**
Appending to conversation memory without limits or summarization.

**Symptoms:**
- Context window overflow
- Increasing latency over time
- OOM errors
- Degraded response quality

**Solution:**
```python
# Implement memory strategies
class ManagedMemory:
    def __init__(self, max_messages=50, summary_threshold=30):
        self.messages = []
        self.summary = ""

    def add(self, message):
        self.messages.append(message)
        if len(self.messages) > self.summary_threshold:
            self.summarize_and_trim()

    def summarize_and_trim(self):
        # Summarize old messages, keep recent ones
        old_messages = self.messages[:-10]
        self.summary = summarize(old_messages)
        self.messages = self.messages[-10:]
```

---

### 10. Stateless Agent Assumptions

**Anti-Pattern:**
Designing agents as if they remember everything from previous calls.

**Symptoms:**
- "But I told you that already!"
- Agent asks same questions repeatedly
- Lost context between interactions

**Solution:**
- Explicitly pass relevant state in each call
- Use persistent memory stores
- Include session context in prompts

---

### 11. Memory Pollution

**Anti-Pattern:**
Storing irrelevant or incorrect information in long-term memory.

**Symptoms:**
- Agent uses outdated information
- Conflicting facts in memory
- Wrong personalization

**Solution:**
- Implement memory validation before storing
- Add timestamps and confidence scores
- Allow memory correction/deletion
- Regular memory cleanup

---

## Tool Use Pitfalls

### 12. Tool Ambiguity

**Anti-Pattern:**
Tools with overlapping functionality or unclear descriptions.

**Symptoms:**
- Agent calls wrong tool
- Inconsistent tool selection
- Agent confused about which tool to use

**Example:**
```python
# WRONG: Ambiguous tools
search_tool = Tool(name="search", description="Search for information")
lookup_tool = Tool(name="lookup", description="Look up data")

# RIGHT: Clear distinctions
web_search_tool = Tool(
    name="web_search",
    description="Search the internet for current events and general knowledge. Use for: news, public info, websites."
)
database_lookup_tool = Tool(
    name="customer_database",
    description="Look up customer records by ID or email. Use for: order history, account details, preferences."
)
```

---

### 13. Missing Tool Error Handling

**Anti-Pattern:**
Tools that fail silently or return confusing error messages.

**Symptoms:**
- Agent doesn't know tool failed
- Cryptic error messages passed to user
- Agent retries infinitely

**Solution:**
```python
# WRONG: Silent failure
def search_tool(query):
    try:
        return api.search(query)
    except:
        return ""  # Agent doesn't know it failed

# RIGHT: Clear failure signals
def search_tool(query):
    try:
        return {"status": "success", "results": api.search(query)}
    except RateLimitError:
        return {"status": "error", "message": "Search rate limited. Try again in 60s."}
    except ConnectionError:
        return {"status": "error", "message": "Search service unavailable. Use cached data or skip."}
```

---

### 14. Over-Privileged Tools

**Anti-Pattern:**
Giving agents tools with more capabilities than needed.

**Symptoms:**
- Security vulnerabilities
- Unintended side effects
- Data corruption risks

**Example:**
```python
# WRONG: Too powerful
database_tool = Tool(
    name="database",
    description="Execute any SQL query",
    function=execute_raw_sql  # Can DROP tables!
)

# RIGHT: Scoped permissions
customer_query_tool = Tool(
    name="get_customer",
    description="Retrieve customer info by ID",
    function=get_customer_by_id  # Read-only, parameterized
)
```

---

## Multi-Agent Coordination Issues

### 15. Unclear Delegation

**Anti-Pattern:**
Coordinator agent has vague or overlapping delegation rules.

**Symptoms:**
- Tasks routed to wrong agents
- Some queries fall through cracks
- Inconsistent routing decisions

**Solution:**
```python
# WRONG: Vague instruction
coordinator_instruction = "Route to the appropriate agent"

# RIGHT: Explicit rules
coordinator_instruction = """
Route based on these rules (check in order):
1. If query mentions 'password', 'login', 'account access' → Security Agent
2. If query mentions 'refund', 'charge', 'payment' → Billing Agent
3. If query mentions 'broken', 'not working', 'error' → Technical Agent
4. All other queries → General Agent

If uncertain, route to General Agent who can re-route if needed.
"""
```

---

### 16. Information Silos

**Anti-Pattern:**
Agents that can't access information gathered by other agents.

**Symptoms:**
- Agent asks user for info another agent already has
- Inconsistent answers across agents
- Duplicated data gathering

**Solution:**
- Use shared state/memory across agents
- Pass relevant context during handoffs
- Implement a central context store

---

### 17. Handoff Without Context

**Anti-Pattern:**
Transferring to another agent without passing conversation context.

**Symptoms:**
- User has to repeat themselves
- New agent asks same questions
- Frustrating user experience

**Solution:**
```python
# Include handoff summary
def transfer_to_specialist(context, reason):
    handoff_summary = f"""
    Transferred from: {context.current_agent}
    Reason: {reason}
    User's original query: {context.original_query}
    Information gathered so far:
    - Customer ID: {context.state.get('customer_id')}
    - Issue type: {context.state.get('issue_type')}
    - Previous attempts: {context.state.get('attempts')}
    """
    return {"handoff_summary": handoff_summary}
```

---

## Safety and Reliability Gaps

### 18. Input Validation Afterthought

**Anti-Pattern:**
Adding input validation only after security incidents.

**Symptoms:**
- Prompt injection vulnerabilities
- Unexpected agent behaviors
- Data leakage

**Solution:**
Implement defense-in-depth from the start:
```python
def process_user_input(raw_input):
    # Layer 1: Content moderation
    if not passes_moderation(raw_input):
        return reject("Content policy violation")

    # Layer 2: Sanitization
    sanitized = sanitize_input(raw_input)

    # Layer 3: Rate limiting
    if exceeds_rate_limit(user_id):
        return reject("Rate limit exceeded")

    # Layer 4: Length limits
    if len(sanitized) > MAX_INPUT_LENGTH:
        return reject("Input too long")

    return sanitized
```

---

### 19. Output Without Validation

**Anti-Pattern:**
Returning LLM outputs directly to users without validation.

**Symptoms:**
- Malformed outputs break downstream systems
- Hallucinated data presented as fact
- Harmful content reaches users

**Solution:**
```python
# Always validate outputs
def generate_response(query):
    raw_output = llm.generate(query)

    # Structural validation
    try:
        parsed = ResponseSchema.model_validate_json(raw_output)
    except ValidationError:
        return fallback_response()

    # Content validation
    if not passes_output_guardrails(parsed):
        return filtered_response(parsed)

    # Fact checking (for critical domains)
    if needs_verification(parsed):
        parsed = verify_facts(parsed)

    return parsed
```

---

### 20. Single Point of Failure

**Anti-Pattern:**
Critical path depends on single external service without fallback.

**Symptoms:**
- Complete outage when service is down
- No graceful degradation
- Users stuck with no response

**Solution:**
```
Primary Path:
[Query] → [External API] → [Process] → [Response]
         ↓ fail
Fallback Path:
[Query] → [Cached/Local Fallback] → [Degraded Response]
         ↓ fail
Final Fallback:
[Query] → [Human Escalation Queue]
```

---

## Performance and Cost Traps

### 21. Unnecessary Iterations

**Anti-Pattern:**
Reflection/refinement loops that don't have diminishing returns checks.

**Symptoms:**
- High latency for simple tasks
- Minimal quality improvement after iteration 2
- Wasted API costs

**Solution:**
```python
def reflect_with_diminishing_returns(output, max_iterations=5):
    for i in range(max_iterations):
        score_before = evaluate(output)
        output = refine(output)
        score_after = evaluate(output)

        improvement = score_after - score_before
        if improvement < MIN_IMPROVEMENT_THRESHOLD:
            break  # Diminishing returns

    return output
```

---

### 22. Model Overkill

**Anti-Pattern:**
Using the most powerful (expensive) model for all tasks.

**Symptoms:**
- High API costs
- Unnecessary latency
- Same quality achievable with smaller models

**Solution:**
Implement tiered model selection:
```python
MODEL_TIERS = {
    "simple": "gpt-4o-mini",      # Simple Q&A, classification
    "standard": "gpt-4o",          # Most tasks
    "complex": "claude-opus",      # Complex reasoning
}

def select_model(task_complexity):
    if is_simple_query(task_complexity):
        return MODEL_TIERS["simple"]
    elif needs_advanced_reasoning(task_complexity):
        return MODEL_TIERS["complex"]
    else:
        return MODEL_TIERS["standard"]
```

---

### 23. Parallel Bottleneck

**Anti-Pattern:**
Using parallelization but having a slow sequential step that negates benefits.

**Symptoms:**
- Parallel tasks complete quickly, then wait
- Total time still dominated by one step
- Marginal improvement from parallelization

**Solution:**
Profile and optimize the critical path:
```
WRONG:
[Fast Task 1] ─┐
[Fast Task 2] ─┼─→ [Slow Synthesis: 10s] → Output
[Fast Task 3] ─┘
Total: 10.5s (dominated by synthesis)

RIGHT:
[Fast Task 1] ─┐
[Fast Task 2] ─┼─→ [Optimized Synthesis: 2s] → Output
[Fast Task 3] ─┘
OR: Stream synthesis to start before all tasks complete
```

---

## Testing and Evaluation Blindspots

### 24. Happy Path Testing Only

**Anti-Pattern:**
Only testing with ideal inputs that work perfectly.

**Symptoms:**
- Fails on real user inputs
- Edge cases cause crashes
- Adversarial inputs exploit vulnerabilities

**Solution:**
Test comprehensively:
```
Test Categories:
1. Happy path (ideal inputs)
2. Edge cases (empty, very long, special characters)
3. Error cases (invalid format, missing data)
4. Adversarial (prompt injection, jailbreak attempts)
5. Boundary conditions (limits, timeouts)
6. Concurrent access (race conditions)
```

---

### 25. No Regression Testing

**Anti-Pattern:**
Changing prompts or agents without verifying existing functionality.

**Symptoms:**
- "It used to work"
- Improvements break other cases
- Whack-a-mole bug fixing

**Solution:**
```python
# Maintain test cases that must always pass
GOLDEN_TEST_CASES = [
    {"input": "...", "expected_behavior": "..."},
    {"input": "...", "expected_behavior": "..."},
]

def run_regression_tests(agent):
    for test in GOLDEN_TEST_CASES:
        result = agent.run(test["input"])
        assert meets_expected_behavior(result, test["expected_behavior"])
```

---

### 26. Evaluation Without Baselines

**Anti-Pattern:**
Evaluating agents without comparing to baselines or previous versions.

**Symptoms:**
- "Is this good enough?"
- No objective improvement tracking
- Unclear if changes help or hurt

**Solution:**
```python
def evaluate_with_baseline(new_agent, baseline_agent, test_set):
    results = {
        "new": {"correct": 0, "latency": [], "cost": 0},
        "baseline": {"correct": 0, "latency": [], "cost": 0},
    }

    for test in test_set:
        # Evaluate both
        new_result = timed_evaluate(new_agent, test)
        baseline_result = timed_evaluate(baseline_agent, test)

        # Compare
        update_metrics(results["new"], new_result)
        update_metrics(results["baseline"], baseline_result)

    return comparative_report(results)
```

---

## Quick Anti-Pattern Checklist

Before deploying, verify:

- [ ] No God Agent (responsibilities are separated)
- [ ] Complexity matches the problem
- [ ] No circular agent references
- [ ] Error boundaries in place
- [ ] Prompt instructions are focused and tested
- [ ] Goals are explicit, not implicit
- [ ] Reflection has clear criteria
- [ ] Complex tasks use structured reasoning
- [ ] Memory has bounds and cleanup
- [ ] State is explicitly managed
- [ ] Tool descriptions are unambiguous
- [ ] Tool errors are handled gracefully
- [ ] Tools have minimal necessary permissions
- [ ] Delegation rules are explicit
- [ ] Context passes between agents
- [ ] Inputs are validated
- [ ] Outputs are validated
- [ ] Fallbacks exist for critical services
- [ ] Model selection is cost-appropriate
- [ ] Iterations have diminishing returns checks
- [ ] Tests cover edge cases and failures
- [ ] Regressions are checked
- [ ] Baselines exist for comparison

---

*Learn from others' mistakes. Check this document before and during implementation.*
