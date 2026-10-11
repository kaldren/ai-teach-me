---
name: note
description: Create or update a learning note for a technology in the user's AI & Human in Sync knowledgebase. Use when a technology (framework, library, database, service, CLI tool, language, platform, protocol) is proposed and the user accepts it or it is added to the project, or when the user asks to document, explain or learn a technology ("add a note for X", "/ai-and-human-in-sync:note X").
argument-hint: "[technology]"
---

# Technology note

Goal: the user should understand every technology they adopt. A note is a short, high-signal study guide with
verified links to the official docs, not a copy of the docs.

## 1. Resolve the knowledgebase folder

Use the folder named in the session context by the AI & Human in Sync plugin. If none is given, use `$AI_HUMAN_SYNC_NOTES_DIR`,
else `~/tech-notes`. Expand `~`.

If the folder or its `technologies/` subfolder does not exist, bootstrap it:
- create `<dir>/technologies/`
- copy `assets/kb-readme.md` (next to this file) to `<dir>/README.md` and `assets/template.md` to `<dir>/_TEMPLATE.md`
- if `<dir>` is not inside a git repo, run `git init` there

## 2. Pick the technology and its slug

Use the argument if given; otherwise the technology just adopted in the conversation. If several were adopted at
once, write one note each. Slug: lowercase kebab-case of the common name (`nextjs`, `postgresql`, `tailwind-css`,
`react-query`). Before creating, check for the note under other spellings: list `technologies/` and grep the
`name:`/`aliases:` front matter for the technology's names.

## 3. Note missing → create it

Copy `<dir>/_TEMPLATE.md` (fall back to `assets/template.md`) to `technologies/<slug>.md` and fill every section:
- Write in English, whatever language the conversation is in.
- "Why it was chosen here" is about the current project and the actual reason it was proposed.
- Pin `version_at_time_of_writing` to the version the project uses (check the lockfile/manifest).
- Links: only official docs and well-known resources. Verify each URL with WebFetch or WebSearch when those tools
  are available. If you cannot verify a link, leave it out rather than guess.
- Keep it tight: a note someone reads in 10 minutes, with links for depth.

Then add one line to the index in `<dir>/README.md` under the matching category heading (add the heading if missing):
`- [Name](technologies/<slug>.md) — one-sentence summary`

## 4. Note exists → update it

Do not rewrite it. Add the current project to `used_in_projects` if it is not listed, bump `last_updated`, and
append new project-specific notes, pitfalls or verified resources under "Project notes".

## 5. Save

If `<dir>` is a git repo, commit only the files you changed:
`git -C <dir> add <files> && git -C <dir> commit -m "docs(<slug>): add note"` (or `update note`).
Never push.

## 6. Tell the user

One or two lines: the note's path, whether it was created or updated, and which section or link to read first.
