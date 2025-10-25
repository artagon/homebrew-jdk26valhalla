# Claude Code Specific Instructions

## Shared Context
Claude loads this file plus all files in `.model-context/shared/`:
- instructions.md - Behavioral instructions
- context.md - Repository context
- security.md - Security guidelines
- style-guide.md - Code style rules

## Claude-Specific Tools and Practices

### Task Management
- Use `TodoWrite` tool for multi-step tasks
- Mark tasks `in_progress` before starting
- Mark tasks `completed` immediately after finishing
- Never batch completions

### Code Operations
- Prefer `Edit` tool over `Write` for existing files
- Use `Read` before `Write` or `Edit`
- Use `Grep` and `Glob` for searching (NOT bash grep/find)
- Use `Bash` only for actual shell commands

### Agent Usage
- Use `Task` tool with `subagent_type=Explore` for codebase exploration
- Launch agents in parallel when possible (single message, multiple Task calls)
- Never guess parameters - wait for actual values

### Communication
- Output text directly to user (not via echo/bash)
- No emojis unless user explicitly requests
- Be concise - user sees output in CLI
- Use Github-flavored markdown

## Repository Operations

### Git Commits
- Create commits only when explicitly requested
- Use heredoc for commit messages to preserve formatting
- Never use `--no-verify` to bypass hooks
- Always validate commit message format before committing

### Creating PRs
- Always show full diff before creating PR
- Generate comprehensive PR description
- Include test plan
- Return PR URL when done
