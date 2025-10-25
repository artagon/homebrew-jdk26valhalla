# Security Best Practices

## Overview

Comprehensive security expertise covering input validation, path traversal prevention, command injection mitigation, cryptographic verification, and secure coding practices.

## Core Security Principles

### 1. Input Validation

#### Never Trust External Input
```bash
# ✅ VALIDATE - Regex pattern matching
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version format" >&2
  exit 1
fi

# ✅ VALIDATE - Allowlist approach
case "$platform" in
  linux|macos|windows) ;;
  *) echo "Invalid platform" >&2; exit 1 ;;
esac

# ✅ VALIDATE - Range checking
if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
  echo "Port must be 1-65535" >&2
  exit 1
fi
```

#### Common Validation Patterns
```bash
# Alphanumeric only
[[ "$value" =~ ^[a-zA-Z0-9]+$ ]]

# Semantic version
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]

# Email (basic)
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]

# URL (basic)
[[ "$url" =~ ^https?://[a-zA-Z0-9.-]+(/.*)?$ ]]

# SHA-256 checksum
[[ "$sha" =~ ^[a-f0-9]{64}$ ]]

# IPv4 address
[[ "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
```

### 2. Path Traversal Prevention

#### Canonical Path Validation
```bash
#!/usr/bin/env bash

# ❌ VULNERABLE - No validation
user_file="$1"
cat "/var/data/$user_file"  # Could be: ../../../etc/passwd

# ✅ SECURE - Resolve and validate
validate_path() {
  local user_path="$1"
  local allowed_prefix="$2"

  # Resolve to canonical path
  local resolved
  resolved=$(realpath -m "$user_path")

  # Validate path starts with allowed prefix
  if [[ "$resolved" != "$allowed_prefix"* ]]; then
    echo "ERROR: Path outside allowed directory" >&2
    return 1
  fi

  echo "$resolved"
}

# Usage
if safe_path=$(validate_path "$user_input" "/var/data"); then
  cat "$safe_path"
else
  exit 1
fi
```

#### Directory Traversal Patterns
```bash
# ❌ DANGEROUS patterns
../../../etc/passwd
..\/..\/..\/etc/passwd
....//....//etc/passwd

# ✅ PROTECTION
realpath_safe() {
  local path="$1"
  local base="$2"

  # Resolve to absolute path
  local resolved=$(realpath -m "$path")

  # Check it starts with base directory
  [[ "$resolved" == "$base"* ]] || return 1

  echo "$resolved"
}
```

### 3. Command Injection Prevention

#### Shell Command Safety
```bash
# ❌ VULNERABLE - User input in command
user_input="test; rm -rf /"
eval "echo $user_input"  # DISASTER!

# ❌ VULNERABLE - Unquoted variables
filename="test file.txt; rm -rf /"
cat $filename  # Executes rm!

# ✅ SECURE - Quote variables
cat "$filename"

# ✅ SECURE - Array for arguments
args=("$user_input")
grep "${args[@]}" file.txt
```

#### SQL Injection Prevention
```bash
# ❌ VULNERABLE
query="SELECT * FROM users WHERE name = '$user_name'"

# ✅ SECURE - Use prepared statements (conceptual)
# In shell scripts, avoid direct SQL
# Use parameterized queries in actual database clients
```

### 4. Cryptographic Verification

#### Checksum Verification
```bash
verify_checksum() {
  local file="$1"
  local expected_sha256="$2"

  # Validate checksum format
  if ! [[ "$expected_sha256" =~ ^[a-f0-9]{64}$ ]]; then
    echo "ERROR: Invalid SHA-256 format" >&2
    return 1
  fi

  # Compute actual checksum
  local actual_sha256
  actual_sha256=$(shasum -a 256 "$file" | awk '{print $1}')

  # Compare
  if [ "$expected_sha256" != "$actual_sha256" ]; then
    echo "ERROR: Checksum mismatch!" >&2
    echo "Expected: $expected_sha256" >&2
    echo "Actual:   $actual_sha256" >&2
    return 1
  fi

  echo "✓ Checksum verified" >&2
  return 0
}
```

#### Signature Verification
```bash
verify_signature() {
  local file="$1"
  local signature="$2"
  local public_key="$3"

  # Verify with GPG
  if gpg --verify --keyring "$public_key" "$signature" "$file" 2>/dev/null; then
    echo "✓ Signature valid" >&2
    return 0
  else
    echo "ERROR: Invalid signature" >&2
    return 1
  fi
}
```

### 5. Secret Management

#### Never Commit Secrets
```bash
# ❌ DANGEROUS
API_KEY="sk-1234567890abcdef"  # Hardcoded secret!

# ✅ SECURE - Environment variables
if [ -z "${API_KEY:-}" ]; then
  echo "ERROR: API_KEY not set" >&2
  exit 1
fi

# ✅ SECURE - Load from secure store
API_KEY=$(security find-generic-password -s "my-app" -w)
```

#### Secrets in Git
```bash
# .gitignore patterns
*.key
*.pem
*.p12
*.pfx
.env
.env.local
secrets.yaml
credentials.json
```

### 6. Privilege Escalation Prevention

#### Minimal Privileges
```bash
# ✅ Drop privileges when possible
if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Do not run as root" >&2
  exit 1
fi

# ✅ Use sudo only when necessary
if [ -w "/system/path" ]; then
  # Can write without sudo
  install_file /system/path
else
  # Needs sudo
  sudo install_file /system/path
fi
```

#### Safe sudo Usage
```bash
# ❌ DANGEROUS - Allows any user command
sudo $user_command

# ✅ SECURE - Specific commands only
case "$operation" in
  install)
    sudo /usr/bin/install -m 755 "$file" /usr/local/bin/
    ;;
  uninstall)
    sudo /bin/rm -f /usr/local/bin/"$file"
    ;;
  *)
    echo "ERROR: Unknown operation" >&2
    exit 1
    ;;
esac
```

