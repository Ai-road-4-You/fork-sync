---
applyTo: "**/*.{sh,bash,zsh}"
---
# Shell Script Guidelines

- Start scripts with `#!/usr/bin/env bash` and `set -euo pipefail`
- Quote all variable expansions: `"$var"` not `$var`
- Use `[[ ]]` for conditionals, not `[ ]`
- Use `$()` for command substitution, not backticks
- Use `local` for function-scoped variables
- Use `readonly` for constants
- Check command existence with `command -v` before use
- Provide meaningful exit codes (0=success, 1=general error, 2=usage error)
- Use `trap` for cleanup on EXIT/ERR
