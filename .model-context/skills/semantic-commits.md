# Semantic Commit Messages (Conventional Commits)

## Overview

Expert-level skills for writing clear, structured commit messages using the Conventional Commits specification for automated changelog generation, semantic versioning, and clear project history.

## Commit Message Format

### Basic Structure
```
type(scope): subject

[optional body]

[optional footer]
```

### Components

**Type** (Required): Nature of the change
**Scope** (Optional): Area of codebase affected
**Subject** (Required): Brief description (50 chars or less)
**Body** (Optional): Detailed explanation
**Footer** (Optional): Breaking changes, issue references

## Commit Types

### Core Types

#### feat - New Features
```bash
# Simple feature
git commit -m "feat: add user authentication"

# Feature with scope
git commit -m "feat(auth): add JWT token validation"

# Feature with breaking change
git commit -m "feat(api)!: change response format to JSON:API spec

BREAKING CHANGE: API responses now follow JSON:API specification.
Clients must update to handle new format."
```

#### fix - Bug Fixes
```bash
# Simple fix
git commit -m "fix: resolve memory leak in parser"

# Fix with scope
git commit -m "fix(database): prevent connection pool exhaustion"

# Fix with issue reference
git commit -m "fix(auth): resolve token expiry race condition

Closes #123"
```

#### docs - Documentation
```bash
# README update
git commit -m "docs: add installation instructions"

# API documentation
git commit -m "docs(api): document authentication endpoints"

# Code comments
git commit -m "docs(parser): add JSDoc comments to public methods"
```

### Additional Types

#### style - Code Style
```bash
# Formatting
git commit -m "style: format code with prettier"

# Whitespace
git commit -m "style: remove trailing whitespace"

# Naming
git commit -m "style(api): rename inconsistent variable names"
```

#### refactor - Code Refactoring
```bash
# Restructure
git commit -m "refactor: extract authentication logic to separate module"

# Simplify
git commit -m "refactor(parser): simplify conditional logic"

# Performance
git commit -m "refactor(database): optimize query builder"
```

#### perf - Performance Improvements
```bash
# Optimization
git commit -m "perf: add caching layer for API responses"

# Algorithm
git commit -m "perf(search): use binary search instead of linear"

# Database
git commit -m "perf(database): add indexes for common queries"
```

#### test - Testing
```bash
# Add tests
git commit -m "test: add unit tests for authentication module"

# Fix tests
git commit -m "test(api): fix flaky integration test"

# Coverage
git commit -m "test(parser): increase coverage to 90%"
```

#### chore - Maintenance
```bash
# Dependencies
git commit -m "chore: update dependencies"

# Build
git commit -m "chore(build): optimize webpack configuration"

# Tooling
git commit -m "chore: add prettier configuration"
```

#### ci - CI/CD
```bash
# Workflow
git commit -m "ci: add automated testing workflow"

# Configuration
git commit -m "ci(github): update action versions"

# Deployment
git commit -m "ci(deploy): add production deployment pipeline"
```

## Scopes

### Common Scopes by Project Type

#### API Project
```bash
feat(api): ...
fix(auth): ...
refactor(database): ...
perf(cache): ...
test(middleware): ...
```

#### Frontend Project
```bash
feat(ui): ...
fix(components): ...
style(layout): ...
refactor(hooks): ...
test(utils): ...
```

#### CLI Tool
```bash
feat(cli): ...
fix(parser): ...
docs(commands): ...
refactor(config): ...
test(integration): ...
```

## Subject Line Guidelines

### Writing Good Subjects

#### ✅ Good Subjects
```bash
# Imperative mood
"add user authentication"
"fix memory leak"
"update API documentation"

# Concise and clear
"optimize database queries"
"remove deprecated endpoints"
"add input validation"

# Lowercase, no period
"feat: add password reset feature"
"fix: resolve CORS issue"
```

#### ❌ Bad Subjects
```bash
# Past tense
"added user authentication"
"fixed memory leak"

# Too vague
"updates"
"fixes"
"changes"

# Too long
"add comprehensive user authentication system with JWT tokens and refresh token rotation"

# With period
"feat: add user auth."
```

### Subject Line Rules
- Use imperative mood ("add" not "added")
- Start with lowercase
- No period at end
- Maximum 50 characters (ideally)
- Be specific and descriptive

## Body Guidelines

### When to Add Body

Add body when:
- Subject alone isn't enough
- Need to explain "why"
- Multiple changes in one commit
- Breaking changes need explanation

### Body Format
```bash
git commit -m "feat(api): add rate limiting

Implement rate limiting to prevent API abuse. Uses token bucket
algorithm with per-user limits.

Configuration:
- 100 requests per minute for authenticated users
- 20 requests per minute for anonymous users

Limits stored in Redis for distributed rate limiting across
multiple API servers."
```

### Body Rules
- Wrap at 72 characters
- Separate from subject with blank line
- Explain "what" and "why" (not "how")
- Use bullet points for lists
- Reference issues/PRs when relevant

## Footer Guidelines

### Breaking Changes
```bash
git commit -m "feat(api)!: change authentication method

Replace basic auth with OAuth 2.0.

BREAKING CHANGE: Basic authentication no longer supported.
All clients must migrate to OAuth 2.0. See migration guide
in docs/oauth-migration.md"
```

