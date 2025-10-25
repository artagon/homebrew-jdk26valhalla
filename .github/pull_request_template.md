## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

<!-- Mark the relevant option with an "x" -->

- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📝 Documentation update
- [ ] 🔧 Chore (dependency updates, tooling, etc.)
- [ ] 🚀 JDK version update

## Related Issue

<!-- Link to the issue this PR addresses -->
Fixes #(issue number)

## Changes Made

<!-- List the specific changes made in this PR -->

-
-
-

## JDK Version Update Checklist

<!-- If this is a JDK version update, complete this checklist -->

- [ ] Updated version in `Casks/jdk26ea.rb`
- [ ] Updated version in `Formula/jdk26ea.rb`
- [ ] Updated URLs for all platforms (macOS ARM64/x64, Linux ARM64/x64)
- [ ] Updated SHA256 checksums for all platforms
- [ ] Verified checksums match official release
- [ ] README will be auto-updated by release workflow
- [ ] Tested installation locally (if possible)

## Testing

<!-- Describe how you tested these changes -->

### Validation

- [ ] Ruby syntax validation passed (`ruby -c Casks/jdk26ea.rb`)
- [ ] Ruby syntax validation passed (`ruby -c Formula/jdk26ea.rb`)
- [ ] Semantic commit message format verified
- [ ] CI validation checks pass

### Manual Testing

<!-- Describe any manual testing performed -->

- [ ] Tested cask installation (macOS only)
- [ ] Tested formula installation
- [ ] Verified JAVA_HOME setup
- [ ] Ran `java -version` successfully

## Checklist

<!-- Mark completed items with an "x" -->

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my changes
- [ ] I have commented my code where necessary
- [ ] I have updated documentation as needed
- [ ] My commits follow [Conventional Commits](https://www.conventionalcommits.org/) format
- [ ] All CI checks pass
- [ ] I have tested my changes locally (if applicable)

## Screenshots/Logs

<!-- If applicable, add screenshots or logs to help explain your changes -->

```
# Paste relevant output here
```

## Additional Notes

<!-- Add any additional context or notes for reviewers -->

---

**For Maintainers:**
- Ensure all status checks pass before merging
- Squash and merge with semantic commit message
- Verify release workflow triggers correctly (for version updates)
