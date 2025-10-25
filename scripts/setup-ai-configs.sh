#!/usr/bin/env bash
# Setup configuration files for multiple AI coding assistants

set -euo pipefail

echo "=== Setting Up Multi-AI Assistant Configuration ==="
echo ""

# 1. Claude Code - Already configured
echo "✓ Claude Code - Already configured"
echo "  .agents → .claude/"
echo "  .claude/instructions.md"
echo "  .claude/context.md"
echo ""

# 2. Gemini Code Assist
echo "Setting up Gemini Code Assist..."

mkdir -p .gemini

cat > .gemini/config.yaml << 'EOF'
# Gemini Code Assist Configuration
# https://developers.google.com/gemini-code-assist/docs/customize-gemini-behavior-github

# Enable automatic code review
auto_review: true

# Generate review summaries
review_summary: true

# Comment severity threshold (CRITICAL, HIGH, MEDIUM, LOW)
comment_severity_threshold: MEDIUM

# Maximum number of review comments
max_review_comments: 50

# Files/patterns to ignore during review
ignore:
  - "*.bak"
  - "*.tmp"
  - ".git/**"
  - "scripts/test.sh"
EOF

cat > .gemini/styleguide.md << 'EOF'
# Gemini Code Assist Style Guide for homebrew-jdk26ea

## General Principles
1. Security first - validate all inputs, verify checksums
2. Follow Homebrew conventions and RuboCop rules
3. Use semantic commit messages
4. Comprehensive testing before merge

## Ruby/Homebrew Style

### Cask and Formula Files
- Run `brew style` before committing
- Run `brew audit --cask` for validation
- Maintain proper stanza ordering (sha256 before url)
- Use empty lines between stanza groups

### Security in Cask Scripts
- Always use `realpath` to resolve symlinks
- Validate paths don't escape staging area
- Use `ditto` instead of `rsync` for copying
- Use `system_command!` (with exclamation) to fail fast
- Use `odie` for fatal errors, `ohai` for user messages

## GitHub Actions Workflows

### Critical Security Practices
- Pin ALL third-party actions to commit SHAs (not tags or branches)
- Add version comments for maintainability
  ```yaml
  - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
  ```
