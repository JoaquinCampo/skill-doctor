# Distilled Principles from the Article

Key lessons from "Lessons from Building Claude Code: How We Use Skills" for quick reference during audits.

Source:
- Thariq Shihipar
- X thread: https://x.com/trq212/status/2033949937936085378

---

## Core Philosophy

> "The most interesting part of skills is that they're not just text files. They're folders that can include scripts, assets, data, etc."

A skill = a folder, not a markdown file. Think of the entire file system as context engineering and progressive disclosure.

---

## The 8 Skill-Writing Tips (ranked by impact)

### 1. Build a Gotchas Section
- "The highest-signal content in any skill"
- Built from real failure points, not speculation
- Update over time as Claude hits new edge cases

### 2. Use the File System & Progressive Disclosure
- Tell Claude what files are in your skill; it reads them at appropriate times
- Split detailed signatures/examples into references/api.md
- Include template files in assets/ for copying
- Have folders of references, scripts, examples

### 3. Don't State the Obvious
- Focus on information that pushes Claude out of its normal way of thinking
- Avoid restating what Claude already knows about coding
- Example: frontend-design avoids Inter font and purple gradients

### 4. The Description Field Is For the Model
- Claude scans descriptions to decide "is there a skill for this request?"
- Write trigger conditions, not a summary
- This is the skill's activation function

### 5. Store Scripts & Generate Code
- "One of the most powerful tools you can give Claude is code"
- Scripts let Claude spend turns on composition, not reconstructing boilerplate
- Libraries of helper functions > instructions to write helper functions

### 6. Avoid Railroading Claude
- Be careful of being too specific in instructions
- Give information + flexibility to adapt
- Skills are reusable — rigidity breaks in unexpected contexts

### 7. Think Through the Setup
- Store setup info in config.json in the skill directory
- If config not set up, ask the user (AskUserQuestion tool)
- Graceful first-time experience

### 8. On-Demand Hooks
- Hooks activated only when the skill is called
- Last for the duration of the session
- Use for opinionated guardrails you don't want always-on
- Examples: /careful blocks dangerous commands, /freeze blocks edits outside a directory

---

## Distribution & Lifecycle

- **Small teams**: check skills into repo under ./.claude/skills
- **At scale**: internal plugin marketplace lets teams choose what to install
- **Curation matters**: easy to create bad or redundant skills
- **Compose skills**: reference other skills by name; model invokes if installed
- **Measure skills**: PreToolUse hook to log usage; find undertriggering skills

---

## Memory Pattern

- Store data in anything from text logs to SQLite
- Example: standup-post keeps standups.log of every post
- Data in skill directory may be deleted on upgrade → use `${CLAUDE_PLUGIN_DATA}` for stable storage
