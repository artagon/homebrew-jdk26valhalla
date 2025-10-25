# homebrew-jdk26valhalla

Homebrew tap for JDK 26 Project Valhalla builds with automated updates, CI/CD, and support for both macOS and Linux.

[![Release](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/release.yml/badge.svg)](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/release.yml)
[![Validate](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/validate.yml/badge.svg)](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/validate.yml)
[![License: GPL v2 with Classpath Exception](https://img.shields.io/badge/License-GPL_v2--with--Classpath--Exception-blue.svg)](https://openjdk.java.net/legal/gplv2+ce.html)

## About Project Valhalla

[Project Valhalla](https://openjdk.org/projects/valhalla/) is an OpenJDK project focused on improving Java's performance and memory efficiency through fundamental language enhancements.

### What Does Valhalla Provide?

**Value Classes and Objects ([JEP 401](https://openjdk.org/jeps/401))** - The cornerstone of Project Valhalla:
- **Value Classes**: New type of class that represents pure data without object identity
- **Flattened Memory Layout**: Value objects stored directly in memory without indirection (no object header overhead)
- **Improved Cache Locality**: Better CPU cache performance through memory layout control
- **Zero-Cost Abstraction**: High-level abstractions without runtime overhead
- **Enhanced Generics**: Support for specialized generics over primitive and value types

### Performance Benefits

- **Reduced Memory Footprint**: Value objects eliminate object headers, reducing memory usage by 50-80% for small objects
- **Improved Cache Performance**: Direct memory layout means fewer cache misses
- **Better GC Performance**: Fewer object references mean less garbage collection pressure
- **Faster Array Operations**: Arrays of value types stored contiguously without indirection

### Use Cases

Valhalla is particularly beneficial for:
- High-performance computing and scientific applications
- Financial systems requiring low latency
- Game engines and graphics processing
- Big data processing and analytics
- Any application with large collections of small objects (e.g., Point, Complex, Vector2D)

This tap provides the latest Project Valhalla early-access builds implementing [JEP 401](https://openjdk.org/jeps/401).

## Quick Start

### Cask Installation (macOS)

```bash
brew tap Artagon/jdk26valhalla
brew install --cask jdk26valhalla
```

The cask installation places JDK in `/Library/Java/JavaVirtualMachines/jdk-26-valhalla.jdk` and integrates with macOS's Java management system.

### Formula Installation (macOS/Linux)

```bash
brew tap Artagon/jdk26valhalla
brew install jdk26valhalla
```

The formula installation creates symlinks in your Homebrew bin directory.

## Current Version

**JDK 26 Valhalla Build 26-jep401ea2+1-1** (Released: 2025-10-10)

This build implements:
- JEP 401: Value Classes and Objects

## Features

- **Automatic Updates**: Weekly checks for new Valhalla builds with automated formula/cask updates
- **Multi-Platform Support**:
  - macOS: ARM64 (Apple Silicon) and x64 (Intel)
  - Linux: ARM64 (aarch64) and x64
- **CI/CD Validation**: Automated testing on every commit across all supported platforms
- **GitHub Releases**: Automatic release creation when new versions are detected
- **Flexible Installation**: Choose between cask (macOS system integration) or formula (Homebrew-managed) installation
- **Integrity Verification**: SHA-256 checksum validation for all downloads

## Platform Support

| Platform | Architecture | Cask | Formula | Status |
|----------|-------------|------|---------|--------|
| macOS 13+ | ARM64 (Apple Silicon) | ✅ | ✅ | Fully Tested |
| macOS 13+ | x64 (Intel) | ✅ | ✅ | Fully Tested |
| Linux | ARM64 (aarch64) | ❌ | ✅ | Fully Tested |
| Linux | x64 | ❌ | ✅ | Fully Tested |

**Note:** Cask installation is macOS-only and integrates with the system's Java framework at `/Library/Java/JavaVirtualMachines/`. Formula installation works on both macOS and Linux, placing files in the Homebrew prefix.

## Usage

### Setting JAVA_HOME

After installation, you may want to set `JAVA_HOME`:

**For cask installation:**
```bash
export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-26-valhalla.jdk/Contents/Home"
```

**For formula installation:**
```bash
export JAVA_HOME="$(brew --prefix jdk26valhalla)"
```

### Verifying Installation

```bash
java -version
# Should output: openjdk version "26-jep401ea2" ...
```

### Using Value Classes (JEP 401)

Project Valhalla introduces value classes that provide better performance and memory efficiency:

```java
// Enable preview features to use value classes
javac --enable-preview --release 26 MyValueClass.java
java --enable-preview MyValueClass
```

## Updating

The tap is automatically updated with new Valhalla builds. To update to the latest version:

```bash
brew update
brew upgrade jdk26valhalla  # or brew upgrade --cask jdk26valhalla
```

## Issue Reporting

Found a problem? [Open an issue](https://github.com/Artagon/homebrew-jdk26valhalla/issues/new/choose) using our issue templates.

## Automated Updates

This repository uses GitHub Actions to automatically maintain the latest Valhalla builds:

### Update Workflow
1. **Weekly Checks** (Sundays at 12:00 UTC): Automated script checks [jdk.java.net/valhalla](https://jdk.java.net/valhalla/) for new builds
2. **Multi-Platform Download**: Downloads and verifies binaries for all supported platforms:
   - macOS: ARM64 and x64
   - Linux: ARM64 and x64
3. **SHA-256 Verification**: Calculates checksums for all platform binaries
4. **Automated PR Creation**: Creates pull request with updated formula/cask when new version detected
5. **CI/CD Validation**: Runs comprehensive tests across all platforms:
   - Syntax validation for Ruby code
   - Installation tests on macOS 13, macOS 14, Ubuntu 22.04, Ubuntu 24.04
   - Runtime verification (Java version check and basic compilation)
6. **Auto-Merge**: PR automatically merges after passing all tests
7. **GitHub Release**: Creates tagged release with version notes

### Manual Trigger
You can manually trigger an update check:
```bash
# Via GitHub CLI
gh workflow run update.yml -R Artagon/homebrew-jdk26valhalla
```

Or visit the [Actions tab](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/update.yml) and click "Run workflow".

## Project Valhalla Resources

### Official Documentation
- **[JEP 401: Value Classes and Objects](https://openjdk.org/jeps/401)** - Official JEP specification for value types
- **[Project Valhalla Home](https://openjdk.org/projects/valhalla/)** - Main project page with overview and goals
- **[Early Access Downloads](https://jdk.java.net/valhalla/)** - Official download page for Valhalla builds
- **[Early Access Build Info](https://openjdk.org/projects/valhalla/early-access)** - Build information and release notes

### Technical Specifications
- **[Latest JEP 401 Specification](http://cr.openjdk.java.net/~dlsmith/jep401/latest)** - Detailed technical specification and implementation notes
- **[API Documentation](https://download.java.net/java/early_access/valhalla/26/docs/api/)** - JavaDoc for Valhalla early-access builds
- **[State of Valhalla (Brian Goetz)](https://cr.openjdk.java.net/~briangoetz/valhalla/sov/)** - Series of documents explaining Valhalla's design and evolution
- **[Valhalla Mailing List Archives](https://mail.openjdk.org/pipermail/valhalla-dev/)** - Development discussions and technical details

### Talks and Presentations
- **[Introduction to Project Valhalla](https://openjdk.org/projects/valhalla/)** - Getting started with value types
- **[Java Language Futures (Brian Goetz)](https://www.youtube.com/results?search_query=brian+goetz+valhalla)** - Conference talks about Valhalla
- **[OpenJDK Valhalla Updates](https://wiki.openjdk.org/display/valhalla)** - Wiki with status updates and design documents

### Community and Support
- **[Valhalla Dev Mailing List](https://mail.openjdk.org/mailman/listinfo/valhalla-dev)** - Join the development discussion
- **[OpenJDK Wiki - Valhalla](https://wiki.openjdk.org/display/valhalla)** - Design documents and specifications
- **[GitHub Discussions](https://github.com/Artagon/homebrew-jdk26valhalla/discussions)** - Ask questions about this tap

### Experimental Features
Remember that Valhalla builds include preview features requiring the `--enable-preview` flag:
```bash
javac --enable-preview --release 26 YourCode.java
java --enable-preview YourClass
```

## License

This tap is distributed under the same license as OpenJDK (GPL-2.0 with Classpath Exception).

## Disclaimer

These are early-access builds provided for testing and development purposes. They implement experimental features that are subject to change. They are not intended for production use. For production environments, please use stable JDK releases.

**Important:** Project Valhalla builds include preview features that require the `--enable-preview` flag to use. The APIs and language features are subject to change in future releases.

## Links

- [JDK 26 Valhalla Downloads](https://jdk.java.net/valhalla/)
- [JEP 401: Value Classes and Objects](https://openjdk.org/jeps/401)
- [OpenJDK Project Valhalla](https://openjdk.org/projects/valhalla/)
- [Project Valhalla Early Access](https://openjdk.org/projects/valhalla/early-access)
- [Latest JEP 401 Specification](http://cr.openjdk.java.net/~dlsmith/jep401/latest)
- [Valhalla API Documentation](https://download.java.net/java/early_access/valhalla/26/docs/api/)
- [Homebrew Documentation](https://docs.brew.sh/)
