#!/usr/bin/env bash
# Verify model context sync status

set -euo pipefail

echo "=== Verifying Model Context Sync ==="
echo ""

EXIT_CODE=0

# Check source exists
if [ ! -d ".model-context/shared" ]; then
  echo "❌ .model-context/shared not found"
  exit 1
fi

echo "✓ Source directory exists"
echo ""

# Function to check sync status
check_file() {
  local file="$1"
  local label="$2"

  if [ ! -f "$file" ]; then
    echo "  ❌ $label - MISSING"
    EXIT_CODE=1
    return
  fi

  if grep -q "AUTO-GENERATED from .model-context" "$file" 2>/dev/null; then
    LINES=$(wc -l < "$file")
    echo "  ✓ $label - Synced ($LINES lines)"
  else
    echo "  ⚠️  $label - No sync header (manually edited?)"
    EXIT_CODE=1
  fi
}

echo "Checking Claude Code..."
check_file ".claude/instructions.md" ".claude/instructions.md"
check_file ".claude/context.md" ".claude/context.md"
echo ""

echo "Checking Gemini..."
check_file ".gemini/instructions.md" ".gemini/instructions.md"
check_file ".gemini/context.md" ".gemini/context.md"
check_file ".gemini/styleguide.md" ".gemini/styleguide.md"
if [ -f .gemini/config.yaml ]; then
  echo "  ✓ .gemini/config.yaml exists"
else
  echo "  ⚠️  .gemini/config.yaml missing"
fi
echo ""

echo "Checking Copilot..."
check_file ".github/copilot-instructions.md" ".github/copilot-instructions.md"
echo ""

echo "Checking Cursor..."
check_file ".cursorrules" ".cursorrules"
echo ""

echo "Checking OpenAI Codex..."
check_file "AGENTS.md" "AGENTS.md"
echo ""

if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ All configurations in sync"
  echo ""
  echo "AI Assistants configured:"
  echo "  • Claude Code"
  echo "  • Gemini Code Assist"
  echo "  • GitHub Copilot"
  echo "  • Cursor"
  echo "  • OpenAI Codex"
else
  echo "⚠️  Some files need syncing"
  echo "Run: ./scripts/sync-model-context.sh"
fi

exit $EXIT_CODE
