# ai-instructions

One set of rules for every AI coding assistant I use, on every machine.

- [`AGENTS.md`](AGENTS.md): the rules. Simple English, Caveman response style, BEEP BOOP prefix, almost no code comments, PRs as drafts.
- [`claude/output-styles/caveman.md`](claude/output-styles/caveman.md): the same response style as a Claude Code output style.
- [`claude/CLAUDE.md`](claude/CLAUDE.md): what the user-level Claude file contains: one import line.
- [`install.ps1`](install.ps1): links the files into place and sets the Copilot environment variable. Run once per machine.

## Who reads what

| Tool | What it reads | How this repo gets there |
| ---- | ------------- | ------------------------ |
| Claude Code | `~/.claude/CLAUDE.md`, `~/.claude/output-styles/*.md`, `outputStyle` in `~/.claude/settings.json` | `CLAUDE.md` imports `@~/ai-instructions/AGENTS.md`; `caveman.md` is linked; `outputStyle` is set to `Caveman` |
| Codex CLI and app | `~/.codex/AGENTS.md` only, no imports | linked to `AGENTS.md` |
| Copilot CLI | `~/.copilot/copilot-instructions.md`, and `AGENTS.md` in every folder listed in `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | both |
| Copilot app | built on the CLI; also has "App instructions" in Settings | should follow the CLI; if not, paste `AGENTS.md` there |
| VS Code Copilot | `~/.claude/CLAUDE.md` (setting `chat.useClaudeMdFile`, on by default) | free |
| Codex cloud, Copilot coding agent | repo files only | put an `AGENTS.md` in the repo; for Claude add `CLAUDE.md` with `@AGENTS.md` |

Codex and Copilot have no output-style feature. They get the Caveman rules from the "Response style" section of `AGENTS.md`.

## Install on a new machine

```powershell
git clone https://github.com/bugale/ai-instructions.git $HOME\ai-instructions
powershell -ExecutionPolicy Bypass -File $HOME\ai-instructions\install.ps1
```

The script makes symbolic links when it can (Windows Developer Mode or admin). Otherwise it copies, and the `post-merge` hook re-runs it after
every `git pull`. Existing files are kept as `*.bak` the first time.

## Change a rule

Edit `AGENTS.md` (and `claude/output-styles/caveman.md` if the response style changes), commit, push. On other machines: `git pull`. Start a new
session in each tool; they read the files at start.

## Check that a tool sees it

- Claude Code: `/context` shows the memory files.
- Codex: `codex exec "Summarize the current instructions."`
- Copilot CLI: `/instructions` inside a session.
