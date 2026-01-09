---
name: review-pr
description: Comprehensive PR review with intelligent agent selection and summary saving
argument-hint: "[PR number or branch name]"
model: opus
allowed-tools: ["Bash", "Glob", "Grep", "Read", "Write", "Task", "AskUserQuestion"]
---

# PR Review Command

Comprehensive pull request review using intelligent agent selection based on the code being reviewed.

## Instructions

### Step 1: Sync with Remote

First, pull the latest changes to ensure we're reviewing up-to-date code:

```bash
git fetch origin
git pull origin $(git branch --show-current) --rebase 2>/dev/null || true
```

### Step 2: Get PR Information

If an argument is provided ("$ARGUMENTS"), use it as the PR number or branch name.

```bash
# If numeric, it's a PR number
gh pr view $ARGUMENTS

# If branch name, find the PR
gh pr list --head $ARGUMENTS
```

If no argument, check current branch:
```bash
gh pr view
```

### Step 3: Analyze the Diff

Get the PR diff and analyze what types of files changed:

```bash
gh pr diff $PR_NUMBER --name-only
```

Categorize the changes:
- **Backend code**: `.go`, `.py`, `.java`, `.rs`, `.rb`
- **Frontend code**: `.ts`, `.tsx`, `.js`, `.jsx`, `.vue`, `.svelte`, `.css`, `.html`
- **Test files**: `*_test.go`, `*.test.ts`, `*.spec.ts`, `*_test.py`, etc.
- **Infrastructure**: `.tf`, `.yaml`, `.yml` (CloudFormation, k8s), `Dockerfile`
- **Types/Interfaces**: Files with type definitions, interfaces, structs

### Step 4: Select and Run Agents

Based on the file types detected, run the appropriate agents **in parallel** using the Task tool:

| File Types | Agents to Use |
|------------|---------------|
| Backend (.go, .py, etc.) | `backend-developer` (architecture review) |
| Frontend (.ts, .tsx, etc.) | `frontend-engineer` (UI/UX review) |
| Test files | `pr-review-toolkit:pr-test-analyzer` (test coverage) |
| Error handling code | `pr-review-toolkit:silent-failure-hunter` (error handling) |
| New types/interfaces | `pr-review-toolkit:type-design-analyzer` (type design) |
| All PRs | `pr-review-toolkit:code-reviewer` (general quality) |
| Comments/docs added | `pr-review-toolkit:comment-analyzer` (comment accuracy) |

**Always run `code-reviewer` as baseline. Add other agents based on detected file types.**

Launch agents in parallel for efficiency:
```
Use Task tool with multiple parallel calls for independent agents
```

### Step 5: Compile Review Summary

After all agents complete, compile a summary:

```markdown
# PR Review Summary

**PR:** #[number] - [title]
**Branch:** [branch-name]
**Author:** [author]
**Date:** [date]

## Files Changed
- [list of files with change type: added/modified/deleted]

## Review Results

### Critical Issues (must fix)
- [issue from agent] - `file:line`

### Important Issues (should fix)
- [issue from agent] - `file:line`

### Suggestions (nice to have)
- [suggestion from agent] - `file:line`

### Strengths
- [positive observations]

## Agents Used
- [list of agents that ran]

## Recommendation
[APPROVE / REQUEST_CHANGES / COMMENT]
```

### Step 6: Ask User About PR Comments

Use AskUserQuestion to ask:

```
Would you like me to add review comments to the PR?
- Yes, add all issues as PR comments
- Yes, add only critical/important issues
- No, just save the summary locally
```

If user wants to add comments:
```bash
# For general comment
gh pr comment $PR_NUMBER --body "Review summary..."

# For line-specific comments (if applicable)
gh pr review $PR_NUMBER --comment --body "..."
```

### Step 7: Save Review Summary (User Approval Required)

Ask the user for approval before saving using AskUserQuestion:

```
Would you like to save this review summary?
- Yes, save to .claude/reviews/
- Yes, save to custom location
- No, don't save
```

**Only if user approves**, save the summary:

```bash
mkdir -p .claude/reviews
```

Save as `.claude/reviews/PR-[number]-[date].md`

**Run the file write operation in the background** using the Task tool with `run_in_background: true` so the user can continue working while the summary is being saved.

## Agent Selection Logic

```
IF has backend files (.go, .py, .java, .rs):
  → Run backend-developer agent

IF has frontend files (.ts, .tsx, .js, .jsx, .vue):
  → Run frontend-engineer agent

IF has test files (*_test.*, *.test.*, *.spec.*):
  → Run pr-test-analyzer agent

IF has error handling (try/catch, if err !=, .catch):
  → Run silent-failure-hunter agent

IF has new type definitions (type, interface, struct):
  → Run type-design-analyzer agent

IF has new/modified comments or docs:
  → Run comment-analyzer agent

ALWAYS:
  → Run code-reviewer agent (baseline)
```

## Example Usage

```bash
# Review PR by number
/review-pr 82

# Review PR for current branch
/review-pr

# Review PR by branch name
/review-pr feature/TA-81-migrate-st-create-expiration
```

## Notes

- Agents run in parallel for faster reviews
- Only high-confidence issues (≥80) are reported
- Summary saving requires user approval before writing
- Summary is saved in the background (non-blocking)
- PR comments are optional and user-controlled
- Uses extended thinking (opus model) for thorough analysis
