# Development Workflow Best Practices

## Overview

Expert-level skills for Git workflows, branching strategies, pull request management, code review practices, and CI/CD integration.

## Git Workflows

### 1. Feature Branch Workflow

#### Branch Naming Conventions
```bash
# Feature branches
feat/add-user-authentication
feat/payment-integration

# Bug fixes
fix/login-button-crash
fix/memory-leak-parser

# Hotfixes
hotfix/critical-security-patch
hotfix/production-crash

# Refactoring
refactor/database-layer
refactor/api-client

# Documentation
docs/api-documentation
docs/setup-guide

# CI/CD changes
ci/add-integration-tests
ci/optimize-build-pipeline
```

#### Creating Feature Branches
```bash
# Update main branch
git checkout main
git pull origin main

# Create feature branch
git checkout -b feat/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push to remote
git push -u origin feat/new-feature
```

### 2. Commit Best Practices

#### Atomic Commits
```bash
# ✅ GOOD - One logical change per commit
git add src/auth/
git commit -m "feat(auth): add JWT authentication"

git add tests/auth/
git commit -m "test(auth): add JWT authentication tests"

# ❌ BAD - Multiple unrelated changes
git add .
git commit -m "feat: add auth and fix bugs and update docs"
```

#### Commit Frequency
```bash
# Commit after each logical unit of work
git commit -m "feat: add user model"
git commit -m "feat: add user repository"
git commit -m "feat: add user service"
git commit -m "feat: wire up user components"

# NOT one giant commit at the end
git commit -m "feat: complete entire user system"
```

### 3. Pull Request Workflow

#### Creating Pull Requests
```bash
# Ensure branch is up-to-date
git checkout feat/new-feature
git fetch origin
git rebase origin/main

# Push updated branch
git push --force-with-lease origin feat/new-feature

# Create PR with GitHub CLI
gh pr create \
  --title "feat: add new feature" \
  --body "## Summary
- Adds new feature
- Includes tests
- Updates documentation

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Related Issues
Closes #123
" \
  --base main \
  --head feat/new-feature
```

#### PR Description Template
```markdown
## Summary
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- Bullet list of changes
- Keep it concise

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
![Description](url)

## Related Issues
Closes #123
Relates to #456

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added to complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added
- [ ] All tests pass
```

### 4. Code Review Practices

#### As a Reviewer
```markdown
# Constructive feedback
"Consider using a Map here for O(1) lookup instead of filter() which is O(n)"

# Ask questions
"Why did you choose approach X over Y? I'm curious about the trade-offs."

# Praise good code
"Great use of the builder pattern here! Makes this much more readable."

# Be specific
❌ "This is wrong"
✅ "The variable 'data' is shadowing the outer scope 'data' on line 42"

# Suggest alternatives
"What if we extracted this into a separate function? It would improve testability."
```

#### As an Author
```markdown
# Respond to feedback
"Good catch! Updated to use Map as suggested."

# Explain decisions
"I chose X over Y because of performance in our specific use case (see benchmark in #123)"

# Mark resolved
Resolve conversations after addressing feedback

# Request re-review
After significant changes, request another review
```

### 5. Rebasing and Merging

#### Interactive Rebase
```bash
# Clean up commits before PR
git rebase -i HEAD~5

# In editor:
# pick abc123 feat: add feature
# squash def456 fix: typo (squash into previous)
# reword ghi789 test: add tests (edit message)
# pick jkl012 docs: update README

# Rebase onto main
git fetch origin
git rebase origin/main

# Force push (use with-lease for safety)
git push --force-with-lease origin feat/new-feature
```

#### Merge Strategies
```bash
# Squash merge (keeps main history clean)
gh pr merge --squash --delete-branch

# Merge commit (preserves all commits)
gh pr merge --merge --delete-branch

# Rebase and merge (linear history)
gh pr merge --rebase --delete-branch
```

### 6. Branch Protection

#### Main Branch Protection Rules
```yaml
# Required status checks
- CI tests must pass
- Code coverage threshold
- Security scan passes
- Linting passes

# Required reviews
- At least 1 approval required
- Dismiss stale reviews on new commits
- Require review from code owners

# Branch restrictions
- Restrict force pushes
- Restrict deletions
- Require signed commits

# Additional rules
- Require linear history
- Require up-to-date branches before merge
```

### 7. Git Hooks

#### Pre-Commit Hook
```bash
#!/usr/bin/env bash
# .git/hooks/pre-commit

set -e

echo "Running pre-commit checks..."

# Run linter
echo "Linting..."
npm run lint

# Run tests
echo "Testing..."
npm test

# Check for secrets
echo "Scanning for secrets..."
git diff --cached --name-only | xargs grep -i "api[_-]key\|password\|secret" && {
  echo "ERROR: Possible secret detected"
  exit 1
} || true

echo "✓ Pre-commit checks passed"
```

#### Commit-Msg Hook
```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg

commit_msg=$(cat "$1")

# Check conventional commits format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore|ci)(\(.+\))?: .{1,}$"; then
  echo "ERROR: Commit message must follow Conventional Commits format"
  echo "Example: feat(auth): add JWT authentication"
  exit 1
fi

echo "✓ Commit message valid"
```

