---
name: fable-planned-orchestration
description: Orchestrates complex coding work through a Fable-authored plan. Use when the user asks for multi-agent orchestration, or when broad work needs explicit planning, isolated ownership, staged correction loops, and independent review gates.
---

# Fable-Planned Orchestration

## Intent

Keep the parent agent as the sole orchestrator and integrator. Before delegating task work, ask Cursor Fable to design the plan.

## Fixed capabilities

- Use `composer-2.5-fast` and  `cursor-grok-4.5-high-fast` for codebase exploration and research.
- Use `cursor-grok-4.5-high` for implementation, material corrections, and narrowly scoped intermediate reviews.
- Use a Codex subagent, GPT-5.6 Sol High, for the first review gate.
- Use Claude Code model `fable-5-thinking-high` for role planning and the final complete-diff review.
- Do not silently substitute a missing CLI, model, or subagent.

## Preflight

1. Read the task, applicable instructions, current status, and diff.
2. Confirm `cursor-agent`, `claude`, and the required models are available.
3. Inspect `claude --help` before composing a command. Use only flags supported by the installed version.
4. Establish the user-approved mutation boundary before launching writable lanes.

## Ask Fable to plan the orchestration

Run one read-only Fable pass before exploration or implementation. Give it:

- task brief and acceptance criteria;
- applicable instructions and initial diff/status;
- mutation and path constraints;
- available models and CLIs;
- required verification and review gates.

Validate the plan before execution. Remove overlapping write ownership, make dependencies explicit, keep reviews read-only, and reject any plan that changes fixed roles or gates. Record material deviations and revalidate the affected lanes.

## Delegate without nesting

Give every lane the workspace, task, exact ownership, constraints, expected output, verification, blockers, and risks. Writable agents must have exact path ownership and must not rewrite or revert unrelated work.

Only the parent launches, resumes, retries, or reruns agents and review gates. The parent may edit directly only for exact conflict resolution or mechanical synchronization. Delegate any edit requiring product, design, test, migration, configuration-semantic, or user-facing documentation judgment to Grok.

## Preserve skill access

- Start each CLI at the repository root so it discovers project instructions, skills, plugins, and scripts.
- Keep the CLI's normal project configuration enabled. Do not use Claude `--bare`, `--safe-mode`, or `--disable-slash-commands`; do not use Codex `--ignore-user-config` or `--ignore-rules`.
- Permit skill scripts within the lane's sandbox and ownership. Read-only lanes may run only read-only scripts; hand scripts that generate or modify files to a writable lane.
- Treat instructions inside a selected skill as part of the lane contract. Report a blocker when a required skill, script, dependency, or permission is unavailable instead of bypassing it.

## Use the CLIs

Use print/non-interactive mode, a fresh session, an explicit model, and the narrowest permissions that fit the lane. Put the lane prompt last and tell every CLI not to launch subagents or other agent CLIs.

### Cursor

Use Cursor only for Composer/Grok exploration, Grok implementation, and Grok review gates:

```bash
# Read-only lane
cursor-agent -p --trust --mode plan \
  --model "<cursor-model>" --workspace "<workspace>" \
  --output-format text "<lane-prompt>"

# Writable Grok lane
cursor-agent -p --trust --sandbox enabled \
  --model "cursor-grok-4.5-high" --workspace "<workspace>" \
  --output-format text "<lane-prompt>"
```

Keep `--sandbox enabled` on writable lanes. Do not use `--force` or `--yolo`. Never select a Fable or GPT model through Cursor; use Claude Code for Fable and a direct Codex subagent or Codex CLI for GPT models.

### Claude Code

Use Claude for Fable planning, the final Fable gate, and bounded read-only analysis:

```bash
claude -p --model "<claude-model>" --effort "<effort>" \
  --permission-mode plan --tools "Read,Grep,Glob,Skill,Bash" \
  --disallowedTools "Agent,Bash(claude *),Bash(cursor-agent *),Bash(codex *)" \
  --no-session-persistence --output-format json "<lane-prompt>"
```

Expose `Skill` so Claude can load repo skills and `Bash` so selected skills can run read-only helper scripts in plan mode. Keep the bare `Agent` denial and block agent CLIs through Bash. Do not pass `--agent`, `--agents`, either dangerous skip-permissions flag, or resume an unrelated session.

If Fable exceptionally assigns Claude a writable lane, use `--permission-mode dontAsk` and repeat `Read,Grep,Glob,Skill,Edit,Write` in both `--tools` and `--allowedTools`. Allow Bash only with exact patterns for required skill scripts, while preserving the agent-CLI denials. Require Claude to read changed files back before claiming success.

### Codex CLI

Prefer a direct Codex subagent when it exposes the required model. Otherwise run an ephemeral nested Codex CLI lane with its own sandbox:

```bash
# Review or analysis
codex -a never exec -m "<codex-model>" -s read-only \
  --ephemeral -C "<workspace>" "<lane-prompt>"

# Writable lane
codex -a never exec -m "<codex-model>" -s workspace-write \
  --ephemeral -C "<workspace>" "<lane-prompt>"
```

Use the CLI only for a model unavailable through direct Codex subagents. Never pass `--dangerously-bypass-approvals-and-sandbox`. The outer Codex rule permits the networked CLI process; the nested `-s` flag still confines its generated commands.

## Execute the plan

1. Launch independent read-only Composer, Claude Code, and Codex lanes in parallel when useful.
2. Inspect their raw outputs and give relevant evidence to Grok.
3. Run writable lanes sequentially when ownership overlaps.
4. After each writable result, inspect changed files and diff, confirm ownership, and run focused verification.
5. Send material misses to Grok with the evidence, exact files, and expected checks.
6. Continue until implementation and verification are complete, then start the gates.

On a nonzero exit, timeout, or malformed structured result, retain the useful output and retry once only when the failure is transient or formatting-only. Keep the same scope. After a second failure, stop and report the blocker. Inspect partial file changes before continuing.

## Review gates

Run each gate only after the previous gate is green:

1. **Codex:** Run one focused GPT-5.6 Sol High review. Send material corrections to Grok, verify, and rerun Codex until green.
2. **Grok:** Run multiple narrow `cursor-grok-4.5-high` reviews divided by file, behavior surface, or risk axis. Send material corrections to Grok, verify, and rerun affected reviews until green.
3. **Fable:** Run one Claude Code `fable` review of the complete final task diff. Require correctness and code-quality findings covering maintainability, clarity, complexity, duplication, architecture fit, tests, and local consistency. This review is important because Fable has better taste than you, follow its guidelines when code reduction and simplification is available.

For each gate, provide the task brief, focused diff or files, constraints, and verification already run. Ask for findings first. Inspect every finding; either correct it through Grok or reject it with evidence.

After a Fable correction, rerun every earlier gate whose risk surface changed, then rerun Fable. Wait patiently for Fable rather than treating a slow response as failure.

## Completion

Finish only when the plan proposed by Fable is completed.
