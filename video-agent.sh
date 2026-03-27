#!/bin/bash
# ============================================================
#  VideoAgent Launcher (macOS)
#  Opens Claude Code with the full VideoAgent context loaded.
#
#  Usage:
#    ./video-agent.sh                     Start a session
#    ./video-agent.sh --resume            Resume last session
#    ./video-agent.sh --project MyVideo   Set active project
#    ./video-agent.sh --comfyui URL       Override ComfyUI URL
# ============================================================

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_ARGS=""
ACTIVE_PROJECT=""
COMFYUI_URL="http://127.0.0.1:8000"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --resume)
            CLAUDE_ARGS="--resume"
            shift
            ;;
        --project)
            ACTIVE_PROJECT="$2"
            shift 2
            ;;
        --comfyui)
            COMFYUI_URL="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Write active session config (read by CLAUDE.md)
cat > "$REPO_DIR/state/session.json" << EOF
{
  "comfyui_url": "$COMFYUI_URL",
  "active_project": "$ACTIVE_PROJECT",
  "started": "$(date '+%Y-%m-%d %H:%M:%S')"
}
EOF

# Launch Claude Code in the VideoAgent directory
cd "$REPO_DIR"
echo ""
echo "  VideoAgent Session"
echo "  =================="
echo "  Project dir: $REPO_DIR"
if [ -n "$ACTIVE_PROJECT" ]; then
    echo "  Project:     $ACTIVE_PROJECT"
fi
echo "  ComfyUI:     $COMFYUI_URL"
echo ""

claude $CLAUDE_ARGS
