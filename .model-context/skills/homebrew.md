# Homebrew Formula and Cask Development Skills

## Overview

Expert-level skills for developing secure, compliant Homebrew formulas and casks for distributing JDK 26 Early Access builds across macOS and Linux platforms.

## Core Competencies

### 1. Cask Development

#### Stanza Ordering (Critical)
```ruby
cask "jdk26ea" do
  # 1. Architecture declaration
  arch arm: "aarch64", intel: "x64"

  # 2. Version (MUST be second)
  version "26-ea+20,20"

  # 3. SHA256 (MUST come before url!)
  sha256 arm:   "dc75cdb507e47a66b0edc73d1cfc4a1c011078d5d0785c7660320d2e9c3e04d4",
         intel: "5f9c11b5e0d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2"

  # 4. URL
  url "https://download.java.net/java/early_access/jdk26/#{version.csv.second}/GPL/openjdk-#{version.csv.first}_macos-#{arch}_bin.tar.gz"

  # 5. Name
  name "OpenJDK 26 Early Access"

  # 6. Description
  desc "Early access builds of OpenJDK 26"

  # 7. Homepage
  homepage "https://jdk.java.net/26/"

  # 8. Postflight (installation logic)
  postflight do
    # Secure installation code
  end

  # 9. Uninstall
  uninstall delete: "/Library/Java/JavaVirtualMachines/jdk-26-ea.jdk"
end
```

**Key Rules:**
- Empty lines separate stanza groups
- `sha256` MUST come before `url` (RuboCop requirement)
- No logical operators in `unless` blocks
- Use `arch` for multi-architecture support

### 2. Formula Development

#### Basic Structure
```ruby
class Jdk26ea < Formula
  desc "Early access builds of OpenJDK 26"
  homepage "https://jdk.java.net/26/"
  version "26-ea+20"

  # Platform-specific URLs and checksums
  on_macos do
    if Hardware::CPU.arm?
      url "https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_macos-aarch64_bin.tar.gz"
      sha256 "dc75cdb507e47a66b0edc73d1cfc4a1c011078d5d0785c7660320d2e9c3e04d4"
    else
      url "https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_macos-x64_bin.tar.gz"
      sha256 "5f9c11b5e0d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2e5d1e5c2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_linux-aarch64_bin.tar.gz"
      sha256 "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2"
    else
      url "https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_linux-x64_bin.tar.gz"
      sha256 "f2e1d0c9b8a7z6y5x4w3v2u1t0s9r8q7p6o5n4m3l2k1j0i9h8g7f6e5d4c3b2a1"
    end
  end

  def install
    # Extract directory name
    libexec.install Dir["jdk-#{version}*/*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/java", "-version"
    system "#{bin}/javac", "-version"
  end
end
```

### 3. Secure Postflight Implementation

#### Path Validation (CRITICAL)
```ruby
postflight do
  require "pathname"

  # Step 1: Resolve staging root to prevent symlink attacks
  staged_root = staged_path.realpath

  # Step 2: Find JDK candidates
  candidates = Dir["#{staged_root}/jdk-*.jdk"]

  # Step 3: Validate exactly one candidate
  odie "Expected exactly one JDK bundle in #{staged_root}, found #{candidates.length}" unless candidates.length == 1

  # Step 4: Resolve and validate source path
  jdk_src = Pathname(candidates.first).realpath
  odie "Staged JDK bundle #{jdk_src} is not a directory" unless jdk_src.directory?

  # Step 5: CRITICAL - Prevent directory traversal
  odie "Resolved JDK path escapes staging area" unless jdk_src.to_s.start_with?(staged_root.to_s)

  # Step 6: Define secure target
  jdk_target = Pathname("/Library/Java/JavaVirtualMachines/jdk-26-ea.jdk")

  # Step 7: Remove existing installation if present
  if jdk_target.exist?
    ohai "Removing existing JDK at #{jdk_target}"
    system_command! "/bin/rm",
                    args: ["-rf", jdk_target.to_s],
                    sudo: true
  end

  # Step 8: Copy with ditto (preferred over rsync/cp on macOS)
  ohai "Installing JDK to #{jdk_target}"
  system_command! "/usr/bin/ditto",
                  args: ["--noqtn", jdk_src.to_s, jdk_target.to_s],
                  sudo: true
end
```

