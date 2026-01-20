---
name: lang-bash
description: Apply Bash scripting best practices including strict mode, error handling, and portable patterns.
---

# Bash Scripting Skill

Apply Bash best practices for reliable, maintainable scripts.

## Script Structure

### Standard Header

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Strict Mode Flags

| Flag | Effect |
|------|--------|
| `-e` | Exit on error |
| `-u` | Error on undefined variable |
| `-o pipefail` | Propagate pipe errors |

### Why Strict Mode

Without strict mode, scripts continue after errors, potentially causing:
- Silent failures
- Corrupted data
- Security vulnerabilities
- Hard-to-debug issues

## Error Handling

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Misuse of command |
| 126 | Permission denied |
| 127 | Command not found |
| 128+N | Signal N received |

### Trap for Cleanup

```bash
cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT
```

### Error Messages

```bash
die() {
    echo "ERROR: $*" >&2
    exit 1
}

# Usage
[[ -f "$file" ]] || die "File not found: $file"
```

### Conditional Execution

```bash
# Run cleanup even if command fails
set +e
command_that_might_fail
status=$?
set -e
```

## Variable Patterns

### Declaration

```bash
# Local variables (in functions)
local name="value"

# Read-only constants
readonly CONFIG_DIR="/etc/myapp"

# Export for child processes
export PATH="/custom/bin:$PATH"
```

### Quoting Rules

| Pattern | Use Case |
|---------|----------|
| `"$var"` | Always quote variables |
| `"${var}"` | When adjacent to text |
| `'literal'` | No expansion needed |
| `$'escape\n'` | With escape sequences |

### Default Values

```bash
# Use default if unset
name="${1:-default}"

# Use default if unset or empty
name="${1:=default}"

# Error if unset
name="${1:?Missing required argument}"
```

### String Operations

```bash
# Length
${#string}

# Substring
${string:offset:length}

# Replace first match
${string/pattern/replacement}

# Replace all matches
${string//pattern/replacement}

# Remove prefix
${string#pattern}

# Remove suffix
${string%pattern}
```

## Function Organization

### Function Definition

```bash
# Preferred style
function_name() {
    local arg1="$1"
    local arg2="${2:-default}"

    # Function body
}
```

### Return Values

```bash
# Return status code
is_valid() {
    [[ -n "$1" ]] && return 0 || return 1
}

# Return value via stdout
get_value() {
    echo "result"
}
result=$(get_value)

# Return multiple values via global or nameref
declare -n output_ref="$1"
output_ref="value"
```

### Documentation Pattern

```bash
# Brief description of what function does
# Arguments:
#   $1 - description of first argument
#   $2 - (optional) description with default
# Returns:
#   0 on success, 1 on failure
# Outputs:
#   Writes result to stdout
function_name() {
    # implementation
}
```

## Argument Parsing

### Positional Arguments

```bash
main() {
    [[ $# -lt 2 ]] && die "Usage: $0 <arg1> <arg2>"

    local arg1="$1"
    local arg2="$2"
}
```

### Option Parsing with getopts

```bash
while getopts "vf:h" opt; do
    case $opt in
        v) VERBOSE=true ;;
        f) FILE="$OPTARG" ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))
```

### Long Options Pattern

```bash
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose) VERBOSE=true; shift ;;
        --file) FILE="$2"; shift 2 ;;
        --help) usage; exit 0 ;;
        --) shift; break ;;
        -*) die "Unknown option: $1" ;;
        *) break ;;
    esac
done
```

## Conditionals

### Test Syntax

```bash
# Preferred: double brackets
[[ -f "$file" ]]

# Single brackets for POSIX compatibility
[ -f "$file" ]

# Arithmetic
(( count > 0 ))
```

### File Tests

| Test | Meaning |
|------|---------|
| `-f` | Regular file exists |
| `-d` | Directory exists |
| `-e` | Any file exists |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | Non-empty file |

### String Tests

| Test | Meaning |
|------|---------|
| `-n` | Non-empty string |
| `-z` | Empty string |
| `==` | String equality |
| `!=` | String inequality |
| `=~` | Regex match |

### Numeric Tests

| Test | Meaning |
|------|---------|
| `-eq` | Equal |
| `-ne` | Not equal |
| `-lt` | Less than |
| `-le` | Less or equal |
| `-gt` | Greater than |
| `-ge` | Greater or equal |

## Loops

