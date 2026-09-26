# Context Keeper

Leia em português: [README.pt-BR.md](README.pt-BR.md)

> A Claude Code plugin that builds a local second brain **made for AI** on your machine — and keeps it fed on its own.

Every AI forgets. After many messages the context gets compacted and details disappear. In a new conversation you explain everything again. Many people try to fix this with Obsidian or Notion, but those were made for **humans** to browse: the AI does not know the vault exists, does not know what to read first and does not know when to write.

Context Keeper fixes that. It interviews you, proposes a plan (**you choose**) and builds:

- **An entry point** the AI loads in every session, in any folder.
- **Feeding rules**: the AI records decisions, project state, discoveries and your preferences without you having to ask.
- **Automation** (Claude Code): context is reloaded right after every compaction, and the AI is reminded to run a *checkpoint* when the conversation gets long.

Everything is plain Markdown in a regular folder on your computer.

### What about Obsidian?

You don't need it. The AI reads and writes the files straight from disk and does not open Obsidian the way a person does, so for the AI Obsidian changes nothing. That is why the recommended default is **a plain folder**. If you like Obsidian for browsing your notes, the skill offers that option and explains how to set it up — and you can open the folder in Obsidian later, at any time.

## How it works

```
      every session              when a subject comes up          only when needed
 +------------------------+    +-------------------------+    +-----------------------+
 | HOT   (~2k tokens)     | -> | WARM                    | -> | COLD                  |
 | BRAIN.md  rules        |    | Projects/X/Index.md     |    | Decisions/, Research/ |
 | NOW.md    state        |    | "Current state"         |    | Journal/, Archive/    |
 +------------------------+    +-------------------------+    +-----------------------+
            ^                                                              |
            +--------------- checkpoint: the AI updates the notes <--------+
```

| Level | What it does | Tools |
|---|---|---|
| 1 Manual | Structure and rules. The AI uses the brain when you ask. | Any |
| 2 Connected | The AI loads the brain on its own in every session and follows the feeding rules. | Claude Code, Codex, Gemini CLI, Cursor, Claude Desktop |
| 3 Automatic | Level 2, plus context reloaded after compaction and automatic checkpoint requests. | Claude Code |

## Installation

**Claude Code (recommended: as a plugin).** In a Claude Code session:

```
/plugin marketplace add MenesesLuiz/Context-Keeper
/plugin install context-keeper@context-keeper
```

The plugin ships the skill, the `/context-keeper:checkpoint` and `/context-keeper:review` commands and the automation hooks. The hooks stay inactive until you create your brain.

On Windows, install Claude Code with the official installer to get the `claude` command in your terminal. The executable bundled inside the Claude desktop app lives in a virtualized folder and does not work as a regular terminal command.

**Claude Code (as a standalone skill).** Copy `skills/context-keeper/` into `~/.claude/skills/`. Everything works, but level 3 automation requires the skill to edit your `~/.claude/settings.json` (with a backup).

**Claude.ai / Claude Desktop.** Zip the `skills/context-keeper/` folder and upload it under *Settings → Capabilities → Skills*. These apps have no hooks, so the brain works up to level 2.

## Usage

In a conversation, say something like:

- *"I want to set up a second brain so you stop forgetting things."*
- *"Save what we decided today to the brain."*
- *"Import my Obsidian vault into the brain."*
- *"Review my second brain."*

The skill works in English and Portuguese. Brains in Portuguese use Portuguese file names (`CEREBRO.md`, `AGORA.md`, `Diario/`).

## What gets created

```
SecondBrain/
├── CLAUDE.md         one line that loads BRAIN.md in Claude Code
├── BRAIN.md          rules, map and feeding protocol
├── NOW.md            current focus, open items, latest decisions
├── Profile/          who you are and how you like the AI to work
├── Projects/         Projects-Map.md + one folder per project, with its files and its context
├── Inbox/            quick captures
├── Journal/          one entry per relevant session
├── Templates/        note templates
├── Archive/          finished work (nothing is deleted)
└── .context-keeper/  config and hook state
```

## Organize your projects inside the brain

The brain works best as your workspace: each project in its own folder under `Projects/`, holding both the project's files (documents, code) and its context notes. The AI then has everything it needs in one place, and opening Claude Code inside any project folder loads the brain's rules automatically.

The skill only **recommends** this and shows you the exact moves. It never moves, renames or deletes your files; you do it when you want, and until then the brain records where each project lives.

## Privacy

Everything stays **on your computer**. The skill sends nothing anywhere, backs up any configuration file before changing it and tells the AI to **never** record passwords, tokens or keys. If you version your brain with git, use a **private** repository.

## Repository layout

```
.claude-plugin/              plugin.json and marketplace.json
skills/context-keeper/
├── SKILL.md                 main flow and modes
├── references/              interview, architectures, integrations, feeding protocol, importing, maintenance
├── assets/templates/        brain files, in pt-BR/ and en/
├── assets/hooks/            hooks for standalone installs
└── scripts/                 lib.sh, session-start.sh, checkpoint-stop.sh, brain-lint.sh
hooks/hooks.json             plugin hooks (SessionStart and Stop)
commands/                    /context-keeper:checkpoint and /context-keeper:review
tests/skill-evals.json       test scenarios for the skill
tests/make-personas.sh       fictional test users, each with a simulated home folder
```

## License

[MIT](LICENSE)

See the [ROADMAP.md](ROADMAP.md) for what comes next.
