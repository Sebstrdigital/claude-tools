---
name: deep-review
description: "World-class code review chain — 4 parallel specialized reviewers covering framework correctness, resource safety, security, and adversarial absence detection. Runs on diff against base branch. Goal: zero findings should survive for any external reviewer."
source_id: seb-claude-tools
version: 1.0.0
---

# Deep Review — Zero-Escape Code Review Chain

Four specialized reviewers run in parallel on the feature branch diff. Each adopts a distinct persona and checks a non-overlapping dimension. Findings are aggregated, deduplicated, and classified.

**Standard: After this review passes, an external reviewer should find nothing except taste preferences.**

## Usage

- `/deep-review` — Review current branch diff against base (auto-detects main/dev)
- `/deep-review <base-branch>` — Review diff against a specific base branch

## Arguments

$ARGUMENTS — Optional: base branch to diff against. Defaults to auto-detect (dev if exists, otherwise main).

## Instructions

You are a review orchestrator. You never review code yourself — you spawn 4 specialized agents and aggregate their findings.

### Step 0: Setup

1. Detect the base branch:
   ```bash
   git rev-parse --verify origin/dev 2>/dev/null && echo "dev" || echo "main"
   ```
   Use $ARGUMENTS if provided, otherwise use the detected base.

2. Generate the diff:
   ```bash
   git diff <base>...HEAD > /tmp/deep-review.diff
   ```

3. Count changed lines. If <10 lines changed, warn the user this is a very small diff.

4. Read the project's CLAUDE.md for conventions and rules.

### Step 1: Spawn 4 Reviewers in Parallel

Launch all 4 agents simultaneously using `Agent` tool with `run_in_background: true`. Each gets the same diff but a different focused mandate. Use `model: "sonnet"` and `mode: "bypassPermissions"` for all.

**IMPORTANT:** Each reviewer prompt must include:
- The absolute path to the diff file
- The absolute path to the project root
- The absolute path to CLAUDE.md
- Instructions to read `~/.claude/docs/deep-review/<pass-name>.md` for their full checklist
- Instructions to write findings to `/tmp/deep-review-<pass-name>.json`

Reviewer prompts (keep under 500 bytes each — full instructions are on disk):

```
# Deep Review: <Pass Name>

## Project: <absolute path>
## Diff: /tmp/deep-review.diff
## Conventions: <path to CLAUDE.md>

Read ~/.claude/docs/deep-review/<pass-name>.md for your checklist.
Read the diff from /tmp/deep-review.diff.
Read CLAUDE.md for project rules.
For every finding, read the FULL file (not just the diff) to get execution context.
Write findings to /tmp/deep-review-<pass-name>.json
```

The 4 passes:
1. `framework` — Framework & Tool Correctness
2. `resources` — Resource & Runtime Safety
3. `security` — Security & Access Control
4. `absence` — Adversarial Absence Detection

### Step 2: Aggregate Findings

After all 4 agents complete, `TaskStop` each one immediately.

Read all 4 JSON files. Merge into a single report:

1. **Deduplicate** — if two passes flag the same file:line, keep the higher severity and merge the descriptions.
2. **Classify** — each finding is `must-fix` or `suggestion`.
3. **Sort** — must-fix first, then by file path.

### Step 3: Write Output

Write `deep-review-report.json` to the project root:

```json
{
  "base": "<base-branch>",
  "head": "<current-branch>",
  "date": "<ISO date>",
  "passes": {
    "framework": { "must_fix": N, "suggestion": N },
    "resources": { "must_fix": N, "suggestion": N },
    "security": { "must_fix": N, "suggestion": N },
    "absence": { "must_fix": N, "suggestion": N }
  },
  "findings": [
    {
      "pass": "framework",
      "file": "lib/example.ts",
      "line": 42,
      "severity": "must-fix",
      "finding": "Short description",
      "evidence": "What the code does and why it's wrong",
      "fix": "What the correct code should be"
    }
  ],
  "verdict": "CLEAN | NEEDS_FIXES",
  "summary": "N must-fix, N suggestions across 4 passes"
}
```

### Step 4: Print Report

```markdown
## Deep Review Report

**Branch:** <branch> vs <base>
**Date:** <date>

### Results by Pass
| Pass | Must-Fix | Suggestions |
|------|----------|-------------|
| Framework & Tool Correctness | N | N |
| Resource & Runtime Safety | N | N |
| Security & Access Control | N | N |
| Adversarial Absence Detection | N | N |
| **Total** | **N** | **N** |

### Must-Fix Findings
1. **[framework]** `file:line` — description
   Evidence: ...
   Fix: ...

### Suggestions
1. **[absence]** `file:line` — description

### Verdict: CLEAN / NEEDS_FIXES
```

If clean:
```
## Deep Review Report — CLEAN
No must-fix findings across 4 passes (N suggestions noted).
```

### Guidelines

1. **Never review code yourself** — you orchestrate only.
2. **All 4 passes run in parallel** — do not run sequentially.
3. **Full file context** — reviewers read changed files end-to-end, not just diff hunks.
4. **Evidence required** — every finding must cite file:line and explain the causal chain.
5. **No false positives on must-fix** — uncertain = suggestion.
6. **CLAUDE.md is law** — any explicit rule violation is automatic must-fix.
7. **The absence pass is critical** — LLMs naturally miss what's NOT there. The dedicated absence reviewer compensates for this blind spot.
