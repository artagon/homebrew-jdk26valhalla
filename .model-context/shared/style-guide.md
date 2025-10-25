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
