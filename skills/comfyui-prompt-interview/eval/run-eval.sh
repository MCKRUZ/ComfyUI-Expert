#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════
# Skill Eval Runner — Shared Template v2.0
# ═══════════════════════════════════════════════════════════════════════
# Runs test cases against a skill and captures results for scoring.
# Copy this file into any skill's eval/ directory and set SKILL_NAME.
#
# Usage:
#   bash eval/run-eval.sh                  # Full run (with-skill + baseline)
#   bash eval/run-eval.sh --skill-only     # Skip baseline comparison
#   bash eval/run-eval.sh --case TC-001    # Single test case
#   bash eval/run-eval.sh --baseline-only  # Baseline only (no skill)
#   bash eval/run-eval.sh --score-only     # Score existing results (no new runs)
#
# Assertion types supported:
#   contains(target)         — response includes target (case-insensitive)
#   not_contains(target)     — response does NOT include target
#   regex(pattern)           — response matches extended regex
#   question_before_code     — a "?" appears before first ``` fence
#   json_valid               — response has a parseable JSON block
#   json_fields(f1,f2,...)   — JSON block contains required field names
#   token_limit(N)           — response under ~N tokens (estimated from words)
#   range_check(expr)        — evaluates numeric expression on JSON output
#   word_count(field,min,max)— checks word count of a JSON field
# ═══════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULTS_DIR="$SCRIPT_DIR/results/$TIMESTAMP"

# ── CONFIGURE THIS ──────────────────────────────────────────────────
# Override by setting SKILL_NAME env var or editing this default.
SKILL_NAME="${SKILL_NAME:-$(basename "$PROJECT_DIR")}"
# ────────────────────────────────────────────────────────────────────

# Parse args
RUN_SKILL=true
RUN_BASELINE=true
SCORE_ONLY=false
SINGLE_CASE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill-only)    RUN_BASELINE=false; shift ;;
    --baseline-only) RUN_SKILL=false; shift ;;
    --score-only)    SCORE_ONLY=true; shift ;;
    --case)          SINGLE_CASE="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

mkdir -p "$RESULTS_DIR/with-skill" "$RESULTS_DIR/baseline" "$RESULTS_DIR/prompts"

echo "=== Skill Eval Runner v2.0 ==="
echo "Skill:     $SKILL_NAME"
echo "Timestamp: $TIMESTAMP"
echo "Results:   $RESULTS_DIR"
echo ""

# ─── Extract test cases from YAML ──────────────────────────────────

