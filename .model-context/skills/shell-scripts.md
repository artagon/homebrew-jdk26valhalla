# Shell Scripting Best Practices

## Overview

Expert-level shell scripting skills for writing secure, maintainable, and robust bash/sh scripts with proper error handling, validation, and best practices.

## Core Principles

### 1. Script Header and Strictness

#### Strict Mode (Always)
```bash
#!/usr/bin/env bash
set -euo pipefail

# Explanation:
# -e: Exit on error
# -u: Exit on undefined variable
# -o pipefail: Exit on pipe failure
```

#### Alternative with IFS Protection
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# IFS: Prevents word splitting on spaces
# Useful for processing filenames with spaces
```

### 2. Error Handling

#### Trap for Cleanup
```bash
#!/usr/bin/env bash
set -euo pipefail

# Cleanup function
cleanup() {
  local exit_code=$?
  echo "Cleaning up..."
  rm -f /tmp/tempfile.*
  exit "$exit_code"
}

# Register cleanup on exit
trap cleanup EXIT INT TERM

# Script logic
main() {
  touch /tmp/tempfile.$$
  # ... work ...
}

main "$@"
```

#### Function Error Handling
```bash
# Check command success
if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is not installed" >&2
  exit 1
fi

# Capture output with error checking
if output=$(complex_command 2>&1); then
  echo "Success: $output"
else
  echo "Failed: $output" >&2
  exit 1
fi
```

### 3. Input Validation

#### Argument Validation
```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <version> <platform>

Arguments:
  version   - Version string (e.g., 26-ea+20)
  platform  - Platform (macos-arm64, macos-x64, linux-arm64, linux-x64)

Examples:
  $0 26-ea+20 macos-arm64
EOF
  exit 1
}

# Check argument count
if [ $# -ne 2 ]; then
  usage
fi

VERSION="$1"
PLATFORM="$2"

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+-ea\+[0-9]+$ ]]; then
  echo "ERROR: Invalid version format: $VERSION" >&2
  exit 1
fi

# Validate platform
case "$PLATFORM" in
  macos-arm64|macos-x64|linux-arm64|linux-x64)
    echo "✓ Valid platform: $PLATFORM"
    ;;
  *)
    echo "ERROR: Invalid platform: $PLATFORM" >&2
    exit 1
    ;;
esac
```

#### User Input Validation
```bash
read -rp "Enter build number (1-999): " build

# Validate numeric input
if ! [[ "$build" =~ ^[0-9]+$ ]]; then
  echo "ERROR: Not a number" >&2
  exit 1
fi

# Validate range
if [ "$build" -lt 1 ] || [ "$build" -gt 999 ]; then
  echo "ERROR: Build must be between 1 and 999" >&2
  exit 1
fi
```

### 4. Safe Command Execution

#### Quote All Variables
```bash
# ✅ CORRECT - Quoted variables
file_path="/path/to/my file.txt"
cat "$file_path"

# ❌ WRONG - Unquoted (breaks with spaces)
cat $file_path  # Breaks!

# ✅ CORRECT - Array expansion
files=("file1.txt" "file 2.txt" "file 3.txt")
for file in "${files[@]}"; do
  echo "$file"
done
```

#### Command Substitution
```bash
# ✅ MODERN - $() syntax
current_date=$(date +%Y-%m-%d)
file_count=$(find . -type f | wc -l)

# ❌ OLD STYLE - Backticks (avoid)
current_date=`date +%Y-%m-%d`
```

### 5. Path Handling

#### Absolute Paths
```bash
# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Resolve to absolute path
file_path="$(realpath "$relative_path")"

# Safe path operations
mkdir -p "$(dirname "$file_path")"
```

#### Path Validation
```bash
# Check file exists
if [ ! -f "$file_path" ]; then
  echo "ERROR: File not found: $file_path" >&2
  exit 1
fi

# Check directory exists
if [ ! -d "$directory" ]; then
  echo "ERROR: Directory not found: $directory" >&2
  exit 1
fi

# Check write permissions
if [ ! -w "$file_path" ]; then
  echo "ERROR: No write permission: $file_path" >&2
  exit 1
fi
```

### 6. Output and Logging

#### Colored Output
```bash
# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# Usage
echo -e "${GREEN}✓ Success${NC}"
echo -e "${RED}✗ Error${NC}"
echo -e "${YELLOW}⚠ Warning${NC}"
echo -e "${BLUE}ℹ Info${NC}"
```

#### Logging Function
```bash
log() {
  local level="$1"
  shift
  local message="$*"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  case "$level" in
    INFO)
      echo -e "${timestamp} ${BLUE}[INFO]${NC} $message"
      ;;
    SUCCESS)
      echo -e "${timestamp} ${GREEN}[SUCCESS]${NC} $message"
      ;;
    WARNING)
      echo -e "${timestamp} ${YELLOW}[WARNING]${NC} $message" >&2
      ;;
    ERROR)
      echo -e "${timestamp} ${RED}[ERROR]${NC} $message" >&2
      ;;
  esac
}

# Usage
log INFO "Starting process..."
log SUCCESS "Operation completed"
log WARNING "Deprecated feature used"
log ERROR "Operation failed"
```

### 7. File Operations

#### Safe File Creation
```bash
# Create with exclusive lock
temp_file=$(mktemp)

# Cleanup on exit
trap 'rm -f "$temp_file"' EXIT

# Write to temp file
cat > "$temp_file" <<EOF
Content here
EOF

# Atomic move
mv "$temp_file" "$target_file"
```

#### Reading Files Line by Line
```bash
# ✅ CORRECT - Handles spaces and special chars
while IFS= read -r line; do
  echo "Line: $line"
