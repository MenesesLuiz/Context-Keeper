# Importing existing material

Importing **is not copying**. The goal is a brain that is more useful to the AI, not a bigger one. A whole vault copied over becomes noise: the AI spends tokens reading what does not matter and misses what does.

## Flow

1. **Inventory (change nothing).** List the source: number of files, folders, modification dates, sizes. For Obsidian vaults, ignore `.obsidian/`, `.trash/` and binary attachments.
2. **Triage.** Classify each folder (or each note, if there are few) as:
   - **Bring and reorganize:** living notes relevant to active subjects. They enter the new structure with frontmatter, accent-free file names and fixed links.
   - **Summarize:** lots of material on one topic (e.g. 40 lecture notes) becomes one summary note with the key points and a link to the original folder.
   - **Only link:** large reference material rarely used. It enters as a link in the subject's index note, pointing to the original path.
   - **Leave out:** empty notes, abandoned drafts, duplicates, material unrelated to the declared uses.

   Use the modification date as a hint: what has not been touched in over a year is usually "only link" or "leave out".
3. **Proposal.** Show the triage as a table (folder → destination → action) and wait for approval.
4. **Execution.** Never move or delete the original source — copy into the brain. When rewriting a note, add `source: <original path>` to its frontmatter.
5. **Log.** A journal entry listing what was imported and from where.

## Common sources

- **Obsidian:** if the brain uses regular Markdown links (the default), convert each `[[Note]]` and `[[Note|text]]` into `[text](relative/path/Note.md)`, pointing to where the note landed in the new structure. If the brain uses wikilinks, they can stay. Either way, links to notes that are not coming along become plain text or point to the original path. Attachments (`![[image.png]]`) come only if needed, into an `Attachments/` folder.
- **Notion:** the Markdown export produces names with long IDs (`Page 3f2a...md`); clean them up.
- **Code repositories:** do not copy code. Read the README and the recent history and create the project's index note with overview, stack and "Current state"; link to the repository path.
- **Exported AI conversations:** extract only decisions, preferences and stable facts, using the filter in `feeding-protocol.md`. Conversations are long and almost all of their content is path, not conclusion.
- **Documents (PDF, DOCX):** create a summary note with the points that matter to the user and the path to the original file.