### Iterate Over Arguments

```bash
for arg in "$@"; do
    echo "$arg"
done
```

### Iterate Over Files

```bash
# Safe for filenames with spaces
for file in *.txt; do
    [[ -f "$file" ]] || continue
    process "$file"
done
```

### Read Lines from File

```bash
while IFS= read -r line; do
    process "$line"
done < "$file"
```

### Read Command Output

```bash
while IFS= read -r line; do
    process "$line"
done < <(command)
```

## Arrays

### Declaration

```bash
# Indexed array
declare -a fruits=("apple" "banana" "cherry")

# Associative array
declare -A colors
colors[red]="#FF0000"
colors[blue]="#0000FF"
```

### Array Operations

```bash
# All elements
"${array[@]}"

# Length
"${#array[@]}"

# Specific element
"${array[0]}"

# Keys (associative)
"${!array[@]}"

# Append
array+=("new_element")
```

## Command Execution

### Capture Output

```bash
# Capture stdout
output=$(command)

# Capture stdout and stderr
output=$(command 2>&1)

# Capture to variable, check status
if output=$(command 2>&1); then
    echo "Success: $output"
else
    echo "Failed: $output"
fi
```

### Process Substitution

```bash
# Treat output as file
diff <(command1) <(command2)

# Input to command
command > >(other_command)
```

### Here Documents

```bash
# Variable expansion
cat <<EOF
Hello $USER
EOF

# No expansion
cat <<'EOF'
Literal $USER
EOF

# Trim leading tabs
cat <<-EOF
	Indented content
	EOF
```

## Portability

### Portable Constructs

| Bash | POSIX Alternative |
|------|-------------------|
| `[[` | `[` |
| `(( ))` | `[ ]` with `-eq` etc |
| `function f()` | `f()` |
| `local` | Use in function scope |
| `$'escape'` | `printf` |

### Check for Commands

```bash
command -v jq >/dev/null || die "jq required"
```

### Feature Detection

```bash
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    die "Bash 4+ required"
fi
```

## Security

### Input Validation

```bash
# Validate expected format
[[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid input"

# Sanitize for shell use
sanitized="${input//[^a-zA-Z0-9_-]/}"
```

### Avoid Eval

```bash
# Bad - command injection risk
eval "$user_input"

# Better - use arrays
cmd=("command" "--option" "$user_input")
"${cmd[@]}"
```

### Temporary Files

```bash
# Secure temporary file
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Secure temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
```

### Restricted Permissions

```bash
# Create file with restricted permissions
umask 077
echo "secret" > "$file"
```

## Debugging

### Debug Mode

```bash
# Enable trace
set -x

# Disable trace
set +x

# Trace specific section
set -x
problematic_code
set +x
```

### Print Debug Info

```bash
debug() {
    [[ "${DEBUG:-}" == "true" ]] && echo "DEBUG: $*" >&2
}
```

### Verbose Execution

```bash
# Show each command before execution
bash -v script.sh

# Show expanded commands
bash -x script.sh
```

## Common Patterns

### Main Function Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

main() {
    local arg1="${1:-}"
    [[ -n "$arg1" ]] || die "Usage: $0 <arg>"

    do_work "$arg1"
}

do_work() {
    echo "Processing: $1"
}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

main "$@"
```

### Configuration Loading

```bash
# Load config if exists
config_file="${CONFIG_FILE:-$HOME/.myapprc}"
[[ -f "$config_file" ]] && source "$config_file"
```

### Logging

```bash
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}
```

## Quality Checklist

When writing Bash scripts:

- [ ] Shebang present (`#!/usr/bin/env bash`)
- [ ] Strict mode enabled (`set -euo pipefail`)
- [ ] All variables quoted (`"$var"`)
- [ ] Functions use `local` variables
- [ ] Error messages to stderr
- [ ] Cleanup via trap
- [ ] Exit codes documented
- [ ] Input validated before use

## Anti-Patterns

| Anti-Pattern | Risk | Solution |
|--------------|------|----------|
| No strict mode | Silent failures | Use `set -euo pipefail` |
| Unquoted variables | Word splitting, globbing | Always quote `"$var"` |
| Parsing `ls` output | Breaks on special filenames | Use globs or `find -print0` |
| Using `eval` | Command injection | Use arrays |
| Global variables | State confusion | Use local in functions |
| No error handling | Undefined behavior | Check return codes |

## References

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
