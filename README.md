# Skill Doctor

**Diagnose, evaluate, and fix your Claude Code skills.**

[![GitHub stars](https://img.shields.io/github/stars/JoaquinCampo/skill-doctor?style=flat&color=yellow)](https://github.com/JoaquinCampo/skill-doctor/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/JoaquinCampo/skill-doctor?style=flat&color=blue)](https://github.com/JoaquinCampo/skill-doctor/network/members)
[![Last commit](https://img.shields.io/github/last-commit/JoaquinCampo/skill-doctor?color=green)](https://github.com/JoaquinCampo/skill-doctor/commits)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## The Problem

Writing a Claude Code skill is easy. Writing a **good** one is not.

Thariq Shihipar published ["Lessons from Building Claude Code: How We Use Skills"](https://x.com/trq212/status/2033949937936085378) with 8 concrete tips for effective skills, gotchas sections, progressive disclosure, trigger-optimized descriptions, reusable scripts, and more.

Manually checking your skill against all 8 criteria is tedious.

Skill Doctor is a Claude Code plugin that automates it:

- **Audit** — Evaluate any skill against 9 criteria derived from the article. Get findings-first reports with file:line evidence, not just a verdict.

## Install

**Step 1 — Register the marketplace:**

```bash
/plugin marketplace add JoaquinCampo/skill-doctor
```

**Step 2 — Install the plugin:**

```bash
/plugin install skill-doctor@skill-doctor-marketplace
```

**Step 3 — Restart Claude Code.**

That's it. The `/skill-doctor` skill is now available for auditing and improving skills.

## What It Does

### Audit Mode

Run `/skill-doctor` and point it at any skill. It will:

1. **Discover** the skill directory (local or global)
2. **Explore** every file — SKILL.md, references/, scripts/, config, hooks
3. **Classify** into one of 9 categories (Library Reference, Product Verification, Runbook, etc.)
4. **Assess tier** — Minimal, Standard, or Rich — so it doesn't penalize simple skills for missing features they don't need
5. **Run structural checks** via a bundled bash script
6. **Evaluate** against 9 criteria and produce a findings-first report with a verdict

### Criteria

| # | Criterion | What it checks |
|---|-----------|----------------|
| 1 | Avoids stating the obvious | Does content push Claude beyond defaults? |
| 2 | Has Gotchas section | Are common failure points documented? |
| 3 | Uses progressive disclosure | Does folder structure spread context? |
| 4 | Avoids railroading | Is it flexible for varied situations? |
| 5 | Description optimized for triggering | Trigger conditions, not summary? |
| 6 | Setup/config pattern | Graceful first-time onboarding? |
| 7 | Includes scripts/code | Reusable scripts or libraries? |
| 8 | On-demand hooks | Session-scoped hooks registered? |
| 9 | Memory/data storage | Persists data between runs? |

Inapplicable criteria are marked **N/A** and skipped. A minimal skill with excellent content can be **Strong**.

### Verdicts

| Verdict | Meaning |
|---------|---------|
| **Strong** | No high-severity findings. Follows the article's principles where they apply. |
| **Adequate** | Minor issues or missed opportunities, but functional and not misleading. |
| **Needs Work** | Material issues that would cause the skill to fail, mislead, or go unused. |

## Contributing

```bash
git clone https://github.com/JoaquinCampo/skill-doctor.git
cd skill-doctor
```

Issues and PRs welcome. If you find a criterion that doesn't match real-world skill quality, open an issue — the rubric should evolve with the ecosystem.