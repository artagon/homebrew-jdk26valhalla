# Centralized Model Context System

This directory contains centralized configuration for all AI coding assistants.

## Structure

```
.model-context/
├── README.md           # This file
├── shared/             # Shared context (source of truth)
│   ├── instructions.md   # Behavioral instructions
│   ├── context.md       # Repository context
│   ├── security.md      # Security guidelines
│   └── style-guide.md   # Code style rules
└── agents/             # Agent-specific overrides
    ├── claude.md        # Claude Code specific
    ├── gemini.md        # Gemini specific
    ├── copilot.md       # GitHub Copilot specific
    └── cursor.md        # Cursor specific
```

## Philosophy

**DRY (Don't Repeat Yourself)** - Write instructions once, sync everywhere.

Instead of maintaining separate, duplicate instructions for each AI assistant,
we maintain ONE source of truth in `.model-context/shared/` and compile
agent-specific files from it.

## How It Works

### Source Files (Edit These)

**Shared Context** - `.model-context/shared/`
- `instructions.md` - How AI assistants should behave
- `context.md` - Repository architecture and context
- `security.md` - Security best practices
- `style-guide.md` - Code style and commit conventions

**Agent Overrides** - `.model-context/agents/`
- `claude.md` - Claude Code specific tools and features
- `gemini.md` - Gemini Code Assist specific features
- `copilot.md` - GitHub Copilot specific features
- `cursor.md` - Cursor specific features
- `openai.md` - OpenAI Codex specific features

### Generated Files (Don't Edit These)

The sync script compiles shared + agent-specific files into:
- `.claude/instructions.md` ← shared/*.md + agents/claude.md
- `.claude/context.md` ← shared/context.md
- `.gemini/instructions.md` ← shared/*.md + agents/gemini.md
- `.gemini/context.md` ← shared/context.md
- `.gemini/styleguide.md` ← shared/style-guide.md + security.md + agents/gemini.md
- `.github/copilot-instructions.md` ← shared/*.md + agents/copilot.md
- `.cursorrules` ← shared/*.md + agents/cursor.md
- `AGENTS.md` ← shared/*.md + agents/openai.md

## Workflow

### 1. Edit Shared Context

```bash
# Edit the source files
vim .model-context/shared/security.md
vim .model-context/shared/style-guide.md
```

### 2. Sync to Agent Files

```bash
# Compile and sync
./scripts/sync-model-context.sh
```

### 3. Commit Everything

```bash
# Atomic commit of all changes
git add .model-context/ .claude/ .gemini/ .github/ .cursorrules AGENTS.md
git commit -m "docs: update model context"
```

## Benefits

✅ **Single Source of Truth** - Edit once, applies everywhere
✅ **No Duplication** - DRY principle for AI configuration
✅ **Easy Maintenance** - Update shared context in one place
✅ **Agent Customization** - Override per-agent as needed
✅ **Version Control** - Track all config changes
✅ **Consistency** - All AIs get same core instructions
✅ **Pre-Commit Validation** - Git hook ensures files stay in sync

## File Mappings

| AI Assistant | Reads From | Generated From |
|--------------|-----------|----------------|
| Claude Code | `.claude/instructions.md`<br>`.claude/context.md` | `shared/*.md + agents/claude.md` |
| Gemini | `.gemini/instructions.md`<br>`.gemini/context.md`<br>`.gemini/styleguide.md` | `shared/*.md + agents/gemini.md` |
| Copilot | `.github/copilot-instructions.md` | `shared/*.md + agents/copilot.md` |
| Cursor | `.cursorrules` | `shared/*.md + agents/cursor.md` |
| OpenAI Codex | `AGENTS.md` | `shared/*.md + agents/openai.md` |

## Example: Adding Security Rule

```bash
# 1. Edit shared security guidelines
vim .model-context/shared/security.md
# Add new rule to the file

# 2. Sync to all agents
./scripts/sync-model-context.sh

# 3. All agents now have the new rule
# Claude, Gemini (3 files), Copilot, and Cursor all updated
```

## Verification

```bash
# Verify all configs are in sync
./scripts/verify-model-context-sync.sh

# Should show:
# ✅ All configurations in sync
```

## Git Pre-Commit Hook

A pre-commit hook automatically verifies that model context files are in sync:

```bash
# If you edit shared files without syncing:
vim .model-context/shared/security.md
git add .model-context/
git commit -m "docs: add security rule"

# Hook will BLOCK the commit and show:
# ✗ Model context sync verification failed
# Please run: ./scripts/sync-model-context.sh
```

After syncing and staging all files, the commit will succeed.

## Scripts

- `sync-model-context.sh` - Sync shared context to agent files
- `verify-model-context-sync.sh` - Verify configs are in sync

## Gemini Code Assist Files

Gemini now has three auto-generated files:

1. **`.gemini/instructions.md`** - Behavioral instructions
   - Compiled from: shared/instructions.md + security.md + style-guide.md + agents/gemini.md
   - 2300+ lines

2. **`.gemini/context.md`** - Repository context
   - Compiled from: shared/context.md
   - 400+ lines

3. **`.gemini/styleguide.md`** - Code review guidelines
   - Compiled from: shared/style-guide.md + security.md + agents/gemini.md
   - 200+ lines
   - Used specifically for automated code reviews

Plus one manual config file:

4. **`.gemini/config.yaml`** - Feature toggles (not auto-generated)
   - Controls auto-review, severity thresholds, ignore patterns

## Migration from Old System

Old system had duplicate content:
- `.claude/instructions.md` (2000+ lines)
- `.gemini/styleguide.md` (duplicate content)
- `.github/copilot-instructions.md` (duplicate content)
- `.cursorrules` (duplicate content)

New system has:
- `.model-context/shared/` (~1000 lines total)
- Agent-specific overrides (~50 lines each)
- Generated files (compiled automatically)

Result: Less duplication, easier maintenance, consistent instructions.
