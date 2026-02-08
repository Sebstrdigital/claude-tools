#!/bin/bash
#
# Claude Tools Installer
# Installs agents, commands, and docs into ~/.claude/
#
# Safe install logic:
#   - If target file exists with source_id: seb-claude-tools → overwrite (update)
#   - If target file exists WITHOUT that source_id → install with "sebstrdigital-" prefix
#   - If target file doesn't exist → install as-is
#   - Shows version changes on updates
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_ID="seb-claude-tools"
CLAUDE_DIR="$HOME/.claude"
PREFIX="sebstrdigital-"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

installed=0
updated=0
prefixed=0
skipped=0

get_version() {
    local file="$1"
    grep -m1 '^version:' "$file" 2>/dev/null | sed 's/version: *//' || echo "unknown"
}

check_and_install() {
    local src="$1"
    local target_dir="$2"
    local filename
    filename="$(basename "$src")"

    mkdir -p "$target_dir"

    local target="$target_dir/$filename"
    local src_version
    src_version="$(get_version "$src")"

    if [ -f "$target" ]; then
        # File exists — check for source_id
        if grep -q "source_id: $SOURCE_ID" "$target" 2>/dev/null; then
            # Same source_id — safe to overwrite (update)
            local target_version
            target_version="$(get_version "$target")"

            if [ "$src_version" = "$target_version" ]; then
                echo -e "  ${GRAY}current${NC}  $filename ${GRAY}(v$target_version)${NC}"
                ((skipped++))
            else
                cp "$src" "$target"
                echo -e "  ${BLUE}updated${NC}  $filename ${GRAY}v$target_version → v$src_version${NC}"
                ((updated++))
            fi
        else
            # Different or missing source_id — prefix to avoid conflict
            local prefixed_name="${PREFIX}${filename}"
            local prefixed_target="$target_dir/$prefixed_name"
            cp "$src" "$prefixed_target"
            echo -e "  ${YELLOW}prefixed${NC} $filename → $prefixed_name ${GRAY}(existing file preserved)${NC}"
            ((prefixed++))
        fi
    else
        # No conflict — install directly
        cp "$src" "$target"
        echo -e "  ${GREEN}added${NC}    $filename ${GRAY}(v$src_version)${NC}"
        ((installed++))
    fi
}

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Claude Tools Installer           ║"
echo "║     by Seb @ Sebstrdigital           ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Install agents
echo "Agents → $CLAUDE_DIR/agents/"
for f in "$SCRIPT_DIR"/agents/*.md; do
    [ -f "$f" ] && check_and_install "$f" "$CLAUDE_DIR/agents"
done
echo ""

# Install commands
echo "Commands → $CLAUDE_DIR/commands/"
for f in "$SCRIPT_DIR"/commands/*.md; do
    [ -f "$f" ] && check_and_install "$f" "$CLAUDE_DIR/commands"
done
echo ""

# Install docs
echo "Docs → $CLAUDE_DIR/docs/agentic-patterns/"
for f in "$SCRIPT_DIR"/docs/agentic-patterns/*.md; do
    [ -f "$f" ] && check_and_install "$f" "$CLAUDE_DIR/docs/agentic-patterns"
done
echo ""

# Summary
echo "────────────────────────────────────────"
echo -e "  ${GREEN}Added:${NC}    $installed"
echo -e "  ${BLUE}Updated:${NC}  $updated"
echo -e "  ${GRAY}Current:${NC}  $skipped"
echo -e "  ${YELLOW}Prefixed:${NC} $prefixed"
echo ""
echo "Done. Restart Claude Code to pick up changes."
echo ""
