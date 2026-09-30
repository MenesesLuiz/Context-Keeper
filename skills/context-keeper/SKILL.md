---
name: context-keeper
description: Builds, feeds and maintains a local "second brain" for AI — a folder of Markdown notes the AI loads at the start of every session and updates on its own, so context survives across conversations and after compaction. Interviews the user, proposes an action plan with options for them to choose, and only then creates the structure, rules and automation (Claude Code hooks, instruction files for Cursor/Codex/Gemini). Use whenever the user mentions a second brain ("segundo cérebro"), persistent or long-term memory for AI, "the AI forgets everything" ("a IA esquece tudo"), losing context between sessions, organizing notes for Claude, moving from Obsidian/Notion to something the AI can use, or asks to save, record or checkpoint what was decided "in the brain" ("salva no cérebro") — even if they never say "second brain".
---

# Context Keeper

This skill builds a second brain **made for the AI to read and write**, not just for a human to browse. Compared with a plain Obsidian vault, it adds three things:

1. **A fixed, neutral entry point**: the brain's `CLAUDE.md`, loaded in every session. Its map says where every area and project lives, so the AI goes straight to the right folder instead of spending tokens searching the disk.
2. **A map that stays true**: rebuilt from the real folders at every session start and on demand, including folders the user created by hand.
3. **Feeding rules**: when and what the AI records, without the user having to ask.
4. **Automation**: hooks that keep the map current, reload the work in progress after compaction and ask for a checkpoint before context is lost.

The AI reads the files straight from disk, so the brain does not need Obsidian. A plain folder is the recommended default; Obsidian is an optional viewer for the human.

## Principles

When a case is not covered by the steps below, decide from these.

- **The user chooses, you propose.** Nothing is created before the user approves a plan. Files outside the brain folder are touched only with explicit consent and after a backup. The one exception, agreed in the plan, is the pointer `~/.context-keeper/config` that this skill creates.
- **Layered memory, so it fits in context.**
  - *Hot* (loaded every session, under ~2,000 tokens): only the root `CLAUDE.md` — rules, navigation and the map. It is **neutral**: one line per folder saying what it is, never favoring a subject. The now file is not loaded at start; it is read on demand ("what was I working on?") and reloaded by the hook after a compaction, when work is in progress.
  - *Warm* (loaded when a subject comes up): each subject's index note, with its "Current state" section.
  - *Cold* (read only when needed): decisions, research, older journal entries, archive.
- **The brain keeps the why; code and git keep the how.** Notes never copy what the code, README or git history already hold.
- **The brain is the user's workspace, and you only advise how to organize it.** Recommend keeping each complete project (its files, and its code) in its own folder under the brain's projects folder, next to its context notes, so the AI finds everything in one place. Never move, rename or delete the user's files yourself: explain the benefit, give the steps, and let the user do it. Until they do, the project's index note records where its files live.
- **The brain works without this skill.** All feeding rules are written inside the brain's root file, so any AI can operate it.
- **Update instead of duplicating**, use **absolute dates** (`YYYY-MM-DD`), and **never store secrets** (passwords, tokens, API keys).
- **Plain text, no emojis**, in notes and in messages about the brain.
- **Language.** Run the interview and build the brain in the user's language. Use `assets/templates/pt-BR/` for Portuguese and `assets/templates/en/` for English. For any other language, start from `en/`, translate file and folder names, and record them in `.context-keeper/config.json` → `files`.

## Pick the mode

| The user wants to | Mode |
|---|---|
| Create a second brain, "I want the AI to remember things", adopt an existing brain or notes folder, change the automation level or add another AI tool | **1. Setup** |
| "Save this to the brain", "checkpoint", end of a long session, `/context-keeper:checkpoint`, or the Stop hook asked for it | **2. Checkpoint** |
| Bring in notes from Obsidian/Notion, documents, a repository or exported conversations | **3. Import** |
| "Review/clean up my brain", stale notes, a messy brain, `/context-keeper:review` | **4. Review** |
| "Update the map", new folders, the AI cannot find a project, `/context-keeper:map` | **5. Map** |

---

## Mode 1 — Setup

