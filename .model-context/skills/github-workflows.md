# GitHub Actions Workflow Security and Best Practices

## Overview

Expert-level skills for developing secure, reliable GitHub Actions workflows for automating JDK builds, updates, releases, and CI/CD validation.

## Core Security Principles

### 1. Action Pinning (CRITICAL)

#### SHA Pinning - The Only Secure Method
```yaml
# ✅ SECURE - Immutable commit SHA
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

# ✅ SECURE - With explanatory comment
- uses: peter-evans/create-pull-request@153407881ec5c347639a548ade7d8ad1d6740e38  # v5.0.0

# ❌ DANGEROUS - Mutable branch reference
- uses: Homebrew/actions/setup-homebrew@master

# ❌ DANGEROUS - Mutable tag reference
- uses: actions/checkout@v4  # Tag can be moved!
```

**Why Commit SHAs?**
- Immutable (cannot be changed after creation)
- Prevents supply chain attacks
- Reproducible builds
- Clear audit trail

#### Finding Commit SHAs
```bash
# Method 1: GitHub CLI
gh api repos/actions/checkout/commits/v4.1.1 --jq '.sha'

# Method 2: GitHub Web UI
# Visit: https://github.com/actions/checkout/releases/tag/v4.1.1
# Copy commit SHA from tag page
```

### 2. Token and Secret Security

#### Never Expose Tokens in Commands
```yaml
# ❌ DANGEROUS - Token visible in logs/errors
- name: Call API
  run: |
    curl -H "Authorization: Bearer ${GITHUB_TOKEN}" \
         https://api.github.com/repos/${REPO}/statuses/${SHA}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

# ✅ SECURE - Use GitHub CLI
- name: Call API
  run: |
    gh api repos/${{ github.repository }}/statuses/${{ github.sha }} \
      -X POST \
      -F state=success \
      -F context=ValidateExpected
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Secret Handling
```yaml
# ✅ CORRECT - Secrets in environment variables
- name: Deploy
  run: ./deploy.sh
  env:
    DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
    API_KEY: ${{ secrets.API_KEY }}

# ❌ DANGEROUS - Secrets in command line
- run: ./deploy.sh --token=${{ secrets.DEPLOY_TOKEN }}

# ❌ DANGEROUS - Secret transformations unmask
- run: echo "${{ secrets.MY_SECRET }}" | base64  # NOT masked!
```

### 3. Minimal Permissions

#### Principle of Least Privilege
```yaml
# ✅ CORRECT - Minimal permissions
permissions:
  contents: read        # Read repository
  pull-requests: write  # Create PRs

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - name: Create PR
        run: gh pr create --title "Update" --body "Auto-update"

# ❌ EXCESSIVE - Too broad
permissions:
  contents: write       # Not needed if only creating PRs
  pull-requests: write
  issues: write         # Not needed
  packages: write       # Not needed
```

#### Permission Scopes
```yaml
# For read-only operations
permissions:
  contents: read

# For creating PRs (no direct commits)
permissions:
  contents: read
  pull-requests: write

# For releases and tags
permissions:
  contents: write

# For updating commit statuses
permissions:
  statuses: write
