#!/usr/bin/env bash
# structural-check.sh — Automated structural analysis of a Claude Code skill
# Usage: ./structural-check.sh [--tier minimal|standard|rich|auto] <path-to-skill-directory>

set -euo pipefail

usage() {
  echo "Usage: $0 [--tier minimal|standard|rich|auto] <skill-directory>" >&2
}

TIER="auto"
SKILL_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier)
      [[ $# -ge 2 ]] || {
        usage
        exit 1
      }
      TIER="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$SKILL_DIR" ]]; then
        SKILL_DIR="$1"
        shift
      else
        usage
        exit 1
      fi
      ;;
  esac
done

[[ -n "$SKILL_DIR" ]] || {
  usage
  exit 1
}

case "$TIER" in
  auto|minimal|standard|rich) ;;
  *)
    echo "ERROR: Invalid tier: $TIER" >&2
    usage
    exit 1
    ;;
esac

if [[ ! -d "$SKILL_DIR" ]]; then
  echo "ERROR: Directory not found: $SKILL_DIR"
  exit 1
fi

signal() {
  local level="$1"
  local message="$2"
  printf '[%s] %s\n' "$level" "$message"
}

SKILL_NAME=$(basename "$SKILL_DIR")
echo "=== Structural Check: $SKILL_NAME ==="
echo ""

# --- 1. SKILL.md existence and frontmatter ---
SKILL_FILE=""
for candidate in SKILL.md skill.md; do
  if [[ -f "$SKILL_DIR/$candidate" ]]; then
    SKILL_FILE="$SKILL_DIR/$candidate"
    break
  fi
done

if [[ -z "$SKILL_FILE" ]]; then
  echo "[FAIL] No SKILL.md found"
  exit 1
else
  echo "[PASS] SKILL.md exists"
fi

# --- 2. Frontmatter fields ---
if head -5 "$SKILL_FILE" | grep -q "^name:"; then
  echo "[PASS] Has 'name' field"
else
  echo "[FAIL] Missing 'name' field in frontmatter"
fi

