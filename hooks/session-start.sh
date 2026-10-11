#!/usr/bin/env bash
# Injects the AI, Teach Me! rule into every session so Claude records technologies
# without being asked. Kept short: it costs context tokens in every session.
set -euo pipefail

# Default folder name, overridable by the kb_folder_name option; anything path-like falls back to it.
kb_name="${CLAUDE_PLUGIN_OPTION_KB_FOLDER_NAME:-ai-teach-me-kb}"
case "$kb_name" in
  */*|*\\*|.|..) kb_name="ai-teach-me-kb" ;;
esac

# The user's Documents folder, per OS. Windows runs this under Git Bash.
documents_dir() {
  local d=""
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      # Honors OneDrive/redirected Documents; mixed form (C:/Users/...) works for bash and Windows tools.
      d=$(cygpath -m -O 2>/dev/null || true)
      [ -n "$d" ] || d="${USERPROFILE:-$HOME}/Documents" ;;
    Linux)
      # XDG may localize the folder (e.g. ~/Dokumente); it returns $HOME when unset.
      d=$(xdg-user-dir DOCUMENTS 2>/dev/null || true)
      [ -n "$d" ] && [ "$d" != "$HOME" ] || d="$HOME/Documents" ;;
    *)
      d="$HOME/Documents" ;;
  esac
  printf '%s' "$d"
}

# Folder resolution: plugin option > AI_TEACH_ME_NOTES_DIR env var > legacy ~/tech-notes (if it
# already holds notes) > OS default.
dir="${CLAUDE_PLUGIN_OPTION_NOTES_DIR:-${AI_TEACH_ME_NOTES_DIR:-}}"
dir="${dir/#\~/$HOME}"
if [ -z "$dir" ]; then
  if [ -d "$HOME/tech-notes/technologies" ]; then
    dir="$HOME/tech-notes"
  else
    dir="$(documents_dir)/$kb_name"
  fi
fi
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) dir=$(cygpath -m "$dir" 2>/dev/null || printf '%s' "$dir") ;;
esac

if [ -d "$dir/technologies" ]; then
  count=$(find "$dir/technologies" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
  state="It exists and holds $count note(s)."
else
  state="It does not exist yet; the skill confirms the location with the user and bootstraps it on first use."
fi

context="## AI, Teach Me! plugin (active in every project)
The user wants to understand every technology they adopt instead of coding blindly with AI.
Knowledgebase folder: $dir ($state)

Whenever a technology (framework, library, database, service, CLI tool, language, platform, protocol)
is proposed and the user accepts it, or it gets added to the project, invoke the \`ai-teach-me:note\` skill
for it. When a whole stack is accepted, the skill must cover every technology in it, not just the main one.
Skip trivial utilities. Also offer it for significant technologies already in the project that lack a note.
All notes are written in English, whatever language the conversation is in."

# JSON-escape the context without depending on jq/python.
esc=$(printf '%s' "$context" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/	/\\t/g' | awk 'BEGIN{ORS="\\n"} {print}')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
