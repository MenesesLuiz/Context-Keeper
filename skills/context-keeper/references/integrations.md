# Integrations per tool

General rule for any file outside the brain:
1. If the file exists, **read it** and back it up (`<file>.bak-YYYY-MM-DD`).
2. **Append** the brain block between markers, without deleting what is there:
   ```
   <!-- context-keeper:start -->
   ...
   <!-- context-keeper:end -->
   ```
   The markers let a later Setup run update or remove the block.
3. Record the changed file in `.context-keeper/config.json` → `integrations`.

Tool paths and menus change often. If something below does not match what you find on the user's machine, check the tool's current documentation before going on.

Use `/` in paths even on Windows (e.g. `E:/SecondBrain`), because the scripts run in bash.

In the blocks below, `<BRAIN>` is the brain path and `<ROOT>` is its root file name (`BRAIN.md`, `CEREBRO.md`, or the adopted one). Write the block text in the user's language.

---

## Claude Code

### Level 2 — global import
In `~/.claude/CLAUDE.md` (loaded in every session, in any folder):

```markdown
<!-- context-keeper:start -->
# Second brain
My second brain lives at `<BRAIN>`. Its rules are below; follow them in every session.
@<BRAIN>/<ROOT>
<!-- context-keeper:end -->
```

The `@path` line imports the file into context. To check it worked, the user can run `/memory` in a new Claude Code session and see the root file listed.

> Without this import, the root file only loads when Claude Code is opened inside the brain folder itself — a common gap in hand-made brains.

### Level 3 — hooks

First make sure the pointer `~/.context-keeper/config` exists (`brain_path=<BRAIN>`). Then it depends on how the skill was installed:

**As a plugin (recommended).** The `context-keeper` plugin ships the hooks in `hooks/hooks.json`. They stay inactive until the pointer exists and start working in the next session. Do not edit `~/.claude/settings.json`.

**As a standalone skill.**
1. Copy the skill's `scripts/*.sh` (including `lib.sh`) to `<BRAIN>/.context-keeper/scripts/`.
2. Merge `assets/hooks/claude-settings.json` into `~/.claude/settings.json`, replacing `<BRAIN>` with the real path. If hooks already exist for the same events, **append** entries to the array instead of replacing it.

**Test (both cases):**
```bash
echo '{"source":"startup"}' | bash "<scripts folder>/session-start.sh"
```
The output must be short and contain the now file.

What each hook does:
- **SessionStart** (`session-start.sh`): runs when a session starts, resumes, is cleared or is **compacted**. What it prints (Claude Code accepts up to 10,000 characters; the script cuts at 8,000) enters the AI's context. After a compaction, it adds a note telling the AI to resume from the now file.
- **Stop** (`checkpoint-stop.sh`): runs when the AI finishes an answer. If the transcript grew more than the limit (default ~300 KB) since the last checkpoint, it returns an `additionalContext` asking the AI to run a checkpoint before stopping. The user sees it as "Stop hook feedback", not as an error. It has loop protection (`stop_hook_active`) and fires again only after new growth. The limit can be changed with `CONTEXT_KEEPER_CHECKPOINT_BYTES`.

File names and the hook messages' language come from `.context-keeper/config.json` (`files`, `language`), so the scripts work in any language and in adopted brains (e.g. a `Claude.md` root).

---

## Claude Desktop (chat app) and claude.ai

- **Claude Desktop:** enable the filesystem extension in the extensions settings and give it access to the brain folder. Then, in the profile's personal preferences (or in a Project's instructions), paste:
  > I have a second brain at `<BRAIN>`. At the start of every conversation, read `<ROOT>` and the now file there and follow the rules in `<ROOT>`.
- **claude.ai on the web:** cannot read local files. One option is a Project with the root file, the now file and the profile uploaded as project knowledge — but it is a static copy that must be re-uploaded when it changes. Make this limit clear to the user.

## Cursor

- **Global:** Cursor Settings → Rules → *User Rules*: paste the same text as for Claude Desktop (Cursor's AI reads files by absolute path). This step is manual; list it in the plan as a task for the user.
- **Per project:** Cursor also reads `AGENTS.md` at the project root and rules in `.cursor/rules/`. Only create files in the user's repositories if they ask.

## OpenAI Codex CLI

Global file `~/.codex/AGENTS.md`: append the marked block pointing to `<BRAIN>/<ROOT>` and asking the AI to read it at the start of the session.

## Gemini CLI

Global file `~/.gemini/GEMINI.md`: same block as for Codex.

## GitHub Copilot

Instructions are per repository (`.github/copilot-instructions.md`). Only set it up if the user asks, one repository at a time.

## ChatGPT (web/app)

Cannot read local files. All options are manual:
- Paste the profile and preferences notes into the custom instructions.
- In important conversations, paste the now file at the start and, at the end, ask for a checkpoint-style summary to paste into the brain (or ask an AI with file access to record it).

Be honest with the user: in these tools the brain works at level 1.
