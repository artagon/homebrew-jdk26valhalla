#!/usr/bin/env bash
# Sync centralized model context to agent-specific files

set -euo pipefail

SHARED_DIR=".model-context/shared"
AGENTS_DIR=".model-context/agents"

echo "=== Syncing Model Context ==="
echo ""

# Verify source exists
if [ ! -d "$SHARED_DIR" ]; then
  echo "❌ ERROR: $SHARED_DIR not found"
  exit 1
fi

echo "📂 Source: $SHARED_DIR"
echo "🎯 Targets: .claude/, .gemini/, .github/, .cursorrules"
echo ""

# Function to add sync header
add_header() {
  local file="$1"
  local agent="$2"

  {
    echo "<!-- AUTO-GENERATED from .model-context/"
    echo "     DO NOT EDIT DIRECTLY - Edit .model-context/shared/ instead"
    echo "     Last synced: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
    echo "     Agent: $agent -->"
    echo ""
  } > "$file"
}

# Function to append file with marker
append_file() {
  local source="$1"
  local target="$2"

  if [ -f "$source" ]; then
    {
      echo "<!-- BEGIN: $source -->"
      cat "$source"
      echo ""
      echo "<!-- END: $source -->"
      echo ""
    } >> "$target"
  fi
}

# 1. CLAUDE CODE
echo "🤖 Claude Code..."
mkdir -p .claude

# instructions.md
add_header ".claude/instructions.md" "Claude Code"
append_file "$SHARED_DIR/instructions.md" ".claude/instructions.md"
append_file "$SHARED_DIR/security.md" ".claude/instructions.md"
append_file "$SHARED_DIR/style-guide.md" ".claude/instructions.md"
append_file "$AGENTS_DIR/claude.md" ".claude/instructions.md"

# context.md
add_header ".claude/context.md" "Claude Code"
append_file "$SHARED_DIR/context.md" ".claude/context.md"

echo "  ✓ .claude/instructions.md ($(wc -l < .claude/instructions.md) lines)"
echo "  ✓ .claude/context.md ($(wc -l < .claude/context.md) lines)"
echo ""

# 2. GEMINI
echo "🔷 Gemini Code Assist..."
mkdir -p .gemini

# Gemini instructions.md
add_header ".gemini/instructions.md" "Gemini Code Assist"
append_file "$SHARED_DIR/instructions.md" ".gemini/instructions.md"
append_file "$SHARED_DIR/security.md" ".gemini/instructions.md"
append_file "$SHARED_DIR/style-guide.md" ".gemini/instructions.md"
append_file "$AGENTS_DIR/gemini.md" ".gemini/instructions.md"

# Gemini context.md
add_header ".gemini/context.md" "Gemini Code Assist"
append_file "$SHARED_DIR/context.md" ".gemini/context.md"

# Gemini styleguide.md (for code reviews)
add_header ".gemini/styleguide.md" "Gemini Code Assist"
append_file "$SHARED_DIR/style-guide.md" ".gemini/styleguide.md"
append_file "$SHARED_DIR/security.md" ".gemini/styleguide.md"
append_file "$AGENTS_DIR/gemini.md" ".gemini/styleguide.md"

# Create config.yaml if missing
if [ ! -f .gemini/config.yaml ]; then
  cat > .gemini/config.yaml << 'CONFIGEOF'
# Gemini Code Assist Configuration
auto_review: true
review_summary: true
comment_severity_threshold: MEDIUM
max_review_comments: 50
ignore:
  - "*.bak"
  - "*.tmp"
  - ".git/**"
CONFIGEOF
fi

echo "  ✓ .gemini/instructions.md ($(wc -l < .gemini/instructions.md) lines)"
echo "  ✓ .gemini/context.md ($(wc -l < .gemini/context.md) lines)"
echo "  ✓ .gemini/styleguide.md ($(wc -l < .gemini/styleguide.md) lines)"
echo "  ✓ .gemini/config.yaml"
echo ""

# 3. GITHUB COPILOT
echo "🐙 GitHub Copilot..."
mkdir -p .github

add_header ".github/copilot-instructions.md" "GitHub Copilot"
append_file "$SHARED_DIR/context.md" ".github/copilot-instructions.md"
append_file "$SHARED_DIR/instructions.md" ".github/copilot-instructions.md"
append_file "$SHARED_DIR/security.md" ".github/copilot-instructions.md"
append_file "$SHARED_DIR/style-guide.md" ".github/copilot-instructions.md"
append_file "$AGENTS_DIR/copilot.md" ".github/copilot-instructions.md"

echo "  ✓ .github/copilot-instructions.md ($(wc -l < .github/copilot-instructions.md) lines)"
echo ""

# 4. CURSOR
echo "⚡ Cursor..."

{
  echo "# AUTO-GENERATED from .model-context/"
  echo "# DO NOT EDIT DIRECTLY"
  echo "# Last synced: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""

  # Cursor prefers concise format
  [ -f "$SHARED_DIR/security.md" ] && cat "$SHARED_DIR/security.md" && echo ""
  [ -f "$SHARED_DIR/style-guide.md" ] && cat "$SHARED_DIR/style-guide.md" && echo ""
  [ -f "$AGENTS_DIR/cursor.md" ] && cat "$AGENTS_DIR/cursor.md"
} > .cursorrules

echo "  ✓ .cursorrules ($(wc -l < .cursorrules) lines)"
echo ""

# 5. OPENAI CODEX
echo "🧠 OpenAI Codex..."

{
  echo "# AUTO-GENERATED from .model-context/"
  echo "# DO NOT EDIT DIRECTLY"
  echo "# Last synced: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  echo ""
  echo "# OpenAI Codex Agent Instructions"
  echo "# https://github.com/openai/codex"
  echo ""

  # Codex prefers markdown format
  [ -f "$SHARED_DIR/context.md" ] && cat "$SHARED_DIR/context.md" && echo ""
  [ -f "$SHARED_DIR/instructions.md" ] && cat "$SHARED_DIR/instructions.md" && echo ""
  [ -f "$SHARED_DIR/security.md" ] && cat "$SHARED_DIR/security.md" && echo ""
  [ -f "$SHARED_DIR/style-guide.md" ] && cat "$SHARED_DIR/style-guide.md" && echo ""
  [ -f "$AGENTS_DIR/openai.md" ] && cat "$AGENTS_DIR/openai.md"
} > AGENTS.md

echo "  ✓ AGENTS.md ($(wc -l < AGENTS.md) lines)"
echo ""

# Summary
echo "=== Sync Complete ==="
echo ""
echo "✅ All configurations synced from .model-context/shared/"
echo ""
echo "AI Assistants:"
echo "  • Claude Code   (.claude/)"
echo "  • Gemini        (.gemini/)"
echo "  • Copilot       (.github/)"
echo "  • Cursor        (.cursorrules)"
echo "  • OpenAI Codex  (AGENTS.md)"
echo ""
echo "Verify: ./scripts/verify-model-context-sync.sh"
