# digital-asic-backend

Claude Code plugin that automates the **digital ASIC backend flow** on the Synopsys toolchain: Fusion Compiler (place-and-route), StarRC (parasitic extraction), PrimeTime (DMSA timing signoff), and VCS (post-layout simulation). Project scaffolding, ECO convergence, and report parsing are all driven by skills invoked as slash commands.

- **Version**: 1.2.0
- **Category**: Coding (Interactive, Write capabilities)
- **Toolchain**: Synopsys Fusion Compiler, StarRC, PrimeTime, VCS
- **Target**: digital ASIC place-and-route, parasitic extraction, timing signoff, ECO closure, post-layout simulation

## Plugin layout

```
digital-asic-backend/
├── .claude-plugin/plugin.json     # Claude Code plugin manifest
├── .codex-plugin/plugin.json      # Codex plugin manifest (with UI metadata)
├── releases/
│   └── v1.1.0.md                  # release notes, one file per version
└── skills/                        # one slash command per subdirectory
    ├── check-reports/
    ├── discover-pdk/
    ├── eco-loop/
    ├── modify-floorplan/
    ├── new-project/
    │   ├── SKILL.md
    │   └── template/              # full project scaffold copied by /new-project
    │       ├── fc/
    │       │   ├── Makefile
    │       │   └── scripts/
    │       │       ├── setup.tcl              # global config (DESIGN_NAME, PROJECT_PATH, PDK paths)
    │       │       ├── constraints/           # timing.tcl, io.tcl, physical.tcl, antenna_rules.tcl
    │       │       ├── flows/                 # run_*.tcl — entry point per stage / full flow / ECO
    │       │       └── stages/                # init, floorplan, synthesis, placement, clocktree,
    │       │                                  # routing, dfm, output, eco — one per PnR stage
    │       ├── hdl/filelist.f
    │       ├── pt/{Makefile, scripts/{setup.tcl, dmsa.tcl, dmsa_con.tcl, dmsa_analysis.tcl}}
    │       ├── starrc/{Makefile, scripts/extract_*.cmd}    # 4 corners
    │       └── vcs/post/Makefile
    ├── run-eco/
    ├── run-fc/
    ├── run-fc-step/
    ├── run-pt/
    ├── run-starrc/
    └── run-vcs/
```

The two manifests in `.claude-plugin/` and `.codex-plugin/` carry the same name/version/description; the Codex variant additionally declares UI metadata (`displayName`, `brandColor`, `defaultPrompt`, etc.).

## Skills

Each skill lives in `skills/<name>/SKILL.md` and is invoked as `/<name>` in a Claude Code session. All skills locate the project by walking up from `cwd` to find `fc/scripts/setup.tcl`, then read `DESIGN_NAME` and `PROJECT_PATH` from it.

### Project setup

| Skill | Args | Purpose |
|---|---|---|
| `/discover-pdk` | `<pdk-path>` | One-time scan of a PDK directory. Identifies stdcell NDM (directories, not files), tech file, TLU+ corners, timing DBs, nxtgrd, and antenna rules; confirms with the user; writes `$PDK_PATH/pdk.md` (a markdown table with paths relative to the PDK root). Runs once per PDK; subsequent `/new-project` runs read it instead of re-scanning. |
| `/new-project` | `<pdk-path> <project-path> <design-name>` | Reads `pdk.md` and copies `skills/new-project/template/` to `<project-path>`, substituting `__PLACEHOLDER__` tokens (DESIGN_NAME, all PDK paths). Also copies the real antenna rules file from the PDK over the placeholder. Refuses to overwrite an existing project without confirmation. |
| `/modify-floorplan` | `<natural language description>` | Generates updated `floorplan.tcl` / `io_floorplan.tcl` from a description (e.g. "core 200x100, DAC pins on top edge"). Cross-checks pin names against RTL ports, validates pitch and overlap, writes `*_new.tcl` and shows a diff before replacing originals (with timestamped backups). |

### Fusion Compiler (PnR)

| Skill | Args | Purpose |
|---|---|---|
| `/run-fc` | — | Backs up the existing `.dlib`, then runs `fc/scripts/flows/run_full.tcl` (init → floorplan → synthesis → placement → clocktree → routing → dfm → output) under `nohup` for long jobs. Calls `/check-reports all` on completion. |
| `/run-fc-step` | `<step>` (`init` \| `floorplan` \| `synthesis` \| `placement` \| `clocktree` \| `routing` \| `dfm` \| `output`) | Runs a single stage via `flows/run_<step>.tcl`, after verifying the prerequisite checkpoint exists and backing up the `.dlib`. Each stage writes a checkpoint named `${DESIGN_NAME}_<step>` that the next stage opens from. |

