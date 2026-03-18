---
name: review-pr
description: Review a GitHub pull request for issues
context: fork
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - WebFetch
---

# PR Review Skill

Review the pull request and provide actionable feedback.

## PR Diff

```
!gh pr diff $ARGUMENTS --no-color
```

## PR Details

```
!gh pr view $ARGUMENTS
```

## Review Checklist

Focus on these areas (in priority order):

1. **Security**: Hardcoded secrets, injection vulnerabilities, unsafe deserialization, exposed credentials
2. **Correctness**: Logic errors, edge cases, off-by-one errors, race conditions
3. **Error handling**: Unhandled exceptions, missing error paths, swallowed errors
4. **Test coverage**: Are changes tested? Are edge cases covered?
5. **Naming & clarity**: Are names descriptive? Is intent clear?

## Rules

- Do NOT comment on style, formatting, or cosmetic issues
- Do NOT suggest changes that are out of scope of the PR
- Be specific — reference file paths and line numbers
- If the PR looks good, say so briefly — don't invent issues
- Group findings by severity: critical, warning, suggestion
