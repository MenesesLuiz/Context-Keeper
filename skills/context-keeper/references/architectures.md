# Architectures: structure, viewing and automation levels

File and folder names below are the English ones. For a Portuguese brain, use the names from `assets/templates/pt-BR/` (section 4 of `CEREBRO.md` has the tree).

## Core (present in every structure)

```
<Brain>/
├── CLAUDE.md         one line, `@BRAIN.md` (only for Claude Code users; see below)
├── BRAIN.md          HOT: rules, map and feeding protocol (under ~150 lines)
├── NOW.md            HOT: current focus, open items, latest decisions (under ~60 lines)
├── Projects/
│   └── Projects-Map.md   WARM: every project, one line each (status, next step, link)
├── Profile/
│   ├── About-me.md       who the user is
│   └── Preferences.md    how they like the AI to work (grows with every correction)
├── Inbox/            quick captures not yet sorted
├── Journal/          YYYY-MM-DD.md: one short entry per relevant session
├── Templates/        note templates
├── Archive/          finished or abandoned work (nothing is deleted)
└── .context-keeper/  system: config.json, hook state (Obsidian ignores dot folders)
```

Why each piece exists:
- **Root file separate from the now file**: rules change rarely, state changes every session. Keeping them apart avoids rewriting the rules at every checkpoint and lets the hook reload only the now file after compaction.
- **Preferences**: every "don't do X" or "I prefer Y" goes here. It is what stops the AI from repeating mistakes across sessions.
- **Journal**: chronological and cheap to write. When it is unclear where something belongs, the journal makes sure it is not lost.
- **Archive**: moving things out of the way without deleting keeps active areas small (fewer tokens when searching) and preserves history.
- **Projects map**: the AI's table of contents for all projects, active or paused. The now file lists only what is active this week; the map lists everything and says where each project lives.
- **`CLAUDE.md` in the root**: Claude Code loads `CLAUDE.md` from the folder it is opened in and from every parent folder. With this one-line file, opening Claude Code inside any project in the brain loads the brain's rules automatically.

## Option A — By subject (recommended to start)

```
├── Projects/
│   ├── Projects-Map.md
│   └── <Project-Name>/
│       ├── Index.md      WARM: overview + "Current state" + "Where things are"
│       ├── Decisions/    YYYY-MM-DD-title.md
│       └── ...           the project itself: its files, documents and code
├── Studies/              (if used for studying) one folder per course or subject
└── Research/             research useful to more than one project
```

- Good for: people with few kinds of activity, developers, students.
- Research that serves a single project stays inside that project.

## Option B — PARA (Projects, Areas, Resources, Archive)

```
├── 1-Projects/    have a goal and an end (e.g. "Launch portfolio")
├── 2-Areas/       ongoing responsibilities with no end (Health, Finances, Career, University)
├── 3-Resources/   topics of interest and reference material
└── 4-Archive/     replaces the core Archive/
```

- Good for: people mixing personal life, work and study, or who already know Tiago Forte's method.
- "Does this have an end date?" decides between Project and Area. Explain that to the user.
- Every project and area has its own index note with "Current state", and `1-Projects/` has the projects map.

## Option C — Adopt the existing structure

For users who already have a notes folder written for an AI (a root file of rules, such as `Claude.md` or `AGENTS.md`). A plain Obsidian vault is different: by default it is material to import (Mode 3) into a new, lean brain; adopt it in place only if it is small (under ~200 notes) and already well organized. Map the concepts instead of reorganizing:
- Existing root file (`Claude.md`, `README.md`, `Home.md`) → acts as the root file; propose adding what is missing (feeding protocol, map).
- Main note of each folder → acts as the index note; propose a "Current state" section if missing.
- A subject that is a single file (e.g. `Projects/Recipes-App.md`) stays where it is. Put its decisions in a folder named after it (`Projects/Recipes-App/Decisions/`) and suggest that the user move the file into that folder as its index note.
- You may **add** to the user's notes (frontmatter, a "Current state" section, links), but never rewrite or remove what they wrote.
- Keep the user's link style (`[[wikilinks]]` or regular links) and record it in `config.json` → `link_style`.
- Propose only the missing core pieces (usually the now file, the profile, the journal and `.context-keeper/`), and record the real names in `.context-keeper/config.json` → `files`.

---

## Organizing projects (advice only)

The brain works best as the user's workspace: every project in its own folder under `Projects/`, holding both the project itself and its context. The AI then has everything it needs to help, in one place, and opening Claude Code in a project folder loads the brain's rules through the root `CLAUDE.md`.

