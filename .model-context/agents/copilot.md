# GitHub Copilot Specific Instructions

## Configuration
Copilot loads from `.github/copilot-instructions.md` (auto-generated from shared context)

## Copilot-Specific Features
- Inline code completion
- Chat mode for questions
- Multi-line suggestions
- Context from open files

## Usage Patterns
- Accept suggestions that follow repository conventions
- Reject suggestions that:
  - Use unpinned actions
  - Skip input validation
  - Bypass security checks
  - Don't follow commit message format

## Chat Mode
When using Copilot Chat:
- Ask about semantic commit format before committing
- Request security review for workflow changes
- Verify checksums are included for all platforms
- Check that style guidelines are followed
