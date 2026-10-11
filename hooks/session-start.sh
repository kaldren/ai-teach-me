#!/usr/bin/env bash
# Injects the AI & Human in Sync rule into every session so Claude records technologies
# without being asked. Kept short: it costs context tokens in every session.
set -euo pipefail

# Folder resolution: plugin option > AI_HUMAN_SYNC_NOTES_DIR env var > default.
dir="${CLAUDE_PLUGIN_OPTION_NOTES_DIR:-${AI_HUMAN_SYNC_NOTES_DIR:-$HOME/tech-notes}}"
dir="${dir/#\~/$HOME}"

if [ -d "$dir/technologies" ]; then
  count=$(find "$dir/technologies" -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')
  state="It exists and holds $count note(s)."
else
  state="It does not exist yet; the skill bootstraps it on first use."
fi

context="## AI & Human in Sync plugin (active in every project)
The user wants to understand every technology they adopt instead of coding blindly with AI.
Knowledgebase folder: $dir ($state)

Whenever a technology (framework, library, database, service, CLI tool, language, platform, protocol)
is proposed and the user accepts it, or it gets added to the project, invoke the \`ai-and-human-in-sync:note\` skill
for it. Skip trivial utilities. Also offer it for significant technologies already in the project that lack a note.
All notes are written in English, whatever language the conversation is in."

# JSON-escape the context without depending on jq/python.
esc=$(printf '%s' "$context" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/	/\\t/g' | awk 'BEGIN{ORS="\\n"} {print}')
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$esc"
