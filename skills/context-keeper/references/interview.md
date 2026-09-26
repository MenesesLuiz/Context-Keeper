# Interview and plan

Goal: collect the minimum needed to propose a good plan. Each question says **why it exists**; if the answer is already known (from detection or from something the user said), skip it.

How to run it:
- At most 3–4 questions per round.
- Offer clickable options with one marked as recommended, plus a free-text answer.
- Explain technical terms in one sentence for non-technical users ("hook", "frontmatter", "JSON").
- Speak the user's language; the brain will be built in it.
- At the end, summarize the answers as a list and ask for confirmation before writing the plan.

---

## Quick path (5 questions)

The default. Start with these questions directly — do not spend a round asking "quick or full?". Skip any question the user's first message already answered, and mention in one line that a fuller interview is available if they want to fine-tune. Everything not asked takes the defaults at the end of this file.

1. **What do you use AI for the most?** (multiple choice: programming, studies, office work, content creation, research, personal life and organization)
2. **Which projects or subjects are active right now?** (free text: "list 1 to 5, one line each")
3. **Which AIs do you use?** (confirm what detection found: Claude Code, Claude Desktop/claude.ai, Cursor, Codex, Gemini CLI, ChatGPT, other)
4. **Where should the brain live, and how do you want to view it?** Suggest a concrete path and offer:
   - **A plain folder on your computer (recommended).** Explain that the AI reads and writes the files straight from disk and does not open Obsidian the way a person does. For the AI, Obsidian changes nothing.
   - **Obsidian.** Only for *you* to browse the notes, see the graph and search. It can be added later by opening the same folder as a vault.

   Warn if the path is inside OneDrive/Dropbox: syncing is good for backup, but two machines editing at once can conflict.
5. **How much can the AI do on its own?** Level 1 Manual, 2 Connected or 3 Automatic (see `architectures.md`). Recommend 3 for Claude Code users and 2 for everyone else.

---

## Full path

Use it only when the user asks for it, or when their answers show needs the defaults do not cover (sensitive data, several machines, many ongoing areas).

### A — About you
*Why:* becomes the profile note. It is the context every AI should have and never does.
- What should the AI call you?
- What do you do (job, course, field)?
- Technical level: non-technical / use tools / write code.
- Language of the brain and of the answers.

### B — What the brain is for
*Why:* defines the top-level areas and the structure.
- Main uses (as in the quick path).
- Active projects and subjects, with one line of status each.
- Ongoing areas with no end date (health, finances, career, a university subject)? *These point to the PARA structure.*
- How often do new subjects start? *Many new subjects make the Inbox and triage more important.*

### C — Tools
*Why:* defines the integrations.
- Which AIs, and which one is the main one?
- Notes in Obsidian, Notion, Google Docs, OneNote? Import anything? *Triggers Mode 3.*
- Plain folder or Obsidian? *Recommend the plain folder and explain why (`architectures.md` → "Plain folder or Obsidian"). If Obsidian, ask whether they prefer `[[wikilinks]]` or regular Markdown links; recommend regular links.*
- More than one computer? *Affects syncing and the absolute paths in the pointer.*

### D — Location, privacy and backup
*Why:* avoids data loss and leaks.
- Where to save the folder?
- Sensitive information (health, finances, client data)? *If yes: stress the no-secrets rule, recommend not syncing to a public cloud and, with git, a private repository only.*
- Version with git (full history, undo)? *Recommend it for technical users.*

### E — AI autonomy
*Why:* becomes the feeding rules in the root file.
- Automation level (1/2/3).
- When the AI wants to record something, it should:
  - **ask first**;
  - **write and tell** in one line (recommended);
  - **write silently** and list everything only at the checkpoint.
- May the AI create new folders on its own, or propose them first? (recommended: propose)

### F — How you like to work with AI
*Why:* becomes the conduct rules and the preferences note — things the user is tired of repeating.
- Plan and ask for approval before acting, or act directly?
- Short or detailed answers?
- Anything the AI does that annoys you? Anything it should always do?

### G — Existing material
*Why:* a brain that starts with useful content is one the user keeps using.
- Notes, documents or repositories that should feed the brain from day one? Where?
- Important old AI conversations (ChatGPT/Claude exports)? *Can be triaged in Mode 3.*

---

## Defaults for the quick path

| Item | Default |
|---|---|
| Language | The conversation's |
| Structure | *By subject* up to ~3 areas; *PARA* when there are ongoing areas plus projects |
| Viewing | Plain folder |
| Links | Regular Markdown links with relative paths |
| Write autonomy | Write and tell |
| New folders | Propose first |
| Conduct | Plan and ask for approval on big tasks; do small ones directly |
| Git | Yes for technical users, no for the others |
| Location | `~/SecondBrain` (pt-BR: `~/SegundoCerebro`; Windows: under `%USERPROFILE%`) |

---

## Plan format

Present the plan in the conversation with this format, translated to the user's language. Be concrete: real paths, real folder and project names. The user must be able to approve knowing exactly what will happen.

```markdown
# Your Second Brain plan

## 1. What I understood
- **You:** <name, what you do, technical level>
- **Used for:** <uses>
- **Active subjects:** <list>
- **AIs:** <tools> (main: <X>)
- **Material to import:** <sources or "none">

## 2. Choose the structure
**Option A — By subject** (recommended: <reason in one line>)
<tree with the real names>

**Option B — PARA**
<tree with the real names>

**Viewing:** plain folder (recommended) or Obsidian — <choice and, if Obsidian, the link style>

## 3. Choose the automation level
| Level | What it does | What it touches on your computer |
|---|---|---|
| 1 Manual | ... | only the brain folder |
| 2 Connected | ... | <exact files> |
| 3 Automatic (recommended) | ... | <exact files> |

## 4. What will be created in `<path>`
- <root file>, <now file>, Profile/..., <subjects>/Index.md, ...

## 5. What will change outside the brain
- `~/.context-keeper/config` — pointer to the brain (new file)
- `<file>` — <what changes> (backup at `<file>.bak-YYYY-MM-DD`)

## 6. Starting content
- <subjects that get an index note with Current state>
- <imports and how they will be triaged>

## 7. What you will need to do
- <manual steps, e.g. paste a rule into Cursor> (or "Nothing")

## 8. How to undo
- Delete `<path>` and `~/.context-keeper/`, and restore the backups listed in item 5.

**Reply with your choices (e.g. "A + level 3") or ask for changes.**
```

After approval, save the final version to `<brain>/.context-keeper/setup-plan.md`.