```

### 4. Input Validation

#### Validate ALL External Inputs
```yaml
- name: Fetch and validate version
  run: |
    # Fetch external data
    BUILD=$(curl -s https://jdk.java.net/26/ | grep -oP 'Build \K[0-9]+' | head -1)

    # ✅ CRITICAL - Validate format and range
    if ! [[ "$BUILD" =~ ^[0-9]{1,3}$ ]]; then
      echo "❌ Invalid build number format: $BUILD"
      exit 1
    fi

    if [ "$BUILD" -lt 1 ] || [ "$BUILD" -gt 999 ]; then
      echo "❌ Build number out of range: $BUILD"
      exit 1
    fi

    echo "✅ Build number validated: $BUILD"
    echo "build=$BUILD" >> $GITHUB_OUTPUT
```

#### URL Validation
```yaml
- name: Extract and validate URL
  run: |
    URL=$(grep -oP 'href="\K[^"]*openjdk.*\.tar\.gz' page.html | head -1)

    # Validate URL format
    if ! [[ "$URL" =~ ^https://download\.java\.net/java/early_access/jdk26/[0-9]+/GPL/openjdk-26-ea\+[0-9]+_[a-z0-9_-]+\.tar\.gz$ ]]; then
      echo "❌ Invalid URL format: $URL"
      exit 1
    fi

    # Validate domain
    if [[ "$URL" != https://download.java.net/* ]]; then
      echo "❌ URL not from trusted domain: $URL"
      exit 1
    fi

    echo "✅ URL validated: $URL"
```

#### SHA256 Validation
```yaml
- name: Validate checksum
  run: |
    SHA=$(curl -sL "${URL}.sha256" | awk '{print $1}')

    # Validate SHA256 format
    if ! [[ "$SHA" =~ ^[a-f0-9]{64}$ ]]; then
      echo "❌ Invalid SHA256 format: $SHA"
      exit 1
    fi

    echo "✅ Checksum format validated: $SHA"
```

### 5. Checksum Verification

#### Download AND Verify (Critical)
```yaml
# ❌ DANGEROUS - Just fetching checksums
- name: Get checksums
  run: |
    SHA_MAC_ARM=$(curl -sL "${URL_MAC_ARM}.sha256" | awk '{print $1}')
    # Never actually verified the downloaded file!

# ✅ SECURE - Download and verify
- name: Download and verify checksums
  run: |
    URL="https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_macos-aarch64_bin.tar.gz"

    # 1. Download file
    curl -fsSL "$URL" -o jdk.tar.gz

    # 2. Download checksum
    EXPECTED_SHA=$(curl -fsSL "${URL}.sha256" | awk '{print $1}')

    # 3. Validate checksum format
    if ! [[ "$EXPECTED_SHA" =~ ^[a-f0-9]{64}$ ]]; then
      echo "❌ Invalid checksum format"
      exit 1
    fi

    # 4. Compute actual checksum
    ACTUAL_SHA=$(shasum -a 256 jdk.tar.gz | awk '{print $1}')

    # 5. Compare
    if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
      echo "❌ Checksum mismatch!"
      echo "Expected: $EXPECTED_SHA"
      echo "Actual: $ACTUAL_SHA"
      exit 1
    fi

    echo "✅ Checksum verified"
    echo "sha=$ACTUAL_SHA" >> $GITHUB_OUTPUT
```

## Workflow Patterns

### 6. Auto-Update Workflow (Secure Pattern)

```yaml
name: Auto Update

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM UTC
  workflow_dispatch:

permissions:
  contents: read        # Read repository
  pull-requests: write  # Create PRs only

jobs:
  check-update:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

      - name: Fetch and validate version
        id: version
        run: |
          BUILD=$(curl -s https://jdk.java.net/26/ | grep -oP 'Build \K[0-9]+' | head -1)

          if ! [[ "$BUILD" =~ ^[0-9]{1,3}$ ]] || [ "$BUILD" -lt 1 ] || [ "$BUILD" -gt 999 ]; then
            echo "Invalid build: $BUILD"
            exit 1
          fi

          echo "build=$BUILD" >> $GITHUB_OUTPUT

      - name: Download and verify checksums
        id: checksums
        run: |
          # Implementation from checksum verification section
          # Downloads files, verifies checksums, outputs SHAs

      - name: Update files
        run: |
          sed -i "s/version \".*\"/version \"26-ea+${{ steps.version.outputs.build }}\"/" Casks/jdk26ea.rb
          sed -i "s/sha256 \"[a-f0-9]*\"/sha256 \"${{ steps.checksums.outputs.sha }}\"/" Casks/jdk26ea.rb

      - name: Validate changes
        run: |
          ruby -c Casks/jdk26ea.rb
          brew style Casks/jdk26ea.rb

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@153407881ec5c347639a548ade7d8ad1d6740e38  # v5.0.0
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "chore: update to JDK 26 EA Build ${{ steps.version.outputs.build }}"
          title: "chore: update to JDK 26 EA Build ${{ steps.version.outputs.build }}"
          body: |
            ## Automated Update
            Build: ${{ steps.version.outputs.build }}
            Verified checksums from official source.
          branch: update/build-${{ steps.version.outputs.build }}
          delete-branch: true
```

### 7. Validation Workflow

```yaml
name: Validate

on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read

jobs:
  validate-syntax:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

      - name: Set up Homebrew
        uses: Homebrew/actions/setup-homebrew@c39f0335940fb3214046dce5a5d2f94ed275ab4b

      - name: Validate cask syntax
        run: |
          brew style Casks/jdk26ea.rb
          ruby -c Casks/jdk26ea.rb

      - name: Audit cask
        run: brew audit --cask Casks/jdk26ea.rb

  test-install-macos:
    strategy:
      matrix:
        os: [macos-13, macos-14]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

      - name: Set up Homebrew
        uses: Homebrew/actions/setup-homebrew@c39f0335940fb3214046dce5a5d2f94ed275ab4b

      - name: Test cask installation
        run: brew install --cask Casks/jdk26ea.rb

      - name: Verify installation
        run: |
          if [ -d "/Library/Java/JavaVirtualMachines/jdk-26-ea.jdk" ]; then
            echo "✅ JDK installed successfully"
            /Library/Java/JavaVirtualMachines/jdk-26-ea.jdk/Contents/Home/bin/java -version
          else
            echo "❌ JDK installation failed"
            exit 1
          fi

      - name: Cleanup
        if: always()
        run: brew uninstall --cask Casks/jdk26ea.rb || true

  validation-status:
    name: Validation Status
    runs-on: ubuntu-latest
    needs:
      - validate-syntax
      - test-install-macos
    steps:
      - name: Confirm completion
        run: echo "✅ All validation jobs completed successfully"
```

### 8. Pull Request Security

#### Dangerous: pull_request_target
```yaml
# ❌ EXTREMELY DANGEROUS
on: pull_request_target

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}  # Checks out untrusted code
      - run: npm install  # Could run malicious install scripts!
      - run: npm test     # Could exfiltrate secrets!
```

#### Safe: pull_request
```yaml
# ✅ SAFE for PRs from forks
on: pull_request

permissions:
  contents: read  # Read-only, no secret access

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
      - run: npm install
      - run: npm test
```

#### When to Use pull_request_target
Only when:
1. You need write access (e.g., labels)
2. You DO NOT checkout PR code
3. You only run trusted code

```yaml
on: pull_request_target

permissions:
  pull-requests: write

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      # DO NOT checkout PR code
      - name: Add label
        run: gh pr edit ${{ github.event.pull_request.number }} --add-label "needs-review"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Advanced Patterns

### 9. Matrix Testing
```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - os: macos-13
        arch: x64
      - os: macos-14
        arch: arm64
      - os: ubuntu-22.04
        arch: x64
      - os: ubuntu-24.04
        arch: x64
runs-on: ${{ matrix.os }}
```

### 10. Conditional Execution
```yaml
- name: macOS-specific step
  if: runner.os == 'macOS'
  run: brew install something

- name: Linux-specific step
  if: runner.os == 'Linux'
  run: apt-get install something

- name: Cleanup (always runs)
  if: always()
  run: cleanup.sh
```

### 11. Dependency Jobs
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: make build

  test:
    needs: build  # Waits for build
    runs-on: ubuntu-latest
    steps:
      - run: make test

  deploy:
    needs: [build, test]  # Waits for both
    runs-on: ubuntu-latest
    steps:
      - run: make deploy
```

## Security Checklist

Before committing workflow changes:

**Action Security:**
- [ ] All third-party actions pinned to commit SHAs
- [ ] Version comments added (e.g., `# v4.1.1`)
- [ ] Actions verified from trusted sources

**Token Security:**
- [ ] No tokens in command-line arguments
- [ ] No tokens in curl commands
- [ ] Secrets passed via environment variables only
- [ ] GitHub CLI used for API calls

**Input Validation:**
- [ ] All external inputs validated with regex
- [ ] Numeric values bounded
- [ ] URLs validated for domain and format
- [ ] No user-controlled input in shell commands

**Checksum Verification:**
- [ ] Files downloaded AND verified
- [ ] Checksums compared before use
- [ ] Failures halt execution

**Permissions:**
- [ ] Minimal permissions specified
- [ ] Write access only when necessary
- [ ] No `pull_request_target` with code checkout

**Testing:**
- [ ] YAML syntax validated
- [ ] Workflow tested in fork
- [ ] Error handling for critical steps

## Common Vulnerabilities

| Vulnerability | Severity | Impact | Fix |
|--------------|----------|--------|-----|
| Unpinned actions | Critical | Supply chain attack | Pin to commit SHA |
| Token in curl | Critical | Secret exposure | Use `gh` CLI |
| No input validation | Critical | Code injection | Validate with regex |
| No checksum verification | High | Malicious downloads | Download and verify |
| Excessive permissions | High | Privilege escalation | Minimal permissions |
| pull_request_target misuse | Critical | Secret exposure | Use `pull_request` |
| Direct commits to main | Medium | Bypass reviews | Use PRs |

## Resources

**Official Documentation:**
- [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Automatic token authentication](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
- [Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

**Tools:**
- [actionlint](https://github.com/rhysd/actionlint) - Workflow linter
- [OpenSSF Scorecard](https://github.com/ossf/scorecard) - Security scoring
- [GitGuardian](https://www.gitguardian.com/) - Secret scanning