extract_cases() {
  local yaml_file="$SCRIPT_DIR/test-cases.yaml"
  local current_id=""
  local current_prompt=""
  local in_prompt=false
  local ids=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^-\ id:\ (.+) ]]; then
      if [[ -n "$current_id" ]]; then
        ids+=("$current_id")
        printf '%s' "$current_prompt" > "$RESULTS_DIR/prompts/${current_id}.txt"
      fi
      current_id="${BASH_REMATCH[1]}"
      current_prompt=""
      in_prompt=false
    fi

    if [[ "$line" =~ ^\ \ prompt:\ \"(.+)\"$ ]]; then
      current_prompt="${BASH_REMATCH[1]}"
      in_prompt=false
    fi

    if [[ "$line" =~ ^\ \ prompt:\ [\|>]$ ]]; then
      in_prompt=true
      current_prompt=""
      continue
    fi

    if $in_prompt; then
      if [[ "$line" =~ ^\ \ [a-z] && ! "$line" =~ ^\ \ \ \  ]]; then
        in_prompt=false
      else
        local stripped="${line#    }"
        current_prompt+="${stripped}"$'\n'
      fi
    fi
  done < "$yaml_file"

  if [[ -n "$current_id" ]]; then
    ids+=("$current_id")
    printf '%s' "$current_prompt" > "$RESULTS_DIR/prompts/${current_id}.txt"
  fi

  echo "${ids[@]}"
}

CASE_IDS=($(extract_cases))
echo "Found ${#CASE_IDS[@]} test cases: ${CASE_IDS[*]}"

if [[ -n "$SINGLE_CASE" ]]; then
  CASE_IDS=("$SINGLE_CASE")
  echo "Filtering to: $SINGLE_CASE"
fi
echo ""

# ─── Run test cases ────────────────────────────────────────────────

run_case() {
  local case_id="$1"
  local mode="$2"
  local prompt_file="$RESULTS_DIR/prompts/${case_id}.txt"
  local output_file="$RESULTS_DIR/$mode/${case_id}.md"
  local prompt_text
  prompt_text=$(cat "$prompt_file")

  echo "  [$mode] Running $case_id..."

  if [[ "$mode" == "with-skill" ]]; then
    local full_prompt="Use the $SKILL_NAME skill to answer this: $prompt_text"
    claude -p "$full_prompt" \
      --allowedTools "Read,Glob,Grep" \
      --max-turns 3 \
      --output-format text \
      > "$output_file" 2>/dev/null || {
        echo "EVAL_ERROR: claude command failed for $case_id ($mode)" > "$output_file"
      }
  else
    claude -p "$prompt_text" \
      --allowedTools "Read,Glob,Grep" \
      --max-turns 3 \
      --output-format text \
      > "$output_file" 2>/dev/null || {
        echo "EVAL_ERROR: claude command failed for $case_id ($mode)" > "$output_file"
      }
  fi

  local wc_out
  wc_out=$(wc -w < "$output_file" | tr -d ' ')
  echo "  [$mode] $case_id complete ($wc_out words)"
}

if ! $SCORE_ONLY; then
  if $RUN_SKILL; then
    echo "── With Skill ──"
    for case_id in "${CASE_IDS[@]}"; do
      run_case "$case_id" "with-skill"
    done
    echo ""
  fi

  if $RUN_BASELINE; then
    echo "── Baseline (no skill) ──"
    for case_id in "${CASE_IDS[@]}"; do
      run_case "$case_id" "baseline"
    done
    echo ""
  fi
fi

# ─── Assertion evaluation helpers ──────────────────────────────────

# Extract first JSON block from response
extract_json() {
  local text="$1"
  # Try ```json fenced block first
  local block
  block=$(echo "$text" | sed -n '/```json/,/```/p' | sed '1d;$d')
  if [[ -z "$block" ]]; then
    # Try bare { ... } block
    block=$(echo "$text" | grep -Pzo '\{[^{}]*(\{[^{}]*\}[^{}]*)*\}' 2>/dev/null | head -1 || true)
  fi
  echo "$block"
}

# Get a field value from JSON (uses python if available, else node)
json_field() {
  local json="$1"
  local field="$2"
  if command -v python3 &>/dev/null; then
    echo "$json" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    v = d.get('$field', '')
    if isinstance(v, list): print(len(v))
    elif isinstance(v, (int, float)): print(v)
    else: print(v)
except: print('')
" 2>/dev/null
  elif command -v node &>/dev/null; then
    echo "$json" | node -e "
let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
  try{const o=JSON.parse(d);const v=o['$field'];
  if(Array.isArray(v))console.log(v.length);
  else console.log(v??'');}catch(e){console.log('');}
})" 2>/dev/null
  else
    echo ""
  fi
}

# Word count of a string
word_count() {
  echo "$1" | wc -w | tr -d ' '
}

# ─── Score a single assertion ──────────────────────────────────────

