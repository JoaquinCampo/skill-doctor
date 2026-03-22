# Evaluation Criteria — Internal Checklist

Use these criteria to guide your evaluation. For each one, assess whether the skill meets it — this informs what to include in your findings, not what to output as a table.

## Complexity Tier (assess FIRST)

Not every skill needs every feature. Determine the tier before evaluating.

| Tier | When appropriate | Expected structure |
|------|------------------|--------------------|
| **Minimal** | Narrow scope, <100 lines of useful content, simple reference or guidance | SKILL.md only. Folders would be over-engineering. |
| **Standard** | Library/API reference, multiple subtopics, moderate complexity | SKILL.md + references/. Gotchas section expected. |
| **Rich** | Workflow automation, verification, multi-step processes, data fetching | Full structure: references/, scripts/, config, possibly hooks + memory. |

**Mark inapplicable criteria as N/A — skip them in your assessment.** A minimal skill with excellent content and triggers can be **Strong**.

---

## 1. Avoids Stating the Obvious

Claude already knows how to code. The skill should teach what Claude gets wrong or doesn't know.

| Rating | Definition |
|--------|-----------|
| YES | Content focuses on non-obvious patterns, edge cases, or domain-specific knowledge that pushes Claude beyond defaults |
| PARTIAL | Mix of useful insights and generic information Claude already knows |
| NO | Mostly restates what Claude would do anyway; reads like a tutorial |

**What to look for:**
- Anti-patterns specific to this domain
- "Don't do X because Y" where Y is non-obvious
- Internal conventions or library quirks
- Information that corrects Claude's default behavior

---

## 2. Has Gotchas Section

The article calls this "the highest-signal content in any skill."

| Rating | Definition |
|--------|-----------|
| YES | Dedicated section documenting 3+ common failure points with symptoms and fixes |
| PARTIAL | Warnings scattered throughout but not consolidated; or fewer than 3 gotchas |
| NO | No failure points documented anywhere |

**What to look for:**
- Explicit `## Gotchas` or `## Common Mistakes` heading
- Real failure scenarios, not hypothetical ones
- Error messages, symptoms, root causes
- Built from experience, not speculation

---

## 3. Uses Progressive Disclosure

"A skill is a folder, not just a markdown file." The file system is a form of context engineering.

| Rating | Definition |
|--------|-----------|
| YES | 3+ files across meaningful subdirectories (references/, scripts/, assets/); SKILL.md points to them; Claude can discover content on-demand |
| PARTIAL | Some folder structure (1-2 extra files or a single subfolder), or files exist but SKILL.md doesn't reference them |
| NO | Single SKILL.md file with no supporting structure |

**What to look for:**
- references/ with topic-specific deep dives
- scripts/ with reusable utilities
- assets/ or templates/ with copy-ready materials
- SKILL.md acting as an index/router, not a monolith

---

## 4. Avoids Railroading

Give Claude information, not railroad tracks. Skills are reusable — rigidity breaks in unexpected contexts.

| Rating | Definition |
|--------|-----------|
| YES | Multiple approaches presented; Claude can adapt to context; "prefer X" not "always X" |
| PARTIAL | Generally flexible but some overly prescriptive sections |
| NO | Single rigid workflow with no escape hatches |

**What to look for:**
- Decision trees with branches, not linear steps
- "When X, consider Y" language
- Alternative approaches for different contexts
- Absence of absolute mandates where flexibility is needed

---

## 5. Description Optimized for Triggering

The description field is what Claude scans to decide "should I use this skill?" It's trigger conditions, not a summary.

| Rating | Definition |
|--------|-----------|
| YES | Written as activation conditions: "Use when...", "Triggers on: [specific keywords]", concrete phrases Claude matches against |
| PARTIAL | Mix of trigger language and summary; or good keywords but reads as a feature list |
| NO | Pure summary ("This skill covers X, Y, Z") with no trigger conditions |

**What to look for:**
- "Use when", "Triggers on", "Use this skill whenever"
- Specific file patterns, import names, error signatures
- User intent phrases ("debug", "fix", "create", "review")
- Length: 150-250 chars is ideal; >300 risks truncation

---

## 6. Setup/Config Pattern

Some skills need user-specific context. The article recommends config.json + AskUserQuestion.

| Rating | Definition |
|--------|-----------|
| YES | config.json or equivalent for storing preferences; graceful first-time setup; AskUserQuestion for missing config |
| PARTIAL | Some setup handling (install checks, env var detection) but no persistent config |
| NO | Assumes everything is ready; no onboarding flow |

**Note:** Not all skills need this. Library/API Reference skills that are purely informational don't need setup — mark as N/A, not as a finding.

---

## 7. Includes Scripts/Code

Giving Claude code > giving Claude instructions to write code. Scripts let Claude compose instead of reconstruct.

| Rating | Definition |
|--------|-----------|
| YES | Reusable scripts (*.sh, *.py, *.js) or libraries in scripts/ or resources/; Claude can execute or import them |
| PARTIAL | Code examples throughout that are copy-paste-ready, but no standalone scripts |
| NO | Instructions only; no executable code provided |

**What to look for:**
- scripts/ directory with executable utilities
- resources/ with importable modules (like metrics.py)
- Helper functions Claude can compose
- Templates in assets/ that can be copied

---

## 8. On-Demand Hooks

Skills can register session-scoped hooks that activate when the skill is called. These are powerful guardrails.

| Rating | Definition |
|--------|-----------|
| YES | Registers PreToolUse/PostToolUse hooks via CLAUDE.json; session-scoped behavior |
| PARTIAL | Mentions hook-like behavior in instructions but doesn't register actual hooks |
| NO | No hooks of any kind |

**Examples from the article:**
- `/careful` — blocks destructive commands via PreToolUse
- `/freeze` — blocks edits outside a specific directory

---

## 9. Memory/Data Storage

Skills can persist data between runs using files, JSON, or SQLite in `${CLAUDE_PLUGIN_DATA}`.

| Rating | Definition |
|--------|-----------|
| YES | Writes/reads persistent state (logs, JSON, SQLite) in a stable location |
| PARTIAL | Some caching or state files, but not systematic |
| NO | Completely stateless between invocations |

**What to look for:**
- Use of `${CLAUDE_PLUGIN_DATA}` for stable storage
- Append-only logs (like standups.log)
- JSON/SQLite for structured state
- History that informs future invocations
