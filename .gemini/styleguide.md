<!-- AUTO-GENERATED from .model-context/
     DO NOT EDIT DIRECTLY - Edit .model-context/shared/ instead -->

# Gemini Code Assist Style Guide for homebrew-jdkvalhalla

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
feat(cask): add support for JDK Valhalla Build 21
fix(formula): correct SHA256 checksum for Linux ARM64
ci(workflow): pin actions to commit SHAs for security
docs: update README with installation instructions
```

## Testing Requirements

### Before Committing
- Validate Ruby syntax: `ruby -c Casks/jdkvalhalla.rb`
- Run style checks: `brew style Casks/jdkvalhalla.rb`
- Run audit: `brew audit --cask Casks/jdkvalhalla.rb`

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