eval_assertion() {
  local response="$1"
  local atype="$2"
  local target="$3"
  local json_block="$4"

  case "$atype" in
    contains)
      echo "$response" | grep -qi "$target" && echo "PASS" || echo "FAIL"
      ;;

    not_contains)
      # Handle descriptive targets: if target contains spaces and "should not contain",
      # try to extract the quoted literal(s)
      if [[ "$target" =~ \'([^\']+)\' ]]; then
        local found=false
        while [[ "$target" =~ \'([^\']+)\' ]]; do
          local literal="${BASH_REMATCH[1]}"
          if echo "$response" | grep -qi "$literal"; then
            found=true
            break
          fi
          target="${target#*"'${literal}'"}"
        done
        $found && echo "FAIL" || echo "PASS"
      else
        echo "$response" | grep -qi "$target" && echo "FAIL" || echo "PASS"
      fi
      ;;

    regex)
      echo "$response" | grep -qiE "$target" && echo "PASS" || echo "FAIL"
      ;;

    question_before_code)
      local q_line code_line
      q_line=$(echo "$response" | grep -n '?' | head -1 | cut -d: -f1)
      code_line=$(echo "$response" | grep -n '```' | head -1 | cut -d: -f1)
      if [[ -z "$code_line" ]] || [[ -n "$q_line" && "$q_line" -lt "$code_line" ]]; then
        echo "PASS"
      else
        echo "FAIL"
      fi
      ;;

    json_valid)
      if [[ -n "$json_block" ]]; then
        if command -v python3 &>/dev/null; then
          echo "$json_block" | python3 -c "import sys,json;json.load(sys.stdin)" 2>/dev/null && echo "PASS" || echo "FAIL"
        elif command -v node &>/dev/null; then
          echo "$json_block" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{JSON.parse(d);console.log('PASS')}catch(e){console.log('FAIL')}})" 2>/dev/null
        else
          echo "SKIP"
        fi
      else
        echo "FAIL"
      fi
      ;;

    json_schema|json_fields)
      # Target is comma-separated field names
      if [[ -z "$json_block" ]]; then
        echo "FAIL"
        return
      fi
      local all_found=true
      IFS=',' read -ra FIELDS <<< "$target"
      for field in "${FIELDS[@]}"; do
        field=$(echo "$field" | xargs)  # trim whitespace
        if ! echo "$json_block" | grep -q "\"$field\""; then
          all_found=false
          break
        fi
      done
      $all_found && echo "PASS" || echo "FAIL"
      ;;

    token_limit)
      local wc
      wc=$(word_count "$response")
      local est_tokens=$(( wc * 13 / 10 ))
      [[ "$est_tokens" -le "${target:-99999}" ]] && echo "PASS" || echo "FAIL"
      ;;

    range_check)
      # Parse common patterns from the target expression
      if [[ -z "$json_block" ]]; then
        echo "FAIL"
        return
      fi

      # Handle: bias_score >= X AND bias_score <= Y
      if [[ "$target" =~ ([a-z_]+)\ *\>=\ *(-?[0-9.]+)\ +AND\ +\1\ *\<=\ *(-?[0-9.]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]}"
        local max="${BASH_REMATCH[3]}"
        local val
        val=$(json_field "$json_block" "$field")
        if [[ -n "$val" ]] && command -v python3 &>/dev/null; then
          python3 -c "v=$val; print('PASS' if $min <= v <= $max else 'FAIL')" 2>/dev/null || echo "FAIL"
        else
          echo "SKIP"
        fi
        return
      fi

      # Handle: abs(field) <= X
      if [[ "$target" =~ abs\(([a-z_]+)\)\ *\<=\ *(-?[0-9.]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local limit="${BASH_REMATCH[2]}"
        local val
        val=$(json_field "$json_block" "$field")
        if [[ -n "$val" ]] && command -v python3 &>/dev/null; then
          python3 -c "v=$val; print('PASS' if abs(v) <= $limit else 'FAIL')" 2>/dev/null || echo "FAIL"
        else
          echo "SKIP"
        fi
        return
      fi

      # Handle: quality_score >= X
      if [[ "$target" =~ ([a-z_]+)\ *\>=\ *(-?[0-9.]+)$ ]]; then
        local field="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]}"
        local val
        val=$(json_field "$json_block" "$field")
        if [[ -n "$val" ]] && command -v python3 &>/dev/null; then
          python3 -c "v=$val; print('PASS' if v >= $min else 'FAIL')" 2>/dev/null || echo "FAIL"
        else
          echo "SKIP"
        fi
        return
      fi

      # Handle: len(field) >= X AND len(field) <= Y (character length)
      if [[ "$target" =~ len\(([a-z_]+)\)\ *\>=\ *([0-9]+)\ +AND\ +len\(\1\)\ *\<=\ *([0-9]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]}"
        local max="${BASH_REMATCH[3]}"
        local val
        val=$(json_field "$json_block" "$field")
        local len=${#val}
        [[ "$len" -ge "$min" && "$len" -le "$max" ]] && echo "PASS" || echo "FAIL"
        return
      fi

      # Handle: len(field) <= X
      if [[ "$target" =~ len\(([a-z_]+)\)\ *\<=\ *([0-9]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local max="${BASH_REMATCH[2]}"
        local val
        val=$(json_field "$json_block" "$field")
        local len=${#val}
        [[ "$len" -le "$max" ]] && echo "PASS" || echo "FAIL"
        return
      fi

      # Handle: len(field) >= X (list length)
      if [[ "$target" =~ len\(([a-z_]+)\)\ *\>=\ *([0-9]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]}"
        local val
        val=$(json_field "$json_block" "$field")
        [[ "$val" -ge "$min" ]] 2>/dev/null && echo "PASS" || echo "FAIL"
        return
      fi

      # Handle: word_count(field) >= X AND word_count(field) <= Y
      if [[ "$target" =~ word_count\(([a-z_]+)\)\ *\>=\ *([0-9]+)\ +AND\ +word_count\(\1\)\ *\<=\ *([0-9]+) ]]; then
        local field="${BASH_REMATCH[1]}"
        local min="${BASH_REMATCH[2]}"
        local max="${BASH_REMATCH[3]}"
        local val
        val=$(json_field "$json_block" "$field")
        local wc
        wc=$(word_count "$val")
        [[ "$wc" -ge "$min" && "$wc" -le "$max" ]] && echo "PASS" || echo "FAIL"
        return
      fi

      echo "SKIP"  # Unrecognized expression
      ;;

    # Soft assertion types — logged but always PASS (require LLM judge)
    structure_check|sequence_check)
      echo "SOFT"
      ;;

    *)
      echo "SKIP"
      ;;
  esac
}

# ─── Score all assertions for a case ───────────────────────────────

score_case() {
  local case_id="$1"
  local mode="$2"
  local output_file="$RESULTS_DIR/$mode/${case_id}.md"
  local score_file="$RESULTS_DIR/$mode/${case_id}.score.txt"
  local response
  response=$(cat "$output_file" 2>/dev/null || echo "")

  if [[ "$response" == EVAL_ERROR* ]]; then
    echo "ERROR" > "$score_file"
    echo "ERROR"
    return
  fi

  local json_block
  json_block=$(extract_json "$response")

  local pass=0 fail=0 soft=0 skip=0 total=0
  local critical_fail=false
  local details=""

  # Parse assertions from YAML
  local in_case=false
  local in_assertions=false
  local assert_type="" assert_target="" assert_critical="false" assert_desc=""

  process_assertion() {
    if [[ -z "$assert_type" ]]; then return; fi
    total=$((total + 1))
    local result
    result=$(eval_assertion "$response" "$assert_type" "$assert_target" "$json_block")

    case "$result" in
      PASS) pass=$((pass + 1)) ;;
      FAIL)
        fail=$((fail + 1))
        [[ "$assert_critical" == "true" ]] && critical_fail=true
        ;;
      SOFT) soft=$((soft + 1)) ;;
      SKIP) skip=$((skip + 1)) ;;
    esac

    local label="${assert_desc:-$assert_type($assert_target)}"
    local crit_marker=""
    [[ "$assert_critical" == "true" ]] && crit_marker=" [CRITICAL]"
    details+="  $result$crit_marker — $label"$'\n'
  }

  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ id:\ $case_id$ ]]; then
      in_case=true
      continue
    fi
    if $in_case && [[ "$line" =~ ^-\ id: ]]; then
      break
    fi

    if $in_case && [[ "$line" =~ ^\ \ \ \ -\ type:\ (.+) ]]; then
      process_assertion
      assert_type="${BASH_REMATCH[1]}"
      assert_target=""
      assert_critical="false"
      assert_desc=""
    fi
    if $in_case && [[ "$line" =~ ^\ \ \ \ \ \ target:\ (.+) ]]; then
      assert_target="${BASH_REMATCH[1]}"
      assert_target="${assert_target#\"}"
      assert_target="${assert_target%\"}"
    fi
    if $in_case && [[ "$line" =~ ^\ \ \ \ \ \ critical:\ (.+) ]]; then
      assert_critical="${BASH_REMATCH[1]}"
    fi
    if $in_case && [[ "$line" =~ ^\ \ \ \ \ \ description:\ (.+) ]]; then
      assert_desc="${BASH_REMATCH[1]}"
      assert_desc="${assert_desc#\"}"
      assert_desc="${assert_desc%\"}"
    fi
  done < "$SCRIPT_DIR/test-cases.yaml"
  process_assertion  # last assertion

  local anchored=$((pass + fail))
  local score_line="$pass/$total (${anchored} anchored, ${soft} soft, ${skip} skipped)"
  if $critical_fail; then
    score_line+=" [CRITICAL FAIL]"
  fi

  {
    echo "$score_line"
    echo "$details"
  } > "$score_file"

  echo "$score_line"
}

# ─── Generate scorecard ───────────────────────────────────────────

generate_scorecard() {
  local scorecard="$RESULTS_DIR/scorecard.md"

  cat > "$scorecard" <<HEADER
# Eval Scorecard — $SKILL_NAME
**Timestamp:** $TIMESTAMP

| Test Case | With Skill | Baseline |
|-----------|-----------|----------|
HEADER

  for case_id in "${CASE_IDS[@]}"; do
    local skill_score="—"
    local base_score="—"

    if $RUN_SKILL && [[ -f "$RESULTS_DIR/with-skill/${case_id}.md" ]]; then
      skill_score=$(score_case "$case_id" "with-skill")
    fi
    if $RUN_BASELINE && [[ -f "$RESULTS_DIR/baseline/${case_id}.md" ]]; then
      base_score=$(score_case "$case_id" "baseline")
    fi

    echo "| $case_id | $skill_score | $base_score |" >> "$scorecard"
  done

  echo "" >> "$scorecard"
  echo "## Assertion Details" >> "$scorecard"

  for case_id in "${CASE_IDS[@]}"; do
    echo "" >> "$scorecard"
    echo "### $case_id" >> "$scorecard"
    for mode in "with-skill" "baseline"; do
      if [[ -f "$RESULTS_DIR/$mode/${case_id}.score.txt" ]]; then
        echo "**${mode}:**" >> "$scorecard"
        echo '```' >> "$scorecard"
        cat "$RESULTS_DIR/$mode/${case_id}.score.txt" >> "$scorecard"
        echo '```' >> "$scorecard"
      fi
    done
  done

  echo ""
  echo "=== Scorecard ==="
  cat "$scorecard"
}

generate_scorecard

echo ""
echo "=== Eval complete — $RESULTS_DIR/ ==="