### Issue References
```bash
# Close issue
git commit -m "fix: resolve database connection leak

Closes #123"

# Multiple issues
git commit -m "fix: resolve multiple authentication bugs

Closes #123
Closes #456
Fixes #789"

# Related issues
git commit -m "feat: add user preferences

Related to #123
Part of #456"
```

### Co-authors
```bash
git commit -m "feat: add collaborative editing

Co-authored-by: Jane Doe <jane@example.com>
Co-authored-by: John Smith <john@example.com>"
```

## Advanced Patterns

### Monorepo Commits
```bash
# Package-specific scopes
feat(packages/api): add authentication
fix(packages/ui): resolve button styling
docs(packages/cli): update command reference
```

### Multiple Types
```bash
# Use most significant type
# If adding feature + tests, use feat
git commit -m "feat: add user export functionality

Includes unit and integration tests for export feature."

# If refactoring + performance, use most impactful
git commit -m "perf: optimize rendering algorithm

Refactored component tree structure to enable optimization."
```

### Revert Commits
```bash
git revert abc123

# Generates:
# revert: feat(auth): add JWT authentication
#
# This reverts commit abc123def456.
# Reason: JWT library has critical security vulnerability
```

## Validation and Automation

### Git Hook Validation
```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg

commit_msg=$(cat "$1")

# Validate format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore|ci|revert)(\(.+\))?!?: .{1,}$"; then
  echo "ERROR: Invalid commit message format"
  echo ""
  echo "Format: type(scope): subject"
  echo ""
  echo "Types: feat, fix, docs, style, refactor, perf, test, chore, ci, revert"
  echo "Scope: optional"
  echo "Subject: required, imperative mood"
  echo ""
  echo "Example: feat(auth): add JWT authentication"
  exit 1
fi

# Validate subject length
subject=$(echo "$commit_msg" | head -1)
if [ ${#subject} -gt 72 ]; then
  echo "ERROR: Subject line exceeds 72 characters"
  exit 1
fi

echo "✓ Commit message format valid"
```

### commitlint Configuration
```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'chore',
        'ci',
        'revert'
      ]
    ],
    'subject-case': [2, 'always', 'lower-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72]
  }
};
```

## Changelog Generation

### Automated Changelog
```bash
# Using standard-version
npx standard-version

# Generates CHANGELOG.md:
# ## [1.2.0] - 2025-01-15
#
# ### Features
# - add user authentication
# - add password reset
#
# ### Bug Fixes
# - resolve memory leak
# - fix CORS issue
#
# ### BREAKING CHANGES
# - API authentication changed to OAuth 2.0
```

### Semantic Versioning
```bash
# Based on commits:
# feat: ... → MINOR version bump (1.1.0 → 1.2.0)
# fix: ...  → PATCH version bump (1.1.0 → 1.1.1)
# feat!: ... → MAJOR version bump (1.1.0 → 2.0.0)
```

## Examples by Scenario

### New Feature
```bash
git commit -m "feat(auth): add two-factor authentication

Implement TOTP-based 2FA using Google Authenticator protocol.

Features:
- QR code generation for setup
- Backup codes for account recovery
- Optional per-user enforcement

Closes #234"
```

### Bug Fix
```bash
git commit -m "fix(api): prevent SQL injection in search

Sanitize user input before constructing database queries.
Switch to parameterized queries for all search endpoints.

Fixes #567
Security: CVE-2025-1234"
```

### Breaking Change
```bash
git commit -m "feat(api)!: migrate to GraphQL

Replace REST API with GraphQL endpoint.

BREAKING CHANGE: All REST endpoints removed. Clients must
migrate to GraphQL. Migration guide available at:
https://docs.example.com/graphql-migration

Closes #890"
```

### Documentation
```bash
git commit -m "docs: add architecture decision records

Document key architectural decisions:
- Database selection (Postgres vs MongoDB)
- Authentication strategy (JWT vs Sessions)
- Caching layer (Redis)

ADRs stored in docs/adr/ directory."
```

### Refactoring
```bash
git commit -m "refactor(database): extract query builder

Move query construction logic from repositories to
dedicated QueryBuilder class. Improves testability
and reduces code duplication.

No functional changes."
```

## Best Practices

### Do's
- ✅ Use imperative mood
- ✅ Keep subject under 50 chars
- ✅ Capitalize scope when abbreviation
- ✅ Reference issues in footer
- ✅ Explain "why" in body
- ✅ Use breaking change indicator (!)
- ✅ Be specific and clear

### Don'ts
- ❌ Use past tense
- ❌ End subject with period
- ❌ Be vague ("fix stuff")
- ❌ Include multiple unrelated changes
- ❌ Forget scope for monorepos
- ❌ Mix types (feat + refactor)
- ❌ Skip breaking change notice

## Tools

**Validation:**
- [commitlint](https://commitlint.js.org/) - Lint commit messages
- [husky](https://typicode.github.io/husky/) - Git hooks made easy

**Changelog:**
- [standard-version](https://github.com/conventional-changelog/standard-version) - Automated versioning
- [semantic-release](https://semantic-release.gitbook.io/) - Fully automated releases

**Helpers:**
- [commitizen](https://commitizen-tools.github.io/commitizen/) - Interactive commit messages
- [git-cz](https://github.com/streamich/git-cz) - Commitizen adapter

## Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Angular Commit Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Semantic Versioning](https://semver.org/)