DESC_LINE=$(grep -n "^description:" "$SKILL_FILE" | head -1)
if [[ -n "$DESC_LINE" ]]; then
  echo "[PASS] Has 'description' field"
  # Check description length (approximate)
  DESC_TEXT=$(sed -n '/^description:/,/^---$/p' "$SKILL_FILE" | grep -v "^---" | tr -d '\n')
  DESC_LEN=${#DESC_TEXT}
  if (( DESC_LEN > 300 )); then
    echo "[WARN] Description is ${DESC_LEN} chars (recommend <300 to avoid truncation)"
  elif (( DESC_LEN < 50 )); then
    echo "[WARN] Description is only ${DESC_LEN} chars (may undertrigger)"
  else
    echo "[INFO] Description length: ${DESC_LEN} chars"
  fi
else
  echo "[FAIL] Missing 'description' field in frontmatter"
fi

# --- 3. Trigger language in description ---
if grep -qi "triggers\?\s*on\|use when\|use this.*when" "$SKILL_FILE"; then
  echo "[PASS] Description uses trigger language"
else
  echo "[WARN] Description may read as summary — consider 'Use when...' or 'Triggers on:' phrasing"
fi

# --- 4. Folder structure ---
echo ""
echo "--- Folder Structure ---"

TOTAL_FILES=$(find "$SKILL_DIR" -type f | wc -l | tr -d ' ')
signal "INFO" "Total files: $TOTAL_FILES"

HAS_REFS=false
HAS_SCRIPTS=false
HAS_ASSETS=false
HAS_TEMPLATES=false
HAS_RESOURCES=false
HAS_CONFIG=false
HAS_HOOKS=false

for dir in references refs; do
  [[ -d "$SKILL_DIR/$dir" ]] && HAS_REFS=true
done
[[ -d "$SKILL_DIR/scripts" ]] && HAS_SCRIPTS=true
[[ -d "$SKILL_DIR/assets" ]] && HAS_ASSETS=true
[[ -d "$SKILL_DIR/templates" ]] && HAS_TEMPLATES=true
[[ -d "$SKILL_DIR/resources" ]] && HAS_RESOURCES=true
[[ -f "$SKILL_DIR/config.json" ]] && HAS_CONFIG=true
[[ -f "$SKILL_DIR/CLAUDE.json" ]] && HAS_HOOKS=true

# Count subdirectories with content
SUBDIR_COUNT=0
for sub in references refs scripts assets templates resources examples; do
  if [[ -d "$SKILL_DIR/$sub" ]] && [[ $(find "$SKILL_DIR/$sub" -type f | wc -l) -gt 0 ]]; then
    SUBDIR_COUNT=$((SUBDIR_COUNT + 1))
  fi
done

PERSISTENCE_FOUND=false
if find "$SKILL_DIR" -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.json" \) -print0 \
  | xargs -0 grep -qEi "CLAUDE_PLUGIN_DATA|evaluations\.[A-Za-z0-9]+|\.log|sqlite|persist|append.*log" 2>/dev/null; then
  PERSISTENCE_FOUND=true
fi

if [[ "$TIER" == "auto" ]]; then
  if (( SUBDIR_COUNT == 0 && TOTAL_FILES <= 2 )) && ! $HAS_HOOKS && ! $HAS_CONFIG; then
    TIER="minimal"
  elif $HAS_CONFIG || ( $HAS_HOOKS && $PERSISTENCE_FOUND ) || (( SUBDIR_COUNT >= 3 )); then
    TIER="rich"
  else
    TIER="standard"
  fi
  TIER_SOURCE="heuristic"
else
  TIER_SOURCE="supplied"
fi

signal "INFO" "Interpretation tier: $TIER ($TIER_SOURCE)"

case "$TIER" in
  minimal)
    $HAS_REFS && signal "INFO" "Has references/ directory; make sure the extra structure earns its keep for a minimal skill" \
      || signal "PASS" "No references/ directory; lean structure is fine for a minimal skill"
    $HAS_SCRIPTS && signal "INFO" "Has scripts/ directory; keep only if they save real repetition" \
      || signal "PASS" "No scripts/ directory; fine for a minimal skill"
    $HAS_RESOURCES && signal "INFO" "Has resources/ directory" || signal "INFO" "No resources/ directory"
    $HAS_ASSETS && signal "INFO" "Has assets/ directory" || true
    $HAS_TEMPLATES && signal "INFO" "Has templates/ directory" || true
    $HAS_CONFIG && signal "INFO" "Has config.json; keep it only if the skill truly needs setup state" \
      || signal "INFO" "No config.json; fine unless the skill needs persistent user-specific setup"
    $HAS_HOOKS && signal "INFO" "Has CLAUDE.json hooks; confirm they provide real leverage" \
      || signal "INFO" "No CLAUDE.json hooks; fine for a minimal skill"

    if (( SUBDIR_COUNT == 0 )); then
      signal "PASS" "Lean structure fits the minimal tier"
    elif (( SUBDIR_COUNT == 1 )); then
      signal "INFO" "One content subdirectory present; verify it adds value instead of ceremony"
    else
      signal "WARN" "Multiple content subdirectories may be over-engineering for a minimal skill"
    fi
    ;;
  standard)
    $HAS_REFS && signal "PASS" "Has references/ directory for on-demand detail" \
      || signal "WARN" "Standard skills usually need references/ to avoid a monolithic SKILL.md"
    $HAS_SCRIPTS && signal "INFO" "Has scripts/ directory; good if the scripts remove repeated work" \
      || signal "INFO" "No scripts/ directory; acceptable if the skill is mostly guidance"
    $HAS_RESOURCES && signal "INFO" "Has resources/ directory" || signal "INFO" "No resources/ directory"
    $HAS_ASSETS && signal "INFO" "Has assets/ directory" || true
    $HAS_TEMPLATES && signal "INFO" "Has templates/ directory" || true
    $HAS_CONFIG && signal "INFO" "Has config.json; keep setup lightweight" \
      || signal "INFO" "No config.json; fine unless the skill needs reusable setup"
    $HAS_HOOKS && signal "INFO" "Has CLAUDE.json hooks" \
      || signal "INFO" "No CLAUDE.json hooks; fine unless guardrails or telemetry would materially help"

    if $HAS_REFS || (( SUBDIR_COUNT >= 2 )); then
      signal "PASS" "Progressive disclosure is present"
    else
      signal "WARN" "Standard skills should usually break detailed content out of SKILL.md"
    fi
    ;;
  rich)
    $HAS_REFS && signal "PASS" "Has references/ directory" \
      || signal "WARN" "Rich skills usually need references/ for progressive disclosure"
    $HAS_SCRIPTS && signal "PASS" "Has scripts/ directory" \
      || signal "WARN" "Rich skills usually need reusable scripts or code"
    $HAS_RESOURCES && signal "INFO" "Has resources/ directory" || signal "INFO" "No resources/ directory"
    $HAS_ASSETS && signal "INFO" "Has assets/ directory" || true
    $HAS_TEMPLATES && signal "INFO" "Has templates/ directory" || true
    $HAS_CONFIG && signal "PASS" "Has config.json" \
      || signal "INFO" "No config.json; add it only if the skill needs persistent user-specific setup"
    $HAS_HOOKS && signal "PASS" "Has CLAUDE.json hooks" \
      || signal "INFO" "No CLAUDE.json hooks; fine unless the skill would benefit from guardrails or telemetry"

    if $HAS_REFS && $HAS_SCRIPTS && (( SUBDIR_COUNT >= 2 )); then
      signal "PASS" "Layered structure fits the rich tier"
    else
      signal "WARN" "Rich skills usually need stronger progressive disclosure and reusable resources"
    fi
    ;;
