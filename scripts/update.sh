#!/usr/bin/env bash
# Update JDK 26 EA cask and formula to the latest build
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FORMULA="$ROOT/Formula/jdk26ea.rb"
CASK="$ROOT/Casks/jdk26ea.rb"

# JDK page URL
JDK_PAGE="https://jdk.java.net/26/"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Fetch the JDK page and extract build number
log_info "Fetching latest JDK 26 EA build information from $JDK_PAGE"
page_content=$(curl -fsSL "$JDK_PAGE" 2>/dev/null || {
    log_error "Failed to fetch JDK page"
    exit 1
})

# Extract build number from page
build_number=$(printf '%s\n' "$page_content" | awk '
    match($0, /Build ([0-9]+)/, m) {
        print m[1]
        exit
    }
')

if [[ -z "$build_number" ]]; then
    log_error "Could not extract build number from JDK page"
    exit 1
fi

cask_version="26-ea+${build_number},${build_number}"
version="26-ea+${build_number}"
log_info "Latest build: $version (cask version key: $cask_version)"

# Get current version from cask
current_version=$(sed -n 's/^  version "\(.*\)"/\1/p' "$CASK" 2>/dev/null | head -1)
current_version=${current_version:-unknown}
log_info "Current version: $current_version"

if [[ "$cask_version" == "$current_version" ]]; then
    log_info "Already at latest version: $cask_version"
    exit 0
fi

# Define download URLs
base_url="https://download.java.net/java/early_access/jdk26/${build_number}/GPL"
mac_arm_url="${base_url}/openjdk-${version}_macos-aarch64_bin.tar.gz"
mac_x64_url="${base_url}/openjdk-${version}_macos-x64_bin.tar.gz"
linux_arm_url="${base_url}/openjdk-${version}_linux-aarch64_bin.tar.gz"
linux_x64_url="${base_url}/openjdk-${version}_linux-x64_bin.tar.gz"

# Function to get SHA256 from remote .sha256 file
get_remote_sha256() {
    local url="$1"
    local sha_url="${url}.sha256"

    local sha=$(curl -fsSL "$sha_url" 2>/dev/null | awk '{print $1}')

    if [[ -z "$sha" || ! "$sha" =~ ^[a-f0-9]{64}$ ]]; then
        log_error "Failed to get valid SHA256 for $url"
        return 1
    fi

    echo "$sha"
}

# Fetch all SHA256 checksums
log_info "Fetching SHA256 checksums..."
log_info "  - mac_arm"
mac_arm_sha=$(get_remote_sha256 "$mac_arm_url") || exit 1
log_info "  - mac_x64"
mac_x64_sha=$(get_remote_sha256 "$mac_x64_url") || exit 1
log_info "  - linux_arm"
linux_arm_sha=$(get_remote_sha256 "$linux_arm_url") || exit 1
log_info "  - linux_x64"
linux_x64_sha=$(get_remote_sha256 "$linux_x64_url") || exit 1

log_info "All checksums fetched successfully"

# Backup files
log_info "Creating backups..."
cp "$CASK" "${CASK}.backup"
cp "$FORMULA" "${FORMULA}.backup"

# Update CASK
log_info "Updating Cask..."

# Update version
sed -i.tmp "s/version \".*\"/version \"$cask_version\"/" "$CASK"

# Update checksums in cask
awk -v arm="$mac_arm_sha" -v intel="$mac_x64_sha" '
    /sha256 arm:/ {
        print "  sha256 arm:   \"" arm "\","
        print "         intel: \"" intel "\""
        next
    }
    { print }
' "$CASK" > "${CASK}.new" && mv "${CASK}.new" "$CASK"

# Remove sed temp files
rm -f "${CASK}.tmp"

# Update FORMULA
log_info "Updating Formula..."

# Update version
sed -i.tmp "s/version \".*\"/version \"$version\"/" "$FORMULA"

# Update all URLs
sed -i.tmp \
    -e "s|https://download.java.net/java/early_access/jdk26/[0-9]*/GPL/openjdk-.*_macos-aarch64_bin.tar.gz|${mac_arm_url}|g" \
    -e "s|https://download.java.net/java/early_access/jdk26/[0-9]*/GPL/openjdk-.*_macos-x64_bin.tar.gz|${mac_x64_url}|g" \
    -e "s|https://download.java.net/java/early_access/jdk26/[0-9]*/GPL/openjdk-.*_linux-aarch64_bin.tar.gz|${linux_arm_url}|g" \
    -e "s|https://download.java.net/java/early_access/jdk26/[0-9]*/GPL/openjdk-.*_linux-x64_bin.tar.gz|${linux_x64_url}|g" \
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
echo "Checksums:"
echo "  macOS ARM64:   $mac_arm_sha"
echo "  macOS x64:     $mac_x64_sha"
echo "  Linux ARM64:   $linux_arm_sha"
echo "  Linux x64:     $linux_x64_sha"
echo ""
log_info "Run 'git diff' to review changes"
log_info "Run 'git add . && git commit -m \"Update to JDK $version\"' to commit"
