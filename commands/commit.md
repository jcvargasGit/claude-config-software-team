---
name: commit
description: Generate semantic commit message and commit staged changes
---

# Commit Command

Generate a commit message following conventional commits and commit the staged changes.

## Instructions

1. Run `git status` and `git diff --staged` to see what's being committed
2. Check the number of changed files

### Standard Commit (≤10 files)

Generate a commit message in this format:

```
type(scope): short description

- bullet points for details (if needed)
```

### Large Change Detection (>10 files)

When more than 10 files are changed, analyze and offer to split:

1. **Analyze changes by:**
   - Directory grouping (`services/auth`, `services/users`)
   - Change type (`feat`, `fix`, `test`, `refactor`, `docs`)
   - Logical feature boundaries

2. **Suggest commit groups:**
   ```
   Group 1: feat(auth): add login endpoint (5 files)
   Group 2: test(auth): add login integration tests (3 files)
   Group 3: refactor(auth): extract validation logic (4 files)
   ```

3. **Ask user to select groups or commit all together**

4. **For each selected group:**
   - Stage only the relevant files (`git add <files>`)
   - Commit with semantic message
   - Repeat for next group

## Message Format

**Types:**
- `feat` - new feature
- `fix` - bug fix
- `test` - adding or updating tests
- `docs` - documentation only changes
- `chore` - changes to build process, tooling, or other chores
- `refactor` - code changes that neither fix a bug nor add a feature
- `ci` - CI/CD changes

**Rules:**
- Scope is optional, use folder/module name if relevant
- Description: lowercase, no period, imperative mood ("add" not "added")
- Keep it under 72 characters
- Only add bullet points if multiple distinct changes

## Commit Boundaries

Each commit should represent one logical change:

| Good Commit | Bad Commit |
|-------------|------------|
| `feat(auth): add login endpoint` | `add login, fix bug, update tests` |
| `test(auth): add login integration tests` | `WIP` |
| `refactor(auth): extract validation logic` | `misc changes` |

**What goes together:**
- Feature + its tests = same commit (one logical unit)
- Refactoring = separate commit (behavior unchanged)
- Bug fix = separate commit (easy to revert)
- Config/infra changes = separate commit (different concern)

## Final Steps

3. Run the commit with the generated message (no footer lines)
4. Show the commit hash when done

**Examples:**
```
feat(skills): [branch-name] add Python and Node.js language skills
fix(api): [branch-name] handle null response from user service
refactor(handlers): [branch-name] extract validation logic
docs: [branch-name] update README with new agent structure
chore(deps): [branch-name] upgrade aws-sdk to v3
ci: [branch-name] add integration test workflow
```
