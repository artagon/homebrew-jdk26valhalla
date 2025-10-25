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
