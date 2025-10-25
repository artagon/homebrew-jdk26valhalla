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