### 7. HTTPS and TLS

#### Require HTTPS
```bash
validate_https_url() {
  local url="$1"

  # Must start with https://
  if [[ "$url" != https://* ]]; then
    echo "ERROR: Only HTTPS URLs allowed" >&2
    return 1
  fi

  # Validate domain (if applicable)
  if [[ "$url" != https://trusted-domain.com/* ]]; then
    echo "ERROR: Untrusted domain" >&2
    return 1
  fi

  return 0
}
```

#### Certificate Verification
```bash
# curl with certificate verification (default)
curl -fsSL "$url" -o output

# curl with custom CA bundle
curl --cacert /path/to/ca-bundle.crt "$url" -o output

# curl with certificate pinning
curl --pinnedpubkey "sha256//base64hash..." "$url" -o output
```

### 8. Race Conditions (TOCTOU)

#### Time-of-Check Time-of-Use
```bash
# ❌ VULNERABLE - File could change between check and use
if [ -f "$file" ]; then
  # Attacker could replace file here!
  cat "$file"
fi

# ✅ SECURE - Atomic operations
if content=$(cat "$file" 2>/dev/null); then
  echo "$content"
else
  echo "ERROR: Cannot read file" >&2
  exit 1
fi
```

#### Atomic File Operations
```bash
# ✅ Atomic write with temp file
temp=$(mktemp)
trap 'rm -f "$temp"' EXIT

cat > "$temp" <<EOF
Content
EOF

# Atomic move
mv "$temp" "$final_destination"
```

### 9. Denial of Service Prevention

#### Resource Limits
```bash
# Limit file size
MAX_FILE_SIZE=$((100 * 1024 * 1024))  # 100 MB

if [ -f "$file" ]; then
  file_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
  if [ "$file_size" -gt "$MAX_FILE_SIZE" ]; then
    echo "ERROR: File too large" >&2
    exit 1
  fi
fi

# Timeout for operations
timeout 30s curl "$url" -o output || {
  echo "ERROR: Operation timed out" >&2
  exit 1
}
```

#### Input Length Limits
```bash
validate_input_length() {
  local input="$1"
  local max_length="${2:-1000}"

  if [ "${#input}" -gt "$max_length" ]; then
    echo "ERROR: Input exceeds max length ($max_length)" >&2
    return 1
  fi

  return 0
}
```

### 10. Logging and Auditing

#### Secure Logging
```bash
log_secure() {
  local level="$1"
  shift
  local message="$*"

  # Sanitize message (remove sensitive data)
  message=$(echo "$message" | sed 's/password=[^ ]*/password=***/g')
  message=$(echo "$message" | sed 's/token=[^ ]*/token=***/g')

  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] [$level] $message" >> /var/log/app.log
}

# Usage
log_secure INFO "User logged in: $username"
log_secure ERROR "Login failed for: $username"
```

#### Audit Trail
```bash
audit_log() {
  local action="$1"
  local user="${USER:-unknown}"
  local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  echo "$timestamp | $user | $action" >> /var/log/audit.log
}

# Usage
audit_log "file_accessed: /etc/passwd"
audit_log "configuration_changed: server.conf"
```

## Security Checklists

### Code Review Checklist
- [ ] All external input validated
- [ ] No hardcoded secrets or credentials
- [ ] Paths validated to prevent traversal
- [ ] Commands use quoted variables
- [ ] No use of `eval` on untrusted input
- [ ] HTTPS required for all network calls
- [ ] Checksums verified for downloads
- [ ] Minimal privileges used
- [ ] Error messages don't leak sensitive info
- [ ] Logging doesn't expose secrets

### Deployment Checklist
- [ ] Secrets loaded from environment/vault
- [ ] File permissions restrictive (644 or 600)
- [ ] No world-writable files or directories
- [ ] TLS/SSL certificates valid and current
- [ ] Security updates applied
- [ ] Audit logging enabled
- [ ] Rate limiting in place
- [ ] Backups encrypted

## Common Vulnerabilities

| Vulnerability | Example | Fix |
|--------------|---------|-----|
| Command injection | `eval "$user_input"` | Validate input, quote variables |
| Path traversal | `cat "/data/$user_file"` | Use `realpath`, validate prefix |
| SQL injection | `"SELECT * WHERE id=$id"` | Use prepared statements |
| XSS | `echo "$user_input"` | HTML encode output |
| Insecure deserialization | `eval "$(cat data)"` | Use safe parsers (jq, etc) |
| Broken authentication | No password validation | Enforce strong passwords |
| Sensitive data exposure | `echo "Token: $TOKEN"` | Sanitize logs |
| XXE | `xmllint "$user_xml"` | Disable external entities |
| Broken access control | No permission checks | Validate user permissions |
| SSRF | `curl "$user_url"` | Validate URL, allowlist domains |

## Security Tools

**Static Analysis:**
- [ShellCheck](https://www.shellcheck.net/) - Shell script analysis
- [Bandit](https://github.com/PyCQA/bandit) - Python security linter
- [Semgrep](https://semgrep.dev/) - Multi-language analysis

**Secret Scanning:**
- [GitGuardian](https://www.gitguardian.com/)
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)
- [detect-secrets](https://github.com/Yelp/detect-secrets)

**Dependency Scanning:**
- [Snyk](https://snyk.io/)
- [Dependabot](https://github.com/dependabot)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)

## Resources

**Security Guidelines:**
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

**Best Practices:**
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [Security by Design Principles](https://owasp.org/www-community/Security_by_Design_Principles)
- [Secure Coding Guidelines](https://wiki.sei.cmu.edu/confluence/display/seccode)
