#!/usr/bin/env bash
# Verify which files Claude Code loads from .claude/

set -euo pipefail

echo "=== Claude Code Context Verification ==="
echo ""

# Check .agents file
if [ ! -f .agents ]; then
  echo "❌ .agents file missing"
  exit 1
fi

AGENTS_DIR=$(cat .agents)
echo "Configuration directory: $AGENTS_DIR"
echo ""

# Check directory exists
if [ ! -d "$AGENTS_DIR" ]; then
  echo "❌ Directory $AGENTS_DIR does not exist"
  exit 1
fi

echo "Files in $AGENTS_DIR:"
ls -lh "$AGENTS_DIR"
echo ""

echo "=== Files Claude Code LOADS ==="

# Check instructions.md
if [ -f "$AGENTS_DIR/instructions.md" ] && [ -s "$AGENTS_DIR/instructions.md" ]; then
  LINES=$(wc -l < "$AGENTS_DIR/instructions.md")
  SIZE=$(du -h "$AGENTS_DIR/instructions.md" | cut -f1)
  echo "✅ instructions.md - $LINES lines, $SIZE"
else
  echo "❌ instructions.md - MISSING or EMPTY"
fi

# Check context.md
if [ -f "$AGENTS_DIR/context.md" ] && [ -s "$AGENTS_DIR/context.md" ]; then
  LINES=$(wc -l < "$AGENTS_DIR/context.md")
  SIZE=$(du -h "$AGENTS_DIR/context.md" | cut -f1)
  echo "✅ context.md - $LINES lines, $SIZE"
else
  echo "❌ context.md - MISSING or EMPTY"
fi

echo ""
echo "=== Other Files (NOT loaded by Claude Code) ==="

# Find other markdown files
OTHER_FILES=$(find "$AGENTS_DIR" -type f -name "*.md" ! -name "instructions.md" ! -name "context.md" 2>/dev/null || true)

if [ -z "$OTHER_FILES" ]; then
  echo "  (none)"
else
  echo "$OTHER_FILES" | while read -r file; do
    LINES=$(wc -l < "$file")
    SIZE=$(du -h "$file" | cut -f1)
    echo "⊘ $(basename "$file") - $LINES lines, $SIZE (NOT loaded)"
  done
fi

echo ""
echo "=== Summary ==="
echo "Claude Code loads ONLY these 2 files from $AGENTS_DIR/:"
echo "  1. instructions.md (behavioral instructions)"
echo "  2. context.md (repository context)"
echo ""
echo "All other .md files in $AGENTS_DIR/ are ignored."