**Security Principles:**
- `realpath` resolves all symlinks
- Validate candidate count exactly
- Confirm paths are directories
- Prevent path traversal attacks
- Use Apple-signed commands only
- Fail fast with `system_command!` (with `!`)

### 4. Command Execution Security

#### Approved Commands (Allowlist)
```ruby
# ✅ Apple-signed commands (SAFE)
"/usr/bin/ditto"     # Preferred for file copying
"/bin/mkdir"         # Create directories
"/bin/rm"            # Remove files (with validation)
"/bin/chmod"         # Change permissions
"/bin/ln"            # Create symlinks

# ❌ FORBIDDEN commands
"rsync"              # Not Apple-signed
"curl"               # Use Homebrew download instead
"wget"               # Use Homebrew download instead
"bash"               # No shell execution
"sh"                 # No shell execution
"/usr/bin/ruby"      # No dynamic code execution
```

#### system_command! Patterns
```ruby
# ✅ CORRECT - Args array prevents injection
system_command! "/bin/mkdir",
                args: ["-p", directory_path],
                sudo: true

# ❌ DANGEROUS - String interpolation allows injection
system_command! "/bin/mkdir -p #{directory_path}", sudo: true

# ✅ CORRECT - Explicit error handling
begin
  system_command! "/usr/bin/ditto",
                  args: ["--noqtn", src, dst],
                  sudo: true
rescue => e
  odie "Installation failed: #{e.message}"
end
```

### 5. Error Handling and User Messages

#### Message Types
```ruby
# Fatal errors - stops execution
odie "JDK source directory not found"
odie "Expected exactly one JDK bundle, found #{count}"
odie "Path escapes staging area"

# Informational messages
ohai "Installing JDK 26 EA to #{target}"
ohai "Removing existing installation"

# Warnings (non-fatal)
opoo "JDK installation already exists, will replace"
opoo "Using non-standard installation path"
```

### 6. Checksum Verification

#### HTTPS + SHA256 Required
```ruby
# ✅ CORRECT - Both HTTPS and SHA256
sha256 "dc75cdb507e47a66b0edc73d1cfc4a1c011078d5d0785c7660320d2e9c3e04d4"
url "https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_macos-aarch64_bin.tar.gz"

# ❌ FORBIDDEN - No checksum
url "https://example.com/file.tar.gz"  # DANGEROUS!

# ❌ FORBIDDEN - Bypass checksum
sha256 :no_check  # NEVER USE THIS

# ❌ FORBIDDEN - Dynamic checksum
sha256 ENV['CHECKSUM']  # Insecure
```

#### Checksum Workflow
1. Download official checksum file
2. Verify checksum format (`^[a-f0-9]{64}$`)
3. Download binary
4. Compute actual checksum
5. Compare expected vs actual
6. Fail if mismatch

### 7. Validation and Testing

#### Pre-Commit Validation
```bash
# Syntax validation
ruby -c Casks/jdk26ea.rb
ruby -c Formula/jdk26ea.rb

# Style checking
brew style Casks/jdk26ea.rb
brew style Formula/jdk26ea.rb

# Audit checks
brew audit --cask Casks/jdk26ea.rb
brew audit --formula Formula/jdk26ea.rb

# Install test (local)
brew install --cask Casks/jdk26ea.rb
java -version
brew uninstall --cask jdk26ea
```

