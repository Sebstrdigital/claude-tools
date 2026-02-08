---
source_id: seb-claude-tools
version: 1.0.0
---

# Agentic Design Patterns - Master Summary

This document provides a comprehensive reference of all agentic design patterns from the source material. Use this as a quick lookup when designing or analyzing agent architectures.

---

## Table of Contents

1. [Prompt Chaining](#1-prompt-chaining)
2. [Routing](#2-routing)
3. [Parallelization](#3-parallelization)
4. [Reflection](#4-reflection)
5. [Tool Use](#5-tool-use)
6. [Planning](#6-planning)
7. [Multi-Agent Collaboration](#7-multi-agent-collaboration)
8. [Memory Management](#8-memory-management)
9. [Adaptation](#9-adaptation)
10. [Model Context Protocol (MCP)](#10-model-context-protocol-mcp)
11. [Goal Setting and Monitoring](#11-goal-setting-and-monitoring)
12. [Exception Handling and Recovery](#12-exception-handling-and-recovery)
13. [Human-in-the-Loop](#13-human-in-the-loop)
14. [Knowledge Retrieval (RAG)](#14-knowledge-retrieval-rag)
15. [Inter-Agent Communication (A2A)](#15-inter-agent-communication-a2a)
16. [Resource-Aware Optimization](#16-resource-aware-optimization)
17. [Reasoning Techniques](#17-reasoning-techniques)
18. [Guardrails and Safety Patterns](#18-guardrails-and-safety-patterns)
19. [Evaluation and Monitoring](#19-evaluation-and-monitoring)
20. [Prioritization](#20-prioritization)
21. [Exploration and Discovery](#21-exploration-and-discovery)

---

## 1. Prompt Chaining

**Category:** Workflow Orchestration

**Description:**
Breaking down complex tasks into a sequence of smaller, focused LLM calls where the output of one step becomes the input to the next.

**Key Characteristics:**
- Sequential execution of prompts
- Each step has a single, well-defined purpose
- Output transformation between steps
- Easier debugging and quality control

**Implementation Pattern:**
```python
# LangChain LCEL example
extraction_chain = prompt_extract | llm | StrOutputParser()
full_chain = (
    {"specifications": extraction_chain}
    | prompt_transform
    | llm
    | StrOutputParser()
)
```

**When to Use:**
- Tasks requiring multi-step reasoning
- When you need structured output transformation
- Complex data processing pipelines
- Document analysis and summarization

**Frameworks:** LangChain (LCEL), Google ADK (SequentialAgent)

---

## 2. Routing

**Category:** Workflow Orchestration

**Description:**
Dynamically directing requests to specialized handlers or sub-agents based on the nature of the input.

**Key Characteristics:**
- Classification/categorization of inputs
- Multiple specialized handlers
- LLM-based or rule-based routing decisions
- Separation of concerns

**Implementation Pattern:**
```python
# Router determines which handler to use
coordinator_router_chain = coordinator_router_prompt | llm | StrOutputParser()

# Branch based on router output
delegation_branch = RunnableBranch(
    (lambda x: x['decision'] == 'booker', booking_handler),
    (lambda x: x['decision'] == 'info', info_handler),
    unclear_handler  # Default
)
```

**When to Use:**
- Multi-domain systems (booking, info, support)
- When different queries need specialized handling
- Load balancing across agents
- Complexity isolation

**Frameworks:** LangChain (RunnableBranch), Google ADK (sub_agents with Auto-Flow)

---

## 3. Parallelization

**Category:** Workflow Orchestration

**Description:**
Executing multiple independent LLM calls or agent tasks concurrently, then aggregating results.

**Key Characteristics:**
- Concurrent execution of independent tasks
- Fan-out / fan-in pattern
- Merger/synthesis step to combine results
- Significant latency reduction

**Implementation Pattern:**
```python
# Google ADK
parallel_research_agent = ParallelAgent(
    name="ParallelWebResearchAgent",
    sub_agents=[researcher_1, researcher_2, researcher_3]
)

# LangChain
map_chain = RunnableParallel({
    "summary": summarize_chain,
    "questions": questions_chain,
    "key_terms": terms_chain
})
```

**When to Use:**
- Research tasks requiring multiple sources
- Independent data processing streams
- When latency is critical
- Map-reduce style operations

**Frameworks:** Google ADK (ParallelAgent), LangChain (RunnableParallel)

---

## 4. Reflection

**Category:** Quality Assurance

**Description:**
Having an LLM critique and improve its own output through iterative refinement loops.

**Key Characteristics:**
- Generate-then-critique cycle
- Iterative improvement
- Self-correction capability
- Quality gate before completion

**Implementation Pattern:**
```python
for i in range(max_iterations):
    # Generate
    current_code = llm.invoke(generate_prompt)

    # Reflect
    critique = llm.invoke(reflector_prompt)

    # Check stopping condition
    if "CODE_IS_PERFECT" in critique:
        break

    # Prepare for refinement
    previous_code = current_code
```

**When to Use:**
- Code generation and review
- Content writing and editing
- Quality-critical outputs
- When iterative improvement is feasible

**Frameworks:** LangChain, Google ADK (SequentialAgent with reviewer)

---

## 5. Tool Use

**Category:** Capability Extension

**Description:**
Enabling LLMs to interact with external systems through function calling / tool calling.

**Key Characteristics:**
- Function/tool definitions with schemas
- LLM decides when to call tools
- Tool execution and result integration
- Agent executors manage the loop

**Implementation Pattern:**
```python
@tool
def search_information(query: str) -> str:
    """Provides factual information on a given topic."""
    return simulated_search(query)

agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools)
```

**When to Use:**
- When LLMs need external data access
- Database queries, API calls
- Code execution
- Any capability beyond text generation

**Frameworks:** LangChain (create_tool_calling_agent), Google ADK (FunctionTool), CrewAI

---

## 6. Planning

**Category:** Task Management

**Description:**
Having an agent create a structured plan before execution, breaking complex goals into actionable steps.

**Key Characteristics:**
- Explicit plan generation
- Step-by-step task decomposition
- Plan-then-execute pattern
- Often combined with tool use

**Implementation Pattern:**
```python
planner_agent = Agent(
    role='Article Planner and Writer',
    goal='Plan and then write a concise, engaging summary.',
    instruction=(
        "1. Create a bullet-point plan for a summary.\n"
        "2. Write the summary based on your plan."
    )
)
```

**When to Use:**
- Complex multi-step tasks
- Research and report generation
- Project management automation
- When explicit reasoning is valuable

**Frameworks:** CrewAI, OpenAI Deep Research API, Google ADK

---

## 7. Multi-Agent Collaboration

**Category:** Architecture Pattern

**Description:**
Multiple specialized agents working together with defined roles and coordination patterns.

**Coordination Patterns:**
- **Sequential:** Agents execute in order (pipeline)
- **Parallel:** Agents execute concurrently
- **Coordinator:** Central agent delegates to specialists
- **Loop:** Iterative collaboration until goal met

**Implementation Pattern:**
```python
# Coordinator pattern (ADK)
coordinator = LlmAgent(
    name="Coordinator",
    instruction="Delegate to appropriate specialist agents.",
    sub_agents=[booking_agent, info_agent]
)

# CrewAI sequential
crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    process=Process.sequential
)
```

**When to Use:**
- Complex systems requiring specialization
- Domain-specific expertise needed
- Scalable agent architectures
- Clear separation of responsibilities

**Frameworks:** Google ADK (SequentialAgent, ParallelAgent), CrewAI, LangGraph

---

## 8. Memory Management

**Category:** State Management

**Description:**
Persisting and retrieving information across agent interactions for context continuity.

**Memory Types:**
- **Short-term:** Conversation buffer, immediate context
- **Long-term:** Persistent storage, vector databases
- **Semantic:** Embedding-based retrieval
- **Episodic:** Session-based memories

**Implementation Pattern:**
```python
# LangChain conversation memory
memory = ConversationBufferMemory(memory_key="history")
conversation = LLMChain(llm=llm, prompt=prompt, memory=memory)

# LangGraph store
store = InMemoryStore(index={"embed": embed_fn, "dims": 2})
store.put(namespace, "memory-key", {"rules": [...], "preferences": [...]})
```

**When to Use:**
- Multi-turn conversations
- User preference tracking
- Learning from past interactions
- Personalization

**Frameworks:** LangChain (ConversationBufferMemory), LangGraph (BaseStore), Google ADK (SessionService, MemoryService)

---

## 9. Adaptation

**Category:** Learning Pattern

**Description:**
Agents that evolve and improve their behavior over time through automated optimization.

**Key Characteristics:**
- Evolutionary algorithms for prompts/code
- Fitness functions for evaluation
- Population-based optimization
- Self-improvement loops

**Implementation Pattern:**
```python
# OpenEvolve example
evolve = OpenEvolve(
    initial_program_path="path/to/program.py",
    evaluation_file="path/to/evaluator.py",
    config_path="config.yaml"
)
best_program = await evolve.run(iterations=1000)
```

**When to Use:**
- Prompt optimization
- Code generation improvement
- When manual tuning is insufficient
- Long-running optimization tasks

**Frameworks:** OpenEvolve

---

## 10. Model Context Protocol (MCP)

**Category:** Interoperability

**Description:**
A standardized protocol for exposing tools and resources to LLM agents, enabling tool interoperability.

**Key Characteristics:**
- Standardized tool definitions
- Server/client architecture
- Auto-discovery of capabilities
- Framework-agnostic tool sharing

**Implementation Pattern:**
```python
# FastMCP Server
from fastmcp import FastMCP, tool

@tool()
def greet(name: str) -> str:
    """Generates a personalized greeting."""
    return f"Hello, {name}!"

mcp_server = FastMCP()
mcp_server.run()
```

**When to Use:**
- Building reusable tool libraries
- Cross-framework tool sharing
- Standardized agent-tool interfaces
- Plugin architectures

**Frameworks:** FastMCP, Google ADK MCP integration

---

## 11. Goal Setting and Monitoring

**Category:** Task Management

**Description:**
Explicit goal definition with continuous monitoring and iterative refinement until goals are met.

**Key Characteristics:**
- Clear goal specification
- Progress monitoring
- Goal completion evaluation
- Iterative refinement until satisfied

**Implementation Pattern:**
```python
def goals_met(feedback_text: str, goals: list[str]) -> bool:
    """Uses LLM to evaluate if goals are met."""
    review_prompt = f"Based on feedback, have these goals been met? {goals}"
    response = llm.invoke(review_prompt)
    return response.strip().lower() == "true"

for i in range(max_iterations):
    code = generate_code(goals)
    feedback = get_feedback(code, goals)
    if goals_met(feedback, goals):
        break
```

**When to Use:**
- Quality-critical code generation
- Document creation with standards
- Iterative refinement tasks
- Measurable outcome requirements

**Frameworks:** Custom implementations with LangChain/OpenAI

---

## 12. Exception Handling and Recovery

**Category:** Reliability Pattern

**Description:**
Graceful handling of failures with fallback strategies and recovery mechanisms.

**Key Characteristics:**
- Primary and fallback handlers
- State-based error detection
- Graceful degradation
- Sequential fallback attempts

**Implementation Pattern:**
```python
# ADK fallback pattern
robust_agent = SequentialAgent(
    name="robust_location_agent",
    sub_agents=[
        primary_handler,     # Tries precise location
        fallback_handler,    # Falls back to general area
        response_agent       # Presents results
    ]
)
```

**When to Use:**
- External API dependencies
- Unreliable data sources
- Critical user-facing applications
- When graceful degradation is acceptable

**Frameworks:** Google ADK (SequentialAgent), LangGraph

---

## 13. Human-in-the-Loop

**Category:** Safety and Control

**Description:**
Integrating human oversight, approval, or intervention at key decision points.

**Key Characteristics:**
- Escalation triggers
- Human approval gates
- Personalization through callbacks
- Intervention points

**Implementation Pattern:**
```python
# Escalation tool
def escalate_to_human(issue_type: str) -> dict:
    return {"status": "success", "message": f"Escalated to human specialist."}

# Personalization callback
def personalization_callback(context, llm_request):
    customer_info = context.state.get("customer_info")
    if customer_info:
        # Inject personalization into request
        llm_request.contents.insert(0, personalization_content)
```

**When to Use:**
- High-stakes decisions
- Customer support escalation
- Compliance-critical workflows
- Learning from human corrections

**Frameworks:** Google ADK (callbacks), LangGraph (interrupt)

---

## 14. Knowledge Retrieval (RAG)

**Category:** Knowledge Augmentation

**Description:**
Retrieval-Augmented Generation - enhancing LLM responses with relevant retrieved context.

**Key Characteristics:**
- Document chunking and embedding
- Vector store for similarity search
- Context injection into prompts
- Grounded, factual responses

**Implementation Pattern:**
```python
# Retrieval node
def retrieve_documents(state):
    documents = retriever.invoke(state["question"])
    return {"documents": documents}

# Generation node
def generate_response(state):
    context = "\n".join([doc.page_content for doc in state["documents"]])
    response = rag_chain.invoke({"context": context, "question": question})
    return {"generation": response}
```

**When to Use:**
- Question answering over documents
- Knowledge base queries
- Reducing hallucinations
- Domain-specific information retrieval

**Frameworks:** LangChain, LangGraph, Weaviate, Google Search tools

---

## 15. Inter-Agent Communication (A2A)

**Category:** Architecture Pattern

**Description:**
Agent-to-Agent protocol enabling agents to discover, communicate with, and delegate to other agents.

**Key Characteristics:**
- Agent discovery (AgentCard)
- Standardized communication protocol
- Skill-based delegation
- Streaming and async support

**Implementation Pattern:**
```python
# Agent card definition
agent_card = AgentCard(
    name='Calendar Agent',
    description="Manages user calendar",
    skills=[AgentSkill(
        id='check_availability',
        name='Check Availability',
        description="Checks availability using Google Calendar"
    )]
)

# A2A application
a2a_app = A2AStarletteApplication(
    agent_card=agent_card,
    http_handler=request_handler
)
```

**When to Use:**
- Distributed agent systems
- Agent marketplaces
- Microservices-style agent architecture
- Cross-organization agent interop

**Frameworks:** Google ADK A2A, custom implementations

---

## 16. Resource-Aware Optimization

**Category:** Efficiency Pattern

**Description:**
Optimizing agent resource usage by routing to appropriate model tiers based on task complexity.

**Key Characteristics:**
- Model tier selection (cheap/expensive)
- Query complexity analysis
- Cost optimization
- Latency vs. quality tradeoffs

**Implementation Pattern:**
```python
class QueryRouterAgent(BaseAgent):
    async def _run_async_impl(self, context):
        query_length = len(context.current_message.text.split())

        if query_length < 20:
            # Route to cheaper, faster model
            return await gemini_flash_agent.run_async(...)
        else:
            # Route to more capable model
            return await gemini_pro_agent.run_async(...)
```

**When to Use:**
- High-volume applications
- Cost-sensitive deployments
- Mixed complexity workloads
- Latency-critical simple queries

**Frameworks:** Google ADK, LiteLLM, custom routing

---

## 17. Reasoning Techniques

**Category:** Quality Enhancement

**Description:**
Structured approaches to improve LLM reasoning, including Chain-of-Thought and self-correction.

**Techniques:**
- **Chain-of-Thought (CoT):** Step-by-step reasoning before answering
- **Self-Correction:** Reviewing and refining own outputs
- **Code Execution:** Using code to verify reasoning
- **Deep Search:** Multi-step research with web access

**Implementation Pattern:**
```
# CoT prompt structure
1. Analyze the Query: Understand core requirements
2. Formulate Search Queries: Generate precise queries
3. Simulate Retrieval: Consider expected results
4. Synthesize Information: Combine into coherent answer
5. Review and Refine: Critically evaluate before finalizing
```

**When to Use:**
- Complex reasoning tasks
- Mathematical or logical problems
- Research and analysis
- When accuracy is paramount

**Frameworks:** Prompt engineering, OpenAI o3 Deep Research

---

## 18. Guardrails and Safety Patterns

**Category:** Safety and Reliability

**Description:**
Mechanisms to ensure agent outputs are safe, valid, and within acceptable bounds.

**Guardrail Types:**
- **Input validation:** Content moderation, forbidden keywords
- **Output validation:** Schema validation, logical checks
- **Tool restrictions:** Limited tool access per agent
- **Retry with backoff:** Error resilience

**Implementation Pattern:**
```python
# Input moderation
def moderate_input(text: str) -> Tuple[bool, str]:
    pattern = r'\b(' + '|'.join(forbidden_keywords) + r')\b'
    if re.search(pattern, text, re.IGNORECASE):
        return False, "Input contains forbidden content"
    return True, "Input is clean"

# Output validation with Pydantic
class ResearchSummary(BaseModel):
    title: str
    key_findings: list[str]
    confidence_score: float = Field(ge=0.0, le=1.0)

def validate_output(output: str) -> Tuple[bool, Any]:
    data = json.loads(output)
    summary = ResearchSummary.model_validate(data)
    return True, output
```

**When to Use:**
- User-facing applications
- Regulated industries
- When output quality is critical
- Preventing harmful content

**Frameworks:** CrewAI (guardrails), Pydantic, custom implementations

---

## 19. Evaluation and Monitoring

**Category:** Quality Assurance

**Description:**
Using LLMs or metrics to evaluate agent performance and output quality.

**Approaches:**
- **LLM-as-a-Judge:** Using LLMs to score outputs against rubrics
- **Automated metrics:** Structured scoring systems
- **A/B testing:** Comparing agent variations
- **Logging and tracing:** Observability

**Implementation Pattern:**
```python
class LLMJudge:
    def judge(self, output: str) -> dict:
        prompt = f"{RUBRIC}\n\nOutput to evaluate:\n{output}"
        response = self.model.generate_content(
            prompt,
            generation_config={"response_mime_type": "application/json"}
        )
        return json.loads(response.text)
```

**When to Use:**
- Quality assurance pipelines
- Continuous improvement
- A/B testing agent variants
- Compliance verification

**Frameworks:** Custom with Gemini/OpenAI, LangSmith

---

## 20. Prioritization

**Category:** Task Management

**Description:**
Intelligent task prioritization and assignment based on urgency, complexity, and resources.

**Key Characteristics:**
- Task creation and tracking
- Priority assignment (P0, P1, P2)
- Worker assignment
- Status monitoring

**Implementation Pattern:**
```python
class TaskManager:
    def create_task(self, description: str) -> Task:
        task = Task(id=f"TASK-{self.next_id}", description=description)
        self.tasks[task.id] = task
        return task

    def update_task(self, task_id: str, priority: str, assigned_to: str):
        task = self.tasks.get(task_id)
        task.priority = priority
        task.assigned_to = assigned_to

# PM Agent with task tools
pm_agent = create_react_agent(llm, [
    create_task_tool,
    assign_priority_tool,
    assign_worker_tool
], pm_prompt)
```

**When to Use:**
- Project management automation
- Support ticket routing
- Workflow automation
- Resource allocation

**Frameworks:** LangChain ReAct agents, custom task systems

---

## 21. Exploration and Discovery

**Category:** Research Pattern

**Description:**
Multi-agent systems for autonomous research, experimentation, and discovery.

**Key Characteristics:**
- Multiple specialized research roles
- Iterative experimentation
- Review and critique cycles
- Report generation

**Implementation Pattern:**
```python
class ReviewersAgent:
    def inference(self, plan, report):
        # Multiple reviewers with different perspectives
        review_1 = get_score(plan, report, "experiments reviewer")
        review_2 = get_score(plan, report, "impact reviewer")
        review_3 = get_score(plan, report, "novelty reviewer")
        return combine_reviews(review_1, review_2, review_3)

class ProfessorAgent:
    def generate_readme(self):
        # Synthesize all knowledge into documentation
        return query_model(prompt_with_all_context)
```

**When to Use:**
- Automated research pipelines
- Scientific discovery
- Comprehensive literature review
- Hypothesis generation and testing

**Frameworks:** AgentLaboratory, custom multi-agent systems

---

## Quick Reference Matrix

| Pattern | Category | Complexity | Primary Use Case |
|---------|----------|------------|------------------|
| Prompt Chaining | Orchestration | Low | Sequential processing |
| Routing | Orchestration | Medium | Multi-domain systems |
| Parallelization | Orchestration | Medium | Latency optimization |
| Reflection | Quality | Medium | Self-improvement |
| Tool Use | Extension | Low | External access |
| Planning | Task Mgmt | Medium | Complex tasks |
| Multi-Agent | Architecture | High | Specialization |
| Memory | State | Medium | Context persistence |
| Adaptation | Learning | High | Self-optimization |
| MCP | Interop | Medium | Tool standardization |
| Goal Setting | Task Mgmt | Medium | Quality targets |
| Exception Handling | Reliability | Medium | Fault tolerance |
| Human-in-the-Loop | Safety | Low | Oversight |
| RAG | Knowledge | Medium | Document QA |
| A2A | Architecture | High | Agent interop |
| Resource Optimization | Efficiency | Medium | Cost control |
| Reasoning | Quality | Low | Accuracy |
| Guardrails | Safety | Medium | Validation |
| Evaluation | Quality | Medium | Monitoring |
| Prioritization | Task Mgmt | Medium | Workflow mgmt |
| Exploration | Research | High | Discovery |

---

*Reference: Based on "Agentic Design Patterns" source material*
