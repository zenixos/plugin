---
name: skill
description: Skill manager for zenix
---

# skill

Skill manager for zenix.

## Usage

```bash
zenix                    # List available skills
zenix list               # Same as above
zenix <skill> [args]     # Run a skill
zenix create <name>      # Create new skill
zenix doctor [name]      # Validate skill conventions
```

## Setup

Add to PATH (one-time):

```bash
export PATH="$HOME/.zenix/bin:$PATH"
```

## Examples

```bash
zenix                    # See all available skills
zenix work on "task"     # Start working on a task
zenix browser open       # Open browser
zenix create my-tool     # Create new skill
zenix doctor             # Check all skills
zenix doctor vault       # Check specific skill
```

---

# Creating Skills

## Structure

Skills live in `~/.zenix/<tier>/<name>/` (repo is symlinked to `~/.zenix`).

```
<tier>/<name>/
├── SKILL.md              # Context for AI (required)
├── run                   # Thin dispatcher (routes to scripts/)
├── scripts/              # One script per command
├── lib/                  # Shared utilities (sourced or piped)
├── config/               # YAML configuration files
├── watchers/*.yaml       # Triggers (auto-discovered by watcher)
├── hooks/*.sh            # Claude Code lifecycle hooks
├── prompts/              # AI system prompts for sub-sessions
├── templates/            # Document templates
└── data -> ~/.zenix/data/<name>/   # Symlink to persistent storage
```

**Tiers:**

| Tier | Location | Tracking |
|------|----------|----------|
| `system` | Monorepo | Core infrastructure, always present |
| `native` | Monorepo | Essential skills, always present |
| `plugin` | Submodules | Distributable skills, `zenix-<name>` repos |

## Layers

| File | Purpose | Discovery |
|------|---------|-----------|
| SKILL.md | AI context when `/skill` invoked | By name |
| run | CLI entry point (thin dispatcher) | Via `zenix <skill>` |
| env | Shell environment (aliases, exports) | Auto at shell startup |
| scripts/*.sh | One script per command | Called by run |
| lib/*.sh | Shared utilities | Sourced or piped |
| watchers/*.yaml | Event triggers | Auto by watcher |
| hooks/*.sh | Claude Code lifecycle | Via `.claude/settings.json` |

## Auto-Enrollment

Skills are **auto-enrolled by default**. Use `# @ignore` in the first 3 lines to opt out.

| File | Default | With `# @ignore` |
|------|---------|------------------|
| `run` | Symlink created in `bin/` | No symlink |
| `env` | Sourced at shell startup | Not sourced |

```bash
#!/bin/bash
# @ignore
# This skill won't get a bin symlink
```

**Management:**
- `zenix setup bins` — sync all bin symlinks
- `zenix doctor` — check for mismatches
- `zenix doctor --fix` — auto-repair

## Hooks (hooks/settings.yaml)

Hooks require explicit `scope` field:

```yaml
- event: SessionStart
  scope: claude-code
  script: my-hook.sh
  description: What this hook does
```

| Scope | Handler | Output |
|-------|---------|--------|
| `claude-code` | `hook build` | `.claude/settings.json` |
| `zenix` | zenix dispatcher | Runtime only (SkillStart/SkillEnd) |

**Build:** `zenix hook build` generates settings.json from all `scope: claude-code` hooks.

## One Script Per Command

The `run` file should be a **thin dispatcher** (~50 lines) that routes to scripts:

```bash
# run
case "${1:-}" in
    list)   exec "$SKILL_DIR/scripts/list.sh" "${@:2}" ;;
    create) exec "$SKILL_DIR/scripts/create.sh" "${@:2}" ;;
    *)      route_skill "$@" ;;  # core routing stays in run
esac
```

**Organization:**

| Location | Contains | Example |
|----------|----------|---------|
| `run` | Dispatcher + core routing | `route_skill()`, case statement |
| `scripts/` | One script per command | `list.sh`, `create.sh`, `doctor.sh` |
| `lib/` | Shared utilities | `output.sh` (sourced), `list-format.sh` (piped) |

**Benefits:**
- Each command is independently testable
- Clear responsibility boundaries
- `run` stays readable (<100 lines)

## Data Convention

```bash
mkdir -p ~/.zenix/data/<name>
ln -s ~/.zenix/data/<name> <tier>/<name>/data
```

Scripts use relative `./data` — portable, no hardcoded paths.

| Location | Contains | In Git |
|----------|----------|--------|
| `<tier>/<name>/` | Code, config, prompts | Yes |
| `~/.zenix/data/<name>/` | Runtime data, state | No |
| `<tier>/<name>/data` | Symlink | Yes (link only) |

## SKILL.md Format

```markdown
---
name: skill-name
description: One-line for skill list
---

# Skill Name

What this skill does.

## Usage
## Commands
## Configuration
```

## Config (config/*.yaml)

Skill-specific configuration. Format varies by skill, but typically:

```yaml
# config/settings.yaml
enabled: true
options:
  key: value
```

Scripts read config via: `yq '.options.key' "$SKILL_DIR/config/settings.yaml"`

## Watchers (watchers/*.yaml)

```yaml
name: unique-watcher-name
description: Brief description for zenix watcher list
type: fswatch | cron

# fswatch
path: relative/path/
events: [Created, Updated]
exclude: [\.DS_Store]
debounce: 15
rules:
  - match: ^pattern\.md$
    action: scripts/handler.sh

# cron
schedule: "*/30 * * * *"
action: scripts/periodic.sh
```

## List Format (lib/list-format.sh)

Unified list formatter for consistent output across skills.

**Input:** TSV via stdin (group, name, tag, description)

```bash
# Usage
source "$ZENIX_ROOT/system/zenix/lib/list-format.sh"
printf '%s\t%s\t%s\t%s\n' "skill" "name" "tag" "description" | list_format --group
```

**Styles:**
- `--group` (default): Group by first column with `[group]` headers
- `--inline`: Flat list with `[group]` inline after name

**Output format:**
```
[group]
name (tag): description
```

## Inter-Skill Communication

1. **Watcher** — skill defines `watchers/*.yaml`, `watcher` runs it
2. **Sub-sessions** — skill calls `claude -p` with `prompts/*.md`
3. **Shared data** — skills read/write to known paths
4. **Scripts** — one skill calls another's `scripts/`

## Plugin Skills (Submodules)

Plugin skills are separate repos, tracked as git submodules.

**Naming:** `zenix-<skill>` (e.g., `zenix-wechat`, `zenix-feishu`)

### Adding a Plugin Skill

```bash
git submodule add https://github.com/user/zenix-<skill>.git plugin/<skill>
```

### Working on a Plugin Skill

```bash
cd plugin/<skill>               # Submodule has its own jj
jj new                          # Create work commit
# ... make changes ...
jj commit -m "description"
jj git push                     # Push to zenix-<skill> repo
```

### Updating Submodule Pointer (in parent)

```bash
cd "$(work on 'bump skill')"    # Workspace in parent repo
cd plugin/<skill>
git pull origin master
cd ..                           # Back to workspace root
work done "bump <skill>"        # Commits new pointer
```

## Skill Examples

| Skill | Demonstrates |
|-------|--------------|
| vault | watch + prompts + scripts + templates |
| watcher | auto-discovery + central runner |
| memory | data symlink + run.sh |
| daily | hooks (precompact, session-end) |
| wechat | community submodule |