### 8. Versioning and Tagging

#### Semantic Versioning
```bash
# Format: MAJOR.MINOR.PATCH
# 1.2.3
# MAJOR: Breaking changes
# MINOR: New features (backward compatible)
# PATCH: Bug fixes

# Create release tag
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin v1.2.3

# Create tag with changelog
git tag -a v1.2.3 -m "$(git log v1.2.2..HEAD --pretty=format:'- %s')"
```

#### Release Process
```bash
# 1. Update version in files
sed -i 's/"version": "1.2.2"/"version": "1.2.3"/' package.json

# 2. Update CHANGELOG.md
cat >> CHANGELOG.md <<EOF
## [1.2.3] - $(date +%Y-%m-%d)
### Added
- New feature X

### Fixed
- Bug Y

### Changed
- Improvement Z
EOF

# 3. Commit version bump
git add package.json CHANGELOG.md
git commit -m "chore: bump version to 1.2.3"

# 4. Create and push tag
git tag -a v1.2.3 -m "Release version 1.2.3"
git push origin main
git push origin v1.2.3
```

### 9. CI/CD Integration

#### Testing Before Push
```bash
# Pre-push script
#!/usr/bin/env bash

echo "Running tests before push..."

# Run full test suite
npm test || {
  echo "Tests failed. Push aborted."
  exit 1
}

# Run build
npm run build || {
  echo "Build failed. Push aborted."
  exit 1
}

echo "✓ All checks passed. Proceeding with push."
```

#### CI Pipeline Stages
```yaml
stages:
  - lint      # Code style checks
  - test      # Unit and integration tests
  - build     # Compile/bundle
  - security  # Security scanning
  - deploy    # Deployment (if applicable)

# Each stage must pass before next begins
# Any failure stops the pipeline
```

### 10. Collaborative Workflows

#### Trunk-Based Development
```bash
# Main branch is always deployable
# Short-lived feature branches (1-2 days max)
# Frequent integration to main
# Feature flags for incomplete features

# Create short-lived branch
git checkout -b feat/quick-fix

# Make small change
git commit -m "feat: add feature flag for X"

# Merge quickly (same day)
git push origin feat/quick-fix
gh pr create --fill
gh pr merge --squash
```

#### GitFlow (For Release-Based Projects)
```bash
# Long-lived branches: main, develop
# Support branches: feature/*, release/*, hotfix/*

# Feature development
git checkout -b feature/new-feature develop
# ... work ...
git checkout develop
git merge --no-ff feature/new-feature

# Release preparation
git checkout -b release/1.2.0 develop
# ... version bump, changelog ...
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0

# Hotfix
git checkout -b hotfix/1.2.1 main
# ... fix ...
git checkout main
git merge --no-ff hotfix/1.2.1
git tag -a v1.2.1
```

## Best Practices Checklist

### Before Committing
- [ ] Code follows style guidelines
- [ ] All tests pass locally
- [ ] No console.log or debug statements
- [ ] No commented-out code
- [ ] Commit message follows convention
- [ ] Changes are atomic and focused

### Before Creating PR
- [ ] Branch is up-to-date with main
- [ ] All commits are clean and logical
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] PR description is complete
- [ ] Self-review performed

### Before Merging PR
- [ ] All CI checks pass
- [ ] Required approvals received
- [ ] Conflicts resolved
- [ ] PR description accurate
- [ ] Branch up-to-date with base
- [ ] No broken links or todos

## Common Anti-Patterns

### ❌ Don't Do This
```bash
# Committing directly to main
git checkout main
git commit -m "quick fix"
git push origin main

# Giant commits
git add .
git commit -m "lots of changes"

# Vague commit messages
git commit -m "fix stuff"
git commit -m "updates"
git commit -m "WIP"

# Force push without lease
git push --force origin main

# Merge main into feature repeatedly
git merge origin/main  # Creates merge commits
```

### ✅ Do This Instead
```bash
# Use feature branches
git checkout -b fix/specific-issue
git commit -m "fix(auth): resolve token expiry issue"
gh pr create

# Atomic commits
git add src/auth.js
git commit -m "fix(auth): resolve token expiry"

# Clear commit messages
git commit -m "fix(auth): prevent token refresh race condition"

# Safe force push
git push --force-with-lease origin feat/branch

# Rebase feature onto main
git rebase origin/main  # Clean history
```

## Tools

**Git Utilities:**
- [GitHub CLI (gh)](https://cli.github.com/) - GitHub from terminal
- [tig](https://jonas.github.io/tig/) - Text-mode interface for Git
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for Git

**Code Review:**
- [Reviewdog](https://github.com/reviewdog/reviewdog) - Automated code review
- [Danger](https://danger.systems/) - PR automation

**Changelog:**
- [Conventional Changelog](https://github.com/conventional-changelog/conventional-changelog) - Generate changelog
- [Release Please](https://github.com/googleapis/release-please) - Automated releases

## Resources

- [Git Book](https://git-scm.com/book/en/v2)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [GitFlow](https://nvie.com/posts/a-successful-git-branching-model/)