Six steps. Never skip step 3: the plan approval is what keeps the user in charge.

1. **Detect, silently.** Find out what you can before asking anything. Look only in the user's home folder (top level, Documents, Desktop) and in paths the user mentioned — never scan other drives or other people's folders:
   - operating system and home folder;
   - AI tools present (`~/.claude/`, `~/.claude/CLAUDE.md`, `~/.codex/`, `~/.gemini/`, Cursor);
   - an existing brain: first `~/.context-keeper/config`, then folders with `CLAUDE.md`, `AGENTS.md`, `BRAIN.md`, `CEREBRO.md` or `.context-keeper/config.json`;
   - an Obsidian vault (a folder with `.obsidian/`);
   - where the user's projects live (folders with code or documents, e.g. `~/code`, `Documents/<something>`) — only their names and locations, not their contents;
   - `bash`, only if Claude Code is present (it is needed for the hooks; on Windows it ships with Git for Windows, which Claude Code already requires).

   Summarize what you found in 2–4 lines at the top of your first reply, so the user can correct it.

   Then decide how to start:
   - **A brain exists** (a notes folder already written for an AI, with a root file of rules): switch to **adopt**. Keep everything the user made, map it to this skill's concepts (e.g. their `Claude.md` acts as the root file), keep their link style, and propose only what is missing. If it was created by this skill, read `.context-keeper/config.json` and ask what they want to change. Never overwrite existing notes.
   - **An Obsidian vault or notes folder exists, but not for an AI:** treat it as **material to import** (Mode 3) into a new, lean brain. Offer adopting the vault in place as the alternative only when it is small (under ~200 notes) and already well organized.
   - **Project or document folders exist** (code repositories, a university folder, client folders): list them in the interview as candidate subjects, and in the plan recommend organizing them under the brain's projects folder (see `references/architectures.md` → "Organizing projects").
   - **A tool the user named was not found:** trust the user — it may be installed somewhere you did not look. Confirm it in the interview and plan its integration as a manual step if needed. Never assume the user is wrong about their own tools.

2. **Interview.** Follow `references/interview.md`. Start directly with the quick-path questions, skipping any the user already answered; mention in one line that a fuller interview is available. Ask at most 4 questions per round, and use `AskUserQuestion` when available.

3. **Plan.** Build the plan with the format at the end of `references/interview.md`, using `references/architectures.md` for the options. Present it and **wait for the user's choices**. Adjust and present again as many times as needed.

4. **Build**, in this order, reporting progress:
   1. **Folders**: only the core ones and those that will have content now. Empty folders confuse the AI and the user. In adopt mode, do not add `Inbox/` or `Archive/` until something needs them.
   2. **Core files** from the language's template set: the root `CLAUDE.md` (with the map markers), the now file, the profile and preferences notes from the interview answers, the note templates copied into `Templates/`, and `.context-keeper/config.json` from `assets/templates/config.json`. Keep `CLAUDE.md` under ~150 lines: it loads every session, and Claude Code loads it in any folder inside the brain. If the user also uses other AIs, add a one-line `AGENTS.md` telling them to read `CLAUDE.md` first. In adopt mode, keep the user's root file and propose adding the map markers to it.
   3. **Map**: run `bash scripts/update-map.sh <brain>` to fill the map. Every area and project folder gets an index note with a one-line, neutral `descricao:`/`description:`.
   4. **Pointer**: write `~/.context-keeper/config` with the line `brain_path=<brain path, forward slashes>`. The hooks and the checker find the brain through it. If it already points elsewhere, ask before replacing it.
   5. **Integrations** for the chosen level: follow `references/integrations.md`.
   6. **Git** (if chosen): `git init`, `.gitignore` with `.context-keeper/state/` and with any project folder that is its own git repository, first commit. For a remote, recommend a **private** repository. In adopt mode, always ask before creating a repository in the user's existing folder.

5. **Seed.** An empty brain helps nobody:
   - an index note for each active subject the user mentioned, with "Current state" and "Where things are" (the real location of its files) filled in, and a one-line `description:` so it shows up in the map;
   - the now file with the current focus and open items;
   - imports the user asked for (Mode 3);
   - the first journal entry recording the setup and the choices made, and the approved plan saved to `.context-keeper/setup-plan.md`.

