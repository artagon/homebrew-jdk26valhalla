# Gemini Code Assist Specific Instructions

## Configuration
Gemini loads from `.gemini/styleguide.md` (auto-generated from shared context)

## Gemini-Specific Features
- Automated code reviews on PRs
- Multi-file context awareness
- Natural language code generation
- Integrated with Google Cloud

## Code Review Focus
When reviewing PRs, prioritize:
1. Security vulnerabilities (path traversal, injection, token exposure)
2. Missing SHA256 checksums
3. Unpinned GitHub Actions
4. Semantic commit message compliance
5. RuboCop/style violations
6. Test coverage

## Review Comments
- Use severity levels: CRITICAL, HIGH, MEDIUM, LOW
- Be specific about fixes required
- Reference relevant documentation
- Suggest concrete improvements
