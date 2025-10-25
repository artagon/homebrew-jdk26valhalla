# OpenAI Codex Specific Instructions

## Configuration
OpenAI Codex loads from `AGENTS.md` in project root (auto-generated from shared context)

## Codex-Specific Features
- Terminal-based coding agent
- Multi-file editing capabilities
- Git integration
- Natural language to code translation
- Inline code generation

## Usage Patterns
When using OpenAI Codex:
- Follow repository semantic commit conventions
- Run validation scripts before committing
- Use natural language for complex multi-file changes
- Verify security guidelines for workflow changes
- Check that all platforms have SHA256 checksums

## Repository-Specific
- Always use `brew style` before completing tasks
- Validate commit messages match semantic format
- Pin GitHub Actions to commit SHAs
- Verify checksums for all platform downloads
- Create PRs instead of direct commits to main
