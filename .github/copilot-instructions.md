# Copilot Instructions — fork-sync

## Project

- **Name**: fork-sync
- **Organization**: Ai-road-4-You
- **Enterprise**: iAiFy
- **Language**: Shell
- **Description**: Fork synchronization automation for iAiFy managed forks

## Conventions

- Use kebab-case for file and directory names
- Use conventional commits (feat:, fix:, chore:, docs:, refactor:, test:)
- All PRs require review before merge
- Branch from main, merge back to main
- All file names in kebab-case

## Shared Infrastructure

- Reusable workflows: Ai-road-4-You/enterprise-ci-cd@v1
- Composite actions: Ai-road-4-You/github-actions@v1
- Governance standards: Ai-road-4-You/governance

## Quality Standards

- Run lint and tests before submitting PRs
- Keep dependencies updated via Dependabot
- No hardcoded secrets — use GitHub Secrets or environment variables
- Follow OWASP Top 10 security practices
