# Module: ai-feature
Trigger: the product calls a language model at run time, or model output is scored by a judge.
Adds: `.claude/rules/ai.md`.
## Append
- CLAUDE.md | Model calls and evals follow .claude/rules/ai.md.
- project/decisions.md | Measuring instrument v1, dated at install: judge model version, rubric version and headline formula. A change to any of them adds a new entry.
- project/brief.md | Outputs a model never produces here: list them (rule 4 of .claude/rules/ai.md).
## Manual
- Set `paths` in `ai.md` to where model calls, prompts and the eval set live.
Skip when: the model only helps build the project.
