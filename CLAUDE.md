# asic-design-plugins — Claude Code Plugin Marketplace

This repository is a Claude Code plugin marketplace. Its purpose is to package and distribute Claude Code plugins focused on **ASIC design automation**. End users add this repo as a marketplace in their Claude Code installation and then install plugins from it.

- **Marketplace name**: `asic-design-plugins`
- **Owner**: szj (`yhszj2013@hotmail.com`)
- **Manifest**: `.claude-plugin/marketplace.json`

## Repository layout

```
.
├── .claude-plugin/
│   └── marketplace.json        # marketplace manifest — lists every plugin in the repo
└── plugins/
    └── digital-asic-backend/   # one plugin per subdirectory
```

Each plugin under `plugins/` is a self-contained Claude Code plugin with its own `.claude-plugin/plugin.json` manifest and (optionally) a `.codex-plugin/plugin.json` manifest for Codex compatibility. See the per-plugin `CLAUDE.md` for details.

## marketplace.json

`.claude-plugin/marketplace.json` is the manifest that Claude Code reads when this repo is added as a marketplace. Each entry under `plugins[]` maps a plugin name to its source path inside this repo and declares its version, description, author, and search keywords.

When adding a new plugin to this marketplace:
1. Create a new subdirectory under `plugins/<plugin-name>/`.
2. Add the plugin's own `.claude-plugin/plugin.json` (and `.codex-plugin/plugin.json` if shipping to Codex).
3. Append a new entry to the `plugins[]` array in `.claude-plugin/marketplace.json` with `source: "./plugins/<plugin-name>"`.
4. Keep the version in `marketplace.json` in sync with the version in the plugin's own `plugin.json`.

## Plugins

| Plugin | Version | Summary |
|---|---|---|
| [`digital-asic-backend`](plugins/digital-asic-backend/CLAUDE.md) | 1.2.0 | Synopsys-based digital ASIC backend flow: Fusion Compiler PnR, StarRC extraction, PrimeTime DMSA signoff, ECO convergence, and post-layout VCS simulation. |

## Installing a plugin from this marketplace

From a Claude Code session:

```
/plugin marketplace add /ic_data/szj/claude          # or the git URL of this repo
/plugin install digital-asic-backend@asic-design-plugins
```

Once installed, the plugin's skills become available as slash commands (e.g. `/run-fc`, `/check-reports`).
