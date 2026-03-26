#!/usr/bin/env bash
# Update JDK Valhalla cask and formula to the latest build
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Directories
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CASK="$ROOT/Casks/jdkvalhalla.rb"

# JDK Valhalla page URL
JDK_PAGE="https://jdk.java.net/valhalla/"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $*"
}

# Fetch the JDK Valhalla page and extract build information
log_info "Fetching latest JDK Valhalla build information from $JDK_PAGE"
page_content=$(curl -fsSL "$JDK_PAGE" 2>/dev/null || {
    log_error "Failed to fetch JDK Valhalla page"
    exit 1
})

# Extract the Valhalla build version string (e.g. "27-valhalla+27-1")
# Look for patterns like: openjdk-27-jep401ea3+1-1_macos-aarch64_bin.tar.gz
build_version=$(printf '%s\n' "$page_content" | grep -oE 'openjdk-[0-9]+-[a-z0-9]+\+[0-9]+-[0-9]+' | head -1 | sed 's/^openjdk-//')

if [[ -z "$build_version" ]]; then
    log_error "Could not extract Valhalla build version from JDK page"
    exit 1
fi

# Extract the major JDK version (e.g. "27" from "27-jep401ea3+1-1")
major_version=$(echo "$build_version" | grep -oE '^[0-9]+')

if [[ -z "$major_version" ]]; then
    log_error "Could not extract major JDK version from build version: $build_version"
    exit 1
fi

FORMULA="$ROOT/Formula/jdkvalhalla@${major_version}.rb"

log_info "Detected JDK major version: $major_version"
log_info "Detected Valhalla build version: $build_version"

# Extract download URLs from the page (pattern: download.java.net/java/early_access/valhalla/...)
base_url_pattern="https://download.java.net/java/early_access/valhalla/"

mac_arm_url=$(printf '%s\n' "$page_content" | grep -oE "${base_url_pattern}[^\"]*_macos-aarch64_bin\\.tar\\.gz" | head -1)
mac_x64_url=$(printf '%s\n' "$page_content" | grep -oE "${base_url_pattern}[^\"]*_macos-x64_bin\\.tar\\.gz" | head -1)
linux_arm_url=$(printf '%s\n' "$page_content" | grep -oE "${base_url_pattern}[^\"]*_linux-aarch64_bin\\.tar\\.gz" | head -1)
linux_x64_url=$(printf '%s\n' "$page_content" | grep -oE "${base_url_pattern}[^\"]*_linux-x64_bin\\.tar\\.gz" | head -1)

if [[ -z "$mac_arm_url" || -z "$mac_x64_url" || -z "$linux_arm_url" || -z "$linux_x64_url" ]]; then
    log_error "Could not extract all download URLs from JDK Valhalla page"
    [[ -z "$mac_arm_url" ]] && log_error "  Missing: macOS ARM64 URL"
    [[ -z "$mac_x64_url" ]] && log_error "  Missing: macOS x64 URL"
    [[ -z "$linux_arm_url" ]] && log_error "  Missing: Linux ARM64 URL"
    [[ -z "$linux_x64_url" ]] && log_error "  Missing: Linux x64 URL"
    exit 1
fi

log_info "Download URLs found:"
log_info "  macOS ARM64: $mac_arm_url"
log_info "  macOS x64:   $mac_x64_url"
log_info "  Linux ARM64: $linux_arm_url"
log_info "  Linux x64:   $linux_x64_url"

# Build the cask version string
# Valhalla cask version format: <build_version>,<build_number_suffix>
# e.g. "27-jep401ea3+1-1,1"
cask_build_number=$(echo "$build_version" | grep -oE '\+[0-9]+' | head -1 | tr -d '+')
cask_version="${build_version},${cask_build_number}"
version="$build_version"

log_info "Cask version key: $cask_version"

# Get current version from cask
if [[ -f "$CASK" ]]; then
    current_version=$(sed -n 's/^  version "\(.*\)"/\1/p' "$CASK" 2>/dev/null | head -1)
    current_version=${current_version:-unknown}
else
    current_version="unknown"
fi
log_info "Current version: $current_version"

if [[ "$cask_version" == "$current_version" ]]; then
    log_info "Already at latest version: $cask_version"
    exit 0
fi

