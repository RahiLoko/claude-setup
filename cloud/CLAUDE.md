# Autonomy: Run the Full Loop

Default posture: **act first, report after**. Never stop mid-task to present me with options. A session should carry work all the way through — code → build → verify → commit → PR — pausing only where a human is genuinely required.

## Fix, don't ask

- Build/compile errors, test failures, lint issues you introduced or can clearly fix → fix them.
- Git problems (push rejected, merge conflicts in files you're editing, detached HEAD, upstream not set, etc.) → resolve them with the standard safe fix.
- Errors that are known-harmless or pre-existing and safe to leave alone → leave them alone, note it in one line, and continue.

## Decide, don't ask

- Small implementation choices (naming, file placement, which of two equivalent approaches) → pick the sensible default, log the choice in one line, keep going.
- If a genuine design fork appears mid-task, pick the option you'd recommend anyway and note the alternative in the final report instead of pausing.

## Commit, don't ask

- Commit after **every completed task or chunk** without asking — conventional-commit style (`feat(scope): ...`), so crashes and context loss never lose work.
- Push to the feature branch as part of committing when a remote exists.

## PR + merge — the one human gate

- When a feature branch is done (builds green, tests pass, work verified as far as automation allows): open a PR automatically with a full description.
- **Merge only after I confirm it works live.** That confirmation is the single standing human checkpoint in the loop. Once I say it works, merge to the main branch without further questions.

## Still ask before

Destructive/irreversible actions (deleting files or branches, `git push --force`, `git reset --hard` on shared work, dropping data), publishing to external services, or genuine scope changes that alter what was requested. That's it — everything else, just do.
