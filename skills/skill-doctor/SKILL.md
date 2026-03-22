---
name: skill-doctor
description: >
  Use when auditing or improving a Claude Code skill. Triggers on:
  "audit skill", "evaluate skill", "review skill", "skill score",
  "skill health check", "improve skill", "does this skill follow best practices".
---

# /skill-doctor — Evaluate Skills Against Best Practices

Assess any Claude Code skill against the criteria from Anthropic's "Lessons from Building Claude Code: How We Use Skills." Produces a findings-first audit with actionable improvements and a supporting scorecard.

## Workflow

Use the bundled references intentionally:
- Read `references/category-taxonomy.md` when classifying the skill.
- Read `references/criteria.md` when rating criteria or deciding when to use **N/A**.
- Read `references/article-principles.md` only when you need the article's reasoning, not for every audit.

### 1. Discover — Identify the Target Skill

If the user specifies a skill name, locate it:
- Check `~/.claude/skills/{name}/`
- Check `./.claude/skills/{name}/`
- If ambiguous, use `AskUserQuestion` to clarify

If no skill is specified, ask the user which skill to audit.

### 2. Explore — Read Everything

Read **all** files in the skill directory, not just SKILL.md. The whole point of this audit is assessing folder structure, progressive disclosure, and supporting assets.

Take inventory:
- Main SKILL.md (frontmatter: name, description)
- Subdirectories (references/, scripts/, assets/, templates/, resources/)
- Config files (config.json, CLAUDE.json)
- Scripts (*.sh, *.py, *.js)
- Hook registrations
- Data/memory files

### 3. Classify — Determine Skill Category

Classify the skill into exactly one of the 9 categories. See `references/category-taxonomy.md` for definitions. If the skill straddles multiple categories, note this as a concern — the article warns that the most confusing skills straddle several.

### 4. Assess Complexity Fit — Is the Skill Right-Sized?

Determine whether the skill is **Minimal**, **Standard**, or **Rich** before you score it. See `references/criteria.md` for the tier definitions.

Mark inapplicable criteria as **N/A**. Do not punish a narrow skill for not having scripts, hooks, or storage it does not need.

### 5. Run Structural Signals

Run the checker after choosing a tier:

```bash
scripts/structural-check.sh --tier <minimal|standard|rich> <skill-path>
```

Treat the output as **signals**, not as the verdict. The script can catch stale structure, missing files, and weak descriptions, but it cannot decide whether the skill is over-engineered or under-specified on its own.

### 6. Evaluate — Write Findings

Find the material issues first. Use `references/criteria.md` as your internal checklist — do not output the criteria as a table.

For each finding:
- State the problem plainly.
- Cite file and line evidence.
- Explain why it matters in practice.
- Suggest the smallest high-leverage fix.

If there are no material findings, say so explicitly.

### 7. Verdict

Based on your findings, assign one verdict:

| Verdict | When to use |
|---------|-------------|
| **Strong** | No high-severity findings. The skill does what it sets out to do and follows the article's principles where they apply. |
| **Adequate** | Minor issues or missed opportunities, but functional and not misleading. |
| **Needs Work** | Material issues that would cause the skill to fail, mislead, or go unused in practice. |

A minimal skill with a great SKILL.md and clear triggers can be **Strong**. A rich skill missing gotchas and with broken scripts cannot.

### 8. Report

Output format:

```
## Skill Audit: {name}

### Findings
- [High] {material issue with file:line evidence and why it matters}
- [Medium] ...
- If there are no material findings, say that explicitly.

### Recommended Fixes
1. {smallest highest-leverage change}
2. ...
3. ...

### Strengths
- {2-3 bullets}

**Category**: {category} | **Tier**: {minimal|standard|rich} | **Verdict**: {Strong|Adequate|Needs Work}

### Structural Check
{output from scripts/structural-check.sh}
```

Lead with findings. A clear top-three list with evidence is more useful than any rating.

### 9. Improve Mode

If the user asks to improve the skill after the audit, patch the highest-leverage issues directly:
- Tighten the description before adding new files.
- Remove generic prose before adding more prose.
- Align scripts and hooks with the rubric before inventing new infrastructure.
- Add references, scripts, assets, config, hooks, or persistence only when they make the skill easier to use or more reliable.

After making changes, rerun the checker and summarize what materially improved.

### 10. Persist — Log the Evaluation

Append a one-line summary to the evaluations log:
```
echo "{date}|{skill-name}|{verdict}|{category}" >> "${CLAUDE_PLUGIN_DATA:-$HOME/.claude/skill-doctor-data}/evaluations.log"
```

This enables tracking improvement over time. If the skill was previously evaluated, note the change.

## Gotchas

Common mistakes when auditing skills:

- **Simplicity is not a deficiency.** A single SKILL.md with good content, clear triggers, and no unnecessary folders can be **Strong** if the skill's scope doesn't warrant more. Adding references/, scripts/, or hooks just to check boxes is over-engineering — the same anti-pattern the article warns against. Always assess complexity tier first.
- **Don't penalize reference skills for missing hooks/memory.** Not every skill needs every feature. Library/API Reference skills are often correctly stateless. Mark inapplicable criteria as N/A, not as a finding.
- **"Partial" is not "bad."** A partial gotchas section scattered through references is better than none. Note it as partial, not missing.
- **The verdict summarizes, it doesn't replace the findings.** If your findings point to issues but the overall impression seems fine, revisit the findings — don't just upgrade the verdict.
- **Check if referenced folders actually exist.** Some skills mention references/ or scripts/ in their SKILL.md but never created them. This is worse than not mentioning them at all.
- **Description length matters.** Over 300 chars in the description field gets truncated in skill listings. Aim for 150-250 chars of trigger conditions.
- **Don't conflate content quality with infrastructure quality.** A skill can have excellent content but poor tooling. Report both dimensions in your findings.
- **The article's categories aren't exhaustive.** Some skills (like pencil-design as a context-management wrapper) don't fit any category. That's fine — classify as "Meta/Other" and note it.
- **Beware of over-crediting folder structure.** Having a references/ folder with one file is barely progressive disclosure. Look for meaningful decomposition across 3+ files.

## Comparison Mode

If the user wants to compare two skills, evaluate both and present side-by-side:
- Same findings format for each
- Highlight where one outperforms the other
- Recommend which patterns the weaker skill should borrow

## Batch Mode

If the user wants to audit all skills, spawn one subagent per skill (using the Agent tool with subagent_type Explore) and compile results into a summary table sorted by verdict (Needs Work, Adequate, Strong). Write the full report to `~/.claude/skill-doctor-report.md`.