# Function to independently compute SHA256 by downloading the tarball
compute_sha256() {
    local url="$1"
    local label="$2"
    local tmpfile
    tmpfile=$(mktemp)
    trap "rm -f '$tmpfile'" RETURN

    log_step "Downloading $label to compute SHA256..."
    if ! curl -fsSL -o "$tmpfile" "$url" 2>/dev/null; then
        log_error "Failed to download $url"
        return 1
    fi

    local computed_sha
    computed_sha=$(shasum -a 256 "$tmpfile" | awk '{print $1}')
    echo "$computed_sha"
}

# Function to get SHA256 from remote .sha256 file
get_remote_sha256() {
    local url="$1"
    local sha_url="${url}.sha256"

    local sha
    sha=$(curl -fsSL "$sha_url" 2>/dev/null | awk '{print $1}')

    if [[ -z "$sha" || ! "$sha" =~ ^[a-f0-9]{64}$ ]]; then
        log_error "Failed to get valid SHA256 from $sha_url"
        return 1
    fi

    echo "$sha"
}

# Fetch and verify all SHA256 checksums
log_info "Fetching and verifying SHA256 checksums (downloading each tarball independently)..."

log_step "Processing macOS ARM64..."
mac_arm_sha_remote=$(get_remote_sha256 "$mac_arm_url") || exit 1
mac_arm_sha_computed=$(compute_sha256 "$mac_arm_url" "macOS ARM64") || exit 1
if [[ "$mac_arm_sha_remote" != "$mac_arm_sha_computed" ]]; then
    log_error "SHA256 MISMATCH for macOS ARM64!"
    log_error "  Remote .sha256 file: $mac_arm_sha_remote"
    log_error "  Computed from download: $mac_arm_sha_computed"
    exit 1
fi
log_info "  macOS ARM64 SHA256 verified: $mac_arm_sha_remote"

log_step "Processing macOS x64..."
mac_x64_sha_remote=$(get_remote_sha256 "$mac_x64_url") || exit 1
mac_x64_sha_computed=$(compute_sha256 "$mac_x64_url" "macOS x64") || exit 1
if [[ "$mac_x64_sha_remote" != "$mac_x64_sha_computed" ]]; then
    log_error "SHA256 MISMATCH for macOS x64!"
    log_error "  Remote .sha256 file: $mac_x64_sha_remote"
    log_error "  Computed from download: $mac_x64_sha_computed"
    exit 1
fi
log_info "  macOS x64 SHA256 verified: $mac_x64_sha_remote"

log_step "Processing Linux ARM64..."
linux_arm_sha_remote=$(get_remote_sha256 "$linux_arm_url") || exit 1
linux_arm_sha_computed=$(compute_sha256 "$linux_arm_url" "Linux ARM64") || exit 1
if [[ "$linux_arm_sha_remote" != "$linux_arm_sha_computed" ]]; then
    log_error "SHA256 MISMATCH for Linux ARM64!"
    log_error "  Remote .sha256 file: $linux_arm_sha_remote"
    log_error "  Computed from download: $linux_arm_sha_computed"
    exit 1
fi
log_info "  Linux ARM64 SHA256 verified: $linux_arm_sha_remote"

log_step "Processing Linux x64..."
linux_x64_sha_remote=$(get_remote_sha256 "$linux_x64_url") || exit 1
linux_x64_sha_computed=$(compute_sha256 "$linux_x64_url" "Linux x64") || exit 1
if [[ "$linux_x64_sha_remote" != "$linux_x64_sha_computed" ]]; then
    log_error "SHA256 MISMATCH for Linux x64!"
    log_error "  Remote .sha256 file: $linux_x64_sha_remote"
    log_error "  Computed from download: $linux_x64_sha_computed"
    exit 1
fi
log_info "  Linux x64 SHA256 verified: $linux_x64_sha_remote"

# Use the verified checksums
mac_arm_sha="$mac_arm_sha_remote"
mac_x64_sha="$mac_x64_sha_remote"
linux_arm_sha="$linux_arm_sha_remote"
linux_x64_sha="$linux_x64_sha_remote"

log_info "All checksums fetched and independently verified"

# Verify target files exist
if [[ ! -f "$CASK" ]]; then
    log_error "Cask file not found: $CASK"
    exit 1
fi

if [[ ! -f "$FORMULA" ]]; then
    log_warn "Formula file not found: $FORMULA"
    log_warn "You may need to create Formula/jdkvalhalla@${major_version}.rb first."
    exit 1
fi

# Backup files
log_info "Creating backups..."
cp "$CASK" "${CASK}.backup"
cp "$FORMULA" "${FORMULA}.backup"

# Update CASK
log_info "Updating Cask (Casks/jdkvalhalla.rb)..."

# Update version
sed -i.tmp "s/version \".*\"/version \"$cask_version\"/" "$CASK"

