# homebrew-jdk26valhalla

Homebrew tap for JDK 26 Project Valhalla builds with automated updates, CI/CD, and support for both macOS and Linux.

[![Release](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/release.yml/badge.svg)](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/release.yml)
[![Validate](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/validate.yml/badge.svg)](https://github.com/Artagon/homebrew-jdk26valhalla/actions/workflows/validate.yml)

## About Project Valhalla

Project Valhalla is an OpenJDK project focused on improving Java's performance and memory efficiency through:
- **Value Classes and Objects (JEP 401)**: Introducing value types that enable more efficient memory layouts and improved performance
- **Inline types**: User-definable types that can be stored directly in memory without object headers
- **Enhanced generics**: Support for specialization over primitive types and value types

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

- Automatic updates when new Valhalla builds are released
- Support for macOS (ARM64 & Intel) and Linux (ARM64 & x64)
- CI/CD validation with GitHub Actions
- Automatic GitHub releases on version updates
- Both cask and formula options

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

This repository uses GitHub Actions to:
- Validate cask/formula syntax on every commit
- Create GitHub releases when the version changes
- Run weekly audits to ensure quality

## Project Valhalla Resources

### Official Documentation
- [JEP 401: Value Classes and Objects](https://openjdk.org/jeps/401) - Official JEP specification
- [Project Valhalla Home](https://openjdk.org/projects/valhalla/) - Main project page
- [Project Valhalla Early Access Downloads](https://jdk.java.net/valhalla/) - Download page
- [Early Access Builds](https://openjdk.org/projects/valhalla/early-access) - Build information

### Technical Resources
- [Latest JEP 401 Specification](http://cr.openjdk.java.net/~dlsmith/jep401/latest) - Detailed technical specification
- [API Documentation](https://download.java.net/java/early_access/valhalla/26/docs/api/) - JavaDoc for Valhalla builds

### Learning Resources
- [Value Classes Tutorial](https://openjdk.org/projects/valhalla/) - Getting started with value types
- [Performance Benefits](https://openjdk.org/projects/valhalla/) - Understanding the performance improvements

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