6. **Verify and hand off.**
   1. Run `bash scripts/brain-lint.sh <brain>` (from this skill's folder) and fix what it reports.
   2. At level 3, run the start hook without the brain path, to test the pointer too: `echo '{"source":"compact"}' | bash scripts/session-start.sh`. The output must contain the now file and stay under 8,000 characters. With `"startup"` and an up-to-date map, it prints nothing — that is expected.
   3. Give the user a **one-screen guide**: where the brain lives, what happens automatically, 3–4 useful phrases ("save this to the brain", "what's in NOW?", "review the brain"), the recommended project organization with the exact moves for them to do (if their projects live elsewhere), and, if they chose Obsidian, how to open the folder as a vault.
   4. Suggest a real test: open a new session and ask "what was I working on?".

## Mode 2 — Checkpoint

Follow the *Checkpoint* section of `references/feeding-protocol.md`:

1. Read the root file and the now file.
2. List what is worth keeping since the last checkpoint: decisions (with the reason), state changes, open items, discoveries, new preferences.
3. Update decision notes, the "Current state" of each subject touched, the now file, the preferences file and the journal.
4. Tell the user in 2–4 lines what was saved and where. If nothing relevant happened, say so instead of creating empty notes.

## Mode 3 — Import

Follow `references/importing.md`. Importing is not copying:

1. Take an inventory of the source, without changing anything.
2. Triage each part: bring and reorganize, summarize, only link to it, or leave out.
3. Present the triage as a table and wait for approval.
4. Copy into the brain (never move or delete the source) and log the import in the journal.

## Mode 4 — Review

Follow `references/maintenance.md`:

1. Run `scripts/brain-lint.sh`.
2. Add the checks that need judgment (duplicates, contradicting decisions, stale "Current state").
3. Present a short report in plain language, most costly problems first.
4. Apply only what the user approves and log the review in the journal.

## Mode 5 — Map

Keeps the map in `CLAUDE.md` true to the real folders:

1. Run `bash scripts/update-map.sh <brain>`. It rewrites only the part between the map markers. If the markers are missing, propose where to add them and wait for approval. Where scripts cannot run (Claude Desktop, AIs without a shell), do the same by hand: list the folders two levels deep, take each description from the `descricao:`/`description:` line of the folder's index note, and rewrite only the block between the markers in the same tree format.
2. For each folder "without description", propose a one-line, neutral description (what the folder is, not its status) and, after approval, write it in the folder's index note (create the note from the template if needed). Run the script again.
3. Tell the user in 2–4 lines what changed.

Also run it yourself, without being asked, right after creating a folder in the brain.

---

## Files

| File | When to read |
|---|---|
| `references/interview.md` | Setup steps 2–3 (questions, defaults and the plan format) |
| `references/architectures.md` | Setup step 3 (folder structures, plain folder vs Obsidian, link style, automation levels) |
| `references/integrations.md` | Setup step 4 (Claude Code, Claude Desktop, Cursor, Codex, Gemini, ChatGPT) |
| `references/feeding-protocol.md` | Writing the root file's feeding rules, and Mode 2 |
| `references/importing.md` | Mode 3 |
| `references/maintenance.md` | Mode 4 |
| `scripts/update-map.sh` | Mode 5, Setup step 4, and the start hook: rebuilds the map in `CLAUDE.md` from the real folders (`--check` only reports) |
| `assets/templates/pt-BR/`, `assets/templates/en/` | Brain files per language |
| `assets/templates/config.json` | The brain's `.context-keeper/config.json` |
| `assets/hooks/claude-settings.json` | Hooks for `~/.claude/settings.json` (level 3, standalone install only) |
| `scripts/lib.sh` | Shared by the scripts: finds the brain, its file names and language |
| `scripts/session-start.sh` | Hook: updates the map at every session start (prints it only if it changed) and reloads the now file and the journal after compaction |
| `scripts/checkpoint-stop.sh` | Hook: asks for a checkpoint when the conversation grew a lot since the last one |
| `scripts/brain-lint.sh` | Health check of the brain |