# Update checksums in cask
awk -v arm="$mac_arm_sha" -v intel="$mac_x64_sha" '
    /sha256 arm:/ {
        print "  sha256 arm:   \"" arm "\","
        print "         intel: \"" intel "\""
        next
    }
    /intel:/ && !/sha256/ { next }
    { print }
' "$CASK" > "${CASK}.new" && mv "${CASK}.new" "$CASK"

# Remove sed temp files
rm -f "${CASK}.tmp"

# Update FORMULA
log_info "Updating Formula (Formula/jdkvalhalla@${major_version}.rb)..."

# Update version
sed -i.tmp "s/version \".*\"/version \"$version\"/" "$FORMULA"

# Update all URLs (pattern: download.java.net/java/early_access/valhalla/...)
sed -i.tmp \
    -e "s|https://download.java.net/java/early_access/valhalla/[^\"]*_macos-aarch64_bin.tar.gz|${mac_arm_url}|g" \
    -e "s|https://download.java.net/java/early_access/valhalla/[^\"]*_macos-x64_bin.tar.gz|${mac_x64_url}|g" \
    -e "s|https://download.java.net/java/early_access/valhalla/[^\"]*_linux-aarch64_bin.tar.gz|${linux_arm_url}|g" \
    -e "s|https://download.java.net/java/early_access/valhalla/[^\"]*_linux-x64_bin.tar.gz|${linux_x64_url}|g" \
    "$FORMULA"

# Update checksums in formula
awk -v mac_arm="$mac_arm_sha" \
    -v mac_x64="$mac_x64_sha" \
    -v linux_arm="$linux_arm_sha" \
    -v linux_x64="$linux_x64_sha" '
    BEGIN { in_macos=0; in_linux=0; in_arm_block=0 }

    /on_macos do/ { in_macos=1; in_linux=0; next_is_macos=1 }
    /on_linux do/ { in_linux=1; in_macos=0; next_is_linux=1 }

    /if Hardware::CPU\.arm\?/ { in_arm_block=1 }
    /else$/ { in_arm_block=0 }
    /^  end$/ {
        if (in_macos || in_linux) {
            in_macos=0
            in_linux=0
        }
    }

    /sha256/ {
        if (in_macos && in_arm_block) {
            gsub(/sha256 ".*"/, "sha256 \"" mac_arm "\"")
        }
        else if (in_macos && !in_arm_block) {
            gsub(/sha256 ".*"/, "sha256 \"" mac_x64 "\"")
        }
        else if (in_linux && in_arm_block) {
            gsub(/sha256 ".*"/, "sha256 \"" linux_arm "\"")
        }
        else if (in_linux && !in_arm_block) {
            gsub(/sha256 ".*"/, "sha256 \"" linux_x64 "\"")
        }
    }

    {print}
' "$FORMULA" > "${FORMULA}.new" && mv "${FORMULA}.new" "$FORMULA"

# Remove sed temp files
rm -f "${FORMULA}.tmp"

# Validate Ruby syntax
log_info "Validating Ruby syntax..."

if ! ruby -c "$CASK" > /dev/null 2>&1; then
    log_error "Cask syntax validation failed!"
    log_warn "Restoring backup..."
    mv "${CASK}.backup" "$CASK"
    mv "${FORMULA}.backup" "$FORMULA"
    exit 1
fi

if ! ruby -c "$FORMULA" > /dev/null 2>&1; then
    log_error "Formula syntax validation failed!"
    log_warn "Restoring backup..."
    mv "${CASK}.backup" "$CASK"
    mv "${FORMULA}.backup" "$FORMULA"
    exit 1
fi

# Clean up backups
rm -f "${CASK}.backup" "${FORMULA}.backup"

# Summary
log_info "Successfully updated to $version"
echo ""
echo "Summary of changes:"
echo "  Previous cask version:   $current_version"
echo "  New cask version:        $cask_version"
echo "  Formula version updated: $version"
echo ""
echo "Updated files:"
echo "  - $CASK"
echo "  - $FORMULA"
echo ""
echo "Checksums (independently verified):"
echo "  macOS ARM64:   $mac_arm_sha"
echo "  macOS x64:     $mac_x64_sha"
echo "  Linux ARM64:   $linux_arm_sha"
echo "  Linux x64:     $linux_x64_sha"
echo ""
log_info "Run 'git diff' to review changes"
log_info "Run 'git add . && git commit -m \"chore(formula): update JDK Valhalla to $version\"' to commit"
