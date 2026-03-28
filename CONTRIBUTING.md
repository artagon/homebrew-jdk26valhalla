# Contributing to homebrew-jdkvalhalla

Thank you for your interest in contributing to the JDK Project Valhalla Homebrew tap!

## Branch Protection and PR-Based Workflow

This repository uses a **PR-based workflow** with strict branch protection on `main`. All changes must go through pull requests.

### Branch Protection Rules

The `main` branch is protected with the following rules:

- ✅ **Required status checks**: All CI tests must pass
  - `validate-syntax` - Validates cask and formula syntax
  - `test-install-macos` - Tests installation on macOS 13 and 14
  - `test-install-linux` - Tests installation on Ubuntu 22.04 and 24.04
- ✅ **Enforce admins**: Even repository admins must follow the rules
- ❌ **No force pushes**: Force pushes are not allowed
- ✅ **Require conversation resolution**: All review conversations must be resolved
- ✅ **Strict checks**: Branches must be up to date before merging

## Development Workflow

### 1. Create a Feature Branch

```bash
# Ensure you're on main and up to date
git checkout main
git pull origin main

# Create a feature branch
git checkout -b <type>/<description>
```

**Branch naming convention:**
- `feat/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `chore/` - Maintenance tasks
- `ci/` - CI/CD changes

**Examples:**
```bash
git checkout -b feat/add-valhalla-build-28
git checkout -b fix/checksum-validation
git checkout -b docs/update-installation-guide
```

### 2. Make Your Changes

Make your changes following our coding standards:

- **Semantic commits**: All commits must follow [Conventional Commits](https://www.conventionalcommits.org/)
- **Ruby style**: Run `brew style` before committing
- **Validation**: Run `brew audit` to ensure quality

```bash
# Make your changes
vim Casks/jdkvalhalla.rb

# Validate syntax
brew style Casks/jdkvalhalla.rb
brew audit --cask Casks/jdkvalhalla.rb

# Commit with semantic message
git add Casks/jdkvalhalla.rb
git commit -m "feat(cask): update to Valhalla build 28"
```

### 3. Push Your Branch

```bash
git push -u origin <type>/<description>
```

### 4. Create a Pull Request

```bash
gh pr create \
  --title "<type>: <description>" \
  --body "## Summary
<describe your changes>

## Changes
- <list key changes>

## Testing
- <describe testing performed>

## Checklist
- [ ] Follows semantic commit format
- [ ] All tests pass locally
- [ ] Documentation updated (if needed)" \
  --base main \
  --head <type>/<description>
```

**Or use the GitHub web interface:**
1. Go to https://github.com/artagon/homebrew-jdkvalhalla
2. Click "Pull requests" -> "New pull request"
3. Select your branch
4. Fill in the PR template
5. Submit the PR

### 5. Wait for CI Checks

All PRs must pass CI checks before merging:

- ✅ Syntax validation
- ✅ macOS installation tests (macOS 13, 14)
- ✅ Linux installation tests (Ubuntu 22.04, 24.04)

**Check CI status:**
```bash
gh pr checks <pr-number>
```

**View CI logs:**
```bash
gh pr view <pr-number> --web
```

### 6. Address Review Comments

If changes are requested:

```bash
# Make the requested changes
vim <file>

# Commit and push
git add <file>
git commit -m "fix: address review comments"
git push
```

CI will automatically re-run.

### 7. Merge the PR

Once all checks pass and reviews are approved:

```bash
# Merge via CLI
gh pr merge <pr-number> --squash --delete-branch

# Or click "Squash and merge" on GitHub
```

## Common Tasks

### Update to New Valhalla Build

```bash
# Create branch
git checkout -b feat/valhalla-build-XX

# Update formula (example for JDK 27)
vim Formula/jdkvalhalla@27.rb
# - Update version
# - Update URLs
# - Calculate and update SHA256 checksums

# Update cask (tracks latest, currently JDK 27)
vim Casks/jdkvalhalla.rb
# - Update version
# - Update SHA256 checksums

# Validate
brew style Casks/jdkvalhalla.rb Formula/jdkvalhalla@27.rb
brew audit --cask Casks/jdkvalhalla.rb

# Test locally (optional but recommended)
brew install --cask Casks/jdkvalhalla.rb
java -version
brew uninstall --cask jdkvalhalla

# Commit and push
git add Casks/jdkvalhalla.rb Formula/jdkvalhalla@27.rb
git commit -m "feat: update to Valhalla build XX"
git push -u origin feat/valhalla-build-XX

# Create PR
gh pr create --title "feat: update to Valhalla build XX"
```

### Fix a Bug

```bash
git checkout -b fix/description
# Make changes
git commit -m "fix: description of fix"
git push -u origin fix/description
gh pr create
```

### Update Documentation

```bash
git checkout -b docs/description
# Make changes
git commit -m "docs: description of update"
git push -u origin docs/description
gh pr create
```

## Semantic Commit Format

All commits must follow this format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code formatting
- `refactor` - Code refactoring
- `perf` - Performance improvements
- `test` - Adding tests
- `chore` - Maintenance
- `ci` - CI configuration

### Scopes

- `cask` - Cask file changes
- `formula` - Formula file changes
- `workflow` - GitHub Actions changes
- `docs` - Documentation changes
- `scripts` - Script changes

### Examples

```bash
feat(cask): update to Valhalla build 28
fix(formula): correct SHA256 checksum for Linux ARM64
docs: add contributing guidelines
ci(workflow): improve validation checks
chore: update dependencies
```

## Code Style

### Ruby/Homebrew

- Follow Homebrew's RuboCop rules
- Run `brew style` before committing
- Run `brew audit` to ensure quality
- Stanza ordering matters in casks
- Quote all variables in shell scripts

### Validation Before Commit

```bash
# Syntax validation
ruby -c Casks/jdkvalhalla.rb
ruby -c Formula/jdkvalhalla@27.rb
ruby -c Formula/jdkvalhalla@26.rb

# Style checking
brew style Casks/jdkvalhalla.rb Formula/jdkvalhalla@27.rb Formula/jdkvalhalla@26.rb

# Audit
brew audit --cask Casks/jdkvalhalla.rb
brew audit --formula Formula/jdkvalhalla@27.rb
brew audit --formula Formula/jdkvalhalla@26.rb
```

## Testing

### Local Testing

**Test cask:**
```bash
brew install --cask Casks/jdkvalhalla.rb
/Library/Java/JavaVirtualMachines/jdk-valhalla.jdk/Contents/Home/bin/java -version
brew uninstall --cask jdkvalhalla
```

**Test formula:**
```bash
brew install Formula/jdkvalhalla@27.rb
$(brew --prefix jdkvalhalla@27)/bin/java -version
brew uninstall jdkvalhalla@27
```

### CI Testing

All PRs automatically run:
- Syntax validation
- Style checks
- Installation tests on multiple platforms
- Functional tests

## Getting Help

- **Issues**: [Open an issue](https://github.com/artagon/homebrew-jdkvalhalla/issues/new/choose)
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the [README](README.md)

## License

By contributing, you agree that your contributions will be licensed under the GPL-2.0 with Classpath Exception, matching the OpenJDK license.
