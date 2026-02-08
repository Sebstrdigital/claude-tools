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

**Agentic Design Patterns Toolkit**

| Command | Description |
|---------|-------------|
| `/patterns` | Diagnose problems and analyze architectures against 21 design patterns |
| `/agent-review` | Deep architecture review — scores patterns, scans anti-patterns, produces recommendations |
| `/agent-audit` | Quick 23-point pass/fail pre-deployment audit |

### Reference Docs

| Doc | Used By |
|-----|---------|
| `patterns-master-summary.md` | `/patterns`, `/agent-review`, `/agent-audit` |
| `patterns-selection-guide.md` | `/patterns`, `/agent-review` |
| `patterns-anti-patterns.md` | `/patterns`, `/agent-review`, `/agent-audit` |

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
│   └── agent-audit.md
├── docs/                           → ~/.claude/docs/
│   └── agentic-patterns/
│       ├── patterns-master-summary.md
│       ├── patterns-selection-guide.md
│       └── patterns-anti-patterns.md
├── install.sh
└── README.md
```

## Metadata

Every file includes YAML frontmatter with:
- `source_id: seb-claude-tools` — identifies files from this repo
- `version: 1.0.0` — tracks versions for safe updates
