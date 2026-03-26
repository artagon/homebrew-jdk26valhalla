# GitHub Copilot Instructions for homebrew-jdkvalhalla

## Repository Overview
This is a Homebrew tap for OpenJDK Project Valhalla Early Access builds (JDK 26 and JDK 27) with automated updates and releases.

## Commit Message Requirements
**CRITICAL:** All commits MUST follow Conventional Commits format.

Format: `type(scope): description`

Valid types: feat, fix, docs, style, refactor, perf, test, chore, ci
Valid scopes: cask, formula, workflow, docs, scripts

Examples:
- `feat(cask): add support for JDK 27 Valhalla build`
- `fix(formula): correct SHA256 checksum for Linux ARM64`
- `ci(workflow): pin actions to commit SHAs`

## Ruby/Homebrew Guidelines

### Before Committing
1. Run `ruby -c Casks/jdkvalhalla.rb` to validate syntax
2. Run `brew style Casks/jdkvalhalla.rb` to check style
3. Run `brew audit --cask Casks/jdkvalhalla.rb` to audit

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
# Correct
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

# Wrong
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
- Cask file: `Casks/jdkvalhalla.rb` (latest, currently JDK 27)
- Formula files: `Formula/jdkvalhalla@27.rb`, `Formula/jdkvalhalla@26.rb`
- Workflows: `.github/workflows/*.yml`
- Scripts: `scripts/*.sh`

## Testing
- macOS cask installation tested on macOS 13, 14
- Formula installation tested on Ubuntu 22.04, 24.04
- Verify `java -version` works
- Test JAVA_HOME setup

## Common Patterns

### Update Version
1. Update version in both Casks/jdkvalhalla.rb and Formula/jdkvalhalla@27.rb
2. Update SHA256 for all 4 platforms (macOS ARM64/x64, Linux ARM64/x64)
3. Validate syntax
4. Commit: `feat: update to JDK 27 Valhalla Build XX`

### Fix Security Issue
1. Identify vulnerability
2. Apply fix following security guidelines
3. Test thoroughly
4. Commit: `fix(workflow): pin action to commit SHA for security`

## What NOT to Do
- Don't commit without semantic format
- Don't skip `brew style` validation
- Don't use rsync in cask (use ditto)
- Don't hardcode paths without validation
- Don't bypass git hooks with --no-verify
- Don't use unpinned GitHub Actions
- Don't commit directly to main (use PRs)
