# Claude Tools

Custom agents, commands, and reference docs for [Claude Code](https://claude.ai/code) by [@Sebstrdigital](https://github.com/Sebstrdigital).

## What's Included

### Agents

| Agent | Description |
|-------|-------------|
| `seb-the-boss` | TDD engineer — writes failing tests first, implements minimal code, refactors. Includes quality checklist. |
| `nordic-ux-critic` | Scandinavian minimalist UI/UX critic. Applies Dieter Rams' principles and Nordic design tenets. |
| `test-agent` | QA specialist — runs test suites, analyzes coverage, generates missing tests, produces reports. |

### Commands

**Swiss Design UI Toolkit** (workflow: `/ui` or `/component` or `/page` → `/refine` → `/prd`)

| Command | Description |
|---------|-------------|
| `/ui` | Generate complete HTML+CSS pages in International Typographic Style |
| `/component` | Generate self-contained UI components (buttons, cards, modals, etc.) |
| `/page` | Generate full page layouts (landing, pricing, dashboard, blog, etc.) |
| `/refine` | Iterate on generated POCs until the design is approved |
| `/prd` | Convert approved UI POCs into implementation-ready Product Requirements Documents |

**UX Copy Toolkit** (workflow: `/product-context` → `/ux-audit` and/or `/brand-voice` → `/ux-copy`)

| Command | Description |
|---------|-------------|
| `/product-context` | Guided interview that captures product identity, value proposition, aha moment, and user journey |
| `/ux-audit` | Scans codebase for user-facing touchpoints, applies 7 UX frameworks (Fogg, JTBD, progressive disclosure, etc.), produces audit report with optional interactive visualization |
| `/brand-voice` | Guided interview that produces voice traits, tone map, customer language inventory, and competitive positioning |
| `/ux-copy` | Writes production-ready UX copy for every user-facing surface using microcopy frameworks (Three Cs, Grice's maxims, PAS, Yifrah) |

**Client Work**

| Command | Description |
|---------|-------------|
| `/client-proposal` | Generate client-facing proposals with built-in leak review — produces deliverables then runs an interactive checklist against internal leak rules before delivery |

**Debugging**

| Command | Description |
|---------|-------------|
| `/debug` | Debug session tracker — maintains a breadcrumb trail file so you can close sessions and resume without losing context |

**Harness Design Toolkit** (workflow: `/harness-interview` → `/harness-architect` → `/harness-spec` → `/harness-build` or takt)

| Command | Description |
|---------|-------------|
| `/harness-interview` | Guided interview capturing domain, systems, platform, autonomy, scale, and harness-type signals for designing an agentic harness |
| `/harness-architect` | Selects harness type (General Purpose, Specialized, Autonomous, Hierarchical, Multi-Agent, DAG), designs agent decomposition, orchestration, and tool map |
| `/harness-spec` | Generates implementation-ready specification — the fork point for `/harness-build` or `/feature` → `/sprint` → takt |
| `/harness-build` | Generates runnable scaffolding adapted to harness type × platform (Claude Code skills, LangGraph, CrewAI, custom) |
| `/harness-review` | Deep 28-point + type-specific review of harness implementations against the 6 harness patterns and anti-patterns |
| `/skill-review` | 22-point review of Claude Code skill files for format, interaction design, chain integration, and effectiveness |

**Agentic Design Patterns Toolkit**

| Command | Description |
|---------|-------------|
| `/patterns` | Diagnose problems and analyze architectures against 21 design patterns |
| `/agent-review` | Deep architecture review — scores patterns, scans anti-patterns, produces recommendations |
| `/agent-audit` | Quick 23-point pass/fail pre-deployment audit |

**Project Audit Suite** (workflow: `/project-audit` orchestrates all of the below in parallel)

| Command | Description |
|---------|-------------|
| `/project-audit` | Full audit orchestrator — detects agent pipeline, runs all applicable audits in parallel, produces `docs/audits/` with overview and optional interactive playground |
| `/security-audit` | 35-check security audit across 7 domains: auth, input validation, LLM-specific attacks, data access, API security, secrets, and infrastructure |
| `/data-integrity-audit` | 30-check audit of AI-generated query results — traces the full chain from user question to displayed answer and flags where correctness can break |
| `/infra-audit` | Interview-based infrastructure assessment — matches current setup against your scale targets, produces gap analysis and migration roadmap |
| `/code-review` | 25-check general code quality review across 5 domains: structure, naming, complexity, error handling, and type safety/testing |

### Reference Docs

| Doc | Used By |
|-----|---------|
| `patterns-master-summary.md` | `/patterns`, `/agent-review`, `/agent-audit`, `/harness-architect` |
| `patterns-selection-guide.md` | `/patterns`, `/agent-review`, `/harness-architect` |
| `patterns-anti-patterns.md` | `/patterns`, `/agent-review`, `/agent-audit`, `/harness-architect` |
| `harness-types.md` | `/harness-architect`, `/harness-review` |
| `harness-selection-guide.md` | `/harness-architect`, `/harness-review` |
| `skill-authoring-guide.md` | `/harness-build`, `/skill-review` |

## Installation

```bash
git clone git@github.com:Sebstrdigital/claude-tools.git
cd claude-tools
./install.sh
```

The installer copies files into `~/.claude/` (agents, commands, and docs).

**Safe install behavior:**
- If a file with the same name already exists and came from this repo (`source_id: seb-claude-tools`), it gets **updated** with version tracking
- If a file with the same name exists but belongs to something else, it installs with a `sebstrdigital-` prefix to avoid conflicts
- If no conflict, it installs directly

After installing, restart Claude Code to pick up changes.

## Updating

Pull the latest and re-run the installer:

```bash
cd claude-tools
git pull
./install.sh
```

The installer shows version changes (e.g., `v1.0.0 → v1.1.0`) and skips files that are already up to date.

## File Structure

```
claude-tools/
├── agents/                         → ~/.claude/agents/
│   ├── seb-the-boss.md
│   ├── nordic-ux-critic.md
│   └── test-agent.md
├── commands/                       → ~/.claude/commands/
│   ├── ui.md
│   ├── component.md
│   ├── page.md
│   ├── refine.md
│   ├── prd.md
│   ├── patterns.md
│   ├── agent-review.md
│   ├── agent-audit.md
│   ├── project-audit.md
│   ├── security-audit.md
│   ├── data-integrity-audit.md
│   ├── infra-audit.md
│   ├── code-review.md
│   ├── client-proposal.md
│   ├── debug.md
│   ├── product-context.md
│   ├── ux-audit.md
│   ├── brand-voice.md
│   ├── ux-copy.md
│   ├── harness-interview.md
│   ├── harness-architect.md
│   ├── harness-spec.md
│   ├── harness-build.md
│   ├── harness-review.md
│   └── skill-review.md
├── docs/                           → ~/.claude/docs/
│   ├── agentic-patterns/
│   │   ├── patterns-master-summary.md
│   │   ├── patterns-selection-guide.md
│   │   └── patterns-anti-patterns.md
│   ├── harness-patterns/
│   │   ├── harness-types.md
│   │   └── harness-selection-guide.md
│   └── skill-authoring-guide.md
├── install.sh
└── README.md
```

## Metadata

Every file includes YAML frontmatter with:
- `source_id: seb-claude-tools` — identifies files from this repo
- `version: 1.0.0` — tracks versions for safe updates

## License

[MIT](LICENSE)
