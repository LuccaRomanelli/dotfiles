#!/bin/bash

# Function to generate visual progress bar
generate_bar() {
    local pct=$1
    local width=10
    local filled=$(awk -v pct="$pct" -v w="$width" 'BEGIN { printf "%d", (pct/100)*w }')
    local empty=$((width - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo "$bar"
}

# Function to format token count (k/M)
format_tokens() {
    awk -v t="$1" 'BEGIN {
        if (t >= 1000000) printf "%.1fM", t/1000000
        else if (t >= 1000) printf "%.0fk", t/1000
        else print t
    }'
}

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Get git branch (skip optional locks for performance)
branch=""
if [ -d "$cwd/.git" ]; then
    branch=$(cd "$cwd" && git --no-optional-locks branch --show-current 2>/dev/null)
    [ -z "$branch" ] && branch=$(cd "$cwd" && git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
fi

# Get project name from directory
project=$(basename "$cwd")

# Build status line parts
parts=()

# Model (cyan)
parts+=("$(printf '\033[36m%s\033[0m' "$model")")

# Token usage with visual bar (color-coded: green < 50%, yellow < 80%, red >= 80%)
total_tokens=$((total_input + total_output))
if [ -n "$used_pct" ] && [ "$total_tokens" -gt 0 ]; then
    # Calculate limit from percentage
    limit=$(awk -v t="$total_tokens" -v pct="$used_pct" 'BEGIN {
        if (pct > 0) printf "%.0f", t/(pct/100)
        else print 0
    }')

    # Determine color based on percentage
    color=$(awk -v pct="$used_pct" 'BEGIN {
        if (pct < 50) print "\\033[32m"
        else if (pct < 80) print "\\033[33m"
        else print "\\033[31m"
    }')

    # Generate bar and format tokens
    bar=$(generate_bar "$used_pct")
    token_display=$(format_tokens "$total_tokens")
    limit_display=$(format_tokens "$limit")

    # Format: [████████░░░░░░░░░░░░] 45k/200k (22.5%)
    parts+=("$(printf "${color}[%s] %s/%s (%.1f%%)\033[0m" "$bar" "$token_display" "$limit_display" "$used_pct")")
elif [ "$total_tokens" -gt 0 ]; then
    # Fallback if no percentage available
    token_display=$(format_tokens "$total_tokens")
    parts+=("$(printf '\033[35m%s\033[0m' "$token_display")")
fi

# Git branch (yellow)
if [ -n "$branch" ]; then
    parts+=("$(printf '\033[33m%s\033[0m' "$branch")")
fi

# Project name (blue)
parts+=("$(printf '\033[34m%s\033[0m' "$project")")

# Join all parts with separator
printf '%s' "${parts[0]}"
for i in "${parts[@]:1}"; do
    printf ' \033[90m|\033[0m %s' "$i"
done
printf '\n'