esac

# --- 5. Gotchas section ---
echo ""
echo "--- Content Checks ---"

if grep -qiE "^#{1,3}\s*(gotchas?|common\s*(mistakes?|failures?|pitfalls?|problems?)|anti.?patterns?|never\s*do|failure\s*modes?)" "$SKILL_FILE"; then
  echo "[PASS] Has gotchas/failure section in SKILL.md"
else
  # Check reference files too
  GOTCHA_IN_REFS=false
  while IFS= read -r -d '' f; do
    if grep -qiE "^#{1,3}\s*(gotchas?|common\s*(mistakes?|failures?|pitfalls?)|anti.?patterns?|failure\s*modes?)" "$f"; then
      GOTCHA_IN_REFS=true
      break
    fi
  done < <(find "$SKILL_DIR" -name "*.md" -not -name "SKILL.md" -print0 2>/dev/null)
  if $GOTCHA_IN_REFS; then
    echo "[PARTIAL] Gotchas found in reference files (not in main SKILL.md)"
  else
    echo "[MISS] No gotchas/failure section found anywhere"
  fi
fi

# --- 6. Script files ---
SCRIPT_COUNT=$(find "$SKILL_DIR" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \) | wc -l | tr -d ' ')
if (( SCRIPT_COUNT > 0 )); then
  signal "PASS" "Contains ${SCRIPT_COUNT} script file(s)"
else
  if [[ "$TIER" == "rich" ]]; then
    signal "WARN" "No script files (*.sh, *.py, *.js, *.ts); rich skills often benefit from reusable code"
  else
    signal "INFO" "No script files (*.sh, *.py, *.js, *.ts)"
  fi
fi

# --- 7. Code examples in markdown ---
CODE_BLOCKS=$(grep -c '```' "$SKILL_FILE" 2>/dev/null || echo 0)
CODE_BLOCKS=$((CODE_BLOCKS / 2))
signal "INFO" "${CODE_BLOCKS} code block(s) in SKILL.md"

# --- 8. Memory/persistence ---
if $PERSISTENCE_FOUND; then
  signal "PASS" "References or implements persistence"
else
  if [[ "$TIER" == "rich" ]]; then
    signal "INFO" "No persistence pattern found; only add it if the workflow benefits from history or state"
  else
    signal "INFO" "No persistence pattern found; stateless is fine when the skill does not need memory"
  fi
fi

# --- Summary ---
echo ""
echo "=== Summary ==="
echo "Skill: $SKILL_NAME"
echo "Tier: $TIER"
echo "Files: $TOTAL_FILES"
echo "Subdirectories with content: $SUBDIR_COUNT"
echo "Script files: $SCRIPT_COUNT"
echo "Code blocks in SKILL.md: $CODE_BLOCKS"
echo "Note: structural signals support the audit; they are not the final score."