done < "$file"

# ✅ CORRECT - With process substitution
while IFS= read -r line; do
  echo "Line: $line"
done < <(grep "pattern" "$file")
```

### 8. Array Handling

#### Array Creation and Iteration
```bash
# Create array
platforms=("macos-arm64" "macos-x64" "linux-arm64" "linux-x64")

# Iterate
for platform in "${platforms[@]}"; do
  echo "Processing: $platform"
done

# Get array length
length=${#platforms[@]}

# Access specific element
first="${platforms[0]}"
```

#### Associative Arrays (Bash 4+)
```bash
# Declare
declare -A checksums

# Populate
checksums["macos-arm64"]="abc123..."
checksums["macos-x64"]="def456..."

# Iterate
for platform in "${!checksums[@]}"; do
  echo "$platform: ${checksums[$platform]}"
done
```

### 9. Function Best Practices

#### Function Definition
```bash
# Function with validation
download_file() {
  local url="$1"
  local output="$2"

  # Validate arguments
  if [ $# -ne 2 ]; then
    echo "ERROR: download_file requires 2 arguments" >&2
    return 1
  fi

  # Execute
  if curl -fsSL "$url" -o "$output"; then
    echo "✓ Downloaded: $output"
    return 0
  else
    echo "✗ Download failed: $url" >&2
    return 1
  fi
}

# Usage
if download_file "https://example.com/file.tar.gz" "output.tar.gz"; then
  echo "Success"
else
  echo "Failed"
  exit 1
fi
```

#### Return Values
```bash
# Return 0 for success, non-zero for failure
validate_version() {
  local version="$1"

  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return 0  # Success
  else
    return 1  # Failure
  fi
}

# Usage
if validate_version "1.2.3"; then
  echo "Valid version"
fi
```

### 10. Network Operations

#### Safe curl Usage
```bash
# ✅ CORRECT - With error handling
if curl -fsSL "$url" -o "$output"; then
  echo "✓ Downloaded: $url"
else
  echo "✗ Download failed: $url" >&2
  exit 1
fi

# Flags:
# -f: Fail on HTTP errors
# -s: Silent mode
# -S: Show errors
# -L: Follow redirects
```

#### Checksum Verification
```bash
download_and_verify() {
  local url="$1"
  local expected_sha="$2"
  local output="$3"

  # Download file
  if ! curl -fsSL "$url" -o "$output"; then
    echo "ERROR: Download failed" >&2
    return 1
  fi

  # Compute checksum
  local actual_sha
  actual_sha=$(shasum -a 256 "$output" | awk '{print $1}')

  # Verify
  if [ "$expected_sha" != "$actual_sha" ]; then
    echo "ERROR: Checksum mismatch!" >&2
    echo "Expected: $expected_sha" >&2
    echo "Actual:   $actual_sha" >&2
    rm -f "$output"
    return 1
  fi

  echo "✓ Checksum verified: $output"
  return 0
}
```

## Advanced Patterns

### 11. Parallel Execution
```bash
# Run tasks in background
pids=()

for platform in "${platforms[@]}"; do
  process_platform "$platform" &
  pids+=($!)
done

# Wait for all to complete
for pid in "${pids[@]}"; do
  if ! wait "$pid"; then
    echo "ERROR: Process $pid failed" >&2
    exit 1
  fi
done

echo "✓ All processes completed"
```

### 12. Dry Run Mode
```bash
DRY_RUN=false

while getopts "n" opt; do
  case "$opt" in
    n) DRY_RUN=true ;;
    *) usage ;;
  esac
done

execute() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute: $*"
  else
    "$@"
  fi
}

# Usage
execute mv file.txt newfile.txt
```

### 13. Configuration Files
```bash
# Load configuration
load_config() {
  local config_file="$1"

  if [ ! -f "$config_file" ]; then
    echo "ERROR: Config file not found: $config_file" >&2
    return 1
  fi

  # Source config (be careful with trust!)
  # shellcheck source=/dev/null
  source "$config_file"
}

# config.sh example:
# VERSION="1.2.3"
# PLATFORMS=("linux" "macos")
```

## Security Best Practices

### 14. Avoid Command Injection
```bash
# ❌ DANGEROUS - User input in eval
eval "echo $user_input"

# ❌ DANGEROUS - Unquoted user input
rm -rf $user_path

# ✅ SAFE - Validate and quote
if [[ "$user_path" =~ ^/safe/directory/.+ ]]; then
  rm -rf "$user_path"
fi
```

### 15. Secure Temporary Files
```bash
# ✅ SECURE - mktemp creates with 0600 permissions
temp_file=$(mktemp)
temp_dir=$(mktemp -d)

# Always cleanup
trap 'rm -rf "$temp_file" "$temp_dir"' EXIT
```

## Validation Checklist

- [ ] Strict mode enabled (`set -euo pipefail`)
- [ ] All variables quoted
- [ ] Error handling implemented
- [ ] Input validated
- [ ] Functions return proper exit codes
- [ ] Cleanup on exit (trap)
- [ ] No use of `eval` or `source` on untrusted input
- [ ] Paths are absolute or validated
- [ ] ShellCheck passes with no warnings

## Tools

**Linting:**
- [ShellCheck](https://www.shellcheck.net/) - Static analysis
- [shfmt](https://github.com/mvdan/sh) - Formatter

**Testing:**
- [Bats](https://github.com/bats-core/bats-core) - Bash testing framework

## Resources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls)
- [Bash Guide](https://mywiki.wooledge.org/BashGuide)
