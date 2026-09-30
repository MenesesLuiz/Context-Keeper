# Changelog

All notable changes to this project are documented here. Dates use `YYYY-MM-DD`.

## [0.3.0] — unreleased

### Added
- **The map**: the root `CLAUDE.md` holds a map of every folder, two levels deep (`Area/Project/`), one neutral line each. The AI finds any area or project by reading one file instead of searching the disk.
- `scripts/update-map.sh` rebuilds the map from the real folders, between markers, without touching the rest of `CLAUDE.md`. Descriptions come from each folder's index note (`descricao:` / `description:`); `--check` only reports.
- `/context-keeper:map` command (Mode 5): updates the map and asks for descriptions of new folders.
- `brain-lint.sh` reports a map that no longer matches the folders.

### Changed
- **`CLAUDE.md` is the root file in every language**, modeled as a neutral global scope: purpose, rules of conduct, navigation, map (current and planned), conventions, feeding protocol and decisions. `BRAIN.md`/`CEREBRO.md` are gone for new brains (still detected in existing ones).
- **Neutral session start**: the start hook updates the map and prints it only if it changed; it no longer loads the now file at every start. The now file is read on demand and reloaded only after a compaction.
- Top-level folders are the areas of the user's life (University, Work, Projects...), each with an index note.

- **Windows without Git**: PowerShell versions of the map script and of both hooks (`update-map.ps1`, `session-start.ps1`, `checkpoint-stop.ps1`, `lib.ps1`), written for the Windows PowerShell 5.1 that ships with Windows. Each hook is registered twice (bash and PowerShell); exactly one answers on each system and the other steps aside silently.
- The Claude Desktop guide uses the current menu names (*Settings > Extensions > Filesystem > Allowed Directories*, *Settings > Instructions for Claude*) and explains how to keep the map without scripts.

### Fixed
- The map no longer shows a template placeholder as the description of `Templates/`.

### Removed
- The separate projects map (`Projects-Map.md` / `Mapa-de-Projetos.md`): the map in `CLAUDE.md` replaces it.

## [0.2.0] — 2026-09-25

First public release.

### Added
- **Claude Code plugin** with its own marketplace: install with `/plugin marketplace add MenesesLuiz/Context-Keeper` and `/plugin install context-keeper@context-keeper`.
- **Hooks shipped with the plugin**, inactive until a brain exists:
  - `SessionStart` loads the now file and the latest journal entry at session start and right after every compaction;
  - `Stop` asks for a checkpoint when the context has grown by 50,000 tokens since the last one (`CONTEXT_KEEPER_CHECKPOINT_TOKENS`), measured from the transcript's real token usage.
- **Commands** `/context-keeper:checkpoint` and `/context-keeper:review`.
- **Brain pointer** `~/.context-keeper/config`, so hooks and the checker find the brain without editing `settings.json`.
- **Templates in English and Portuguese** (`BRAIN.md`/`NOW.md`/`Journal/` and `CEREBRO.md`/`AGORA.md`/`Diario/`), including an about-me note and a projects map. Hook messages follow the brain's language.
- **Project organization advice:** the skill recommends keeping each complete project in its own folder under `Projects/`, with its context notes, and shows the exact moves. It never moves the user's files itself.
- **Root `CLAUDE.md`** that imports the brain's rules, so Claude Code loads them in any folder inside the brain.
- **Test personas** (`tests/make-personas.sh`): fictional users with simulated home folders, used to test the skill without touching real data.

### Changed
- The skill is now in English, with 4 modes (Setup, Checkpoint, Import, Review) and 6 references. The interview still runs in the user's language.
- Obsidian is optional. A plain folder is the recommended default, and regular Markdown links with relative paths replace `[[wikilinks]]` as the default link style.
- Detection only looks in the user's home folder and in paths the user mentions.
- An Obsidian vault is treated as material to import into a lean brain; adopting it in place is only offered for small, well-organized vaults.
- The interview goes straight to at most 4 questions per round; the automation level is chosen inside the plan.

### Fixed
- `brain-lint.sh` no longer writes temporary files outside the brain. Before, a missing temp folder made the broken-link check skip silently.
- `brain-lint.sh` ignores project code kept inside the brain (nested git repositories, `node_modules`, build folders) and checks secrets only in Markdown notes.

## [0.1.0] — 2026-09-25

Initial draft of the skill, in Portuguese, as a standalone skill folder.
