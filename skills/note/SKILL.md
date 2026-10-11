---
name: note
description: Create a learning note for a technology in the user's AI, Teach Me! knowledgebase, one note per major version. Use when a technology (framework, library, database, service, CLI tool, language, platform, protocol) is proposed and the user accepts it or it is added to the project, or when the user asks to document, explain or learn a technology ("add a note for X", "/ai-teach-me:note X").
argument-hint: "[technology]"
---

# Technology note

Goal: the user should understand every technology they adopt. A note is a short, high-signal study guide with
verified links to the official docs, not a copy of the docs. Notes are plain Markdown files the user opens and
reads on their own machine.

Hard rules:
- Write only inside the knowledgebase folder. Never write notes into the current project or its repo.
- No git: never run `git init`, `git add` or `git commit` in the knowledgebase folder.
- Never edit an existing note. A note is either created or skipped.

## 1. Resolve the knowledgebase folder

Use the folder named in the session context by the AI, Teach Me! plugin. If none is given, use
`$AI_TEACH_ME_NOTES_DIR`, else `~/tech-notes` if it already holds a `technologies/` folder, else
`ai-teach-me-kb` (or the plugin's `kb_folder_name` option) inside the user's Documents folder (macOS: `~/Documents`; Windows: the Documents
folder, `cygpath -m -O` in Git Bash; Linux: `xdg-user-dir DOCUMENTS`, else `~/Documents`). Expand `~`.

The path may contain spaces: always double-quote it in shell commands.

If the folder or its `technologies/` subfolder does not exist, first confirm the location with the user (one
question: the resolved path, or another folder). If they pick another folder, use it, and tell them to save it
under `/config` → AI, Teach Me! → Knowledge base folder so future sessions use it too. Then bootstrap it:
- create `<dir>/technologies/`
- copy `assets/kb-readme.md` (next to this file) to `<dir>/README.md` and `assets/template.md` to `<dir>/_TEMPLATE.md`

## 2. Pick the technology, its slug and its version line

Use the argument if given; otherwise the technology just adopted in the conversation. If several were adopted at
once, handle each one. Slug: lowercase kebab-case of the common name (`nextjs`, `postgresql`, `tailwind-css`,
`react-query`).

Find the version the project uses (lockfile, manifest, `--version` output); with no project version, use the
latest stable release. Reduce it to its **version line**, the level at which breaking changes happen:
- semver `>= 1.0`: the major (`15.2.3` → `15`)
- semver `0.x`: major.minor (`0.4.2` → `0.4`)
- not semver (calendar versions, some languages and platforms): the release the official release notes treat as
  carrying breaking changes; check them when unsure
- no meaningful version (a protocol, a hosted service with no versioned API): none

File name: `technologies/<slug>-v<line>.md` (`nextjs-v15.md`, `zod-v0.4.md`), or `technologies/<slug>.md` when
there is no version line.

## 3. Existing notes → create or skip

List `technologies/` and grep the `name:`/`aliases:` front matter for the technology's names. Existing notes for it
are `<slug>-v*.md`, plus a plain `<slug>.md` from older plugin versions; for those, take the line from their
`version:` or `version_at_time_of_writing:` field.

- **A note for this version line exists** → skip. Minor and patch releases inside a line bring no breaking
  changes, so nothing is written. Go to step 6.
- **Notes exist only for other lines** (a newer major arrived, or the project uses one without a note) → create a
  note for this line (step 4) and fill its "What changed since the previous version" section: the breaking
  changes from the closest older line that has a note, with a link to the official migration guide.
- **No note at all** → create one (step 4) and delete the "What changed since the previous version" section.

## 4. Create the note

Copy `<dir>/_TEMPLATE.md` (fall back to `assets/template.md`) to the file name from step 2 and fill every section:
- Write in English, whatever language the conversation is in.
- "Why it was chosen here" is about the current project and the actual reason it was proposed.
- Write about this version line: its APIs, defaults and pitfalls, not older ones.
- Links: only official docs and well-known resources, pointing to this version's docs where they are versioned.
  Verify each URL with WebFetch or WebSearch when those tools are available. If you cannot verify a link, leave
  it out rather than guess.
- Keep it tight: a note someone reads in 10 minutes, with links for depth.

## 5. Update the index

Add one line to the index in `<dir>/README.md` under the matching category heading (add the heading if missing):
`- [Name <line>](technologies/<file>.md) — one-sentence summary` (no `<line>` when there is none). This is the one
existing file you may change.

## 6. Tell the user

One or two lines:
- created: the note's full path and which section or link to read first;
- skipped: that a note for this version line already exists, with its path.
