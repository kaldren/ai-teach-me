# AI & Human in Sync

**Stop coding blind with AI.** A Claude Code plugin that writes a learning note every time you adopt a
technology Claude suggests: what it is, why it was chosen for your project, key concepts, common pitfalls,
alternatives, and verified links to the official docs.

The notes are plain Markdown in a folder you own (a git repo), so over time you build your own reference for
your whole stack.

## Install

In Claude Code:

```
/plugin install ai-and-human-in-sync --marketplace kaldren/ai-and-human-in-sync
```

Answer `y` to add the marketplace and pick the **user** scope so it works in every project. You can choose where
notes are stored during install (default `~/tech-notes`).

## How it works

1. A `SessionStart` hook adds a short rule to every session: when a technology is proposed and you accept it,
   record it.
2. The `ai-and-human-in-sync:note` skill does the work:
   - looks for an existing note (by slug and aliases);
   - **missing**: creates `technologies/<slug>.md` from the template, pinned to the version your project uses,
     and adds it to the index in `README.md`;
   - **exists**: adds the current project to `used_in_projects` and appends new notes. It never rewrites
     existing content;
   - commits the change in the notes repo (it never pushes).
3. On first use it bootstraps the folder: a `README.md` index, a `_TEMPLATE.md`, and `git init`.

Notes are always written in English, whatever language you talk to Claude in.

You can also ask for a note manually:

```
/ai-and-human-in-sync:note PostgreSQL
```

## Configuration

| Setting | How | Default |
|---|---|---|
| Notes folder | plugin option `notes_dir` (`/plugin` → ai-and-human-in-sync → configure), or the `AI_HUMAN_SYNC_NOTES_DIR` env var | `~/tech-notes` |
| Note format | edit `_TEMPLATE.md` in your notes folder; new notes follow it | the bundled template |

## Repository layout

```
.claude-plugin/plugin.json        manifest + notes_dir option
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
hooks/session-start.sh            injects the rule into each session (bash, no dependencies)
skills/note/SKILL.md              the procedure Claude follows
skills/note/assets/               template and index copied into a new notes folder
```

## Development

```
claude plugin validate --strict .
claude --plugin-dir /path/to/ai-and-human-in-sync
```

## License

MIT