- Never expose tokens in curl commands - use `gh` CLI instead
- Validate all scraped/external inputs with regex
- Actually download and verify checksums (don't just fetch them)
- Use minimal permissions (contents: read, pull-requests: write)
- Create PRs instead of committing directly to main

### Input Validation
- Validate build numbers: `^[0-9]{1,3}$`
- Validate URLs match expected domain and format
- Validate SHA256 checksums: `^[a-f0-9]{64}$`
- Bound all numeric values

## Commit Messages

### Format
```
type(scope): description

[optional body]
```

### Valid Types
- feat, fix, docs, style, refactor, perf, test, chore, ci

### Valid Scopes
- cask, formula, workflow, docs, scripts

### Examples
```
feat(cask): add support for JDK 26 EA Build 21
fix(formula): correct SHA256 checksum for Linux ARM64
ci(workflow): pin actions to commit SHAs for security
docs: update README with installation instructions
```

## Testing Requirements

### Before Committing
- Validate Ruby syntax: `ruby -c Casks/jdk26ea.rb`
- Run style checks: `brew style Casks/jdk26ea.rb`
- Run audit: `brew audit --cask Casks/jdk26ea.rb`

### CI Expectations
- All tests must pass on macOS 13, macOS 14
- Formula tests must pass on Ubuntu 22.04, 24.04
- Installation verification required
- Java version checks required

## Code Review Focus

When reviewing code, prioritize:
1. **Security vulnerabilities** (path traversal, command injection, token exposure)
2. **SHA256 checksum verification** (all platforms must have valid checksums)
3. **Semantic commit message compliance**
4. **RuboCop/style violations**
5. **Missing input validation** in workflows
6. **Unpinned GitHub Actions**
7. **Test coverage** for changes

## Common Issues to Flag

### High Priority
- Missing SHA256 checksums
- Unpinned GitHub Actions (using @master or @v1)
- Tokens in curl commands
- No input validation in workflows
- Direct commits to main branch
- Path validation missing in cask scripts

### Medium Priority
- RuboCop violations
- Missing commit message scope
- Incomplete test coverage
- Documentation out of sync

### Low Priority
- Code style preferences
- Minor optimization opportunities
EOF

echo "✓ Gemini Code Assist configured"
echo "  .gemini/config.yaml"
echo "  .gemini/styleguide.md"
echo ""

# 3. GitHub Copilot
echo "Setting up GitHub Copilot..."

mkdir -p .github

cat > .github/copilot-instructions.md << 'EOF'
# GitHub Copilot Instructions for homebrew-jdk26ea

## Repository Overview
This is a Homebrew tap for OpenJDK 26 Early Access builds with automated updates and releases.

## Commit Message Requirements
**CRITICAL:** All commits MUST follow Conventional Commits format.

Format: `type(scope): description`

Valid types: feat, fix, docs, style, refactor, perf, test, chore, ci
Valid scopes: cask, formula, workflow, docs, scripts

Examples:
- `feat(cask): add support for JDK 26 EA Build 21`
- `fix(formula): correct SHA256 checksum for Linux ARM64`
- `ci(workflow): pin actions to commit SHAs`

## Ruby/Homebrew Guidelines

### Before Committing
1. Run `ruby -c Casks/jdk26ea.rb` to validate syntax
2. Run `brew style Casks/jdk26ea.rb` to check style
3. Run `brew audit --cask Casks/jdk26ea.rb` to audit

### Cask Security Rules
- Use `realpath` to resolve all paths
- Validate paths are within staging area
- Use `ditto` instead of `rsync`
- Use `system_command!` (with !) for error handling
- Use `odie` for fatal errors
- Never skip path validation

## GitHub Actions Security

### Action Pinning (CRITICAL)
Pin ALL third-party actions to commit SHAs:
```yaml
# ✅ Correct
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

# ❌ Wrong
- uses: actions/checkout@v4
- uses: Homebrew/actions/setup-homebrew@master
```

### Token Security
- Never use tokens in curl commands
- Use `gh` CLI for GitHub API calls
- Pass secrets via environment variables only

### Input Validation
- Validate all scraped values with regex
- Bound numeric inputs (build: 1-999)
- Validate URLs match expected domain
- Verify SHA256 format: ^[a-f0-9]{64}$

### Checksum Verification
- Download files AND verify checksums
- Don't just fetch checksum values
- Fail workflow if verification fails

## File Naming Conventions
- Cask file: `Casks/jdk26ea.rb`
- Formula file: `Formula/jdk26ea.rb`
- Workflows: `.github/workflows/*.yml`
- Scripts: `scripts/*.sh`

## Testing
- macOS cask installation tested on macOS 13, 14
- Formula installation tested on Ubuntu 22.04, 24.04
- Verify `java -version` works
- Test JAVA_HOME setup

## Common Patterns

### Update Version
1. Update version in both Casks/jdk26ea.rb and Formula/jdk26ea.rb
2. Update SHA256 for all 4 platforms (macOS ARM64/x64, Linux ARM64/x64)
3. Validate syntax
4. Commit: `feat: update to JDK 26 EA Build XX`

### Fix Security Issue
1. Identify vulnerability
2. Apply fix following security guidelines
3. Test thoroughly
4. Commit: `fix(workflow): pin action to commit SHA for security`

## What NOT to Do
- ❌ Don't commit without semantic format
- ❌ Don't skip `brew style` validation
- ❌ Don't use rsync in cask (use ditto)
- ❌ Don't hardcode paths without validation
- ❌ Don't bypass git hooks with --no-verify
- ❌ Don't use unpinned GitHub Actions
- ❌ Don't commit directly to main (use PRs)
EOF

echo "✓ GitHub Copilot configured"
echo "  .github/copilot-instructions.md"
echo ""

# 4. Cursor
echo "Setting up Cursor..."

cat > .cursorrules << 'EOF'
# Cursor Rules for homebrew-jdk26ea

You are working on a Homebrew tap for OpenJDK 26 Early Access builds.

## Commit Messages
Use Conventional Commits: type(scope): description
Types: feat, fix, docs, style, refactor, perf, test, chore, ci
Scopes: cask, formula, workflow, docs, scripts

## Ruby/Homebrew
- Run `brew style` before committing
- Run `brew audit --cask` for validation
- Use `ditto` instead of `rsync` in cask scripts
- Validate all paths with `realpath`
- Use `system_command!` for error handling

## GitHub Actions Security
- Pin actions to commit SHAs (not tags/branches)
- Validate all external inputs
- Use `gh` CLI instead of curl for API calls
- Verify checksums of downloads
- Use minimal permissions

## Testing
- Validate syntax: `ruby -c Casks/jdk26ea.rb`
- Style check: `brew style Casks/jdk26ea.rb`
- Audit: `brew audit --cask Casks/jdk26ea.rb`

## Repository-Specific
- Current version in Casks/jdk26ea.rb and Formula/jdk26ea.rb
- Update both files together
- Update all 4 platform checksums (macOS ARM64/x64, Linux ARM64/x64)
- Don't update README manually (auto-updated by release workflow)

## Security First
- Validate paths don't escape staging
- Verify SHA256 checksums
- Bound numeric inputs
- No tokens in command lines
- Create PRs instead of direct commits
EOF

echo "✓ Cursor configured"
echo "  .cursorrules"
echo ""

# Summary
echo "=== Configuration Summary ==="
echo ""
echo "AI Assistant Configurations Created:"
echo "  ✓ Claude Code      (.agents → .claude/)"
echo "  ✓ Gemini           (.gemini/)"
echo "  ✓ GitHub Copilot   (.github/copilot-instructions.md)"
echo "  ✓ Cursor           (.cursorrules)"
echo ""
echo "Next steps:"
echo "  1. Review generated configuration files"
echo "  2. Customize as needed for your workflow"
echo "  3. Commit all configurations:"
echo "     git add .agents .claude/ .gemini/ .github/ .cursorrules"
echo "     git commit -m 'docs: add multi-AI assistant configurations'"
echo ""
echo "Files created/updated:"
find . -maxdepth 2 \( -name ".agents" -o -name ".cursorrules" -o -path "./.claude/*" -o -path "./.gemini/*" -o -path "./.github/copilot-instructions.md" \) -type f | sort
