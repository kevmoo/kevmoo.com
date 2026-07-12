---
name: triage-projects
description: Inspect new activity, commits, and pub releases across Kevin's personal projects since the last review session using tool/triage_projects.dart.
---

# Triage Projects Skill

Use this skill whenever the user asks to check on recent project updates, triage packages, or sync project metadata on `kevmoo.com`.

## Workflow
1. Run `dart run tool/triage_projects.dart` (or `dart run tool/triage_projects.dart --dump`) to generate a summary of commits and releases across `_projects/*.md` since the last review timestamp (`last_reviewed_at`).
2. Present the summary cleanly to the user in the chat or as an artifact.
3. Ask the user which updates they want to highlight, whether they want to write a blog post for any major releases, and whether they want to accept and record the new state.
4. If approved, run `dart run tool/triage_projects.dart --accept` to update `version`, `stars`, `last_reviewed_sha`, and `last_reviewed_at` right in the frontmatter of `_projects/*.md`.
5. If the user asks to clean or normalize frontmatter defaults, run `dart run tool/clean_projects.dart`.