#### Common RuboCop Issues
```ruby
# ❌ Missing empty line between stanza groups
sha256 "..."
url "https://..."

# ✅ Correct spacing
sha256 "..."

url "https://..."

# ❌ Logical operators in unless
unless !condition || other_condition  # WRONG

# ✅ Use if with negation
if condition && !other_condition  # CORRECT
```

### 8. Multi-Architecture Support

#### macOS Architecture Handling
```ruby
cask "jdk26ea" do
  # Modern arch syntax (Homebrew 4.0+)
  arch arm: "aarch64", intel: "x64"

  sha256 arm:   "arm64_checksum...",
         intel: "x64_checksum..."

  url "https://download.java.net/.../openjdk-#{version}_macos-#{arch}_bin.tar.gz"
end
```

#### Linux Architecture Handling
```ruby
class Jdk26ea < Formula
  on_linux do
    if Hardware::CPU.arm?
      url "https://.../linux-aarch64_bin.tar.gz"
      sha256 "arm64_checksum..."
    else
      url "https://.../linux-x64_bin.tar.gz"
      sha256 "x64_checksum..."
    end
  end
end
```

### 9. Version Management

#### Version String Parsing
```ruby
# Version format: "26-ea+20,20"
# First part: JDK version (26-ea+20)
# Second part: Build number (20)

version "26-ea+20,20"

# Access components
version.csv.first   # "26-ea+20"
version.csv.second  # "20"

# Use in URLs
url "https://download.java.net/java/early_access/jdk26/#{version.csv.second}/GPL/openjdk-#{version.csv.first}_macos-#{arch}_bin.tar.gz"
```

### 10. Best Practices Checklist

**Before Every Commit:**
- [ ] `ruby -c` passes for all Ruby files
- [ ] `brew style` passes with no violations
- [ ] `brew audit` passes with no errors
- [ ] SHA256 checksums verified for ALL platforms
- [ ] All URLs use HTTPS
- [ ] Version strings updated consistently
- [ ] Path validation in postflight blocks
- [ ] Only Apple-signed commands used
- [ ] `system_command!` (with !) used for critical operations
- [ ] Error handling with `odie`, `ohai`, `opoo`
- [ ] Tested on actual platform (when possible)

## Common Patterns

### Pattern: Multi-Platform Updates
```bash
# 1. Update version in both files
vim Casks/jdk26ea.rb    # Line 2
vim Formula/jdk26ea.rb  # Line 4

# 2. Download and verify ALL checksums
for platform in macos-aarch64 macos-x64 linux-aarch64 linux-x64; do
  url="https://download.java.net/java/early_access/jdk26/20/GPL/openjdk-26-ea+20_${platform}_bin.tar.gz"
  curl -fsSL "${url}.sha256" | awk '{print $1}'
done

# 3. Update checksums in both files
# 4. Validate all changes
brew style Casks/jdk26ea.rb Formula/jdk26ea.rb
brew audit --cask Casks/jdk26ea.rb
brew audit --formula Formula/jdk26ea.rb
```

### Pattern: Secure File Operations
```ruby
# Always: realpath → validate → execute
path = Pathname(user_path).realpath
odie "Invalid path" unless path.to_s.start_with?(allowed_prefix)
system_command! "/usr/bin/ditto", args: ["--noqtn", path.to_s, target.to_s], sudo: true
```

## Resources

**Official Documentation:**
- [Homebrew Formula Cookbook](https://docs.brew.sh/Formula-Cookbook)
- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [RuboCop Style Guide](https://docs.brew.sh/Homebrew-Style-Guide)
- [Acceptable Casks](https://docs.brew.sh/Acceptable-Casks)

**Security References:**
- [Homebrew Security Policy](https://github.com/Homebrew/brew/security/policy)
- [system_command API](https://rubydoc.brew.sh/Cask/DSL#system_command-instance_method)
- [Staged Path Documentation](https://rubydoc.brew.sh/Cask/DSL#staged_path-instance_method)