### Signoff

| Skill | Args | Purpose |
|---|---|---|
| `/run-starrc` | — | Runs `StarXtract` for all 4 corners (`cmax_25c`, `cmax_125c`, `cmin_25c`, `cmin_125c`) against the FC DFM checkpoint. Verifies all 4 SPEF files exist and have non-zero size, and greps stardir summaries for errors. |
| `/run-pt` | — | Launches `pt_shell -multi_scenario` (DMSA over 4 scenarios: `func_tt_cmax`, `func_tt_cmin`, `func_ss_cmax`, `func_ss_cmin`). Generates `*_allvios.rpt` and `*_fix_all_vios.report`. Determines convergence by checking whether `fc/scripts/eco_changes.tcl` is empty. |
| `/run-eco` | — | Applies PT-generated ECO via `flows/run_eco.tcl` only — never re-runs the full FC flow. Backs up `.dlib` and FC outputs first. Re-runs DFM + output reports. |
| `/eco-loop` | — | Drives the StarRC → PT → FC ECO loop for **at most 5 iterations**. Stops early when `eco_changes.tcl` is empty (converged); otherwise reports remaining violations after iteration 5 and asks the user to intervene. Maintains a per-iteration metric table. |

### Verification & reporting

| Skill | Args | Purpose |
|---|---|---|
| `/check-reports` | `<stage>` (`fc-synthesis` \| `fc-placement` \| `fc-clocktree` \| `fc-routing` \| `fc-dfm` \| `fc-output` \| `starrc` \| `pt` \| `eco` \| `all`) | Parses the report files for a stage and prints a uniform metric table (slack, TNS, violating paths, DRC/LVS, area, utilization, power). Read-only — never modifies report files. |
| `/run-vcs` | — | Runs `make com` in `vcs/post/` to compile and simulate the post-layout netlist. Reports compile errors/warnings, setup/hold violations, and waveform output. |

## Typical workflows

**First-time project bringup**
```
/discover-pdk /path/to/PDK         # writes PDK/pdk.md (one-time per PDK)
/new-project /path/to/PDK /path/to/proj design_top
# fill in hdl/, constraints/timing.tcl, floorplan, etc.
/run-fc                            # full PnR
/run-starrc
/run-pt
/eco-loop                          # iterate to closure
/run-vcs                           # post-layout sim
```

**Iterating a single PnR stage**
```
/run-fc-step floorplan
/check-reports fc-routing
/modify-floorplan "increase die by 20%"
/run-fc-step floorplan
```

## Conventions enforced by every skill

- **Project root discovery**: walk up from `cwd` to find `fc/scripts/setup.tcl`; read `DESIGN_NAME` and `PROJECT_PATH` from it. Skills never hard-code paths.
- **Backups before mutation**: every skill that touches `.dlib`, SPEF, FC outputs, or floorplan TCL creates a timestamped backup first.
- **Reports are read-only**: never delete or overwrite report files; missing reports are flagged, not papered over.
- **Never modify RTL** to make backend pass — the floorplan/constraints adapt to the RTL, not the other way around.
- **ECO never re-runs the full flow**: `/run-eco` and `/eco-loop` only invoke `flows/run_eco.tcl`.
- **Hard 5-iteration cap on `/eco-loop`**: escalates to the user past that.

## Project layout produced by `/new-project`

```
<project>/
├── hdl/                # RTL + filelist.f (user fills in)
├── fc/
│   ├── scripts/        # copied from template, placeholders substituted
│   ├── report/         # all FC reports land here
│   ├── output/         # ${DESIGN}_pt.v, .sdc, .gds, .def, ${DESIGN}_lvs.v
│   ├── temp/           # fc_shell working dir
│   └── ${DESIGN}.dlib  # FC design library (created by `init`)
├── starrc/
│   ├── scripts/        # extract_cmax/cmin_25c/125c.cmd
│   ├── spef/           # 4 SPEF outputs
│   └── temp/           # StarRC working dir
├── pt/
│   ├── scripts/        # dmsa.tcl + setup.tcl
│   ├── report/         # *_allvios.rpt, *_fix_all_vios.report
│   ├── result/         # ECO scripts written for FC consumption
│   └── work/           # PT scratch
└── vcs/post/           # post-layout simulation
```

## Versioning & releases

- One markdown file per release under `releases/` (e.g. `releases/v1.1.0.md`) holds that version's notes, including any migration commands.
- Update **all three** version strings in lockstep when releasing: `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, and the entry in the parent marketplace's `.claude-plugin/marketplace.json`.
