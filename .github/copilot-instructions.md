<!-- AUTO-GENERATED from .model-context/
     DO NOT EDIT DIRECTLY - Edit .model-context/shared/ instead
     Last synced: 2025-10-25 10:34:16 UTC
     Agent: GitHub Copilot -->

<!-- BEGIN: .model-context/shared/context.md -->
# homebrew-jdk26ea - Repository Context

## Project Overview

**Repository:** https://github.com/Artagon/homebrew-jdk26ea
**Purpose:** Homebrew tap providing automated distribution of OpenJDK 26 Early Access builds
**Current Version:** JDK 26 EA Build 20 (Released: 2025-10-17)
**License:** GPL-2.0 with Classpath Exception (matching OpenJDK)

This is a Homebrew tap that automates the distribution and updating of JDK 26 Early Access builds from [jdk.java.net/26](https://jdk.java.net/26/). It provides both a **cask** (native macOS app installation) and a **formula** (command-line package) for cross-platform support.

## Architecture

### Distribution Methods

1. **Cask (`Casks/jdk26ea.rb`)** - macOS only
   - Installs to: `/Library/Java/JavaVirtualMachines/jdk-26-ea.jdk`
   - Integrates with macOS Java management system
   - Uses secure `ditto` command for installation
   - Path validation to prevent directory traversal attacks
   - Supports both ARM64 (Apple Silicon) and Intel x64

2. **Formula (`Formula/jdk26ea.rb`)** - macOS and Linux
   - Creates symlinks in Homebrew bin directory
   - Cross-platform (macOS ARM64/x64, Linux ARM64/x64)
   - Used for scripting and server environments

### Platform Support

| Platform | Architecture | Cask | Formula | CI Tested |
|----------|-------------|------|---------|-----------|
| macOS 13 | Intel x64 | ✅ | ✅ | ✅ |
| macOS 14 | Apple Silicon ARM64 | ✅ | ✅ | ✅ |
| Linux (Ubuntu 22.04) | x64 | ❌ | ✅ | ✅ |
| Linux (Ubuntu 24.04) | x64 | ❌ | ✅ | ✅ |
| Linux | ARM64 | ❌ | ✅ | ❌ |

## Key Technologies

- **Ruby** - Homebrew DSL for formula/cask definitions
- **Bash/Shell** - Update automation scripts
- **YAML** - GitHub Actions workflows
- **GitHub Actions** - CI/CD platform (5 active workflows)
- **Homebrew** - Package manager and distribution platform

## Directory Structure

```
homebrew-jdk26/
├── .github/
│   ├── workflows/           # GitHub Actions automation
│   │   ├── audit.yml        # Weekly syntax validation
│   │   ├── auto-update.yml  # Daily auto-update checks
│   │   ├── release.yml      # Automated GitHub releases
│   │   ├── validate.yml     # CI validation on push/PR
│   │   └── update.yml       # Manual update workflow
│   ├── ISSUE_TEMPLATE/      # Issue templates
│   └── pull_request_template.md
├── .githooks/               # Git commit message validation
│   └── commit-msg           # Semantic commit enforcement
├── Formula/
│   └── jdk26ea.rb          # Homebrew formula (cross-platform)
├── Casks/
│   └── jdk26ea.rb          # Homebrew cask (macOS only)
├── scripts/
│   └── update.sh           # Manual update script
├── README.md
└── .gitignore
```

## Automated Workflows

### 1. Auto-Update (`auto-update.yml`)
- **Frequency:** Daily at 6:00 AM UTC
- **Purpose:** Check for new JDK 26 EA builds and create PRs automatically
- **Process:**
  1. Scrapes jdk.java.net/26 for latest build number
  2. Downloads SHA256 checksums from official sources
  3. Updates cask and formula with new version/checksums
  4. Validates Ruby syntax
  5. Creates PR with detailed changelog
  6. Applies labels: `automated`, `update`

### 2. Release (`release.yml`)
- **Trigger:** When Formula/Casks files change on main branch
- **Purpose:** Create GitHub releases automatically
- **Process:**
  1. Audits cask before release
  2. Extracts version and build number
  3. Generates changelog from git commits
  4. Updates README with new version/date
  5. Creates GitHub pre-release
  6. Documents platform support

### 3. Validate (`validate.yml`)
- **Trigger:** Push to main, pull requests
- **Purpose:** Comprehensive CI testing across platforms
- **Jobs:**
  - `validate-syntax`: Ruby syntax, brew style, brew audit
  - `test-install-macos`: Tests on macOS 13 and 14
  - `test-install-linux`: Tests on Ubuntu 22.04 and 24.04
- **Testing:** Verifies installation, runs `java -version`, compiles HelloWorld.java

### 4. Audit (`audit.yml`)
- **Frequency:** Weekly on Monday at 12:00 PM UTC
- **Purpose:** Manual syntax validation checks
- **Can be triggered:** Via workflow_dispatch

## Coding Standards

### Semantic Commits

**Enforced via git hooks** (`.githooks/commit-msg`)

**Format:** `type(scope): description`

**Valid types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style (formatting)
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Test changes
- `chore` - Build process or tooling
- `ci` - CI configuration changes

**Valid scopes:**
- `cask` - Cask file changes
- `formula` - Formula file changes
- `workflow` - GitHub Actions changes
- `docs` - Documentation changes
- `scripts` - Script changes

**Examples:**
```bash
feat(cask): add support for JDK 26 EA Build 21
fix(formula): correct SHA256 checksum for Linux ARM64
docs: update README with new installation instructions
chore(workflow): update auto-update schedule
```

**Breaking Changes:**
```bash
feat(cask)!: rename from jdk26valhalla to jdk26ea

BREAKING CHANGE: Users must uninstall old cask and reinstall with new name
```

### Ruby Style

- Follows Homebrew's RuboCop rules
- Enforced via `brew style` and `brew audit`
- Stanza ordering in casks matters
- Empty lines between stanza groups required
- No logical operators in `unless` statements

## Security Practices

### Cask Installation Security

1. **Path Validation**
   - Uses `realpath` to resolve symlinks
   - Validates JDK bundle is within staging area
   - Prevents directory traversal attacks
   - Validates paths don't escape staging

2. **Secure Copying**
   - Uses Apple's `ditto` instead of external `rsync`
   - `ditto` is Apple-signed and part of macOS
   - Better metadata preservation (ACLs, extended attributes)
   - `--noqtn` flag prevents quarantine issues

3. **Error Handling**
   - Uses `system_command!` for immediate error detection
   - Uses `odie` for fatal errors (stops execution)
   - Uses `ohai` for user-facing messages
   - Validates source exists before operations

### Download Verification

- **SHA256 checksums** for all platform downloads
- Downloaded from official `.sha256` files on download.java.net
- Verified by Homebrew during installation
- Four platforms verified independently:
  - macOS ARM64
  - macOS x64
  - Linux ARM64
  - Linux x64

## Version Management

### Version Format
`26-ea+{build_number}`

**Example:** `26-ea+20`

### Update Process

**Automated:**
1. `auto-update.yml` runs daily
2. Scrapes jdk.java.net/26 for new builds
3. Downloads checksums
4. Updates both cask and formula
5. Creates PR for review

**Manual:**
```bash
./scripts/update.sh
```

### Version Locations
- `Casks/jdk26ea.rb` - Line 2: `version "26-ea+20"`
- `Formula/jdk26ea.rb` - Line 4: `version "26-ea+20"`
- `README.md` - Line 30: Current version display

## Testing

### CI Test Matrix

| Job | OS | Architecture | Package Type |
|-----|-----|------------|--------------|
| test-install-macos | macOS 13 | Intel x64 | Cask |
| test-install-macos | macOS 14 | Apple Silicon ARM64 | Cask |
| test-install-linux | Ubuntu 22.04 | x64 | Formula |
| test-install-linux | Ubuntu 24.04 | x64 | Formula |

### Test Coverage

Each test verifies:
1. Installation succeeds
2. `java -version` executes
3. `javac -version` executes (Linux only)
4. Can compile HelloWorld.java (Linux only)
5. Can run compiled Java programs (Linux only)
6. JAVA_HOME setup works (Linux only)

### Local Testing

**Cask:**
```bash
brew install --cask Casks/jdk26ea.rb
java -version
brew uninstall --cask jdk26ea
```

**Formula:**
```bash
brew install Formula/jdk26ea.rb
java -version
brew uninstall jdk26ea
```

## Common Tasks

### Update to New JDK Build

1. **Automated:** Wait for `auto-update.yml` to create PR
2. **Manual:**
   ```bash
   ./scripts/update.sh
   git add Formula/jdk26ea.rb Casks/jdk26ea.rb
   git commit -m "feat: update to JDK 26 EA Build XX"
   ```

### Fix RuboCop Violations

```bash
# Check style
brew style Casks/jdk26ea.rb
brew style Formula/jdk26ea.rb

# Audit
brew audit --cask Casks/jdk26ea.rb

# Validate syntax
ruby -c Casks/jdk26ea.rb
ruby -c Formula/jdk26ea.rb
```

### Create Release

Releases are automated when version changes on `main` branch.

Manual trigger:
```bash
# Push version change to main
git push origin main

# Release workflow triggers automatically
# Creates GitHub release with pre-release flag
```

## Important Files

### Configuration Files
- `.gitignore` - Excludes macOS, Homebrew, and temp files
- `.githooks/commit-msg` - Semantic commit validation
- `CODEOWNERS` - Code ownership (@you owns all)

### Documentation
- `README.md` - User-facing documentation
- `.github/ISSUE_TEMPLATE/` - Issue templates
- `.github/pull_request_template.md` - PR template

### Scripts
- `scripts/update.sh` - Manual update automation
  - Scrapes jdk.java.net/26
  - Downloads SHA256 checksums
  - Updates cask and formula
  - Validates syntax
  - Colored output

## External Dependencies

### Data Sources
- `https://jdk.java.net/26/` - Official JDK 26 EA page
- `https://download.java.net/java/early_access/jdk26/{build}/GPL/` - Binary downloads
- Accompanying `.sha256` files for checksums

### GitHub Actions
- `actions/checkout@v4` - Checkout repository
- `Homebrew/actions/setup-homebrew@master` - Setup Homebrew on Linux

## Known Limitations

1. **Linux ARM64 not tested in CI** - Requires self-hosted runners
2. **Early Access only** - Not production-ready
3. **Single maintainer** - All owned by @you
4. **Web scraping dependency** - Relies on jdk.java.net page structure

## Maintenance Notes

### Branch Protection
- `main` branch requires PR
- `Validate` status check required
- No force pushes allowed
- Auto-delete merged branches

### Git Configuration
This repository uses a dedicated SSH identity:
- Host: `github.com-artagon`
- User: `trumpyla@gmail.com`
- Identity file: `~/.ssh/id_trumpyla@gmail.com`

### Recent Changes
- Removed `issue-commands.yml` (security concern)
- Removed `CONTRIBUTING.md` (simplified docs)
- Replaced `rsync` with `ditto` (security)
- Added comprehensive CI testing
- Repository renamed from `jdk26valhalla` to `jdk26ea`

## Troubleshooting

### RuboCop Violations
- Check stanza ordering (sha256 before url)
- Ensure empty lines between stanza groups
- Avoid logical operators in `unless`

### Installation Failures
- Verify SHA256 checksums match official sources
- Check JDK bundle naming matches `jdk-*.jdk` pattern
- Ensure sufficient permissions for `/Library/Java/JavaVirtualMachines/`

### CI Failures
- Check Ruby syntax: `ruby -c Casks/jdk26ea.rb`
- Run brew audit: `brew audit --cask Casks/jdk26ea.rb`
- Verify all platform URLs are accessible
- Confirm checksums are correct

## Project History

- Originally `homebrew-jdk26valhalla` for Project Valhalla
- Renamed to `homebrew-jdk26ea` for general EA builds
- Build 20 current as of 2025-10-17
- 31 commits total
- Active maintenance and improvements ongoing



<!-- END: .model-context/shared/context.md -->

<!-- BEGIN: .model-context/shared/instructions.md -->
# AI Assistant Instructions for homebrew-jdk26ea

## Domain-Specific Skills

This repository uses domain-organized skill files for specialized expertise. AI assistants should reference these files for detailed guidance in each area:

### Core Skills
- **[Homebrew Development](../skills/homebrew.md)** - Formula and cask development, security patterns, validation
- **[GitHub Workflows](../skills/github-workflows.md)** - Actions security, input validation, workflow patterns
- **[Shell Scripting](../skills/shell-scripts.md)** - Bash best practices, error handling, safe patterns
- **[Security Practices](../skills/security.md)** - Input validation, path traversal prevention, cryptographic verification
- **[Development Workflow](../skills/development-workflow.md)** - Git workflows, PR management, code review
- **[Semantic Commits](../skills/semantic-commits.md)** - Conventional commits, changelog generation

## Project-Specific Requirements

### Repository Context
- **Purpose**: Homebrew tap for OpenJDK 26 Early Access builds
- **Platforms**: macOS (ARM64, x64), Linux (ARM64, x64)
- **Automation**: Daily auto-updates, automated releases, multi-platform CI testing

### Commit Requirements
All commits MUST follow Conventional Commits format. See [semantic-commits.md](../skills/semantic-commits.md) for details.

**Quick Reference:**
```
type(scope): description

Valid types: feat, fix, docs, style, refactor, perf, test, chore, ci
Valid scopes: cask, formula, workflow, docs, scripts
```

**Examples:**
```bash
feat(cask): add support for JDK 26 EA Build 21
fix(formula): correct SHA256 checksum for Linux ARM64
ci(workflow): pin action to commit SHA for security
```

### File Structure
```
homebrew-jdk26/
├── Casks/jdk26ea.rb           # macOS cask
├── Formula/jdk26ea.rb         # Linux/macOS formula
├── .github/workflows/         # CI/CD automation
├── scripts/                   # Update and sync scripts
└── .model-context/            # AI configuration
    ├── skills/               # Domain-specific skills
    ├── shared/               # Shared context
    └── agents/               # Agent-specific overrides
```

### Version Updates

When updating to a new JDK build:

1. **Update version** in both Casks/jdk26ea.rb and Formula/jdk26ea.rb
2. **Download and verify checksums** for all 4 platforms
3. **Validate changes** with brew style and brew audit
4. **Commit** with semantic message: `feat: update to JDK 26 EA Build XX`

**Reference Skills:**
- [Homebrew Development](../skills/homebrew.md#version-management)
- [Security Practices](../skills/security.md#cryptographic-verification)
- [Shell Scripting](../skills/shell-scripts.md#network-operations)

### Security Requirements

**Critical Rules:**
- Pin ALL GitHub Actions to commit SHAs → [github-workflows.md](../skills/github-workflows.md#action-pinning)
- Validate ALL external inputs → [security.md](../skills/security.md#input-validation)
- Verify checksums before use → [security.md](../skills/security.md#cryptographic-verification)
- Use realpath for path operations → [homebrew.md](../skills/homebrew.md#path-validation)
- Quote all shell variables → [shell-scripts.md](../skills/shell-scripts.md#safe-command-execution)

### Testing Requirements

**Before Committing:**
```bash
# Syntax validation
ruby -c Casks/jdk26ea.rb
ruby -c Formula/jdk26ea.rb

# Style checking
brew style Casks/jdk26ea.rb Formula/jdk26ea.rb

# Audit
brew audit --cask Casks/jdk26ea.rb
brew audit --formula Formula/jdk26ea.rb
```

**CI Testing:**
- macOS 13, 14 (cask installation)
- Ubuntu 22.04, 24.04 (formula installation)
- Syntax and style validation
- Functional tests (java -version, compile HelloWorld)

### Workflow Patterns

**Feature Development:**
```bash
# Create feature branch
git checkout -b feat/description

# Make changes with semantic commits
git commit -m "feat(cask): add support for new feature"

# Push and create PR
git push -u origin feat/description
gh pr create --title "feat: description" --body "..."
```

**Reference:**
- [Development Workflow](../skills/development-workflow.md#feature-branch-workflow)
- [Semantic Commits](../skills/semantic-commits.md#commit-types)

### Automation

**Daily Auto-Updates** (6 AM UTC):
- Scrapes https://jdk.java.net/26/ for new builds
- Downloads and verifies checksums
- Creates PR if new build available

**Automated Releases** (on main branch push):
- Validates syntax and style
- Runs multi-platform tests
- Creates GitHub release with changelog

**Reference:**
- [GitHub Workflows](../skills/github-workflows.md#auto-update-workflow)
- [Development Workflow](../skills/development-workflow.md#versioning-and-tagging)

## Quick Reference: Common Tasks

### Task: Add New JDK Build
1. Run `./scripts/update.sh <build-number>` or update manually
2. Verify checksums for all 4 platforms
3. Test: `brew style` and `brew audit`
4. Commit: `feat: update to JDK 26 EA Build XX`
5. Push and create PR

**Skills:** [homebrew.md](../skills/homebrew.md), [security.md](../skills/security.md#cryptographic-verification)

### Task: Fix Security Issue
1. Identify vulnerability
2. Create branch: `fix/security-issue-name`
3. Apply fix following security best practices
4. Add tests if applicable
5. Commit: `fix(scope): description` with security note
6. Create PR with security context

**Skills:** [security.md](../skills/security.md), [github-workflows.md](../skills/github-workflows.md)

### Task: Update GitHub Workflow
1. Validate YAML syntax
2. Pin all actions to commit SHAs
3. Validate inputs and add error handling
4. Test in fork if possible
5. Commit: `ci(workflow): description`
6. Monitor workflow runs after merge

**Skills:** [github-workflows.md](../skills/github-workflows.md), [security.md](../skills/security.md#input-validation)

### Task: Write Shell Script
1. Start with strict mode: `set -euo pipefail`
2. Add input validation
3. Implement error handling (trap)
4. Quote all variables
5. Test with ShellCheck
6. Commit: `chore(scripts): description`

**Skills:** [shell-scripts.md](../skills/shell-scripts.md), [security.md](../skills/security.md)

## Error Prevention

### Common Mistakes

❌ **Don't:**
- Skip brew style validation
- Hardcode SHA256 checksums without verification
- Use unpinned GitHub Actions
- Commit without semantic format
- Update README version manually (automated)
- Use rsync in cask postflight (use ditto)

✅ **Do:**
- Run validation before every commit
- Download and verify checksums
- Pin actions to commit SHAs with version comments
- Follow Conventional Commits format
- Let automation handle README updates
- Use ditto (Apple-signed) for file operations

## Emergency Procedures

**If auto-update creates bad PR:**
1. Close the PR
2. Fix issue locally
3. Let auto-update run again next day, or
4. Create manual PR with fix

**If release fails:**
1. Check workflow logs for errors
2. Fix validation/test failures
3. Re-push to main (triggers re-run)

**If CI failing:**
1. Check RuboCop violations
2. Verify SHA256 checksums
3. Test locally when possible
4. Review detailed workflow logs

## Repository Operations

All repository operations should follow the guidelines in:
- [Development Workflow](../skills/development-workflow.md) for Git operations
- [Semantic Commits](../skills/semantic-commits.md) for commit messages
- [GitHub Workflows](../skills/github-workflows.md) for CI/CD changes

## Summary

This repository values:
1. **Security** - Path validation, secure commands, checksum verification
2. **Automation** - Daily updates, automatic releases, comprehensive CI
3. **Quality** - RuboCop enforcement, semantic commits, multi-platform testing
4. **Simplicity** - Clear documentation, skill-based organization
5. **Reliability** - Early detection, rollback capabilities

When in doubt:
- Consult relevant skill file for detailed guidance
- Prioritize security over convenience
- Let automation handle routine tasks
- Follow semantic commit format
- Test before committing

<!-- END: .model-context/shared/instructions.md -->

<!-- BEGIN: .model-context/shared/security.md -->
# Security Guidelines for homebrew-jdk26ea

## 1. GitHub Actions Security

### Pin Actions to Commit SHAs
- NEVER use tags or branches (they're mutable)
- ALWAYS use full commit SHA with version comment
- Example: `uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1`

### Token Security
- Never expose tokens in curl commands
- Use `gh` CLI for GitHub API calls
- Pass secrets via environment variables only
- Use minimal permissions (contents: read, pull-requests: write)

### Input Validation
- Validate ALL external inputs with regex
- Build numbers: `^[0-9]{1,3}$` (range: 1-999)
- URLs: Must match `https://download.java.net/java/early_access/...`
- SHA256: `^[a-f0-9]{64}$`
- Reject invalid inputs immediately

### Checksum Verification
- Download files AND verify checksums (don't just fetch checksums)
- Compare expected vs actual before using values
- Fail workflow if verification fails

## 2. Cask/Formula Security

### Path Validation
- Use `realpath` to resolve all symlinks
- Validate paths stay within staging area
- Check: `path.to_s.start_with?(staged_root.to_s)`
- Validate candidate count: `odie` if not exactly 1

### Command Execution
- Use `system_command!` (with !) to fail fast
- Use `ditto` instead of `rsync` (Apple-signed)
- Pass args as array (never string interpolation)
- Use `sudo` only for system locations

### Error Handling
- Use `odie` for fatal errors (stops execution)
- Use `ohai` for user messages
- Use `opoo` for warnings (non-fatal)
- Never silently continue on errors

## 3. Workflow Permissions

### Minimal Permissions
```yaml
# For auto-update PRs
permissions:
  contents: read
  pull-requests: write

# For releases
permissions:
  contents: write
```

### Avoid Direct Commits
- Create PRs instead of pushing to main
- Exception: Documentation-only auto-updates with clear justification
- Always respect branch protection rules

## 4. Common Vulnerabilities

| Vulnerability | Fix |
|--------------|-----|
| Unpinned actions | Pin to commit SHA |
| Token in curl | Use gh CLI |
| No input validation | Add regex validation |
| No checksum verify | Download and verify |
| Excessive permissions | Use minimal permissions |
| Direct commits to main | Create PRs |

## 5. New Security Rule
- Always validate API responses

<!-- END: .model-context/shared/security.md -->

<!-- BEGIN: .model-context/shared/style-guide.md -->
# Code Style Guide for homebrew-jdk26ea

## Commit Messages

### Format
```
type(scope): description

[optional body]
```

### Valid Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code formatting
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Adding/modifying tests
- `chore` - Build process, dependencies
- `ci` - CI configuration changes

### Valid Scopes
- `cask` - Changes to Casks/jdk26ea.rb
- `formula` - Changes to Formula/jdk26ea.rb
- `workflow` - GitHub Actions workflows
- `docs` - Documentation changes
- `scripts` - Script changes

### Examples
```bash
feat(cask): add support for JDK 26 EA Build 21
fix(formula): correct SHA256 checksum for Linux ARM64
ci(workflow): pin action to commit SHA for security
docs: update README with installation instructions
```

## Ruby/Homebrew Style

### Before Committing
1. Validate syntax: `ruby -c Casks/jdk26ea.rb`
2. Check style: `brew style Casks/jdk26ea.rb`
3. Run audit: `brew audit --cask Casks/jdk26ea.rb`

### Cask Stanza Ordering
1. `arch` declaration
2. `version`
3. `sha256` (before url!)
4. `url`
5. `name`
6. `desc`
7. `homepage`
8. `postflight`
9. `uninstall`

### Common Issues
- Missing empty lines between stanza groups
- SHA256 after URL (should be before)
- Logical operators in `unless` (use `if` with negation)

## Workflow Style

### YAML Structure
- Use consistent indentation (2 spaces)
- Add comments for complex logic
- Name all steps clearly
- Group related steps

### Security Annotations
```yaml
# Pin to commit SHA with version comment
- uses: actions/checkout@a1b2c3d...  # v4.1.1

# Document why permissions are needed
permissions:
  contents: read      # Checkout repository
  pull-requests: write  # Create update PRs
```

## Testing

### Required Tests
- Syntax validation (all files)
- Style checks (brew style)
- Audit checks (brew audit)
- Installation tests (macOS 13, 14, Ubuntu 22.04, 24.04)
- Functional tests (java -version, compile HelloWorld)

### CI Expectations
- All jobs must pass
- No RuboCop violations
- No audit failures
- Successful installation on all platforms

<!-- END: .model-context/shared/style-guide.md -->

<!-- BEGIN: .model-context/agents/copilot.md -->
# GitHub Copilot Specific Instructions

## Configuration
Copilot loads from `.github/copilot-instructions.md` (auto-generated from shared context)

## Copilot-Specific Features
- Inline code completion
- Chat mode for questions
- Multi-line suggestions
- Context from open files

## Usage Patterns
- Accept suggestions that follow repository conventions
- Reject suggestions that:
  - Use unpinned actions
  - Skip input validation
  - Bypass security checks
  - Don't follow commit message format

## Chat Mode
When using Copilot Chat:
- Ask about semantic commit format before committing
- Request security review for workflow changes
- Verify checksums are included for all platforms
- Check that style guidelines are followed

<!-- END: .model-context/agents/copilot.md -->

