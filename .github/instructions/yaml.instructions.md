---
applyTo: "**/*.{yml,yaml}"
---

# YAML conventions

- Use 2-space indentation consistently
- Quote strings that could be misinterpreted (yes/no, on/off, 1.0)
- For GitHub Actions workflows:
  - Pin third-party actions to full commit SHA with version comment
  - Set explicit `permissions` block (least privilege)
  - Use `secrets: inherit` for reusable workflow calls
  - Reference shared workflows from Ai-road-4-You/enterprise-ci-cd@v1
