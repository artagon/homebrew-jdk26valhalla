# Security Policy

## Overview

This document outlines the security measures and supply chain security practices for the homebrew-jdk26valhalla Homebrew tap. We take the security of our users seriously and have implemented multiple layers of protection.

## Reporting Security Vulnerabilities

If you discover a security vulnerability, please report it by:

1. **DO NOT** open a public issue
2. Email security concerns to the repository maintainers
3. Provide detailed information about the vulnerability
4. Allow reasonable time for a fix before public disclosure

## Supply Chain Security Measures

### 1. Release Approval Process

**Manual Approval Required**: All releases require manual approval before distribution to prevent automatic deployment of potentially compromised JDK builds.

- Releases use GitHub Environments with required reviewers
- The `release-approval` environment must be configured with trusted reviewers
- Configuration: Settings > Environments > release-approval > Required reviewers

### 2. Download Verification

**SHA256 Checksums**: All JDK downloads are verified using SHA256 checksums.

- Checksums are embedded in the Homebrew formula and cask files
- Homebrew automatically verifies downloads before installation
- Any checksum mismatch will abort the installation

**GPG Verification** (when available): We check for GPG signatures from OpenJDK.

- OpenJDK EA builds typically don't provide GPG signatures
- When available, signatures will be verified automatically
- Current status is logged in release workflows

### 3. Software Bill of Materials (SBOM)

Each release includes an SBOM in SPDX 2.3 format:

- Provides transparency about package contents
- Includes licensing information
- Available as a release asset (`sbom-*.spdx.json`)
- Enables downstream verification and compliance

### 4. Automated Security Scanning

**CodeQL Analysis**:
- Runs on every push and pull request
- Weekly scheduled scans on Mondays
- Analyzes Python and Ruby code
- Uses extended security and quality queries

**Dependabot**:
- Monitors GitHub Actions dependencies
- Weekly checks for updates
- Automated pull requests for dependency updates
- Configured in `.github/dependabot.yml`

### 5. Network Security

**Request Timeouts**: All network requests have 30-second timeouts to prevent hanging operations.

**HTTPS Only**: All downloads and API requests use HTTPS.

### 6. Workflow Security

**Pinned Actions**: All GitHub Actions use SHA-pinned versions for immutability.

**Limited Permissions**: Workflows follow the principle of least privilege.
- `release.yml`: Only `contents: write` and `pull-requests: write`
- Other workflows: Minimal required permissions

**First-Time Contributor Approval**:
- First-time contributors require manual approval to run workflows
- Protects against malicious workflow modifications
- Configure in: Settings > Actions > General > Fork pull request workflows

**Input Validation**:
- All shell variables are properly quoted
- `set -euo pipefail` used in bash scripts for error handling
- Version strings validated before use

### 7. Code Review Requirements

**Branch Protection** (recommended configuration):
- Require pull request reviews before merging
- Require status checks to pass (Validate workflow)
- Require up-to-date branches before merging
- Require conversation resolution before merging

### 8. Audit Trail

**Comprehensive Logging**:
- All release steps are logged
- Verification status recorded in workflow outputs
- Git tags preserve release history
- Release notes include detailed changelogs

## Verification Guide for Users

### Verifying a Download

1. **Check the Formula/Cask**:
   ```bash
   brew cat artagon/jdk26valhalla/jdk26valhalla
   ```
   Verify the SHA256 checksums are present

2. **Review Release Notes**:
   - Visit the [Releases page](../../releases)
   - Check for the SBOM file
   - Review the changelog for unexpected changes

3. **Verify Installation**:
   ```bash
   # After installation
   java -version
   ```
   Confirm the version matches the expected build

### Verifying SBOM

Download the SBOM from the release assets:
```bash
curl -LO https://github.com/Artagon/homebrew-jdk26valhalla/releases/download/v{VERSION}/sbom-{VERSION}.spdx.json
```

Verify it contains expected package information.

## Security Best Practices for Contributors

### When Contributing

1. **Never commit secrets** (API keys, tokens, credentials)
2. **Test locally** before submitting pull requests
3. **Follow secure coding practices**:
   - Quote shell variables
   - Validate inputs
   - Use timeouts for network operations
4. **Keep dependencies updated**
5. **Review Dependabot PRs** promptly

### Workflow Modifications

Changes to workflows require extra scrutiny:
- Avoid adding new network calls without timeouts
- Don't disable security features (e.g., `set -e`)
- Maintain least-privilege permissions
- Document security implications

## Incident Response

### If a Compromise is Detected

1. **Immediate Actions**:
   - Pause all releases
   - Revoke compromised credentials
   - Assess impact scope

2. **Investigation**:
   - Review audit logs
   - Check for unauthorized changes
   - Verify integrity of recent releases

3. **Communication**:
   - Notify users via GitHub Security Advisory
   - Provide remediation steps
   - Document timeline and impact

4. **Remediation**:
   - Release patched version
   - Update security measures
   - Conduct post-mortem

## Compliance and Standards

### Standards Followed

- **SPDX 2.3**: Software Bill of Materials format
- **Semantic Versioning**: Version numbering follows JDK versioning
- **GitHub Security Best Practices**: Actions and workflow security

### Future Enhancements

**SLSA Provenance** (planned):
- Will implement when OpenJDK supports SLSA
- Provides cryptographic guarantees about build process
- Enables comprehensive supply chain verification

**Multi-Source Verification** (planned):
- Cross-check versions against multiple sources
- Verify consistency across distribution channels
- Detect potential tampering

## Security Update Policy

### Dependency Updates

- GitHub Actions: Weekly Dependabot checks
- Homebrew formula: Updated when new JDK builds are released
- Security patches: Applied immediately upon discovery

### Workflow Updates

- Security improvements: Implemented promptly
- Breaking changes: Announced in advance
- Deprecations: Minimum 30-day notice

## Contact

For security concerns, please contact the repository maintainers through:
- GitHub Issues (for non-sensitive topics)
- Email (for security vulnerabilities - see repository contact info)

## Acknowledgments

This security policy is based on industry best practices and GitHub's security recommendations.

---

**Last Updated**: 2025-10-25
**Policy Version**: 1.0
