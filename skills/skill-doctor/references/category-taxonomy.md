# Skill Category Taxonomy

From "Lessons from Building Claude Code: How We Use Skills" (Anthropic).

The best skills fit cleanly into one category. Skills that straddle several tend to be confusing.

---

## 1. Library & API Reference

Skills that explain how to correctly use a library, CLI, or SDK. Can be internal or external libraries that Claude sometimes has trouble with.

**Signals:** reference code snippets, gotcha lists, API patterns, anti-patterns
**Examples:** billing-lib, internal-platform-cli, frontend-design, pydantic, go

---

## 2. Product Verification

Skills that describe how to test or verify that code is working. Often paired with external tools (Playwright, tmux, etc.).

**Signals:** test scripts, assertion steps, headless browser workflows, video recording
**Examples:** signup-flow-driver, checkout-verifier, tmux-cli-driver, agent-browser

---

## 3. Data Fetching & Analysis

Skills that connect to data and monitoring stacks. May include credential helpers, dashboard IDs, query patterns.

**Signals:** SQL/query patterns, dashboard references, data source helpers, analysis workflows
**Examples:** funnel-query, cohort-compare, grafana, wandb-plot

---

## 4. Business Process & Team Automation

Skills that automate repetitive workflows into one command. Often simple instructions but complex dependencies on other skills/MCPs.

**Signals:** multi-step workflows, log file persistence, Slack/ticket integration, formatted outputs
**Examples:** standup-post, create-ticket, weekly-recap, trip-planner

---

## 5. Code Scaffolding & Templates

Skills that generate framework boilerplate. Useful when scaffolding has natural language requirements beyond pure code.

**Signals:** template files, directory generators, create-X workflows, annotation helpers
**Examples:** new-workflow, new-migration, create-app, pento-blog-writer, theme-factory

---

## 6. Code Quality & Review

Skills that enforce code quality and help review code. May include deterministic scripts for robustness. Can run in hooks or GitHub Actions.

**Signals:** review checklists, severity taxonomies, subagent critique patterns, style enforcement
**Examples:** adversarial-review, code-style, testing-practices, pr-review, **skill-doctor**

---

## 7. CI/CD & Deployment

Skills that help fetch, push, and deploy code. May reference other skills to collect data.

**Signals:** PR monitoring, deployment pipelines, rollback logic, merge conflict resolution
**Examples:** babysit-pr, deploy-service, cherry-pick-prod

---

## 8. Runbooks

Skills that take a symptom and walk through multi-tool investigation to produce a structured report.

**Signals:** symptom → tool → query mapping, alert processing, log correlation, incident reports
**Examples:** service-debugging, oncall-runner, log-correlator

---

## 9. Infrastructure Operations

Skills for routine maintenance and operational procedures, including destructive actions with guardrails.

**Signals:** cleanup scripts, soak periods, user confirmations, cost analysis, dependency audits
**Examples:** resource-orphans, dependency-management, cost-investigation

---

## Meta / Other

Skills that don't fit the above categories (e.g., context-management wrappers, meta-tooling). Note this in the audit but don't penalize for it.