```
<Brain>/
├── CLAUDE.md
├── BRAIN.md, NOW.md, ...
└── Projects/
    ├── Projects-Map.md        one line per project
    ├── agentops/
    │   ├── Index.md           overview, Current state, Where things are
    │   ├── Decisions/
    │   └── app/               the code repository
    ├── client-site-2/
    │   ├── Index.md
    │   └── briefs/, drafts/   the client's documents
    └── personal-project-3/
```

How to recommend it:
- **Advise, never move.** Explain the benefit in one or two sentences, list the exact moves ("move `~/code/agentops` to `<Brain>/Projects/agentops/app`"), and let the user do it when they want. Never move, rename or delete the user's files yourself.
- **Code repositories:** keep the repository in a subfolder of the project (e.g. `app/`), so the context notes do not mix with the repository's own files and history. If the brain uses git, add that subfolder to the brain's `.gitignore`.
- **Warn about side effects** before the user moves code: open editors, scripts or deploy settings with absolute paths may need updating, and cloud-synced folders (OneDrive, Dropbox) handle `node_modules`, virtual environments and build folders badly.
- **Until the user moves a project**, its index note's "Where things are" and its line in the projects map record the current location, so the AI can still find it.

---

## Plain folder or Obsidian

**Recommendation: a plain folder of Markdown files.** Explain to the user, in simple words:

- The AI **does not open Obsidian**. It reads and writes the `.md` files straight from disk, like any other file. The brain works the same with or without Obsidian.
- Obsidian is a **viewer for humans**: graph, search, link navigation. Useful for browsing the notes, but optional.
- They can change their mind any time: opening the brain folder as a vault changes nothing in it.

**Links.** The default is a regular Markdown link with a path relative to the current note:

```markdown
[Use Postgres](Decisions/2026-09-25-use-postgres.md)
```

It is the best format for the AI: the path is exact, so it opens the file without searching by name. It also works on GitHub, in VS Code and in Obsidian itself.

If the user picks Obsidian and **prefers** wikilinks (`[[use-postgres]]`), that is fine: set `"link_style": "wikilink"` in `config.json` and write the convention into the root file. The cost is that the AI has to search for the file by name before opening it.

Keep the plain folder as the recommendation even for people who already use Obsidian; just add that they can open the new folder in the Obsidian they already have.

**If they pick Obsidian**, tell them how to set it up:
- Open the brain folder as a vault (*Open folder as vault*).
- To keep regular links: *Settings → Files and links* → turn off *Use [[Wikilinks]]* and set *New link format* to *Relative path to file*.
- Obsidian creates a `.obsidian/` folder; the scripts and the AI ignore it.
- Avoid using Obsidian-only features as the source of truth (Dataview queries, Canvas): the AI sees the query text, not its result.

---

## Automation levels

Tell the user what each level **does** and what it **touches** on their computer.

### Level 1 — Manual
- **Does:** creates the folder, the rules and the templates. The AI uses the brain only when told to ("read my brain at X").
- **Touches:** nothing outside the brain folder.
- **For:** people who want to try first, or who use AIs without file access (ChatGPT on the web).

### Level 2 — Connected
- **Does:** the AI loads the root file automatically in every session, in any folder, and follows the feeding protocol on its own.
- **Touches:** the pointer `~/.context-keeper/config` and the global instruction files of the chosen tools (e.g. `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`), each backed up first.
- **Limit:** depends on the AI remembering to save. In very long conversations, compaction may happen before the save.

### Level 3 — Automatic (Claude Code)
- **Does, on top of level 2:**
  - At session start **and right after every compaction**, loads the now file and the latest journal entry into context: the AI "wakes up" knowing where it stopped.
  - When the conversation has grown a lot since the last checkpoint, asks the AI to run one before finishing its answer, so the state reaches the brain before compaction summarizes it.
- **Touches:** everything level 2 touches (the pointer and the `~/.claude/CLAUDE.md` import), plus:
  - installed as a plugin: nothing else — the hooks ship with the plugin and find the brain through the pointer;
  - installed as a standalone skill: `~/.claude/settings.json` (merge, with backup) and scripts in `<Brain>/.context-keeper/scripts/`.
- **Requires:** `bash` (on Windows it ships with Git for Windows, which Claude Code already requires).
- **Cost:** a few seconds per checkpoint and ~1–2 thousand tokens per session for the hot context.
